#!/usr/bin/env bash

set -e

eval "$(pcf-bosh-ci/scripts/director-environment bosh-vars-store/*-bosh-vars-store.yml terraform-state/metadata)"

cat <<SCSVARS > scs-vars-template.yml
---

########################
# Cloud Foundry config #
########################
apps_domain: [$(jq -r .apps_domain terraform-state/metadata)]
system_domain: $(jq -r .sys_domain terraform-state/metadata)
skip_ssl_validation: true
SCSVARS

cp scs-vars-store/*-scs-vars-store.yml new-scs-vars-store/scs-vars-store.yml

bosh -n deploy penguin-ci/manifests/scs/p-scs.yml \
  --deployment p-scs \
  --vars-file scs-vars.yml 
  
bosh run-errand deploy-service-broker -d p-scs

bosh run-errand register-service-broker -d p-scs



