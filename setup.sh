#!/bin/bash

if [ $# -eq 1 ] && [ $1 = "install" -o $1 = "--install" ];then
  echo ./install_runtime.sh
  ./install_runtime.sh
  if [ $? -ne 0 ]; then
    echo failed to install runtime
    exit 1
  fi
  echo
fi

echo "Input your GameHint User ID"
read -p "User ID: " id
echo
echo "Authorize GameHint to access your Twitter account"
read -p "Twitter Username or email: " user
read -sp "Twitter Password: " pass
tty -s && echo

USER_DATA_DIR=user_data
rm -r $USER_DATA_DIR
mkdir $USER_DATA_DIR
echo -e "$id\n$user\n$pass" > ${USER_DATA_DIR}/.account
echo
echo "Authenticating..."

tmpfile="tmp_stdout"
python update_cookie.a > $tmpfile 2>&1
res=`cat $tmpfile | grep "login succeeded"`

if [ -n "$res" ]; then
  echo "Setup succeeded!"
  rm $tmpfile
else
  cat $tmpfile
  rm $tmpfile
  echo "The username or password you entered is invalid."
  echo "run ./setup.sh again"
fi

