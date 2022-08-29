#!/bin/bash

# star crond (not automatically activated in wsl)
sudo service cron start

echo "Enter URL to apply."
read -p "URL: " url
tty -s && echo
echo "Checking URL..."

tmpfile="tmp_stdout"

python update_cookie.a > $tmpfile 2>&1
res=`cat $tmpfile | grep "login succeeded"`

if [ -z "$res" ]; then
  echo "The username or password is invalid."
  echo "run ./setup.sh again"
  exit
fi

PYTHONIOENCODING=utf-8 python check_url.a $url > $tmpfile 2>&1
res=`cat $tmpfile | grep "URL is valid"`

if [ -z "$res" ]; then
  echo "The URL you entered is invalid."
  echo "Enter the URL of the Gamehint event that not open for applicant."
  rm $tmpfile
  exit
fi

res=`cat $tmpfile | grep "Title: "`
title=${res#"Title: "}
res=`cat $tmpfile | grep "Date: "`
date=${res#"Date: "}
date=${date%" "}
rm $tmpfile

echo Apply for $title at $date
scheduled=`date -d "${date} 1 minute ago" +'%M %H %-d %-m'`
cwd=`pwd`
echo "${scheduled} * cd ${cwd}; PYTHONIOENCODING=utf-8 python applicant.a ${url} >> /tmp/cron.log 2>&1" > cron_applicant.conf
crontab cron_applicant.conf

start_s=`date +%s -d "${date}"`
now=`date +%s`
dt=$((start_s - now))
((sec=dt%60, min=(dt%3600)/60, hrs=dt/3600))
if [ $hrs -gt 23 ]; then
  diff=$(printf "%d days" $((hrs / 24)))
else
  diff=$(printf "%d:%02d:%02d" $hrs $min $sec)
fi
echo The script will automatically run in the background after ${diff}.

