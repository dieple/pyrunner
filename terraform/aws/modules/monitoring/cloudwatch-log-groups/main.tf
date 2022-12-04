resource "aws_cloudwatch_log_group" "this" {
  count             = length(var.log_group_names)
  name              = element(var.log_group_names, count.index)
  retention_in_days = var.retention_in_days
  tags              = merge({ Name = "${terraform.workspace}-${element(var.log_group_names, count.index)}" }, var.tags)
}
