locals {
  tcp_protocol     = "tcp"
  http_protocol    = "HTTP"
  all_protocol     = "-1"
  all_cidr_block   = "0.0.0.0/0"
  ssm_port         = 443
  alb_ingress_port = 80
  alb_egress_port  = 0
}

resource "aws_launch_template" "hello_world" {
  name                   = "${var.application_name}-launch-template"
  image_id               = data.aws_ami.ubuntu_noble.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.hello_world_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    server_port = var.server_port,
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.application_name
    }
  }
}


# Launch template SG setup starts here.
resource "aws_security_group" "hello_world_sg" {
  name = "${var.application_name}-security-group"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = [local.all_cidr_block]
    description = "Allow inbound HTTP (for the webserver)."
  }

  egress {
    from_port   = local.ssm_port
    to_port     = local.ssm_port
    protocol    = local.tcp_protocol
    cidr_blocks = [local.all_cidr_block]
    description = "Allow outbound HTTPS (for the ssm agent)."
  }
}


# ASG setup starts here.
resource "aws_autoscaling_group" "hello_world_asg" {
  name                = "${var.application_name}-auto-scaling-group"
  desired_capacity    = 3
  min_size            = 2
  max_size            = 10
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.hello_world_alb_tg.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.hello_world.id
    version = aws_launch_template.hello_world.latest_version
  }
}


# ALB setup starts here.
resource "aws_lb" "hello_world_alb" {
  name               = "${var.application_name}-app-load-balancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.hello_world_alb_sg.id]
}

resource "aws_lb_listener" "hello_world_alb_listener" {
  load_balancer_arn = aws_lb.hello_world_alb.arn
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

resource "aws_lb_target_group" "hello_world_alb_tg" {
  name     = "${var.application_name}-app-load-balancer-tg"
  port     = var.server_port
  protocol = local.http_protocol
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = local.http_protocol
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "hello_world_alb_listener_rule" {
  listener_arn = aws_lb_listener.hello_world_alb_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello_world_alb_tg.arn
  }
}

resource "aws_security_group" "hello_world_alb_sg" {
  name = "${var.application_name}-app-load-balancer-security-group"

  ingress {
    from_port   = local.alb_ingress_port
    to_port     = local.alb_ingress_port
    protocol    = local.tcp_protocol
    cidr_blocks = [local.all_cidr_block]
    description = "Allow inbound HTTP requests to access the LB."
  }

  egress {
    from_port   = local.alb_egress_port
    to_port     = local.alb_egress_port
    protocol    = local.all_protocol
    cidr_blocks = [local.all_cidr_block]
    description = "Allow all outbound requests to enable LB health checks."
  }
}
