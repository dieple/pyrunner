#!/usr/bin/env python3

# Orchestrator build script for all environments - to be called by Gitlab or can be used interactively
import argparse
import sys
import os
import inspect
import hcl2

from ruamel.yaml import YAML

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

DEPLOY_YAML_FILE     = "./deploy.yaml"
INPUT_ENVS_FILE      = "./variables/_envs.tf"
TF_ACTIONS           = ["plan", "apply", "plan-destroy", "apply-destroy"]
MODULE_DIRS          = ["main"]
MODULES_FOR_SRE_ONLY = ["./main/containers/ecr-repositories"]
EMAIL_SETUP_ONLY     = ["./main/management/email-setup"]

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

  optional.add_argument('-d', '--deploy',
                        type=str2bool,
                        nargs='?',
                        default=False,
                        const=False,
                        required=False,
                        help='Deploy mode using deploy.yaml file')

  optional.add_argument('-t', '--tfaction',
                        required=False,
                        default='',
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


def setup_build_data(build_workspace, args, mod, workspaces_dict, deploy=False, deploy_action=None):

  build_env = workspaces_dict[0][build_workspace]

  if not str2bool(args.deploy):
    # auto-approve set to True in non-interactive mode
    auto_approve = True
  else:
    auto_approve = args.approve

  if deploy and deploy_action is not None:
    tfaction = deploy_action
  else:
    tfaction = args.tfaction

  build_data = {
    "workspace": build_workspace,
    "modules": mod,
    "auto_approve": auto_approve,
    "deploy": args.deploy,
    "tfaction": tfaction,
    "environment": build_env,
    "bucket_region": workspaces_dict[0][build_workspace]["bucket_region"],
    "bucket": workspaces_dict[0][build_workspace]["bucket"],
    "dynamodb": workspaces_dict[0][build_workspace]["dynamodb"],
    "multi_thread": args.concurrent
  }

  return build_data


def get_deploy_data():
  src = YAML(typ='safe')
  with open(DEPLOY_YAML_FILE) as f:
    deploy_data = src.load(f)
  return deploy_data


def main():

  args = process_arguments()
  modules_to_plan = []
  build_data = {}
  print (f"Parameters passed to orchestrators:---> tfaction: {args.tfaction}, deploy: {args.deploy}, branch {args.branch}, modules: {args.modules}, pre-req: {args.prereq}, concurrent: {args.concurrent}")

  if not str2bool(args.deploy):
    print ("running in interactive mode")
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

  else:
    # running in non interactive mode using deploy.yaml file

    if is_empty(args.tfaction) or is_empty(args.workspace):
      print ("Arguments ERROR: both TF action and workspace are required in using deploy.yaml")
      exit(1)

    deploy_data = get_deploy_data()
    build_modules = deploy_data["workspace"][0][args.workspace]['modules']
    _, workspaces_dict = parse_envs_file(INPUT_ENVS_FILE)

    if args.workspace != "sre":
      for module in MODULES_FOR_SRE_ONLY:
        if module in build_modules:
          build_modules.remove(module)

    # only run ses-setup in these workspaces below
    if args.workspace != "sre":
      for module in EMAIL_SETUP_ONLY:
        if module in build_modules:
          print(f"Email setup module is build in SRE only: {module}")
          build_modules.remove(module)

    build_data = setup_build_data(args.workspace, args, build_modules, workspaces_dict, True, args.tfaction)

    if len(build_modules) > 0:
      print("\n******* Modules to run:  *********")
      print("\n".join([m for m in build_modules]))
      print("**********************************")
      tfrun(build_data)


if __name__ == '__main__':
  main()
