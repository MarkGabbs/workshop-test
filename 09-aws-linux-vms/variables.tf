variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the private subnet. If null, the first AZ in the region is used."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type. Default is t4g.nano (Graviton/ARM). Smallest general-purpose."
  type        = string
  default     = "t4g.nano"
}

variable "instance_count" {
  description = "Number of Linux instances to launch"
  type        = number
  default     = 3
}

variable "ami_id" {
  description = "AMI ID for the instances. If null, the latest Amazon Linux 2023 is used."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH (not usable without network access)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Project = "WEI-Workshop"
  }
}
