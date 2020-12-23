#!/usr/bin/env bash 
NS=${3:-che}
CUR_USER=`oc whoami`
oc project $NS
CHE_ROUTE=$(oc get route/che --namespace=$NS -o=jsonpath={'.spec.host'})
CHE_SERVER_URL='https://'${CHE_ROUTE}
PUB_KEY=$(cat ./certs/public.pub | sed 's/-----BEGIN PUBLIC KEY-----//g' |  sed 's/-----END PUBLIC KEY-----//g' | tr -d '\n')

echo ' Go to Administration -> Application Links'
echo ' Enter ->>  '$CHE_SERVER_URL'/dashboard/ in the 'application url' field and press the 'Create new link' button and `Continue`.'
echo ' After that in `Link applications` window'
echo ' Application Name:      Che'
echo ' Application Type:      Generic Application'
echo ' Consumer key:          key123321'
echo ' Shared secret:         key123321'
echo ' Request Token URL:     '$CHE_SERVER_URL'/plugins/servlet/oauth/request-token'
echo ' Access token URL:      '$CHE_SERVER_URL'/plugins/servlet/oauth/access-token'
echo ' Authorize URL:         '$CHE_SERVER_URL'/plugins/servlet/oauth/authorize'
echo ' Create incoming link:  true'
echo '    '
echo ' Next screen   '
echo '    '
echo ' Consumer Key:          key123321'
echo ' Consumer Name:         Che'
echo ' Public Key :           '$PUB_KEY
