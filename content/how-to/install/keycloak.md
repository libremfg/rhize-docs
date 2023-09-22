+++
title = "Authenticate with Keycloak"
description = "The Rhize GraphQL implementation uses OpenIDConnect for Authentication and role-based access control. This section describes how to set up Keycloak"
weight = 1
[menu.main]
    name = "Auth with Keycloak"
    parent = "install"
    identifier = "keycloak-integration"
+++


Rhize uses OpenIDConnect to connect to a Keycloak server to authenticate users and manage Role-based access controls.

## Overview of OpenIDConnect

Open ID Connect is a security architecture that uses JSON Web Tokens (JWTs) to access secured resources.
JWT are issued by KeyCloak, and the users can be managed in KeyCloak, or managed in other services like LDAP, Google, Azure AD, Facebook, etc.

When a user accesses the user interface, the UI redirects to Keycloak, which depending on how it is configured, will redirect to the authentication provider so that the user can log in. If the user is successfully authenticated, Keycloak will redirect back to the user interface with an authentication code in the url parameters.
The UI then calls a secure API to exchange the authentication code for a JWT.

The UI then uses that JWT to access secured API like the RHIZE GraphQL API.

The RHIZE DB has the public key from Keycloak, which can be used to verify the JWT.

```mermaid
sequenceDiagram
	actor User
	participant UI as Web UI
	participant Rhize as RHIZE DB
	participant KC as KeyCloak
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

## Set up Keycloak

The following sections step through how to set up Keycloak.

### 1. Create a realm

Keycloak need to have a realm, which is like a tenant that contains all of the configuration.
Here we have created a realm named "libre"

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.39.15%20pm.png)

### 2. Create a client

Once we have created a realm, we can go head and create a client for the database, and a client for the UI.

Here we have a client for the UI named libreUI, and a client for the database called libreBaas

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.41.00%20pm.png)

The LibreBaas client should be configured like this:

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.43.51%20pm.png)

### 3. Assign permissions to the client system account

We need to assign permissions to the service account in the client so that the Rhize DB can create roles

Add these roles to the service account in the libreBaas client

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.45.47%20pm.png)

### 4. Configure Rhize to connect to the Keycloak client

Whe you start Rhize, you provide the credentials to your OIDC server in the startup flags like this:

```shell
alpha --my=0.0.0.0:7080 --zero=0.0.0.0:5080 --security whitelist=0.0.0.0/0 --graphql debug=true --cdc nats="nats://system:system@localhost:4222" --oidc bypass=false;url=http://localhost:8090;realm=libre;client-id=libreBaas;client-secret=pk98t8jVtwF9P8erRHZpLklWtz1TzGTR;scopemap=./scopemap.json
```

The `--oidc` flag has the following sub-flags:

- `bypass=false` This flag allows you to bypass security completely to help you get started quickly. To bypass security, set this to true. The server will then not try to validate your access token.
- `url=http://localhost:8090`  This is the url of the keycloak server
- `realm=libre` The realm within the Keycloak server that holds your users, groups and clients
- `client-id=libreBaas` The name of the client within Keycloak
- `client-secret=YourSecretHere` The secret to use to access the client in KeyCloak
- `scopemap=./scopemap`. The path to your ScopeMap, an example JSON file that maps client roles in KeyCloak to types in the schema.

  For example, this scopemap provides the `libre` role access to the listed types in the schema:

  ```json
  {
  	"libre": [
  		"AccessPermission",
  		"Comment",
  		"EnvironmentalVariable",
  		"EnvironmentalVariableVersion",
  		"HierarchyScope",
  		"LibreService",
  		"Menu",
  		"Secret",
  		"SecretVersion",
  		"Signature",
  		"SignatureReason"
  	]
  }
  ```

### 5. Check the client Roles

When Rhize starts up and receives the schema, it connects to Keycloak and creates client roles in the libreBaas client for each of the roles in the scopeMap, adding the operation type as shown below:

![Keycloak Client Roles](/images/graphql/KeyCloakClientRoles.png)

### 6. Create a group

We will need a group to act as a collection of the client roles that users should be granted. Here we will create an Admin group that has all of the client roles

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.48.02%20pm.png)

Map the client roles from the libreBaas client into the group.

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.49.23%20pm.png)

### 7. Assign users to the group

Add a user, and assign them to the group. Here we have added a username
![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.51.59%20pm.png)

### 8. Check the roles in the token

We can check our configuration by generating an access token from the libreBaas client.
Select the user you created, and click on `Generate access token`

We want to see that the roles that we mapped into the group that the user is a member of show in the token under resource_access.libreBaas.roles like this:

![Alt text](/images/graphql/Screenshot%202023-08-12%20at%205.53.38%20pm.png)
