data "aws_ami" "ubuntu_noble" {
  most_recent = true
  owners      = ["099720109477"]
  name_regex  = "^ubuntu/images/hvm-ssd(-gp3)?/ubuntu-noble.*amd64-.*"

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_iam_role" "ec2_ssm_core" {
  name = "ec2-ssm-core"
}
