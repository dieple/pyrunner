#!/usr/bin/env python3

# Orchestrator build script for all environments - to be called by Gitlab or can be used interactively
import argparse
import sys
import os
import inspect
import hcl2
import gitlab

from ruamel.yaml import YAML

# from python_terraform import *

# realpath() will make your script run, even if you symlink it :)
build_dir = os.path.realpath(os.path.abspath(os.path.split(inspect.getfile(inspect.currentframe()))[0]))
if build_dir not in sys.path:
  sys.path.insert(0, build_dir)

# include utils or lib modules from a subfolder
for include_dir in ["buildscripts", "variables", "main"]:
  build_subdir = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile(inspect.currentframe()))[0], include_dir)))
  if build_subdir not in sys.path:
    sys.path.insert(0, build_subdir)

from buildscripts.tfmodules import prompt_modules, find_modules
from buildscripts.tfprompts import prompt_account, prompt_tfaction
from buildscripts.tfrun import tfrun
from buildscripts.tfutils import str2bool, is_empty

GITOPS_YAML_FILE = "./gitops.yaml"
INPUT_ENVS_FILE = "./variables/_envs.tf"
TF_ACTIONS = ["plan", "apply", "plan-destroy", "apply-destroy"]
MODULE_DIRS = ["main"]
EXCLUDE_DIRS=["/initials/", "/ecr-repositories/", "/iam/", "/lambda_artefacts/"
              "/tools/", "/serverless/", "vpc-endpoint-service"]
BUILD_WORKSPACES = ["dev"]
INFRA_REPO_PROJECT_ID=39439064

PREREQUISITE_MODULES = ["./main/networkings/security-groups"]

MODULES_FOR_SRE_ONLY = ["./main/containers/ecr-repositories"]

EMAIL_SETUP_ONLY = ["./main/management/email-setup"]

if os.getenv("REGION", None) is None:
  os.environ["REGION"] = "eu-west-2"
else:
  REGION = os.getenv('REGION')


def process_arguments():
  """
  Parse and process program arguments
  :return: argument parser
  """
  parser = argparse.ArgumentParser()
  optional = parser._action_groups.pop()
  required = parser.add_argument_group('Required arguments')

  optional.add_argument('-i', '--interactive',
                        type=str2bool,
                        nargs='?',
                        default=True,
                        const=True,
                        required=False,
                        help='Interactive mode?')

  optional.add_argument('-t', '--tfaction',
                        required=False,
                        default='plan',
                        help='Terraform action (plan, apply, plan-destroy, or apply-destroy')

  optional.add_argument('-a', '--approve',
                        type=str2bool,
                        nargs='?',
                        const=True,
                        default=False,
                        required=False,
                        help='Auto approve?')

  optional.add_argument('-w', '--workspace',
                        default='',
                        required=False,
                        help='Env/Workspace')

  optional.add_argument('-m', '--modules',
                        default='',
                        required=False,
                        help='List of modules')

  optional.add_argument('-k', '--key',
                        required=False,
                        help='Token key')

  optional.add_argument('-b', '--branch',
                        required=False,
                        help='Merge request branch')

  optional.add_argument('-o', '--gitops',
                        default=False,
                        required=False,
                        help='Gitops adhoc yaml')

  optional.add_argument('-p', '--prereq',
                        default=False,
                        required=False,
                        help='Build pre-requisite base modules')

  optional.add_argument('-c', '--concurrent',
                        type=str2bool,
                        nargs='?',
                        default=False,
                        required=False,
                        help='Build modules using multi-threads?')


  parser._action_groups.append(optional)

  return parser.parse_args()


def parse_envs_file(envs_file):
  """
  The envs.tf file contains metadata that required to build an
  environment for a specific workspace
  :param envs_file:
  :return: list of workspaces and workspace data dict
  """
  with(open(envs_file, 'r')) as env_file:
    env_dict = hcl2.load(env_file)
  workspaces_dict = env_dict['variable'][0]['envs']['default']

  # setup the workspace/account to display and prompt user to select one to build
  workspaces = []
  for workspace in workspaces_dict:
    for key, val in workspace.items():
      workspaces.append(key + "|" + val['account_id'] + "|" + val ['account'])
  return workspaces, workspaces_dict


def get_gitlab_file_changes(token, branch):
  print("********** Comparing files changes on merge request branch [{}], with master branch ********* ".format(branch))
  # when a merge request is triggered we need to find out
  # what files were change with the merge request branch against
  # master branch and perform terraform plan on only affected modules
  gl = gitlab.Gitlab('http://gitlab.com', private_token=token)
  gl.auth()
  project = gl.projects.get(INFRA_REPO_PROJECT_ID)
  result = project.repository_compare('main', branch)
  print("List of files changed in this merge requests:")
  print("*********************************************")
  print("\n".join([x['old_path'] for x in result['diffs']]))
  print("*********************************************")

  file_changes = []
  for file_diff in result['diffs']:
    old_path = file_diff['old_path']
    renamed_file = file_diff['renamed_file']
    deleted_file = file_diff['deleted_file']
    # ignore some web servers modules which are not yet enabled
    if str2bool(renamed_file) or str2bool(deleted_file) \
        or "/lambda_artefacts/" in old_path \
        or "/serverless/" in old_path \
        or "/databases/" in old_path \
        or "/eks/" in old_path \
        or "/iam/" in old_path \
        or "/variables/config/" in old_path \
        or "/ecr-repositories/" in old_path \
        or "/tools/" in old_path \
        or "/email-setup/" in old_path \
        or "/vpc-endpoint-service/" in old_path:
      continue
    if old_path not in EXCLUDE_DIRS:
      if is_empty(os.path.splitext(old_path)[1]):
        # No file extension found - means it a new directory change - so ignore
        continue
      if old_path.startswith('terraform/'):
        if old_path.count('/') > 3:
          tf_file_path = old_path.replace('terraform/', './').replace('/templates','').replace('/user_data', '')
          main_full_path = tf_file_path.replace('/modules/', '/main/')
          main_path = main_full_path.rsplit('/', 1)[0]
          file_changes.append(main_path.replace('terraform/', './'))

  # remove dups and return as list
  file_set = set(file_changes)

  # Remove any records which do not exists in the 'main' directory
  # like './main/storage/s3-log-storage' for instance
  file_set = [n for n in list(file_set) if os.path.isdir(n) ]

  print("************ Terraform Main Modules changes ************\n".format(file_set))
  return file_set


def setup_build_data(build_workspace, args, mod, workspaces_dict, gitops=False, gitops_action=None):

  build_env = workspaces_dict[0][build_workspace]

  if not str2bool(args.interactive):
    # auto-approve set to True in non-interactive mode
    auto_approve = True
  else:
    auto_approve = args.approve

  if gitops and gitops_action is not None:
    tfaction = gitops_action
  else:
    tfaction = args.tfaction

  build_data = {
    "workspace": build_workspace,
    "modules": mod,
    "auto_approve": auto_approve,
    "interactive": args.interactive,
    "tfaction": tfaction,
    "environment": build_env,
    "bucket_region": workspaces_dict[0][build_workspace]["bucket_region"],
    "bucket": workspaces_dict[0][build_workspace]["bucket"],
    "dynamodb": workspaces_dict[0][build_workspace]["dynamodb"],
    "multi_thread": args.concurrent
  }

  return build_data


def get_gitops_data():
    src = YAML(typ='safe')
    with open(GITOPS_YAML_FILE) as f:
        gitops_data = src.load(f)
    return gitops_data


def main():

  args = process_arguments()
  modules_to_plan = []
  build_data = {}
  print (f"Parameters passed to orchestrators:---> tfaction: {args.tfaction}, gitops: {args.gitops}, branch {args.branch}, modules: {args.modules}, pre-req: {args.prereq}, concurrent: {args.concurrent}")

  if str2bool(args.interactive):
    print ("running in interactive mode")
    # Not being build by CI/CD tool
    workspaces, workspaces_dict = parse_envs_file(INPUT_ENVS_FILE)

    # prompt user to select an account to build
    account_sel = prompt_account(workspaces)
    if account_sel is None:
      print("User abort exiting...")
      exit (1)

    # prompt user to select module(s) to build
    build_modules = prompt_modules(find_modules(MODULE_DIRS))
    if build_modules is None:
      print("User abort exiting...")
      exit (1)

    # prompt user to choose terraform action
    tfaction = prompt_tfaction(TF_ACTIONS)
    if tfaction is None:
      print("User abort exiting...")
      exit (1)

    args.tfaction = tfaction


    # setup build data for tfrun.py
    build_workspace = account_sel.split('|')[0]

    if build_workspace != "sre":
        for module in MODULES_FOR_SRE_ONLY:
            if module in build_modules:
                print(f"This module is build in SRE account only: {module}")
                build_modules.remove(module)

    # only run ses-setup in these workspaces below
    if build_workspace != "sre":
        for module in EMAIL_SETUP_ONLY:
            if module in build_modules:
                print(f"Email setup module is build in SRE only: {module}")
                build_modules.remove(module)

    if len(build_modules) > 0:
        print("\n******* Modules to run:  *********")
        print("\n".join([m for m in build_modules]))
        print("**********************************")
        build_data = setup_build_data(build_workspace, args, build_modules, workspaces_dict)
        tfrun(build_data)


  elif not str2bool(args.interactive):
    # Run from gitlab-ci.yaml script
    print ("running in CI/CD mode")

    if args.tfaction == "gitops" and args.gitops:
        print("Running in gitops mode...")
        gitops_data = get_gitops_data()
        print("modules to run in gitops mode... {}".format(gitops_data["modules"]))

    if not is_empty(args.branch) and not is_empty(args.key) and is_empty(args.modules):
      # Triggered by Merge Request action
      # get file changes in gitlab in these format for TF successful run:
      # ./main/serverless/lambda-send-alb-logs-to-cloudwatch
      # etc,
      print("Trigger by MR...")
      modules_to_plan = get_gitlab_file_changes (args.key, args.branch)

    # workout correct modules to build...
    if is_empty(args.branch) and is_empty(args.key) and is_empty(args.modules) and not args.gitops and args.prereq:
      print("Running pre-requite modules...")
      modules_to_plan = PREREQUISITE_MODULES
    elif args.tfaction == "gitops" and args.gitops:
      print("Running Gitops modules...")
      modules_to_plan = gitops_data["modules"]

    _, workspaces_dict = parse_envs_file(INPUT_ENVS_FILE)

    if args.tfaction == "gitops" and args.gitops:
      # in gitops.yaml we specified which env to build
      build_ws = gitops_data["workspace"]
    else:
      build_ws = args.workspace


    if is_empty(build_ws):
      # use tf default _env.tf workspace if not supplied
      build_ws = BUILD_WORKSPACES

    if build_ws != "sre":
        for module in MODULES_FOR_SRE_ONLY:
            if module in modules_to_plan:
                modules_to_plan.remove(module)

    # only run ses-setup in these workspaces below
    if build_ws != "sre":
        for module in EMAIL_SETUP_ONLY:
            if module in modules_to_plan:
                print(f"Email setup module is build in SRE only: {module}")
                modules_to_plan.remove(module)

    if args.tfaction == "gitops" and args.gitops == 'True' and modules_to_plan is not None:
        if "./main/containers/ecr-repositories" in modules_to_plan and build_ws not in ["sre"]:
            print("Error: module ecr-repositories can only support in sre and sre-ci environments")
            exit (1)

    if args.tfaction == "gitops" and args.gitops == 'True':
        if modules_to_plan is not None:
            build_data = setup_build_data(build_ws, args, modules_to_plan, workspaces_dict, True, gitops_data["tf_action"])
    else:
        build_data = setup_build_data(build_ws, args, modules_to_plan, workspaces_dict)

    if modules_to_plan is not None:
        if len(modules_to_plan) > 0:
            print("\n******* Modules to run:  *********")
            print("\n".join([m for m in modules_to_plan]))
            print("**********************************")

    if len(build_data) > 0 and modules_to_plan is not None:
        tfrun(build_data)

  else:
    print("Unkown parameter {}".format(args.interactive))


if __name__ == '__main__':
  main()
