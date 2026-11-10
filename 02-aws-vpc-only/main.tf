# Configure the AWS Provider
provider "aws" {
  version = "~> 6.0"
  region  = "us-east-2"
}

provider "aws" {
  region     = "us-east-2"
  access_key = "myAccessKey"
  secret_key = "mySecretKey"
}

# Create a VPC
resource "aws_vpc" "WEI Workshop" {
  cidr_block = "10.123.0.0/16"

  tags = {
    Name = "WEI Workshops"
  }
}































