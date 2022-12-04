resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = var.acceptance_required
  gateway_load_balancer_arns = var.gateway_load_balancer_arns
  network_load_balancer_arns = var.network_load_balancer_arns
  private_dns_name           = var.private_domain
  tags                       = var.tags
}

resource "aws_vpc_endpoint_service_allowed_principal" "this" {
  for_each = toset(var.allowed_principals)

  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  principal_arn           = each.value
}

resource "aws_vpc_endpoint_connection_notification" "this" {
  for_each = {
    for config in try(var.notification_configurations, []) :
    config.sns_arn => config
  }

  vpc_endpoint_service_id     = aws_vpc_endpoint_service.this.id
  connection_notification_arn = each.key
  connection_events           = try(each.value.events, [])
}