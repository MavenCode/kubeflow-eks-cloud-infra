#!/bin/bash
set -euo pipefail

function log {
  echo "$@"
  return 0
}

source export.sh

TERRAFORM_DIR=.

terraform init ${TERRAFORM_DIR}
terraform fmt -recursive

log "setting up terraform plan..."
#export TF_LOG=INFO
terraform plan  -var-file="${TERRAFORM_DIR}/conf.tfvars" "${TERRAFORM_DIR}"

log "delete terraform setup..."
terraform destroy -auto-approve -var-file=${TERRAFORM_DIR}/conf.tfvars ${TERRAFORM_DIR}