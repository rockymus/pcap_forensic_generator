#! /bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
echo 'Welcome to automated generator of assignments for digital forensics analysis!'
echo 'Choose from the options below:'
echo '1) Brute-force attack'
echo '2) ThinkPHP - Multiple PHP injection RCEs'
echo '3) SQL Injection'

read -p "Enter attack type: " ATTACK_TYPE

case $ATTACK_TYPE in
    1)
        cd docker_wordpress
        ./script.sh
        ;;
    2)
        cd docker_php
        ./script.sh
        ;;
    3)
        cd docker_sqlinjection
        ./script.sh
        ;;
    *)
        echo Unknown
esac

