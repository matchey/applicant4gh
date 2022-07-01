#!/bin/bash

crontab -r
if [ $? -eq 0 ]; then
  echo script canceled
fi
