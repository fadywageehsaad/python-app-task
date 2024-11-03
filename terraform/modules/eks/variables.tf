variable "cluster_name" {
    description = "the name of your cluster"
}

variable "cluster_role_arn" {
    description = "role arn to be attached to the created cluster"
}

variable "node_role_arn" {
    description = "role arn to be attached to the created nodes"
}

variable "vpc_id" {
    description = "VPC ID"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}

variable "node_group_name" {
    description = "node group name"
}