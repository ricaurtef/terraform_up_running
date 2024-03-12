provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Maintainer = "Ruben Ricaurte: rricaurte@netrixllc.com",
      ManagedBy  = "Terraform",
    }
  }
}

data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical.
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-jammy.*-amd64-server.*"
}

variable "server_port" {
  description = "The http port to listen to requests."
  type        = number
  default     = 8080
}

output "ec2_public_ip" {
    description = "The public IP address of the web server."
    value = aws_instance.example.public_ip
}

locals {
  instance_name = random_pet.instance_name.id
}

resource "random_pet" "instance_name" {
  length    = 3
  separator = "-"
}

resource "aws_instance" "example" {
  ami                         = data.aws_ami.ubuntu_jammy.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.example-sg.id]
  user_data_replace_on_change = true

  user_data = templatefile("${path.cwd}/user_data.tftpl", {
    server_port = var.server_port
  })

  tags = {
    Name = local.instance_name,
  }
}

resource "aws_security_group" "example-sg" {
  name = "${local.instance_name}-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
