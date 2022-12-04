output "log_group_arns" {
  value = module.log_group.log_group_arns
}

output "log_group_names" {
  value = local.log_group_names["default"]
}

output "log_group_map" {
  value = tomap({
    for i, id in module.log_group.log_group_names :
    id => module.log_group.log_group_arns[i]
  })
}