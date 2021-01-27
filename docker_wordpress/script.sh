#! /bin/bash

FILE='wordpress_users.csv'

#read -p "Enter your choice: " ATTACK
read -p "Enter number of packets: " PACK_NUMBER


docker-compose up -d
IP_ADDRESS=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' wordpress)

a=$(shuf -n $PACK_NUMBER $FILE)
index=0
for i in ${a}
do
    index=$((index+1))
    tcpdump -U -i br_wp_interface -w ${index}.pcap & 
    sleep 4
    USERNAME="$(echo $i | cut -d ',' -f1)"
    PASSWORD="$(echo $i | cut -d ',' -f3)"

    docker run -it --rm --net wpsite -v $PWD/wordlists:/wordlists wpscanteam/wpscan --url $IP_ADDRESS --passwords /wordlists/common_passwords.txt --usernames $USERNAME
    pid=$(ps -e | pgrep tcpdump)  
    sleep 3
    kill -2 $pid
done
docker-compose down