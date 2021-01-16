#!/usr/bin/env bash

NS=${3:-che}
CUR_USER=`oc whoami`
CONSUMER_KEY=$(cat ./certs/bitbucket_server_consumer_key)
oc project $NS
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_CONSUMERKEYPATH\": \"/home/user/eclipse-che/conf/oauth1/bitbucket/consumer.key\"}}}}" --type=merge -n $NS
PRIVATE_KEY=$(cat ./certs/privatepkcs8.pem | sed 's/-----BEGIN PRIVATE KEY-----//g' |  sed 's/----END PRIVATE KEY-----//g' | tr -d '\n')
oc patch checluster/eclipse-che --patch "{\"spec\":{\"server\":{\"customCheProperties\": {\"CHE_OAUTH1_BITBUCKET_PRIVATEKEYPATH\": \"/home/user/eclipse-che/conf/oauth1/bitbucket/private.key\"}}}}" --type=merge -n $NS
BITBUCKET_HOST=$(oc get routes -n bitbucket -o json | jq -r '.items[0].spec.host')
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
  private.key: $(echo -n $PRIVATE_KEY | base64) 
  consumer.key: $(echo -n $CONSUMER_KEY | base64) 
EOF
