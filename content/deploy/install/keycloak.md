---
title: Configure Keycloak
description: The Rhize GraphQL implementation uses OpenIDConnect for
  Authentication and role-based access control. This section describes how to
  set up Keycloak
weight: 100
categories: "how-to"
menu:
  main:
    name: Configure Keycloak
    parent: install
    identifier: keycloak-integration
create_client: 1. In the side menu, select **Clients > create client**.
 
---

Rhize uses Keycloak as an OpenID provider.
In your cluster, the Keycloak server to authenticate users, services, and manages Role-based access controls.

This topic describes how to set up Keycloak in your Rhize cluster.

> To get a conceptual picture of the authentication flow, read [About OpenID Connect]({{< relref "../about-openidconnect.md" >}})


## Prerequisites

First, ensure that you have followed the instructions from [Set up Kubernetes]({{< ref "configure-kubernetes.md" >}}). All of the prerequistes for that step apply here.

## Log in

1. Go to localhost on the port where you forwarded the URL.
1. Use the container credentials to log in.

   To find this, look in the `keycloak.yaml` file.

## Create a realm

A Keycloak _realm_ is like a tenant that contains all configuration.

1. In the side menu, select **Master** then **Create Realm**.
1. For the **Realm Name**, enter `{{< param application_name >}}`. **Create.**
1. In the side menu, select **Realm Settings**.
1. Enter the following values:
  | Field        | value                 |
  |--------------|-----------------------|
  | Frontend URL | keycloak frontend URL |
  | Require SSL  | External requests     |
  

After you've created the realm, you can create clients.
  
## Create clients

In Keycloak, _clients_ are entities that request Keycloak to authenticate a user.
You need to create a client for each service.

First, create a client for the DB as follows:
{{% param create_client %}}

1. Configure the **General Settings**:

    - **Client Type**: OpenID Connect
    - **Client ID**: {{< param application_name >}}Baas
    - **Name**: {{< param brand_name >}} Backend as a Service
    - **Description**: {{< param brand_name >}} Backend as a Service

    When finished, select **Next.**
  
1. Configure the **Capability config**:
    - **Client Authentication**: On
    - **Authorization**: On
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit flow

1. Select **Next**, then **Save**.


Repeat this process for the following services:

- UI
    - **Client Type**: OpenID Connect
    - **Client ID**: {{< param application_name >}}UI
    - **Name**: Rhize user interface 
    - **Description**: Rhize user interface
    - **Client Authentication**: `On`
    - **Authorization**: `Off`
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit flow
- Core
    - **Client Type**: OpenID Connect
    - **Client ID**: {{< param application_name >}}Core
    - **Name**: {{< param application_name >}} Core
    - **Description**: {{< param application_name >}} Core
    - **Client Authentication**: `On`
    - **Authorization**: `Off`
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit flow
- Router
    - **Client Type**: OpenID Connect
    - **Client ID**: {{< param application_name >}}Router
    - **Name**: {{< param application_name >}} Router
    - **Description**: {{< param application_name >}} Router
    - **Client Authentication**: `On`
    - **Authorization**: `Off`
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit flow

- BPMN
    - **Client Type**: OpenID Connect
    - **Client ID**: {{< param application_name >}}Bpmn
    - **Name**: {{< param application_name >}} BPMN
    - **Description**: {{< param application_name >}} BPMN
    - **Client Authentication**: `On`
    - **Authorization**: `Off`
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit 
- Dashboard
    - **Client Type**: OpenID Connect
    - **Client ID**: dashboard
    - **Name**: Rhize Dashboard
    - **Description**: Grafana dashboard
    - **Client Authentication**: `On`
    - **Authorization**: `Off`
    - For **Authentication flow**, enable:
       - 🗸 Standard flow

## Scope services

### Create a client scope

In Keycloak, a _scope_ bounds a services access.
Rhize creates a default client scope, then binds each services to that scope.

To create a scope for your Rhize services, follow these steps:



1. Select **Client Scopes > Create client scope**.
1. Fill in the following values:
    - **Name**: {{< param application_name >}}ClientScope
    - **Description**: {{< param brand_name >}} Client Scope
    - **Type**: None
    - **Display on consent screen**: On
    - **Include in token scope**: On
1. **Create**.
1. Select the **Mappers** tab, then **Configure new mapper**. Add an audience mapper for the DB client:

    - Mapper Type: Audience
    - Name: {{< param application_name >}}BaasAudienceMapper
    - Include Client Audience: {{< param application_name >}}Baas
    - Add to ID Token: On
    - Add to access token: On
1. Repeat the preceding step for a mapper for the UI client:

    - Mapper Type: Audience
    - Name: {{< param application_name >}}UIAudienceMapper
    - Include Client Audience: {{< param application_name >}}UI
    - Add to ID Token: On
    - Add to access token: Off

### Add services to the scope

1. Go to **Clients**. Select {{< param db >}}
1. Select the **Client Scopes** tab.
1. Select **Add Client scope**
1. Select {{< param application_name >}}ClientScope from the list.
1. **Add > Default**.

Repeat this process for the {{< param application_name >}}UI client.

## Create roles and groups

### Add the admin realm role

1. Select **Realm Roles**. Then **Create role**.
1. Enter the following values:
     - Role name: `ADMIN`
     - Description: `ADMIN`
 1. **Save**

### Add the Admin Group

1. In the left hand menu, select **Groups > Create group**.
1. Give the group a name like `{{< param application_name >}}AdminGroup`
1. **Create**

Now map a role.

1. From the group list, select the group you just created.
1. Select the **Role mapping** tab.
1. Select **Assign Role**
1. **Select ADMIN**
1. **Assign.**

### Add the dashboard realm roles

1. Select **Realm Roles**, and then **Create role**.
1. Name the role `dashboard-admin`.
1. **Save**.
1. Repeat the process to create a role `dashboard-dev`.

### Add the dashboard groups

1. In the left hand menu, select **Groups**, and then **Create Group**.
1. Name the group `dashboard-admin`
1. **Create.**
1. Repeat the process to create `dashboard-dev` and `dashboard-user` groups.

Now map the group to a role:
1. Select dashboard-admin from the list
1. Select the **Role mapping** tab.
1. Select **Assign Role.**
1. Select **`dashboard-admin`**
1. **Assign.**
1. Repeat the process for `dashboard-dev`


## Add the group client scope

1. In the left hand menu, select **Client scopes** and **Create client scope**.
1. Name it `groups` and provide a description.
1. **Save**.

Now map the scope:
1. Select the **Mappers** tab.
1. **Add predefined mappers.**
1. Select `groups`.
1. **Add**.

## Add new client scopes to dashboard client

1. In the left hand menu, select **Clients**, and then `dashboard`.
1. Select the **Client scopes** tab.
1. **Add client scope**.
1. Select `groups` and {{< param application_name >}}ClientScope.
1. **Add Default**.

## Add Client Policy

1. In the left hand menu, select **Clients**, and then `{{< param application_name >}}Baas`.
1. Select the **Authorization** tab.
1. Select **Policies > Create Policy**
1. Select **Group > Create Policy**.
1. Name the policy `{{< param application_name >}}AdminGroupPolicy`.
1. Select **Add Groups**.
1. Select `{{< param application_name >}}AdminGroup`.
1. **Add**.
1. For **Logic**, choose `Positive`.
1. **Save**.

## Add users

1. In the left hand menu, select **Users**, and **Add User**.
1. Fill in the following values:
     - **Username**: `system@{{< param domain_name >}}`.
     - **Email**: `system@{{< param domain_name >}}`.
     - **Email Verified**: `On`
     - **First name**: `system`
     - **Last name**: `{{< param brand_name >}}`
     - **Join Groups**: `{{< param application_name >}}AdminGroup`
1. **Create** 

Now create a user password:
1. Select the **Credentials** tab.
1. **Set Password**. 
1. Enter a strong 
1. For **Temporary**, choose `Off`.
1. **Save**.

Repeat this process for the following accounts:

- Core:
    - **Username**: `{{< param application_name >}}Core@{{< param domain_name >}}`
    - **Email**: `{{< param application_name >}}Core@{{< param domain_name >}}`
    - **Email Verified**: `On`
    - **First name**: `Core`
    - **Last name**: `{{< param brand_name >}}`
    - **Join Groups**: `{{< param application_name >}}AdminGroup`
-  BPMN
     - **Username**: `{{< param application_name >}}Bpmn@{{< param domain_name >}}`
     - **Email**: `{{< param application_name >}}Bpmn@{{< param domain_name >}}`
     - **Email Verified**: `On`
     - **First name**: `Bpmn`
     - **Last name**: `{{< param brand_name >}}`
     - **Join Groups**: `{{< param application_name >}}AdminGroup`
- Router
    - **Username**: `{{< param application_name >}}Router@{{< param domain_name >}}`
    - **Email**: `{{< param application_name >}}Router@{{< param domain_name >}}`
    - **Email Verified**: `On`
    - **First name**: `Router`
    - **Last name**: `{{< param brand_name >}}`
    - **Join Groups**: `{{< param application_name >}}AdminGroup`
- Agent
    - **Username**: `{{< param application_name >}}Agent@{{< param domain_name >}}`
    - **Email**: `{{< param application_name >}}Agent@{{< param domain_name >}}`
    - **Email Verified**: `On`
    - **First name**: `Agent`
    - **Last name**: `{{< param brand_name >}}`
    - **Join Groups**: `{{< param application_name >}}AdminGroup`
`
`
