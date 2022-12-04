output "registry_ids" {
  value = [for k, v in aws_ecr_repository.repository : v.id]
}

output "repository_urls" {
  value = [for k, v in aws_ecr_repository.repository : v.repository_url]
}

output "repository_names" {
  value = [for k, v in aws_ecr_repository.repository : v.name]
}
