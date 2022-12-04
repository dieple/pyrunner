# Initial IAM Roles

This module creates IAM roles and policies in the organisation member accounts.

It creates the following:
- administrators role
- developers role
- operations role
- read only access policy


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_iam\_root\_account\_id | account id of the root IAM account | string | `"667800118351"` | no |
| aws\_monitoring\_account\_ids | account id allowed to assume the CloudWatch role and monitor it. for now shared transit account. | list | `<list>` | no |
| developers\_full\_access | give the developers group full access to this account | string | `"false"` | no |
| operations\_full\_access | give the developers group full access to this account | string | `"false"` | no |
| override\_administrator\_policy | override the policy | string | `"false"` | no |
| override\_administrator\_policy\_arn | name of the policy to override | string | `""` | no |
| override\_administrator\_role\_policy | override the policy | string | `"false"` | no |
| override\_administrator\_role\_policy\_arn | name of the policy to override | string | `""` | no |
| override\_developer\_role\_policy | override the policy | string | `"false"` | no |
| override\_developer\_role\_policy\_arn | name of the policy to override | string | `""` | no |
| override\_operations\_role\_policy | name of the policy to override | string | `"false"` | no |
| override\_operations\_role\_policy\_arn | name of the policy to override | string | `""` | no |
| override\_read\_only\_policy | override the policy | string | `"false"` | no |
| override\_read\_only\_policy\_arn | name of the policy to override | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| administrators\_role\_arn | Administrators role ARN |
| developers\_role\_arn | Developers role ARN |
| operations\_role\_arn | Operations role ARN |
| cloudwatch\_allow\_read\_role\_arn | CloudWatch allow read role ARN |
