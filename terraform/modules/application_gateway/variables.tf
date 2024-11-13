variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "app_gateway_subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "endpoint_subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
}

variable "app_gateway_name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "zones" {
  description = "The availability zones to use"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "backend_address" {
  description = "backend address"
  type        = string
}

variable "backend_port" {
  description = "backeend port"
  type        = number
}