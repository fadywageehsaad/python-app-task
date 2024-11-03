variable "cidr_block" {
    description = "the name of your cluster"
    type        = string
}

variable "subnet_count" {
    description = "how many subnets to be deplpyed"
    type        = number
}

variable "enable_dns_support" {
    description = "Enable dns support"
    type        = bool
    default     = true 
}

variable "enable_dns_hostnames" {
  description = "Enable dns Hostname"
  type        = bool
  default     = true
}

variable "auto_assign" {
  description = "Enable auto assign public Ip"
  type = bool
  default = true
}
