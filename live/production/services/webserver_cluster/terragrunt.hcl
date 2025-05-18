locals {
  version = "v0.0.1"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "github.com/ricaurtef/modules//services/webserver_cluster?ref=${local.version}"
}

inputs = {
  application_name     = "hello-world-${include.root.locals.environment}"
  server_port          = 8080
  instance_type        = "t2.micro"
  desired_capacity     = 3
  min_size             = 2
  max_size             = 10
  asg_schedule_enabled = true
}
