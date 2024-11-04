provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  cidr_block       = "10.0.0.0/16"
  subnet_count     = 2
  eks_cluster_name = "my-eks-cluster"
}

module "ecr" {
  source = "./modules/ecr"
  repository_name = "my-ecr-repo"
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    example = {
      instance_types = ["m3.medium"]

      min_size = 2
      max_size = 5
      desired_size = 2
    }
  }
}