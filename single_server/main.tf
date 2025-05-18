resource "aws_instance" "example" {
  ami                         = data.aws_ami.ubuntu_noble.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.example_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.example_profile.id
  key_name                    = "rubinho_personal_lenovo"
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh", {
    server_port = var.server_port,
  })

  tags = {
    Name = "terraform-example"
  }
}


# IAM instance profile setup starts here.
resource "aws_iam_instance_profile" "example_profile" {
  name = "tf-example-profile"
  role = data.aws_iam_role.ec2_ssm_core.name
}


# EC2 SG setup starts here.
resource "aws_security_group" "example_sg" {
  name = "tf-example-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.ssm_port
    to_port     = var.ssm_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound HTTPS (for the SSM agent)."
  }
}
