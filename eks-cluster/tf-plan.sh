#!/bin/bash
set -euo pipefail

function log {
  echo "$@"
  return 0
}

source ../export.sh

export TF_VAR_region="us-east-2"
export TF_VAR_availability_zones='["us-east-2a", "us-east-2b"]'
export TF_VAR_namespace="eg"
export TF_VAR_stage="test"
export TF_VAR_name="eks"
export TF_VAR_instance_type="t2.small"
export TF_VAR_health_check_type="EC2"
export TF_VAR_wait_for_capacity_timeout="10m"
export TF_VAR_max_size=3
export TF_VAR_min_size=2
export TF_VAR_autoscaling_policies_enabled=true
export TF_VAR_cpu_utilization_high_threshold_percent=80
export TF_VAR_cpu_utilization_low_threshold_percent=20
export TF_VAR_associate_public_ip_address=true
export TF_VAR_kubernetes_version="1.14"
export TF_VAR_kubeconfig_path="/.kube/config"
export TF_VAR_oidc_provider_enabled=true
export TF_VAR_enabled_cluster_log_types='["audit"]'
export TF_VAR_cluster_log_retention_period=7

TERRAFORM_DIR=.

terraform init ${TERRAFORM_DIR}
terraform fmt -recursive

log "setting up terraform plan..."
#export TF_LOG=INFO
terraform plan  -var-file="${TERRAFORM_DIR}/conf.tfvars" "${TERRAFORM_DIR}"