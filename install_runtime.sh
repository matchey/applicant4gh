#!/bin/bash

trap 'echo "trap SIGINT"; exit' SIGINT

rtn=0

echo apt install python
sudo apt install -y python
if [ $? -ne 0 ]; then
  echo failed to install python
  ((rtn+=1))
fi

echo apt install pip
sudo add-apt-repository universe
sudo apt update
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
# sudo apt install -y pip
rm get-pip.py
if [ $? -ne 0 ]; then
  echo failed to install pip
  ((rtn+=1))
fi

# check google chrom  version
# google_dir="/mnt/c/Program Files/Google/Chrome/Application/"
google_dir="/mnt/c/Program Files/Google/Chrome/Application/use_bin"
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
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y ./google-chrome-stable_current_amd64.deb
  rm ./google-chrome-stable_current_amd64.deb
  ver=(`google-chrome --version`)
  for ver in "${ver[@]}"; do : ; done
fi

echo pip install chromedriver-binary==${ver}
pip install chromedriver-binary==${ver} 2> tmp_stderr
if [ $? -ne 0 ]; then
  ver_ex=`cat tmp_stderr | grep "from versions" | sed -e "s/from versions:/${ver},/" | cut -d"(" -f2 | cut -d")" -f1 | sed -e 's/, /\n/g' | sort -V | grep ${ver} -B 1 | head -1`
  if [ -n $ver_ex ]; then
    pip install chromedriver-binary==${ver_ex}
  fi
fi
if [ $? -ne 0 ]; then
  echo failed to install chromedriver
  ((rtn+=1))
fi
rm tmp_stderr

echo pip install selenium
pip install selenium
if [ $? -ne 0 ]; then
  echo failed to install selenium
  ((rtn+=1))
fi

if [ $rtn -ne 0 ]; then
  echo failed to install $rtn pkg
  exit 1
fi

echo installed successfully

