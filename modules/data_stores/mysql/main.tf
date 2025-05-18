resource "aws_db_instance" "hello_world_db" {
  identifier_prefix   = "hello-world-"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "hello_world_database"
  username            = var.db_main_username
  password            = var.db_main_password
}
