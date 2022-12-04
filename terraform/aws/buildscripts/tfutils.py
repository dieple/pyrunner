import argparse
import boto3

def str2bool(v):
  if isinstance(v, bool):
    return v
  if v.lower() in ('yes', 'true', 't', 'y', '1'):
    return True
  elif v.lower() in ('no', 'false', 'f', 'n', '0'):
    return False
  else:
    raise argparse.ArgumentTypeError('Boolean value expected.')


def is_empty(chk_data):
  if chk_data:
    return False
  else:
    return True

def get_credentials(role_arn):
  # create an STS client object that represents a live connection to the
  # STS service
  sts_client = boto3.client('sts')

  # Call the assume_role method of the STSConnection object and pass the role
  # ARN and a role session name.
  assumed_role_object = sts_client.assume_role(
    RoleArn=role_arn,
    RoleSessionName="AssumeRoleSessionCI"
  )

  # From the response that contains the assumed role, get the temporary
  # credentials that can be used to make subsequent API calls
  return assumed_role_object['Credentials']