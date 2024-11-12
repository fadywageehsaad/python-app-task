variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the App Service Plan"
  type        = string
}

variable "app_service_name" {
  description = "The name of the App Service"
  type        = string
}

variable "container_image" {
  description = "The container image to use for the App Service"
  type        = string
}

variable "application_insights_key" {
  description = "The instrumentation key for Application Insights"
  type        = string
}

variable "container_registry_login_server" {
  description = "The login server of the Azure Container Registry"
  type        = string
}

variable "container_registry_username" {
  description = "admin_username of the Azure Container Registry"
  type        = string
}

variable "container_registry_password" {
  description = "password of the Azure Container Registry"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name to be used"
  type        = string
}