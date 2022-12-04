output "key_arn" {
  value = module.key_pair.key_pair_arn
}

output "key_name" {
  value = module.key_pair.key_pair_name
}

output "key_pair_id" {
  value = module.key_pair.key_pair_id
}

output "fingerprint" {
  value = module.key_pair.key_pair_fingerprint
}

output "devops_key_arn" {
  value = module.devops.key_pair_arn
}

output "devops_key_name" {
  value = module.devops.key_pair_name
}

output "devops_key_pair_id" {
  value = module.devops.key_pair_id
}

output "devops_fingerprint" {
  value = module.devops.key_pair_fingerprint
}