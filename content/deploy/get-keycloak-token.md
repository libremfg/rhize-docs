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

If the `grant_type` is set for password authentication the request will also require a username and password:

```shell
curl -X POST "https://<KEYCLOAK_HOST>/realms/<REALM_NAME>/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=<CLIENT_ID>" \
  -d "client_secret=<CLIENT_SECRET>" \
  -d "username=<USERNAME>" \
  -d "password=<PASSWORD>"
```

## Response

An example response returns a JSON object with the following structure.
The `access_token` property has the token value.

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldU...",
  "expires_in": 28800,
  "refresh_expires_in": 0,
  "token_type": "Bearer",
  "not-before-policy": 0,
  "scope": "profile email"
}
```

