#!/bin/bash
set -euo pipefail

function log {
  echo "$@"
  return 0
}

export CLUSTER_NAME="terraform-eks-demo"
export AWS_REGION="us-east-1"

eks_sagemaker_kf_iam_role="eks-demo-cluster-sa-role"

log "1. describe the cluster status"
aws eks describe-cluster \
    --name ${CLUSTER_NAME} \
    --region ${AWS_REGION} \
    --query cluster.identity.oidc.issuer \
    --output text \
    --profile prod-eks

log "2. create a new IAM role that can be assumed by the cluster service accounts"
# shellcheck disable=SC2154
check=$(aws iam get-role --profile prod-eks --role-name ${eks_sagemaker_kf_iam_role} 2> /dev/null)
if [ "$check" ]; then
   log "IAM Manager role ${eks_sagemaker_kf_iam_role} exists, skipping this step ..."
else
  aws iam create-role \
      --role-name ${eks_sagemaker_kf_iam_role} \
      --assume-role-policy-document file://trust.json \
      --output text \
      --profile prod-eks
fi
log "3. Attach role to Amazon SageMaker and granting it the AmazonSageMakerFullAccess "
aws iam attach-role-policy \
    --role-name ${eks_sagemaker_kf_iam_role} \
    --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess \
    --output text \
    --profile prod-eks


#log "4. Creating Fargate Profile"
#check=$(eksctl create fargateprofile --cluster ${CLUSTER_NAME} --namespace sagemaker-k8s-operator-system 2> /dev/null)
#if [ "$check" ]; then
#  log "Fargate Profile already created..."
#else
#  eksctl create fargateprofile --cluster ${CLUSTER_NAME} --namespace sagemaker-k8s-operator-system
#fi

log "5. getting kubeconfig all set"
aws sts get-caller-identity --profile prod-eks
aws eks update-kubeconfig \
      --region ${AWS_REGION} \
      --name ${CLUSTER_NAME} \
      --profile prod-eks





#sh setup-aws.sh
#1. describe the cluster status
#https://oidc.eks.us-east-1.amazonaws.com/id/472462C696F84A8555EEE41E90ABBF67
#2. create a new IAM role that can be assumed by the cluster service accounts
#ROLE    arn:aws:iam::000654207548:role/eks-demo-cluster-sa-role 2020-03-04T02:10:53Z    /       AROAQAJX6NI6EQ2V7DVFB   eks-demo-cluster-sa-role
#ASSUMEROLEPOLICYDOCUMENT        2012-10-17
#STATEMENT       sts:AssumeRoleWithWebIdentity   Allow
#STRINGEQUALS    sts.amazonaws.com       system:serviceaccount:sagemaker-k8s-operator-system:sagemaker-k8s-operator-default
#PRINCIPAL       arn:aws:iam::472462C696F84A8555EEE41E90ABBF67:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/472462C696F84A8555EEE41E90ABBF67
#3. Attach role to Amazon SageMaker and granting it the AmazonSageMakerFullAccess