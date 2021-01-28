#!/usr/bin/env bash
rm -rf ./certs
mkdir certs
openssl genrsa -out ./certs/private.pem 2048
openssl rsa -in ./certs/private.pem -pubout > ./certs/public.pub
openssl pkcs8 -topk8 -inform pem -outform pem -nocrypt -in ./certs/private.pem -out ./certs/privatepkcs8.pem 
openssl rand -base64 24 > ./certs/bitbucket_server_consumer_key
openssl rand -base64 24 > ./certs/bitbucket_shared_secret
