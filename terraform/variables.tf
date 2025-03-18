variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "spot-cluster"
}

variable "vpc_id" {
  description = "VPC ID where instances will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be deployed"
  type        = list(string)
}

variable "key_name" {
  description = "SSH key name to access instances"
  type        = string
  default     = "ssh-key"
}

variable "debian_instance_count" {
  description = "Number of Debian instances to create"
  type        = number
  default     = 2
}

variable "debian_instance_master_count" {
  description = "Number of Debian instances to create"
  type        = number
  default     = 1
}

variable "debian_instance_type" {
  description = "Instance type for Debian servers"
  type        = string
  default     = "t3.small"
}

variable "rocky_instance_type" {
  description = "Instance type for Rocky Linux servers"
  type        = string
  default     = "t3.small"
}

variable "spot_price" {
  description = "Maximum spot price for instances"
  type        = string
  default     = "0.016"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
