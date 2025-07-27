variable "project" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "instance_class" {
  default = "db.t3.micro"
}
variable "allocated_storage" {
  default = 20
}
variable "security_group_ids" {
  type = list(string)
}