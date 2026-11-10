# Configure the AWS Provider
provider "aws" {
  version = "~> 6.0"
  region  = "us-east-2"
}

provider "aws" {
  region     = "us-east-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

# Create a VPC
resource "aws_vpc" "WEI Workshop" {
  cidr_block = "10.123.0.0/16"

  tags = {
    Name = "WEI Workshops"
  }
}































