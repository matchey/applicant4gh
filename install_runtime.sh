#!/bin/bash

trap 'echo "trap SIGINT"; exit' SIGINT

rtn=0

echo sudo apt install pip
sudo apt install pip
if [ $? -ne 0 ]; then
  echo failed to install pip
  ((rtn+=1))
fi

# check google chrom  version
google_dir="/mnt/c/Program Files/Google/Chrome/Application/"
if [ -e "${google_dir}" ]; then
  res=`find "${google_dir}" -name *.manifest 2>/dev/null`
  if [ $? -ne 0 ]; then
    echo "unmet env"
  ((rtn+=1))
  elif [ -z "$res" ]; then
    echo "unmet env"
    echo "install google chrome"
  ((rtn+=1))
  else
    ver=`basename "${res}"`
    ver=${ver%.manifest}
  fi
elif [ `which google-chrome` != "" ]; then
  ver=(`google-chrome --version`)
  for ver in "${ver[@]}"; do : ; done
else
  echo "install google chrome"
  ((rtn+=1))
fi

echo pip install chromedriver-binary==${ver}
pip install chromedriver-binary==${ver}
if [ $? -ne 0 ]; then
  echo failed to install chromedriver
  ((rtn+=1))
fi

echo pip install selenium
pip install selenium
if [ $? -ne 0 ]; then
  echo failed to install selenium
  ((rtn+=1))
fi

echo pip install pickle
pip install pickle
if [ $? -ne 0 ]; then
  echo failed to install pickle
  ((rtn+=1))
fi

if [ $rtn -ne 0 ]; then
  echo failed to install $rtn pkg
  exit 1
fi

