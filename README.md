## Deploy concourse

**Install BOSH CLI v2**

Documentation available here: [https://bosh.io/docs/cli-v2.html](https://bosh.io/docs/cli-v2.html)

**Get bosh bootloader**

```
git clone [https://github.com/cloudfoundry/bosh-bootloader.git](https://github.com/cloudfoundry/bosh-bootloader.git)
```

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

**Creating infrastructure and BOSH director**

bbl will create infrastructure and deploy a BOSH director with the following command:

```
bbl up \
    --aws-access-key-id <INSERT ACCESS KEY ID> \
    --aws-secret-access-key <INSERT SECRET ACCESS KEY> \
    --aws-region us-west-1 \
    --iaas aws
```

**Create Concourse lbs **

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

**Deploy Concourse**

```
git clone [https://github.com/fushewokunze-pivotal/penguin-ci.git](https://github.com/fushewokunze-pivotal/penguin-ci.git)

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
git clone [https://github.com/fushewokunze-pivotal/penguin-ci.git](https://github.com/fushewokunze-pivotal/penguin-ci.git)
```

**Create a credentials file**

In a separate location on your file system - Create a file with the following credentials. (DO NOT CHECK THIS FILE INTO GIT!!)

```
$ vi credentials.yml

penguin_env_private_key:
penguin_aws_access_key_id: 
penguin_aws_secret_access_key: 
penguin_lbs_ssl_cert:
penguin_lbs_ssl_signing_key:
penguin_domain:
```

**Set Concourse pipeline using fly**

```
$ fly --target cf-deploy set-pipeline --config pipeline.yml --pipeline cf-deploy -l credentials.yml
```
