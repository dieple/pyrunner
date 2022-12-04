output "key_arn" {
  value = module.kms.key_arn
}

output "key_id" {
  value = module.kms.key_id
}

output "alias_arn" {
  value = module.kms.alias_arn
}

output "alias_name" {
  value = module.kms.alias_name
}

output "alias_map" {
  value = tomap({
    for i, id in module.kms.alias_name :
    id => module.kms.key_arn[i]
  })
}
