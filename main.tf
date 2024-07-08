provider "aws" {
  region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}


#RESOURCE - São os recursos que serão criados no provider
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# ---------------------------------------------------------------------

# DATA - Consulta recursos e componentes ja existentes no provider
# data "aws_vpc" "existing_vpc" {
#   default = true
# }

# resource "aws_subnet" "dev-subnet-2" {
#   vpc_id = data.aws_vpc.existing_vpc.id
#   cidr_block = "172.31.48.0/20"
#   availability_zone = "us-east-1b"
#   tags = {
#     Name = "teste-dev-subnet-2"
#   }
# }

# output "dev-vpc-id" {
#   value = aws_vpc.dev-vpc.id
# }

# output "dev-subnet-id" {
#   value = aws_subnet.dev-subnet-1.id
# }