#!/usr/bin/env bash

set -e

eval "$(pcf-bosh-ci/scripts/director-environment bosh-vars-store/*-bosh-vars-store.yml terraform-state/metadata)"

cat <<RABBITMQVARS > p-rabbitmq-vars-template.yml
---

########################
# Cloud Foundry config #
########################
apps_domain: [$(jq -r .apps_domain terraform-state/metadata)]
system_domain: $(jq -r .sys_domain terraform-state/metadata)
skip_ssl_validation: true
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
  
bosh run-errand broker-registrar  -d cf-rabbitmq

