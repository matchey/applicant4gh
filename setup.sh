#!/bin/bash

if [ $# -eq 1 ] && [ $1 = "install" -o $1 = "--install" ];then
  echo ./install_runtime.sh
  ./install_runtime.sh
  echo
fi

echo "Input your GameHint User ID"
read -p "User ID: " id
echo
echo "Authorize GameHint to access your Twitter account"
read -p "Twitter Username or email: " user
read -sp "Twitter Password: " pass
tty -s && echo

mkdir -p user_data
echo -e "$id\n$user\n$pass" > user_data/.account
echo
echo "Authenticating..."

tmpfile="tmp_stdout"
PYTHONIOENCODING=utf-8 python update_cookie.py > $tmpfile 2>&1
res=`cat $tmpfile | grep "login succeeded"`

if [ -n "$res" ]; then
  rm $tmpfile
  echo "Setup succeeded!"
else
  cat $tmpfile
  rm $tmpfile
  echo "The username or password you entered is invalid."
  echo "run ./setup.sh again"
fi

