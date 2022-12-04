output "log_group_arns" {
  value = aws_cloudwatch_log_group.this.*.arn
}

output "security_alerts" {
  # "arn:aws:logs:eu-west-1:aws-account-id:log-group:/aws/dev/security-alerts:*",
  value = element(split(":", [for e in aws_cloudwatch_log_group.this.*.arn : e if length(regexall("security-alerts", e)) > 0][0]), 6)
}