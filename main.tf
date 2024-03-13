locals {
  instance_name = random_pet.instance_name.id
}

resource "random_pet" "instance_name" {
  length    = 3
  separator = "-"
}

resource "aws_launch_template" "example" {
  image_id               = data.aws_ami.ubuntu_jammy.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  /* For individual instances.
  user_data_replace_on_change = true
  */

  user_data = base64encode(templatefile("${path.cwd}/user_data.tftpl", {
    server_port = var.server_port
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.instance_name,
    }
  }
}

resource "aws_security_group" "example_sg" {
  name = "${local.instance_name}-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "example_asg" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  desired_capacity    = 3
  min_size            = 2
  max_size            = 10
  target_group_arns   = [aws_lb_target_group.example_lb_tg.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}

# ALB setup.
resource "aws_lb" "example_lb" {
  name               = "${local.instance_name}-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.example_lb_sg.id]
}

resource "aws_lb_listener" "example_lb_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page.
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found."
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "example_lb_listener_rule" {
  listener_arn = aws_lb_listener.example_lb_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_lb_tg.arn
  }
}

resource "aws_lb_target_group" "example_lb_tg" {
  name     = "${local.instance_name}-lb-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "example_lb_sg" {
  name = "${local.instance_name}-alb"

  # Allow inbound HTTP requests.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
