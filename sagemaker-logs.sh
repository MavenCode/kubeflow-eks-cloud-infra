#!/bin/bash
set -euo pipefail

function log {
  echo "$@"
  return 0
}

export os="linux"

wget https://amazon-sagemaker-operator-for-k8s-us-east-1.s3.amazonaws.com/kubectl-smlogs-plugin/latest/${os}.amd64.tar.gz
tar xvzf ${os}.amd64.tar.gz

# Move binaries to a directory in your homedir.
mkdir ~/sagemaker-k8s-bin
cp ./kubectl-smlogs.${os}.amd64/kubectl-smlogs ~/sagemaker-k8s-bin/.

# This line will add the binaries to your PATH in your .bashrc.
echo 'export PATH=$PATH:~/sagemaker-k8s-bin' >> ~/.bashrc

# Source your .bashrc to update environment variables:
source ~/.bashrc