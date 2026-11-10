provider "nutanix" {
  username     = var.nutanix_username
  password     = var.nutanix_password
  endpoint     = var.nutanix_endpoint
  port         = 9440
  insecure     = true          # Set false + proper certs in production
  wait_timeout = 60
}

# Lookup target cluster and subnet
data "nutanix_cluster" "cluster" {
  name = var.cluster_name
}

data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

# Optional: upload an image (comment out if using an existing one)
resource "nutanix_image" "image" {
  count = var.image_name == "" ? 1 : 0

  name        = "rocky-9-cloud"
  description = "Rocky Linux 9 Cloud Image"
  source_uri  = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
}

data "nutanix_image" "existing" {
  count      = var.image_name != "" ? 1 : 0
  image_name = var.image_name
}

locals {
  image_uuid = var.image_name != "" ? data.nutanix_image.existing[0].id : nutanix_image.image[0].id
}

# Create 3 VMs
resource "nutanix_virtual_machine" "vms" {
  count = var.vm_count

  name                 = "${var.vm_name_prefix}-${count.index + 1}"
  description          = "Terraform-managed VM ${count.index + 1}"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = 2
  num_sockets          = 1
  memory_size_mib      = 4096
  power_state          = "ON"

  # OS disk cloned from image
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = local.image_uuid
    }
    device_properties {
      device_type = "DISK"
      disk_address = {
        adapter_type = "SCSI"
        device_index = 0
      }
    }
  }

  # Optional data disk (100 GiB)
  disk_list {
    disk_size_mib = 100 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        adapter_type = "SCSI"
        device_index = 1
      }
    }
  }

  # Network
  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  # Optional cloud-init (Linux) – base64-encoded
  # guest_customization_cloud_init_user_data = base64encode(templatefile("${path.module}/cloud-init.yml", {
  #   hostname = "${var.vm_name_prefix}-${count.index + 1}"
  # }))
}

output "vm_names" {
  value = nutanix_virtual_machine.vms[*].name
}

output "vm_uuids" {
  value = nutanix_virtual_machine.vms[*].id
}





































