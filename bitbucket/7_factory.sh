#!/usr/bin/env bash

NS=${3:-che}
CUR_USER=`oc whoami`
oc project $NS
CHE_ROUTE=$(oc get route/che --namespace=$NS -o=jsonpath={'.spec.host'})
CHE_SERVER_URL='https://'${CHE_ROUTE}
KEYCLOAK_ROUTE=$(oc get route/keycloak --namespace=$NS -o=jsonpath={'.spec.host'})
KEYCLOAK_URL='https://'${KEYCLOAK_ROUTE}
OS_TOKEN=$(oc whoami --show-token)
BITBUCKET_ROUTE=$(oc get route/bitbucket --namespace=bitbucket -o=jsonpath={'.spec.host'})
echo 'Using Eclipse Che namespace: '$NS
echo 'Using Eclipse Che route: '$CHE_SERVER_URL
echo 'Using Eclipse KEYCLOAK route: '$KEYCLOAK_ROUTE
echo 'Using Eclipse KEYCLOAK url: '$KEYCLOAK_URL
echo 'Bitbucket url: '$BITBUCKET_ROUTE
#echo 'KC token: '$KEYCLOAK_TOKEN
echo '======='

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OPEN_FUNC=xdg-open;;
    Darwin*)    OPEN_FUNC=open;;
    CYGWIN*)    OPEN_FUNC=xdg-open;;
    MINGW*)     OPEN_FUNC=xdg-open;;
    *)          OPEN_FUNC=xdg-open
esac

$OPEN_FUNC $CHE_SERVER_URL'/f?url=https://'$BITBUCKET_ROUTE'/scm/che/che-server.git'