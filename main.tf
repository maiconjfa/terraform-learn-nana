provider "aws" {
  region = "us-east-1"
}


variable "cidr_blocks" {
  description = "cidr block for vpc an subnet"
  type = list(string)
}

variable "environment" {
  description = "deployment environment"
}

#RESOURCE - São os recursos que serão criados no provider
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_blocks[0]
  tags = {
    Name = var.environment
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.cidr_blocks[1]
  availability_zone = "us-east-1a"
  tags = {
    Name = "teste-dev-subnet-1"
  }
}

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

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}