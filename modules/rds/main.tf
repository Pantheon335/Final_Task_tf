resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.project}-db"
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  engine_version         = "17.5"
  instance_class         = var.instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  deletion_protection    = false

  tags = {
    Name = "${var.project}-db"
  }
}