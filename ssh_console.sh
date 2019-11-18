#!/bin/bash

host=${1}

# printf "%s" "waiting for ${host} ..."
# while ! ping -c 1 -n -w 1 ${host} &> /dev/null
# do
#     printf "%c" "."
# done

ssh ${host} -p 8022
