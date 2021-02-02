#!/usr/bin/env bash 
NS=${3:-che}
CUR_USER=`oc whoami`
oc project $NS
CHE_ROUTE=$(oc get route/che --namespace=$NS -o=jsonpath={'.spec.host'})
BITBUCKET_ROUTE=$(oc get route/bitbucket --namespace=bitbucket -o=jsonpath={'.spec.host'})
CHE_SERVER_URL='https://'${CHE_ROUTE}
BITBUCKET_URL='https://'${BITBUCKET_ROUTE}
PUB_KEY=$(cat ./certs/public.pub | sed 's/-----BEGIN PUBLIC KEY-----//g' |  sed 's/-----END PUBLIC KEY-----//g' | tr -d '\n')
CONSUMER_KEY=$(cat ./certs/bitbucket_server_consumer_key)
SHARED_SECRET=$(cat ./certs/bitbucket_shared_secret)
echo '     '
echo '     '
echo ' Open '$BITBUCKET_URL
echo '     '
echo '     '
echo ' Go to Administration -> Application Links'
echo ' Enter ->>  '$CHE_SERVER_URL'/dashboard/ in the 'application url' field and press the 'Create new link' button and `Continue`.'
echo ' After that in `Link applications` window'
echo ' Application Name:      Che'
echo ' Application Type:      Generic Application'
echo ' Service Provider Name: Che'
echo ' Consumer key:          '$CONSUMER_KEY
echo ' Shared secret:         '$SHARED_SECRET
echo ' Request Token URL:     '$BITBUCKET_URL'/plugins/servlet/oauth/request-token'
echo ' Access token URL:      '$BITBUCKET_URL'/plugins/servlet/oauth/access-token'
echo ' Authorize URL:         '$BITBUCKET_URL'/plugins/servlet/oauth/authorize'
echo ' Create incoming link:  true'
echo '    '
echo ' Next screen   '
echo '    '
echo ' Consumer Key:          '$CONSUMER_KEY
echo ' Consumer Name:         Che'
echo ' Public Key :           '$PUB_KEY

