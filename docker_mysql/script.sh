#! /bin/bash

FILE_USERS='data/users.csv'
FILE_PASS='data/passwords.csv'
read -p "Enter number of packets: " PACK_NUMBER

docker network create --driver bridge --subnet 172.30.0.0/16 -o "com.docker.network.bridge.name"=br_mysql_int mysql_network
for ((i = 1; i <= PACK_NUMBER; i++))
do
    user=$(shuf -n 1 $FILE_USERS)
    password=$(shuf -n 1 $FILE_PASS)
    docker run --name mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_USER=$user -e MYSQL_PASSWORD=$password --net mysql_network --ip=172.30.0.2 -d  mysql:5   
    sleep 5
    tcpdump -i br_mysql_int -w ${i}.pcap & 
    docker run -i --name metasploit --net mysql_network --ip=172.30.0.3 -v $PWD/data:/usr/src/metasploit-framework/passwords metasploitframework/metasploit-framework <<EOF
use auxiliary/scanner/mysql/mysql_log
set RHOSTS 172.30.0.2
set PASS_FILE passwords/passwords.csv
set USERNAME $user
run
EOF

    pid=$(ps -e | pgrep tcpdump)
    sleep 4
    kill -2 $pid
    ./remove_all.sh
done
docker network rm mysql_network