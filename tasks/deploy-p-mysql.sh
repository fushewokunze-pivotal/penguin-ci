#!/usr/bin/env bash

set -e

eval "$(pcf-bosh-ci/scripts/director-environment bosh-vars-store/*-bosh-vars-store.yml terraform-state/metadata)"

cat <<MYSQLVARS > p-mysql-vars-template.yml
---
################
# MySQL config #
################

cf_mysql_external_host: p-mysql.$(jq -r .sys_domain terraform-state/metadata)

###########################
# MySQL Monitoring config #
###########################

mysql_monitoring_recipient_email: not-a-real-email@example.com
mysql_monitoring_cluster_identifier: "p-mysql-$(cat terraform-state/name)"

########################
# Cloud Foundry config #
########################

cf_api_url: https://api.$(jq -r .sys_domain terraform-state/metadata)
cf_app_domains: [$(jq -r .apps_domain terraform-state/metadata)]
system_domain: $(jq -r .sys_domain terraform-state/metadata)
skip_ssl_validation: true
nats:
  password: ((/aws-director-credhub/cf/nats_password))
  machines: ((nats_ips))
  user: nats
  port: 4222
MYSQLVARS

bosh -n interpolate p-mysql-vars-template.yml \
    -l pcf-bosh-ci/vars-files/gcp-nats-ips.yml > p-mysql-vars.yml

cp mysql-vars-store/*-mysql-vars-store.yml new-mysql-vars-store/mysql-vars-store.yml

bosh -n deploy penguin-ci/manifests/mysql/p-mysql.yml \
  --deployment p-mysql \
  --vars-file p-mysql-vars.yml 

bosh run-errand broker-registrar

