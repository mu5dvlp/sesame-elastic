variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type for ELK Stack"
  type        = string
  default     = "t3.medium"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
}

variable "allowed_kibana_cidr" {
  description = "CIDR block allowed for Kibana access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "sesame_api_key" {
  description = "Sesame API authentication key"
  type        = string
  sensitive   = true
}

variable "sesame_device_uuids" {
  description = "Comma-separated list of Sesame device UUIDs to monitor"
  type        = string
}

variable "elk_version" {
  description = "ELK Stack version"
  type        = string
  default     = "8.11.0"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression for Lambda"
  type        = string
  default     = "rate(5 minutes)"
}
