#!/bin/bash
set -e
echo 'Logged in as ' $(oc whoami)

NS=${1:-che}
CHE_ROUTE=$(oc get route/che --namespace=$NS -o=jsonpath={'.spec.host'})
CHE_SERVER_URL='https://'${CHE_ROUTE}
KEYCLOAK_ROUTE=$(oc get route/keycloak --namespace=$NS -o=jsonpath={'.spec.host'})
KEYCLOAK_URL='https://'${KEYCLOAK_ROUTE}
DEVFILE_REGISTRY_ROUTE=$(oc get route/devfile-registry --namespace=$NS -o=jsonpath={'.spec.host'})
DEVFILE_REGISTRY_URL='https://'${DEVFILE_REGISTRY_ROUTE}
OS_TOKEN=$(oc whoami --show-token)
DEVFILE_ID=''
echo 'Using Eclipse Che namespace: '$NS
echo 'Using Eclipse Che route: '$CHE_URL
echo 'Using Eclipse Che server url : '$CHE_SERVER_URL
echo 'Using Eclipse KEYCLOAK route: '$KEYCLOAK_ROUTE
echo 'Using Eclipse KEYCLOAK url: '$KEYCLOAK_URL
echo 'Using Eclipse Devfile registry route: '$DEVFILE_REGISTRY_ROUTE
#echo 'OS token: '$OS_TOKEN


KEYCLOAK_TOKEN=$(curl -s -X POST -d "client_id=che-public" \
     --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
      -d "subject_token=$OS_TOKEN" \
      -d "subject_issuer=openshift-v4" \
     --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:access_token" \
  $KEYCLOAK_URL/auth/realms/che/protocol/openid-connect/token | jq -j .access_token)
echo 'KC token: '$KEYCLOAK_TOKEN
echo '======='
#echo 'https://che-che.apps.cluster-2d6e.2d6e.example.opentlc.com/api/oauth/1.0/authenticate?&userId=6cbb0fc1-e5d7-4066-807c-2dea8b3c398f&oauth_provider=bitbucket-server&request_method=POST&signature_method=rsa&redirect_after_login=/dashboard&token='$KEYCLOAK_TOKEN
echo '==Signature='
BITBACKET_REQUEST_URL='https%3A%2F%2Fbitbucket-bitbucket.apps.cluster-devtools-360d.devtools-360d.example.opentlc.com%2Frest%2Faccess-tokens%2F1.0%2Fusers%2Fksmster'
BITBACKET_REQUEST_METHOD='GET'
SIGNATURE_REQUEST='https://che-che.apps.cluster-devtools-360d.devtools-360d.example.opentlc.com/api/oauth/1.0/signature?oauth_provider=bitbucket-server&request_method='$BITBACKET_REQUEST_METHOD'&request_url='$BITBACKET_REQUEST_URL'&user_id=55af264f-4ee3-4a37-bbd8-6cf385bde734&token='$KEYCLOAK_TOKEN
echo $SIGNATURE_REQUEST
echo '==Execute Signature='
REQUEST_SIGNATURE=$(curl -s $SIGNATURE_REQUEST )
echo '--------SIG-------------'
echo $REQUEST_SIGNATURE
echo '--------SIG--------------'
#jq -sRr 'https://bitbucket-bitbucket.apps.cluster-2d6e.2d6e.example.opentlc.com/rest/access-tokens/latest/users/ksmster'
curl -v -H "Authorization: $REQUEST_SIGNATURE" 'https://bitbucket-bitbucket.apps.cluster-devtools-360d.devtools-360d.example.opentlc.com/rest/access-tokens/1.0/users/ksmster' | jq .

