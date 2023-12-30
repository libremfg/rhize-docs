---
title: About OpenID connect
description: The Rhize GraphQL implementation uses OpenIDConnect for
  Authentication and role-based access control. This section describes how to
  set up Keycloak
weight: 999
categories: ["concepts"]
menu:
  main:
    parent: deploy
    identifier: about-openid-connect
---

Rhize uses [OpenIDConnect](https://openid.net/developers/how-connect-works/) to connect to a [Keycloak](https://www.keycloak.org/) server to authenticate users and manage Role-based access controls.

Open ID Connect is a security architecture that uses JSON Web Tokens (JWTs) to access secured resources.
JWTs are issued by Keycloak. Users can also be managed in Keycloak.
Or you can manage users in other services such as LDAP, Google, Azure AD, Facebook, etc.

The general authentication flow is as follows:
1. When a user accesses the user interface, the UI redirects to Keycloak.
1. Depending on how it is configured, Keycloak redirects to the authentication provider so that the user can log in.
1. If the user is successfully authenticated, Keycloak redirects back to the user interface with an authentication code in the URL parameters.
1. The UI calls a secure API to exchange the authentication code for a JWT.
1. The UI then uses that JWT to access secure APIs such as the Rhize GraphQL API.

The Rhize DB, {{< param db >}}, has the public key from Keycloak, which can be used to verify the JWT.

```mermaid
sequenceDiagram
	actor User
	participant UI as Web UI
	participant Rhize as Rhize DB
	participant KC as Keycloak
	participant AP as AuthProvider
	Rhize->>KC: Get Public Key
	User->>UI: Log In
	UI-->>KC: Redirect
	KC-->>AP: Redirect
	AP->>User: Credentials
	AP-->>KC: Auth Result
	KC-->>UI: Redirect with Code
	UI->>KC: Exchange Code for Token
	KC->>UI: Reply with id_token and access_token
	UI->>Rhize: Access API with Bearer Token
	Rhize->>Rhize: Verify Token with Public Key from Keycloak

```

