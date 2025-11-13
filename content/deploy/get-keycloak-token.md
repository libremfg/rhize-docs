---
title: Get Keycloak Token
description: Get a Keycloak bearer token
---

When build applications on Rhize, your clients to need authenticate requests.
To do that, they need to periodically request a bearer token from the Keycloak service.

## Get token

With `grant_type` set for client credentials, you can get a bearer token with the following request:

```shell
curl -X POST "https://<KEYCLOAK_HOST>/realms/<REALM_NAME>/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=<CLIENT_ID>" \
  -d "client_secret=<CLIENT_SECRET>"
```

If the `grant_type` is set for password authentication, you can get a bearer with the following request:

```shell
USERNAME=backups@libremfg.com \
&& PASSWORD=password \
&& curl --location \
  --request POST "${BAAS_OIDC_URL}/realms/libre/protocol/openid-connect/token" \
  --header 'Content-Type\ application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=password' \
  --data-urlencode "username=${USERNAME}" \
  --data-urlencode "password=${PASSWORD}"  \
  --data-urlencode "client_id=${BAAS_OIDC_CLIENT_ID}" \
  --data-urlencode "client_secret=${OIDC_SECRET}" | jq .access_token
```

## Response

An example response returns a JSON object with the following structure.
The `access_token` property has the token value.

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldU...",
  "expires_in": 300,
  "token_type": "Bearer",
  "scope": "email profile"
}
```

