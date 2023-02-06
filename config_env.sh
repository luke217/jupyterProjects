#! /bin/bash
set -e

if [ -z "$1" ]; then
  # print out current projects list
  echo "You have following projects:"
  ls -d */ | grep -v logs | grep -v packages-template
  # ask for project name
  idx=0
  while [ -z "$project_name" ] && [ "$idx" -lt 3 ]; do
    read -p "Please give a name for your project: " project_name
    idx=`expr $idx + 1`
  done
  if [ -z "$project_name" ]; then
    echo "Program exits."
    exit 1
  fi
else
  project_name=$1
fi
if [ -d "$project_name" ]; then
  echo "Project $project_name already exists."
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate $project_name
  cd $project_name
else
  # check python ver
  idx=0
  while [ "$idx" -lt 3 ]; do
    read -p "What is your python version?[3.9]: " py_ver
    if [ -z "$py_ver" ]; then
      py_ver=3.9
    fi
    if [[ "$py_ver" =~ ^3.([7-9]|10)$ ]]; then
      is_valid_ver=1
      break
    else
      echo "Only support version between 3.7 and 3.10, try again"
      idx=`expr $idx + 1`
    fi
  done
  if [ -z "$is_valid_ver" ]; then
    echo "Program exits."
    exit 1
  fi
  # print out packages-template
  echo "You have the following packages-template:"
  ls packages-template
  # check package template
  idx=0
  while [ "$idx" -lt 3 ]; do
    read -p "What packages-template would you like to install?[base]: " pkgs
    if [ -z "$pkgs" ]; then
      pkgs=base
    fi
    if [ -e "packages-template/${pkgs}.txt" ]; then
      is_valid_pkg=1
      break
    else
      echo "Only support packages-template listed in the folder, try again"
      idx=`expr $idx + 1`
    fi
  done
  if [ -z "$is_valid_pkg" ]; then
    echo "Program exits."
    exit 1
  fi
  echo "Conda creating environment..."
  if (( $(echo "$py_ver != 3.10" |bc -l) )); then
    conda create --name $project_name anaconda python=$py_ver
  else 
    conda create --name $project_name python=$py_ver
  fi
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate $project_name
  echo "Start installing packages..."
  pip install -r packages-template/${pkgs}.txt
  echo "Package installation completed."
  mkdir $project_name && cd $project_name
  echo "Enable notebook extentions..."
  jupyter nbextension enable --py widgetsnbextension
  # ipython kernel install --user --name=$project_name
  # To remove a conda environment from Jupyter Lab, you can run the below command:
  # jupyter kernelspec uninstall $project_name
fi
JUPYTERLAB_SHELL_ENV=$project_name jupyter-lab --no-browser

