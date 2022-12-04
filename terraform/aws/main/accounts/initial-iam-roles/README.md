# Note

After the new account has been created in the AWS Control Tower. Using the root login email address and modify the
iam role `OrganisationAccountAccessRole` Trust Relationships policy to below
``` hcl
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::319061448186:root", # master a/c
                    "arn:aws:iam::120161110524:root", # sre a/c
                    "arn:aws:iam::120161110524:user/terraform"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

also modify the `_envs.tf` file for the SRE account to below:
```terraform
workspace_iam_role  = "arn:aws:iam::120161110524:role/OrganizationAccountAccessRole"
```

Assume role to SRE user/terraform and this module interactively to create the initial `administrators`, `developers`, and `operations` IAM roles.
