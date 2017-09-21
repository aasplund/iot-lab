#!/usr/bin/env bash

mkcdir ()
{
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

while getopts d:c:k: option
do
 case "${option}"
 in
 d) DEVICE=${OPTARG};;
 c) CERT=${OPTARG};;
 k) KEY=${OPTARG};;
 esac
done

mkcdir ${DEVICE}

openssl genrsa -out ${DEVICE}.key 2048
openssl req -new -key ${DEVICE}.key -out ${DEVICE}.csr -subj "/C=SE/L=Gothenburg/O=Gunnebo/CN=${DEVICE}"
openssl x509 -req -in ${DEVICE}.csr -CA ../${CERT} -CAkey ../${KEY} -CAcreateserial -out ${DEVICE}.crt -days 365 -sha256

cd ..