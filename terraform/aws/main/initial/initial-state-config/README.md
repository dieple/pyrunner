# Initial State Config

Initial S3 bucket to hold terraform state files with dynamo DB locking. This is store in the SRE account for all environments.
Note this module should run once and forget and also do not mess around anymore after creation.

## Create terraform initial state
    cd terraform/aws/main/initial-state-config 
    terraform init 
    terraform apply