#!/usr/bin/env bash

NS=${3:-che}
CUR_USER=`oc whoami`
oc project $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_CONSUMERKEY\": \"K80AZGGgFmkjVNiGZ3vL4NDf\"}}}}" --type=merge -n $NS
PRIVATE_KEY=$(cat ./certs/privatepkcs8.pem | sed 's/-----BEGIN PRIVATE KEY-----//g' |  sed 's/----END PRIVATE KEY-----//g' | tr -d '\n')
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_PRIVATEKEY\": \"$PRIVATE_KEY\"}}}}" --type=merge -n $NS
BITBUCKET_HOST=$(oc get routes -n bitbucket -o json | jq -r '.items[0].spec.host')
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_ENDPOINT\": \"https://$BITBUCKET_HOST\"}}}}" --type=merge -n $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_BITBUCKET_SERVER_ENDPOINTS\": \"https://$BITBUCKET_HOST\"}}}}" --type=merge -n $NS
