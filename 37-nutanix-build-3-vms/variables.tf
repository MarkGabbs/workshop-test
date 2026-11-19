variable "nutanix_username" {
  type      = string
  sensitive = true
}

variable "nutanix_password" {
  type      = string
  sensitive = true
}

variable "nutanix_endpoint" {
  type        = string
  description = "Prism Central IP or FQDN"
}

variable "cluster_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "image_name" {
  type        = string
  default     = ""
  description = "Existing image name. Leave empty to upload a new one."
}

variable "vm_count" {
  type    = number
  default = 3
}

variable "vm_name_prefix" {
  type    = string
  default = "tf-vm"
}





































