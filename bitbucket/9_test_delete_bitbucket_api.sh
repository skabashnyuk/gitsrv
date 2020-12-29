#!/bin/bash

urlencode() {
    # urlencode <string>

    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}


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
BITBUCKET_ROUTE=$(oc get route/bitbucket --namespace=bitbucket -o=jsonpath={'.spec.host'})
echo 'Using Eclipse Che namespace: '$NS
echo 'Using Eclipse Che route: '$CHE_URL
echo 'Using Eclipse Che server url : '$CHE_SERVER_URL
echo 'Using Eclipse KEYCLOAK route: '$KEYCLOAK_ROUTE
echo 'Using Eclipse KEYCLOAK url: '$KEYCLOAK_URL
echo 'Using Eclipse Devfile registry route: '$DEVFILE_REGISTRY_ROUTE
echo 'Bitbucket route: '$BITBUCKET_ROUTE


KEYCLOAK_TOKEN=$(curl -s -X POST -d "client_id=che-public" \
     --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
      -d "subject_token=$OS_TOKEN" \
      -d "subject_issuer=openshift-v4" \
     --data-urlencode "subject_token_type=urn:ietf:params:oauth:token-type:access_token" \
  $KEYCLOAK_URL/auth/realms/che/protocol/openid-connect/token | jq -j .access_token)
USER_ID=$(curl -s  $CHE_SERVER_URL/api/user  -H 'Accept: application/json, text/plain'  -H 'Authorization: Bearer '${KEYCLOAK_TOKEN}  | jq -r .id)  
#echo 'KC token: '$KEYCLOAK_TOKEN
echo 'User ID : '$USER_ID
echo '======='
echo '==REQUEST='
#BITBACKET_REQUEST_URL='https://'$BITBUCKET_ROUTE'/rest/api/1.0/users/ksmster?filter=ksmster'
BITBACKET_REQUEST_URL='https://'$BITBUCKET_ROUTE'/rest/access-tokens/1.0/users/ksmster/718726209545'
BITBACKET_REQUEST_METHOD='DELETE'
BITBACKET_REQUEST_URL_ENCODED=$(urlencode $BITBACKET_REQUEST_URL)
SIGNATURE_REQUEST='https://'$CHE_ROUTE'/api/oauth/1.0/signature?oauth_provider=bitbucket-server&request_method='$BITBACKET_REQUEST_METHOD'&request_url='$BITBACKET_REQUEST_URL_ENCODED'&user_id='$USER_ID'&token='$KEYCLOAK_TOKEN
echo $BITBACKET_REQUEST_URL
echo $BITBACKET_REQUEST_URL_ENCODED
echo $BITBACKET_REQUEST_METHOD
#echo $SIGNATURE_REQUEST
echo '==Execute Signature='
REQUEST_SIGNATURE=$(curl -s $SIGNATURE_REQUEST )
echo '--------SIG-------------'
echo $REQUEST_SIGNATURE
echo '--------SIG--------------'


curl -v -X $BITBACKET_REQUEST_METHOD  \
  --header  "Authorization: $REQUEST_SIGNATURE" \
$BITBACKET_REQUEST_URL  | jq