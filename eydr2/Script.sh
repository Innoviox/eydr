#!/bin/bash

if [ $# -ne 3 ]
then
        echo "Must take exactly four arguments: the name of the container, the ip address, and the network netmask prefix, and UP or DOWN"
        exit 1
fi

if [[ $4 == "UP" ]]
then
        echo $4
else
    echo $4
fi
