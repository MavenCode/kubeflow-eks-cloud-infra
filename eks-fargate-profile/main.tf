provider "aws" {
  region = var.region
}

module "label" {
  source     = "../modules/label"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = var.tags
}

locals {
  tags = merge(module.label.tags, map("kubernetes.io/cluster/${module.label.id}", "shared"))
}

module "vpc" {
  source     = "../modules/vpc"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  cidr_block = var.vpc_cidr_block
  tags       = local.tags
}

module "subnets" {
  source               = "../modules/subnet"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = var.attributes
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false
  tags                 = local.tags
}

module "eks_cluster" {
  source                = "../modules/eks-cluster"
  namespace             = var.namespace
  stage                 = var.stage
  cluster_name                  = var.cluster_name
  attributes            = var.attributes
  common_tags                  = var.common_tags
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.subnets.public_subnet_ids
  kubernetes_version    = var.kubernetes_version
  kubeconfig_path       = var.kubeconfig_path
  oidc_provider_enabled = var.oidc_provider_enabled

  workers_role_arns          = [module.eks_node_group.eks_node_group_role_arn, module.eks_fargate_profile.eks_fargate_profile_role_arn]
  workers_security_group_ids = []
}

module "eks_node_group" {
  source             = "../modules/eks-node-group"
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  attributes         = var.attributes
  tags               = var.tags
  subnet_ids         = module.subnets.public_subnet_ids
  instance_types     = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size
  cluster_name       = module.eks_cluster.eks_cluster_id
  kubernetes_version = var.kubernetes_version
  kubernetes_labels  = var.kubernetes_labels
}

module "eks_fargate_profile" {
  source               = "../modules/eks-fargate-profile"
  namespace            = var.namespace
  stage                = var.stage
  fargate_profile_name                 = var.name
  attributes           = var.attributes
  common_tags                 = var.tags
  subnet_ids           = module.subnets.private_subnet_ids
  cluster_name         = module.eks_cluster.eks_cluster_id
  kubernetes_namespace = var.kubernetes_namespace
  kubernetes_labels    = var.kubernetes_labels
}