#!/usr/bin/env bash

NS=${3:-che}
CUR_USER=`oc whoami`
CONSUMER_KEY=$(cat ./certs/bitbucket_server_consumer_key)
SHARED_SECRET=$(cat ./certs/bitbucket_shared_secret)
PRIVATE_KEY=$(cat ./certs/privatepkcs8.pem | sed 's/-----BEGIN PRIVATE KEY-----//g' |  sed 's/----END PRIVATE KEY-----//g' | tr -d '\n')
BITBUCKET_HOST=$(oc get routes -n bitbucket -o json | jq -r '.items[0].spec.host')
unameOut="$(uname -s)"

case "${unameOut}" in
    Linux*)     BASE64_FUNC='base64 -w 0';;
    Darwin*)    BASE64_FUNC='base64';;
    CYGWIN*)    BASE64_FUNC='base64 -w 0';;
    MINGW*)     BASE64_FUNC='base64 -w 0';;
    *)          BASE64_FUNC='base64 -w 0'
esac

oc project $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_CONSUMERKEYPATH\": \"/home/user/eclipse-che/conf/oauth1/bitbucket/consumer.key\"}}}}" --type=merge -n $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_PRIVATEKEYPATH\": \"/home/user/eclipse-che/conf/oauth1/bitbucket/private.key\"}}}}" --type=merge -n $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_SHAREDSECRETPATH\": \"/home/user/eclipse-che/conf/oauth1/bitbucket/shared_secret\"}}}}" --type=merge -n $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_ENDPOINT\": \"https://$BITBUCKET_HOST\"}}}}" --type=merge -n $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_INTEGRATION_BITBUCKET_SERVER__ENDPOINTS\": \"https://$BITBUCKET_HOST\"}}}}" --type=merge -n $NS
oc delete secret bitbucket-oauth1-config --ignore-not-found=false

cat <<EOF | oc apply -n $NS -f -
apiVersion: v1
kind: Secret
metadata:
  name: bitbucket-oauth1-config
  labels:
    app.kubernetes.io/part-of: che.eclipse.org
    app.kubernetes.io/component: che-secret
  annotations:
    che.eclipse.org/mount-path: /home/user/eclipse-che/conf/oauth1/bitbucket
    che.eclipse.org/mount-as: file
type: Opaque
data:
  private.key: $(echo -n $PRIVATE_KEY | $BASE64_FUNC) 
  consumer.key: $(echo -n $CONSUMER_KEY | $BASE64_FUNC) 
  shared_secret: $(echo -n $SHARED_SECRET | $BASE64_FUNC) 
EOF
