# Note

## Pre-requisite
install conda --> https://docs.conda.io/en/latest/miniconda.html#linux-installers


## Setup virtual environment for terraform:
The following steps are required to activate the virtual environment for running terraform using the `tfplan.py` script

```bash
# Make sure conda is activated and can invoke successfully!
# source /home/teo/miniconda3/etc/profile.d/conda.sh
$ source /opt/conda/etc/profile.d/conda.sh && conda --version

# Create the python3.8 virtual env using conda
# TODO: fix tfplan to work with python3.9
$ conda create --name py38 python=3.8

# To list the virtual environments setup on your laptop...
$ conda info --envs
# conda environments:
#
goenv                    /home/sre/.conda/envs/goenv
py38                     /home/sre/.conda/envs/py38
rustenv                  /home/sre/.conda/envs/rustenv
base                  *  /opt/conda

# activate the above (py38) environment
$ conda activate py38

# install required python packages for running `tfplan.py`
$ python -m pip install -r requirements.txt

# When done Deactivate the environment
$ conda deactivate


# To export the env and share it with other developers
$ `conda env export > tf_py38_env.yml`


# Conda cheatsheet --> https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf

```
