variable "cluster_name" {
    description = "the name of your cluster"
    type        = string
}

variable "cluster_role_arn" {
    description = "role arn to be attached to the created cluster"
    type        = string
}

variable "node_role_arn" {
    description = "role arn to be attached to the created nodes"
    type        = string
}

variable "vpc_id" {
    description = "VPC ID"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs"
    type        = list(string)
    default     = []
}

variable "subnet_count" {
    description = "how many subnets to be deplpyed"
    type        = number
}