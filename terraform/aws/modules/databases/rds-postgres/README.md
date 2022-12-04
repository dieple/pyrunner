# AWS RDS Aurora Terraform module

Taking from `terraform-aws-modules/rds-aurora/aws` version tag 7.5.1 with minor modifications
to make it work with dbnane and db identifiers having issues with 
```
 Error: only lowercase alphanumeric characters and hyphens allowed in "cluster_identifier"```
```