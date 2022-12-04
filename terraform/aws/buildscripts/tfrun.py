import os
import subprocess

from .tfprompts import *
from .tfutils import *

import concurrent.futures

LINK_FILES_LIST = [
  "_accounts.tf",
  "_backend.tf",
  "_envs.tf",
  "_providers.tf"
]

def tfrun(build_data):
  """
  Using python-terraform package we can invoke terraform statements
  such as terraform init, plan, apply etc. in python code
  :param build_data:
  :return:
  """
  if build_data["multi_thread"]:
    # if running inside a docker container make sure it's provision with 4GB to run all 10 threads successfully
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
      future_to_run_module = {executor.submit(run_module, m, build_data): m for m in build_data["modules"]}
      for future in concurrent.futures.as_completed(future_to_run_module):
        mod = future_to_run_module[future]
        try:
          _data = future.result()
        except Exception as exc:
          print(f"{mod} generated an exception: {exc}")
  else:
    # loop through each selected module(s) and apply the action as specified by user
    for m in build_data["modules"]:
      print("\n\n****************************************************************************")
      print("Permforming action \"{0}\" for module {1}".format(build_data["tfaction"], m))
      print("****************************************************************************\n\n")
      run_module(m, build_data)


def softlinking_files(module_path):
  curr_path = os.getcwd()
  rel_path = os.path.relpath(f"{curr_path}/variables", f"{curr_path}/{module_path}")
  for f in LINK_FILES_LIST:
    file_path = f"{curr_path}/{module_path}/{f}"
    rm_ln_cmd = f"cd \"{curr_path}/{module_path}\" && rm {f}"
    if os.path.exists(file_path) and os.path.islink(file_path):
      print(f"removing old linking file {f}...")
      process1 = subprocess.run(rm_ln_cmd, shell=True, check=False, stdout=subprocess.PIPE)
      output1 = process1.stdout
    print(f"linking file {f}...")
    ln_cmd = f"cd \"{curr_path}/{module_path}\" && ln -s \"{rel_path}/{f}\" ."
    process2 = subprocess.run(ln_cmd, shell=True, check=True, stdout=subprocess.PIPE)
    output2 = process2.stdout


def run_module(module_path, build_data):
  """
  Loop through list of selected module(s) and build based on the selected account
  :return:
  """

  curr_path = os.getcwd()
  mod1 = (module_path.split('/')[-1])
  module_name = mod1.split('.')[0]
  mod_path = module_path.replace('./', '')
  workspace = build_data["workspace"]

  key_config = "\"key={0}/terraform.tfstate\"".format(module_name)
  bucket_region_config = "\"region={0}\"".format(build_data["bucket_region"])
  bucket_config = "\"bucket={0}\"".format(build_data["bucket"])
  dynamodb_config = "\"dynamodb_table={0}\"".format(build_data["dynamodb"])

  plan_output_file = "plan.out"
  backend_override = f"{curr_path}/variables/config/backend_override.tf"
  providers_override = f"{curr_path}/variables/config/providers_override.tf"

  softlinking_files(mod_path)

  remove_prev_run = f"cd {module_path} && rm -f {plan_output_file} && rm -rf .terraform"
  cp_override_cmd = f"cd {module_path} && cp \"{backend_override}\" . && cp \"{providers_override}\" ."


  tf_plan_cmd = f"cd {module_path} && \
    terraform workspace select {workspace} || \
    terraform workspace new {workspace} && \
    terraform plan -out {plan_output_file}"

  tf_plan_destroy_cmd = f"cd {module_path} && \
    terraform workspace select {workspace} || \
    terraform workspace new {workspace} && terraform plan -destroy \
    -out {plan_output_file}"

  tf_apply_cmd = f"cd {module_path} && \
    terraform workspace select {workspace} || \
    terraform workspace new {workspace} && \
    terraform apply {plan_output_file}"

  tf_init_cmd = f"cd {module_path} && \
    terraform init --backend-config={key_config} \
    --backend-config={bucket_region_config} \
    --backend-config={dynamodb_config} \
    --backend-config={bucket_config} && \
    terraform workspace new {workspace} || \
    terraform workspace select {workspace}"

  print(tf_init_cmd) # let's leave this in

  # exit immediately when errors
  status = os.system(remove_prev_run)
  if status != 0:
    print(f"{module_name}: Error aborting...")
    exit(1)

  status = os.system(cp_override_cmd)
  if status != 0:
    print(f"{module_name}: Error aborting...")
    exit(1)

  status = os.system(tf_init_cmd)
  if status != 0:
    print(f"{module_name}: Error aborting...")
    exit(1)

  if build_data["tfaction"] == 'plan':
    # always auto approve 'plan' action
    status = os.system(tf_plan_cmd)
    if status != 0:
      print(f"{module_name}: Error aborting...")
      exit(1)
  elif build_data["tfaction"] == 'plan-destroy':
    # always auto approve 'plan' action
    status = os.system(tf_plan_destroy_cmd)
    if status != 0:
      print(f"{module_name}: Error aborting...")
      exit(1)
  elif build_data["tfaction"] == 'apply':
    if str2bool(build_data["auto_approve"]):
      # auto-approve flag enabled so skip user confirmation
      status = os.system(tf_plan_cmd)
      if status != 0:
        print(f"{module_name}: Error aborting...")
        exit(1)
      status = os.system(tf_apply_cmd)
      if status != 0:
        print(f"{module_name}: Error aborting...")
        exit(1)
    else:
      status = os.system(tf_plan_cmd)
      if status != 0:
        print(f"{module_name}: Error aborting...")
        exit(1)
      # confirm with user first
      if user_confirmation("Sure you want to APPLY {0}".format(module_name)):
        status = os.system(tf_apply_cmd)
        if status != 0:
          print(f"{module_name}: Error aborting...")
          exit(1)
      else:
        print("User aborting...")
  elif build_data["tfaction"] == 'apply-destroy':
    if str2bool(build_data["auto_approve"]):
      status = os.system(tf_plan_destroy_cmd)
      if status != 0:
        print(f"{module_name}: Error aborting...")
        exit(1)
      status = os.system(tf_apply_cmd)
      if status != 0:
        print(f"{module_name}: Error aborting...")
        exit(1)
    else:
      # confirm with user first
      status = os.system(tf_plan_destroy_cmd)
      if status != 0:
        print(f"{module_name}: Error aborting...")
        exit(1)
      if user_confirmation("Sure you want to APPLY DESTROY {0}".format(module_name)):
        status = os.system(tf_apply_cmd)
        if status != 0:
          print(f"{module_name}: Error aborting...")
          exit(1)
      else:
        print("User aborting...")
  else:
    print("Error unknown action aborting...")
    exit(1)

  print(f"Module {module_name} ran successfully...")
