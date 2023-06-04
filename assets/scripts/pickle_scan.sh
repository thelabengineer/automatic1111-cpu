#!/bin/bash

for file in *.ckpt; do
    echo "----------------------" ;
    echo "> ${file}";
    picklescan -g -p "${file}"; 
done | grep -e suspicious -e nfected -e angerous | sort -u