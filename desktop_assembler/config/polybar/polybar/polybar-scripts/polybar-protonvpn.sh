#!/bin/bash

connection_status=$(protonvpn s | grep Status | awk '{print $NF}')

if [ "$connection_status" = 'Connected' ]
then
  server=$(protonvpn s | grep Server | awk '{print $NF}')
  echo "旅 $server"
else
  echo "轢"
fi

