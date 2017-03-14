#!/usr/bin/env bash

set -e

eval "$(pcf-bosh-ci/scripts/director-environment bosh-vars-store/*-bosh-vars-store.yml terraform-state/metadata)"

cat <<RABBITMQVARS > p-rabbitmq-vars-template.yml
---

########################
# Cloud Foundry config #
########################
cf_api_url: https://api.$(jq -r .sys_domain terraform-state/metadata)
cf_uaa_admin_client_secret: ((/aws-director-credhub/cf/apps_manager_client_password))
cf_admin_username: push_apps_manager
cf_admin_password: ((/aws-director-credhub/cf/push_apps_manager_password))
cf_app_domains: [$(jq -r .apps_domain terraform-state/metadata)]
cf_sys_domain: $(jq -r .sys_domain terraform-state/metadata)
cf_skip_ssl_validation: true
nats:
  password: ((/aws-director-credhub/cf/nats_password))
  machines: ((nats_ips))
  user: nats
  port: 4222
RABBITMQVARS

bosh -n interpolate p-rabbitmq-vars-template.yml \
    -l pcf-bosh-ci/vars-files/gcp-nats-ips.yml > p-rabbitmq-vars.yml

cp rabbitmq-vars-store/*-rabbitmq-vars-store.yml new-rabbitmq-vars-store/rabbitmq-vars-store.yml

bosh -n deploy penguin-ci/manifests/rabbitmq/p-rabbitmq.yml \
  --deployment cf-rabbitmq \
  --vars-file p-rabbitmq-vars.yml 
