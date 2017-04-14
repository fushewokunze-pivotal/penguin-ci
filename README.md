## Deploy concourse

**Install BOSH CLI v2**

Documentation available here: [https://bosh.io/docs/cli-v2.html](https://bosh.io/docs/cli-v2.html)

**Get bosh bootloader**

```
git clone https://github.com/cloudfoundry/bosh-bootloader.git
```
Full documentation is here: https://github.com/cloudfoundry/bosh-bootloader/blob/master/docs/getting-started-aws.md

**Configure AWS**

The AWS IAM user that is provided to bbl will need the following policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "cloudformation:*",
                "elasticloadbalancing:*",
                "iam:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

**Create infrastructure and BOSH director**

bbl will create infrastructure and deploy a BOSH director with the following command:

```
bbl up \
    --aws-access-key-id <INSERT ACCESS KEY ID> \
    --aws-secret-access-key <INSERT SECRET ACCESS KEY> \
    --aws-region us-west-1 \
    --iaas aws
```

**Create Concourse lbs**

Create self signed certificate for lb.

Then create lbs:

```
bbl create-lbs --type concourse -cert domain.crt --key domain.key
```

**Create AWS Hosted Zone**

Documentation is available here: [http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)

**Login into BOSH director**

The best way to extract credential info is by issuing commands like

```
$ bbl director-username
some-username
$ bbl director-ca-cert
--- BEGIN CERTIFICATE ---
...
--- END CERTIFICATE ---

and so on...
```

To login:

```
$ bosh target 23.248.87.55 <INSERT TARGET NAME>
Username: user-d3783rk
Password: p-23dah71sk1
```

Display cloud config:

```
$ bosh cloud-config
...
```

**Upload stemcell**

```
$ bosh upload stemcell https://s3.amazonaws.com/bosh-core-stemcells/aws/bosh-stemcell-3363.9-aws-xen-hvm-ubuntu-trusty-go_agent.tgz
```

**Deploy Concourse**

```
git clone https://github.com/fushewokunze-pivotal/penguin-ci.git

$ bosh -e <director_ip> deploy concourse.yml --ca-cert directorSSLCA -d concourse
```

Access Concourse from your browser using the LB address or your configured DNS name on Hosted Zones of AWS.

**Install Concourse fly cli**

Download fly from Concourse main page and install on path on your machine 

[https://concourse.ci/fly-cli.html](https://concourse.ci/fly-cli.html)

## Setup Concourse

**Create private git repo**

Create a private git repo to store secrets and set up deploy key as documented here: [https://developer.github.com/guides/managing-deploy-keys/#deploy-keys](https://developer.github.com/guides/managing-deploy-keys/#deploy-keys)

Make sure you use a key with no passphrase as Concourse does not support passphrases.

**Get concourse pipeline**

```
git clone https://github.com/fushewokunze-pivotal/penguin-ci.git
```

**Update pipeline**

Update pipeline file to use your own private repo for storing secrets by replacing all occurances of:

```
uri: git@github.com:fushewokunze-pivotal/penguin-env.git
```

with your your private repo.


**Create a credentials file**

In a separate location on your file system - Create a file with the following credentials. (DO NOT CHECK THIS FILE INTO GIT!!)

Create a Google Storage account and retrieve the credentials required

```
$ vi credentials.yml

p-ert-branch: 1.9
set_to_tag_filter_to_lock_cf_deployment: ignoreme
google_json_key: |
  {
  "type": "service_account",
  "project_id": "project_id",
  "private_key_id": "private_key_id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n ... "
  "client_email": "your_email@developer.gserviceaccount.com",
  "client_id": "client_id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "client_x509_cert_url"
  }
gcs_access_key_id: gcs_access_key_id:
gcs_secret_access_key: gcs_secret_access_key:
env_name: penguin
credhub-encryption-key: credhub-encryption-key:
ssh-username: admin
smtp_host_name: smtp.gmail.com
smtp_host_port: 465
smtp_sender_username: bla@example.com
smtp_sender_password: bla

```

## Seed a new environment

To create a new environment, you must first seed your GCS bucket with some empty files. For an environment named new-environment, the following must be created:

- "new-environment"-bosh-vars-store.yml
- "new-environment"-bosh-state.json
  - This file must be valid JSON, so the contents should be `{}`

_Note_: The filenames include double quotation marks, which are required due to Concourse's parameter interpolation.

## Terraform

Create a file terraform-aws.tfvars.yml

```
env_name: "penguin"
access_key: "access_key"
secret_key: "secret_key:"
public_key: "ssh-rsa public_key"
region: "us-west-1"
availability_zones: ["us-west-1a", "us-west-1c"]
rds_db_username: "admin"
rds_instance_class: "db.m3.large"
rds_instance_count: "1"
parent_hosted_zone_id: ""
dns_suffix: "yourdomain.com"
```

Create these directories:

```
terraform-environment-dbs/
terraform-environments/
```


## Types of deployment

### 1.9-ish

To deploy a ERT reminiscent of PCF 1.9, use the `pipelines/pcf-bosh.yml` pipeline, setting these variables:

- set_to_tag_filter_to_lock_cf_deployment=tag_filter
- p-ert-branch=1.9

_Note_: This includes p-mysql

### Floating

To deploy a ERT using the master of cf-deployment, use the `pipelines/pcf-bosh.yml` pipeline, setting these variables:

- set_to_tag_filter_to_lock_cf_deployment=ignoreme
- p-ert-branch=master

_Note_: This includes p-mysql


### Upgrade

To deploy a pipeline that tests the upgrade process from 1.9 to master, use the `pipelines/upgrade-ert.yml`. No special
 variables are needed.

ref: https://github.com/pivotal-cf/pcf-bosh-ci/edit/master/README.md



**Set Concourse pipeline using fly**

```
$ fly --target cf-deploy set-pipeline --config pipeline.yml --pipeline cf-deploy -l credentials.yml
```
**Run pipeline**

Login into Concourse UI via the browser and run the pipelines

