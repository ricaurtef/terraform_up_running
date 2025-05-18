locals {
  tcp_protocol      = "tcp"
  http_protocol     = "HTTP"
  all_protocol      = "-1"
  all_ip_cidr_block = "0.0.0.0/0"
  ssm_port          = 443
  alb_ingress_port  = 80
  alb_egress_port   = 0
}

resource "aws_launch_template" "this" {
  name                   = "${var.application_name}-lt"
  image_id               = data.aws_ami.ubuntu_noble.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this_lt.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    server_port = var.server_port,
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ Name = var.application_name }, var.custom_tags)
  }
}


# Launch template SG setup starts here.
resource "aws_security_group" "this_lt" {
  name = "${var.application_name}-sg"
}

resource "aws_security_group_rule" "this_lt_in" {
  security_group_id = aws_security_group.this_lt.id
  type              = "ingress"
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = local.tcp_protocol
  cidr_blocks       = [local.all_ip_cidr_block]
  description       = "Allow inbound HTTP (for the webserver)."
}

resource "aws_security_group_rule" "this_lt_out" {
  security_group_id = aws_security_group.this_lt.id
  type              = "egress"
  from_port         = local.ssm_port
  to_port           = local.ssm_port
  protocol          = local.tcp_protocol
  cidr_blocks       = [local.all_ip_cidr_block]
  description       = "Allow outbound HTTPS (for the ssm agent)."
}


# ASG setup starts here.
resource "aws_autoscaling_group" "this" {
  name                = "${var.application_name}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.this.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
}

resource "aws_autoscaling_schedule" "this_out" {
  count = var.asg_schedule_enabled ? 1 : 0

  autoscaling_group_name = aws_autoscaling_group.this.name
  scheduled_action_name  = "scale-out-during-business-hours"
  desired_capacity       = 10
  min_size               = 2
  max_size               = 10
  recurrence             = "0 9 * * *"

}

resource "aws_autoscaling_schedule" "this_in" {
  count = var.asg_schedule_enabled ? 1 : 0

  autoscaling_group_name = aws_autoscaling_group.this.name
  scheduled_action_name  = "scale-in-at-night"
  desired_capacity       = 4
  min_size               = 2
  max_size               = 10
  recurrence             = "0 17 * * *"
}


# ALB setup starts here.
resource "aws_lb" "this" {
  name               = "${var.application_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.this_lb.id]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
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

resource "aws_lb_target_group" "this" {
  name     = "${var.application_name}-alb-tg"
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

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "this_lb" {
  name = "${var.application_name}-alb-sg"
}

resource "aws_security_group_rule" "this_lb_in" {
  security_group_id = aws_security_group.this_lb.id
  type              = "ingress"
  from_port         = local.alb_ingress_port
  to_port           = local.alb_ingress_port
  protocol          = local.tcp_protocol
  cidr_blocks       = [local.all_ip_cidr_block]
  description       = "Allow inbound HTTP requests to access the LB."
}

resource "aws_security_group_rule" "this_lb_out" {
  security_group_id = aws_security_group.this_lb.id
  type              = "egress"
  from_port         = local.alb_egress_port
  to_port           = local.alb_egress_port
  protocol          = local.all_protocol
  cidr_blocks       = [local.all_ip_cidr_block]
  description       = "Allow all outbound requests to enable LB health checks."
}

resource "aws_security_group_rule" "this_lb_extra" {
  for_each = { for arg, rule in var.lb_sg_extra : arg => rule }

  security_group_id = aws_security_group.this_lb.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}
