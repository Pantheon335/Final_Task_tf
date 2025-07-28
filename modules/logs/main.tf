resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project}"
  retention_in_days = 7


  tags = {
    Name = "${var.project}-logs"
  }
}