resource "aws_db_instance" "this" {
  identifier_prefix       = "hello-world-"
  allocated_storage       = 10
  instance_class          = "db.t3.micro"
  skip_final_snapshot     = true
  backup_retention_period = var.backup_retention_period
  replicate_source_db     = var.replicate_source_db

  # Only set these params if replicate_source_db is not set.
  engine   = var.replicate_source_db == null ? "mysql" : null
  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_main_username : null
  password = var.replicate_source_db == null ? var.db_main_password : null
}
