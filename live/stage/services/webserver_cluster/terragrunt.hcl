locals {
  version = "v0.0.1"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # source = "github.com/ricaurtef/modules//services/webserver_cluster?ref=${local.version}"
  source = "../../../modules/services/webserver_cluster"
}

inputs = {
  application_name = "hello-world-${include.root.locals.environment}"
  server_port      = 8080
  instance_type    = "t2.micro"
  desired_capacity = 2
  min_size         = 2
  max_size         = 5

  custom_tags = {
    Application = "hello-world."
  }

  /* Example of how to add extra SG rules to the LB.
  lb_sg_extra = [
    {
      type        = "ingress"
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Internal app traffic"
    },
    {
      type        = "egress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      # description is optional, and will default to "Extra rule for LB SG."
    }
  ]
  */
}
