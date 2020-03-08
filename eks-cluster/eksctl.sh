#!/bin/bash
set -euo pipefail

function log {
  echo "$@"
  return 0
}

AWS_PROFILE="prod-eks"


# install eksctl -> https://eksctl.io/introduction/installation/

eksctl create cluster \
--name eks-sm-kf \
--region us-west-2 \
--nodegroup-name sm-kf-standard-workers \
--node-type t3.medium \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--ssh-access \
--ssh-public-key ~/.ssh/id_dsa.pub \
--managed