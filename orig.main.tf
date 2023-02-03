terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
   region  = var.aws_region
}

resource "aws_vpc" "cloud_vpc" {
  # This is a large vpc, 256 x 256 IPs available
   cidr_block = "100.0.0.0/16"
   enable_dns_support = true
   enable_dns_hostnames = true
   tags = {
      Name = "${var.name_tag} VPC"
      Project = var.project_tag
    }
}

resource "aws_subnet" "main" {
  vpc_id   = aws_vpc.cloud_vpc.id
  # This subnet will allow 256 IPs
  #cidr_block = "100.0.0.0/24"
  cidr_block = var.subnet_prefix[0].cidr_block
  availability_zone = var.availability_zone
   tags = {
      Name = "${var.subnet_prefix[0].name} Subnet"
      Project = var.project_tag
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cloud_vpc.id
   tags = {
      Name = "${var.name_tag} Internet Gateway"
      Project = var.project_tag
    }
}

resource "aws_route_table" "default" {
    vpc_id = aws_vpc.cloud_vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }
   tags = {
      Name = "${var.name_tag} Route Table"
      Project = var.project_tag
    }
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

resource "aws_security_group" "web_ingress" {
  vpc_id = aws_vpc.cloud_vpc.id
  ingress {
      description = "HTTPS"      
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      description = "HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
          description = "Allow SSH from approved IP addresses"
          from_port = 22
          to_port   = 22
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
   }
  tags = {
      Name = "${var.name_tag} WEB SG"
      Project = var.project_tag
  }
} 

resource "aws_network_interface" "web_server_nic" {
  subnet_id   = aws_subnet.main.id
  private_ips = ["100.0.0.10"]
  security_groups = [aws_security_group.web_ingress.id]
}

data "aws_ec2_instance_type" "head_node" {
  instance_type = var.instance_type
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "100.0.0.10"
  depends_on = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip  
}

output "server_private_ip" {
  value = aws_instance.web_instance.private_ip  
}

output "server_id" {
  value = aws_instance.web_instance.id
}

resource "aws_instance" "web_instance" {
  ami = "ami-00874d747dde814fa"
  instance_type = "t2.micro"
  #availability_zone = var.aws_region
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web_server_nic.id    
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server instance > /var/www/html/index.html'
              EOF
  tags = {
    Name = "${var.name_tag} EC2 Web Instance"
    Project = var.project_tag
  }
}
