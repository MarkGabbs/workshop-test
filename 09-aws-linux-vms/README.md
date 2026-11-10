# Terraform Module: Private Linux VMs (No Internet)

Deploys a VPC with a single private subnet and 3 (configurable) Amazon Linux 2023 **ARM** instances of the smallest size (`t4g.nano` by default).

**Key characteristics:**
- No Internet Gateway
- No NAT Gateway
- No public IP addresses
- Route table contains only the local VPC route
- Security group explicitly blocks all inbound and outbound traffic to the internet
- Uses AWS Graviton2 (`t4g.nano`) for lowest cost

## Usage

```hcl
module "private_vms" {
  source = "./terraform-private-linux-vms"

  region               = "us-east-1"
  instance_type        = "t4g.nano"  # Graviton/ARM (default)
  instance_count       = 3
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidr  = "10.0.1.0/24"
  # availability_zone  = "us-east-1a"  # optional
  # key_name           = "my-key"      # optional (SSH will not work without network access)
  # ami_id             = "ami-xxxxxxxx" # optional, must be arm64 if overriding

  tags = {
    Environment = "WEI Workshops"
    Owner       = "Mark Gabryjelski"
  }
}
```

## Outputs

| Name                | Description                      |
|---------------------|----------------------------------|
| `vpc_id`            | VPC ID                           |
| `private_subnet_id` | Private subnet ID                |
| `instance_ids`      | List of EC2 instance IDs         |
| `private_ips`       | List of private IP addresses     |
| `security_group_id` | Security group ID                |

## Notes

- Instances are launched in a completely isolated private subnet.
- There is no path to the internet in either direction.
- To access the instances later you would need to add a bastion host, VPN, or SSM (with VPC endpoints) — none of which are included by design.
- Default instance type is **`t4g.nano`** (2 vCPU, 0.5 GiB RAM, AWS Graviton2 / arm64). The module automatically selects a matching Amazon Linux 2023 arm64 AMI.
- If you override `ami_id`, it **must** be an arm64 AMI when using `t4g.*` instance types.

## Requirements

- Terraform >= 1.5
- AWS provider >= 5.0
- AWS credentials with permissions to create VPC, Subnet, Route Table, Security Group, and EC2 instances
