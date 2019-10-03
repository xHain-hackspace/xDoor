#!/bin/bash

host=${1}

printf "%s" "waiting for ${host} ..."
while ! ping -c 1 -n -w 1 ${host} -p 8022 &> /dev/null
do
    printf "%c" "."
done

ssh ${host}
