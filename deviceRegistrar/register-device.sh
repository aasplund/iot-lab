#!/usr/bin/env bash

mkcdir ()
{
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

while getopts d:c:k:p: option
do
 case "${option}"
 in
 d) DEVICE_ID=${OPTARG};;
 p) POLICY=${OPTARG};;
 esac
done

mkcdir ${DEVICE_ID}

openssl genrsa -out ${DEVICE_ID}-private.pem.key 2048
openssl rsa -in ${DEVICE_ID}-private.pem.key -pubout > ${DEVICE_ID}-public.pem.key
openssl req -new -key ${DEVICE_ID}-private.pem.key -out ${DEVICE_ID}.csr -subj "/C=SE/L=Gothenburg/O=Gunnebo/CN=${DEVICE_ID}"
openssl x509 -req -in ${DEVICE_ID}.csr -CA ../certs/gunneboCACertificate.pem -CAkey ../certs/gunneboCACertificate.key -CAserial ../certs/.srl -out ${DEVICE_ID}-certificate.pem.crt -days 365 -sha256

certificate_arn=`aws iot register-certificate --certificate-pem file://${DEVICE_ID}-certificate.pem.crt --ca-certificate-pem file://../certs/gunneboCACertificate.pem --set-as-active | python -c "import sys, json; print json.load(sys.stdin)['certificateArn']"`
aws iot create-thing --thing-name ${DEVICE_ID}

aws iot attach-thing-principal --thing-name ${DEVICE_ID} --principal ${certificate_arn}
aws iot attach-principal-policy --policy-name ${POLICY} --principal  ${certificate_arn}

rm -rf ${DEVICE_ID}.csr

cd ..
