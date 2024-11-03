provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source       = "./modules/vpc"

  cidr_block   = "10.0.0.0/16"
  subnet_count = 1
}

module "ecr" {
  source = "./modules/ecr"
  repository_name = "my-ecr-repo"
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source           = "./modules/eks"

  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.subnet_ids
  cluster_name     = "my-eks-cluster"
  cluster_role_arn = module.iam.eks_role_arn
  node_role_arn    = module.iam.node_role_arn
  node_group_name  = "my-node-group"
}