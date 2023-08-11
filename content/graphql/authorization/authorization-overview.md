+++
title = "Overview of Authorization and Authentication with GraphQL"
description = "The Rhize GraphQL implementation comes with built-in authorization, and supports various authentication methods, so you can annotate your schema with rules that determine who can access or mutate the data."
weight = 1
[menu.main]
    name = "Overview"
    parent = "authorization"
    identifier = "authorization-overview"
+++

The Rhize GraphQL implementation comes with built-in authorization. This lets you annotate your schema with rules that determine who can query and mutate your data.

First, let's get some concepts defined. There are two important concepts included in what's often called *auth*:

* Authorization: access permissions (what are you allowed to do)
* Authentication: establishment of identity (who you are)

Rhize lets you use your GraphQL schema to manage both authorization and authentication:
* You set authorization rules by annotating your schema with the `@auth` directive
* Authentication is handled via OpenIDConnect, allowing single-sign-on through Keycloak.

Establishing identity and managing identity-based permissions are closely related,
so this page covers both Rhize's authorization capabilities, and how Rhize works with
various authentication methods.

## Authorization

You can add authorization rules to your schema using the `@auth` directive. But,
you also need to configure the `Rhize.Authorization` object (which handles
authentication) on the last line of your schema for the `@auth` directive to
work (as described below).

When authentication and authorization are complete, your schema should look similar to the following:

```graphql
type A @auth(...) {
    ...
}

type B @auth(...) {
    ...
}
```

## Authentication

Whe you start Rhize, you provide the credentials to your OIDC server in the startup flags like this:
```
alpha --my=0.0.0.0:7080 --zero=0.0.0.0:5080 --security whitelist=0.0.0.0/0 --graphql debug=true --cdc nats="nats://system:system@localhost:4222" --oidc bypass=false;url=http://localhost:8090;realm=libre;client-id=libreBaas;client-secret=pk98t8jVtwF9P8erRHZpLklWtz1TzGTR;scopemap=./scopemap.json
```
the --oidc flag has the following sub-flags

- bypass=false  This flag allows you to bypass security completely to help you get started quickly. To bypass security, set this to true. The server will then not try to validate your access token.
- url=http://localhost:8090  This is the url of the keycloak server
- realm=libre  The realm within the Keycloak server that holds your users, groups and clients
- client-id=libreBaas The name of the client within Keycloak
- client-secret=YourSecretHere The secret to use to access the client in KeyCloak

### ScopeMap

The ScopeMap is a json file that allows you to map client roles in KeyCloak to types in the schema.

an example ScopeMap is as follows:
this scopemap would provide the "libre" role with access to the listed types in the schema.
```
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

When Rhize starts up and receives the schema, it connects to Keycloak and creates client roles in the libreBaas client for each of the roles in the scopeMap, adding the operation type as shown below:

![Keycloak Client Roles](../../../static/images/graphql/KeyCloakClientRoles.png)

In order to assign permission for a user to query or mutate in the Rhize database, create a group in Keycloak and map the client roles into the group. Then assign the user to the group.