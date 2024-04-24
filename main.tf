variable "backup_retention_period"      { default = 30 }
variable "db_name"                      {  }
variable "db_username"                  {  }
variable "db_port"                      { default = 5432 }
variable "db_engine_version"            { default = "15.2" }
variable "db_password"                  {  }
variable "db_allocated_storage"         { default = 20 }
variable "db_instance_class"            { default = "db.t2.micro" }
variable "name"                         { default = "Postgres database" }
variable "publicly_accessible"          { default = false }
variable "subnets"                      {  }
variable "security_group_ids"           {  }
variable "create_snapshot"              { default =  true }


resource "aws_db_subnet_group" "default" {
  name          = "${var.name}-db-subnet-group"
  subnet_ids    = var.subnets
}

resource "aws_db_parameter_group" "default" {
  name   = "${var.name}-parameter-group"
  family = "postgres15"

  parameter {
    name  = "lc_messages"
    value = "en_IE.UTF-8"
  }

  parameter {
    name  = "lc_monetary"
    value = "en_IE.UTF-8"
  }

  parameter {
    name  = "lc_numeric"
    value = "en_IE.UTF-8"
  }

  parameter {
    name  = "lc_time"
    value = "en_IE.UTF-8"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "shared_buffers"
    value        = "{DBInstanceClassMemory/32768}"
  }
}



resource "aws_db_instance" "default" {
  allocated_storage           = var.db_allocated_storage
  apply_immediately           = true
  auto_minor_version_upgrade  = false
  backup_retention_period     = var.backup_retention_period
  backup_window               = "01:00-03:00"
  maintenance_window          = "Wed:03:05-Wed:04:05"
  db_subnet_group_name        = aws_db_subnet_group.default.name
  engine                      = "postgres"
  engine_version              = var.db_engine_version
  identifier                  = "${var.name}-postgres"
  instance_class              = var.db_instance_class
  monitoring_interval         = "0"
  multi_az                    = true
  db_name                     = var.db_name
  parameter_group_name        = aws_db_parameter_group.default.id
  password                    = var.db_password
  publicly_accessible         = var.publicly_accessible
  skip_final_snapshot         = true
  storage_type                = "gp2"
  username                    = var.db_username
  vpc_security_group_ids      = var.security_group_ids

  allow_major_version_upgrade = true
  enabled_cloudwatch_logs_exports = ["upgrade"]

  tags = {
    Name = "${var.name}-${var.db_instance_class}-postgres"
  }
}


resource "aws_db_snapshot" "default" {
  count = var.create_snapshot ? 1 : 0
  db_instance_identifier = aws_db_instance.default.identifier
  db_snapshot_identifier = "${var.name}-snapshot"
}


output "address"      { value = aws_db_instance.default.address }
output "arn"          { value = aws_db_instance.default.arn }
output "db_name"      { value = aws_db_instance.default.db_name }
output "db_port"      { value = aws_db_instance.default.port }
output "db_username"  { value = aws_db_instance.default.username }
