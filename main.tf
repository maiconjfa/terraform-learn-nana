provider "aws" {
  region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
# variable public_key_location{} # PARA CRIAÇÃO DA KEY PAIR VIA TERRAFORM


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

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }    
}

resource "aws_security_group" "myapp-sg" {    # Caso utilizemos o sg default, apenas esta linha mudaria: resource "aws_default_security_group" "default-sg"
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["137112412989"] # Proprietario (owner) da imagem AMI
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}

# PARA CRIAÇÃO DE SHAVE E UTILIZAÇÃO DELA VIA TERRAFORM E .SSH
# resource "aws_key_pair" "ssh-key-teste" {
#   key_name = "teste-key-staging"
#   public_key = "${file(var.public_key_location)}"
# }

resource "aws_instance" "myapp-server" {
 ami = data.aws_ami.latest-amazon-linux-image.id
 instance_type = var.instance_type
 
 subnet_id = aws_subnet.myapp-subnet-1.id
 vpc_security_group_ids = [ aws_security_group.myapp-sg.id ]
 availability_zone = var.avail_zone

 associate_public_ip_address = true
 key_name = "teste-staging"

#  user_data = <<EOF
#                  #!/bin/bash
#                  sudo yum update -y && sudo yum install -y docker
#                  sudo systemctl start docker
#                  sudo usermod -aG docker ec2-user
#                  docker run -p 8080:80 nginx
#              EOF

user_data = file("entry-script.sh")

 tags = {
   Name = "${var.env_prefix}-server"
  }
}






# ------------------------------------------------------------------------------------
# OS COMANDOS ABAIXO SERIA PARA CRIAR UMA NOVA TABELA DE ROTAS E ASSOCIAÇÃO A SUBNETS

# resource "aws_route_table" "myapp-route-table" {
#   vpc_id = aws_vpc.myapp-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     Name = "${var.env_prefix}-rtb"
#   }
# }

# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }
# ------------------------------------------------------------------------------------

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id   # Valor obtido atraves do comando "terraform state show aws_vpc.myapp-vpc"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
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