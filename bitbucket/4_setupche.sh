#!/usr/bin/env bash

NS=${1:-eclipse-che}
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
oc delete secret bitbucket-oauth-config --ignore-not-found=false

cat <<EOF | oc apply -n $NS -f -
kind: Secret
apiVersion: v1
metadata:
  name: bitbucket-oauth-config
  labels:
    app.kubernetes.io/part-of: che.eclipse.org
    app.kubernetes.io/component: oauth-scm-configuration
  annotations:
    che.eclipse.org/oauth-scm-server: bitbucket
    che.eclipse.org/scm-server-endpoint: https://$BITBUCKET_HOST
type: Opaque
data:
  private.key: $(echo -n $PRIVATE_KEY | $BASE64_FUNC) 
  consumer.key: $(echo -n $CONSUMER_KEY | $BASE64_FUNC) 
  shared_secret: $(echo -n $SHARED_SECRET | $BASE64_FUNC) 
EOF
