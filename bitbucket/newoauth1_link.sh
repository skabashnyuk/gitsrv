#!/usr/bin/env bash

NS=${3:-che}
CUR_USER=`oc whoami`
oc project $NS
CHE_ROUTE=$(oc get route/che --namespace=$NS -o=jsonpath={'.spec.host'})
CHE_SERVER_URL='https://'${CHE_ROUTE}
KEYCLOAK_ROUTE=$(oc get route/keycloak --namespace=$NS -o=jsonpath={'.spec.host'})
KEYCLOAK_URL='https://'${KEYCLOAK_ROUTE}
OS_TOKEN=$(oc whoami --show-token)
echo 'Using Eclipse Che namespace: '$NS
echo 'Using Eclipse Che route: '$CHE_SERVER_URL
echo 'Using Eclipse KEYCLOAK route: '$KEYCLOAK_ROUTE
echo 'Using Eclipse KEYCLOAK url: '$KEYCLOAK_URL

KEYCLOAK_TOKEN=$(curl -s -X POST -d "client_id=che-public" \
     --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
      -d "subject_token=$OS_TOKEN" \
      -d "subject_issuer=openshift-v4" \
     --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:access_token" \
  $KEYCLOAK_URL/auth/realms/che/protocol/openid-connect/token | jq -j .access_token)
echo 'KC token: '$KEYCLOAK_TOKEN
echo '======='
echo 'url: '$CHE_SERVER_URL'/api/oauth/1.0/authenticate?oauth_provider=bitbucket-server&request_method=POST&userId=55af264f-4ee3-4a37-bbd8-6cf385bde734&signature_method=rsa&redirect_after_login=/dashboard&token='$KEYCLOAK_TOKEN