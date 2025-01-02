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
---

Rhize uses [Keycloak](https://keycloak.org) as an OpenID provider.
In your cluster, the Keycloak server to authenticate users, services, and manage Role-based access controls.

This topic describes how to set up Keycloak in your Rhize cluster.
For a conceptual overview of the authentication flow, read [About OpenID Connect]({{< relref "../about-openidconnect.md" >}})


## Prerequisites

First, ensure that you have followed the instructions from [Set up Kubernetes](/deploy/install/setup-kubernetes).
All prerequisites for that step apply here.

## Steps

Follow these steps to configure a Keycloak realm and associate Rhize services to Keycloak clients, groups, roles, and policies.

### Log in

1. Go to `localhost` on the port where you forwarded the URL. If you used the example values from the last step, that's `localhost:5101`.
1. Use the container credentials to log in.

   To find this, look in the `keycloak.yaml` file.

### Create a realm

A Keycloak _realm_ is like a tenant that contains all configuration.

To create your Rhize realm, follow these steps.

1. In the side menu, select **Master** then **Create Realm**.
1. For the **Realm Name**, enter `{{< param application_name >}}`. **Create.**
1. In the side menu, select **Realm Settings**.
1. Enter the following values:
  | Field        | value                 |
  |--------------|-----------------------|
  | Frontend URL | Keycloak frontend URL |
  | Require SSL  | External requests     |


After you've created the realm, you can create clients.

{{% notice "note" %}}
If created with the Libre Theme `init` container, configure the **Login Theme** in **Realm settings** for `libre`.
{{% /notice %}}

### Create clients

In Keycloak, _clients_ are entities that request Keycloak to authenticate a user.
You need to create a client for each service.

The DB client requires additional configuration of flows and grants.
Other clients, such as the UI and Dashboard, use the standard flow to coordinate authorization between the browser and Keycloak to simplify security and improve user convenience.

{{< notice "note" >}}
Each standard-flow client has its own subdomain.
Refer to [Default URLs and Ports]({{< relref "/reference/default-ports" >}}) for our recommended conventions.
{{< /notice >}}

#### Create DB client


Create a client for the DB as follows:
1. In the side menu, select **Clients > create client**.
1. Configure the **General Settings**:

    - **Client Type**: `OpenID Connect`
    - **Client ID**: `{{< param db >}}`
    - **Name**: `{{< param brand_name >}} Backend as a Service`
    - **Description**: `{{< param brand_name >}} Backend as a Service`

    When finished, select **Next.**

1. Configure the **Capability config**:
    - **Client Authentication**: On
    - **Authorization**: On
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit flow

1. Select **Next**, then **Save**.

   On success, this opens the **Client details** page for the newly created client.

1. Select the **service account Roles** tab and assign the following roles to the `{{< param db >}}` service account. Change popup filter to **Filter by clients** to locate roles:
    - `manage-clients`
    - `manage-account`
    - `manage-users`

#### Create UI client

Create a client for the UI as follows:
1. In the side menu, select **Clients > create client**.
1. Configure the **General Settings**:

    - **Client Type**: `OpenID Connect`
    - **Client ID**: `{{< param application_name >}}UI`
    - **Name**: `{{< param brand_name >}} User Interface`
    - **Description**: `{{< param brand_name >}} User Interface`

    When finished, select **Next.**

1. Configure the **Capability config**:
    - **Client Authentication**: On
    - **Authorization**: On
    - For **Authentication flow**, enable:
       - 🗸 Standard flow
       - 🗸 Direct access grants
       - 🗸 Implicit flow

1. Configure the **Access Settings**:

   - **Root URL**: `<UI_SUBDOMAIN>.<YOUR_DOMAIN>` without trailing slashes
   - **Home URL**: `<UI_SUBDOMAIN>.<YOUR_DOMAIN>` without trailing slashes
   - **Web Origins**: `<UI_SUBDOMAIN>.<YOUR_DOMAIN>` without trailing slashes

1. Select **Next**, then **Save**.

#### Create dashboard client

1. In the side menu, select **Clients > create client**.
1. Configure the **General Settings**:

   - **Client Type**: `OpenID Connect`
   - **Client ID**: `dashboard`
   - **Name**: `{{< param brand_name >}} Dashboard`
   - **Description**: `{{< param brand_name >}} Dashboard`

1. Configure the **Capability config**:

   - **Client Authentication**: On
   - **Authorization**: On
   - For **Authentication flow**, enable:
     - 🗸 Standard flow
     - 🗸 Direct access grants
     - 🗸 Implicit flow

1. Configure the **Access Settings**:

   - **Root URL**: `<DASHBOARD_SUBDOMAIN>.<YOUR_DOMAIN>` without trailing slashes
   - **Home URL**: `<DASHBOARD_SUBDOMAIN>.<YOUR_DOMAIN>` without trailing slashes
   - **Valid redirect URIs**: `<DASHBOARD_URL>/login/generic_oauth` without trailing slashes
   - **Valid post logout redirect URIs**: `+` without trailing slashes
   - **Home URL**: `<DASHBOARD_SUBDOMAIN>.<YOUR_DOMAIN>` without trailing slashes

1. Select **Next**, then **Save**.

#### Create other service clients

The other services do not need authorization but do need client authentication.
By default you need to add only the client ID.

For example, to create the BPMN engine client:
1. In the side menu, select **Clients > create client**.
1. For **Client ID**, enter `{{< param application_name >}}Bpmn`
1. Configure the **Capability config**:
    - **Client Authentication**: On
1. Select **Next**, then **Save**.

**Repeat this process for each of the following services:**

| Client ID                              | Description           |
|----------------------------------------|-----------------------|
| `{{< param application_name >}}Audit`  | The audit log service |
| `{{< param application_name >}}Core`   | The edge agent        |
| `{{< param application_name >}}Router` | API router            |

Based on your architecture, repeat for any Libre Edge Agents, `{{< param application_name >}}Agent`.

### Scope services

In Keycloak, a _scope_ bounds the access a service has.
Rhize creates a default client scope, then binds services to that scope.

#### Create a client scope

To create a scope for your Rhize services, follow these steps:


1. Select **Client Scopes > Create client scope**.
1. Fill in the following values:
    - **Name**: `{{< param application_name >}}ClientScope`
    - **Description**: `{{< param brand_name >}} Client Scope`
    - **Type**: `None`
    - **Display on consent screen**: `On`
    - **Include in token scope**: `On`
1. **Create**.
1. Select the **Mappers** tab, then **Configure new mapper**. Add an audience mapper for the DB client:
    - **Mapper Type**: `Audience`
    - **Name**: `{{< param db >}}AudienceMapper`
    - **Include Client Audience**: `{{< param db >}}`
    - **Add to ID Token**: `On`
    - **Add to access token**: `On`
1. Repeat the preceding step for a mapper for the UI client:
    - **Mapper Type**: `Audience`
    - **Name**: `{{< param application_name >}}UIAudienceMapper`
    - **Include Client Audience**: `{{< param application_name >}}UI`
    - **Add to ID Token**: `On`
    - **Add to access token**: `Off`
1. Repeat the preceding step for a mapper for the BPMN client:
    - **Mapper Type**: `Audience`
    - **Name**: `{{< param application_name >}}BPMNAudienceMapper`
    - **Include Client Audience**: `{{< param application_name >}}Bpmn`
    - **Add to ID Token**: `On`
    - **Add to access token**: `On`
1. If using the Rhize Audit microservice, repeat the preceding step for an Audit scope and audience mapper:
    - **Mapper Type**: `Audience`
    - **Name**: `{{< param application_name >}}AuditAudienceMapper`
    - **Include Client Audience**:
    - **Included Custom Audience**: `audit`
    - **Add to ID Token**: `On`
    - **Add to access token**: `On`

#### Add services to the scope

1. Go to **Clients**. Select `{{< param db >}}`.
1. Select the **Client Scopes** tab.
1. Select **Add Client scope**
1. Select `{{< param application_name >}}ClientScope` from the list.
1. **Add > Default**.

Repeat this process for the `dashboard`, `{{< param application_name >}}UI`, `{{< param application_name >}}Bpmn`, `{{< param application_name >}}Core`, `{{< param application_name >}}Router`, `{{< param application_name >}}Audit` (if applicable). Based on your architecture repeat for any Libre Edge Agent clients.

### Create roles and groups

In Keycloak, _roles_ identify a category or type of user.
_Groups_ are a common set of attributes for a set of users.

Rhize creates an `ADMIN` role and group.

#### Add the admin realm role

1. Select **Realm Roles**. Then **Create role**.
1. Enter the following values:
     - Role name: `ADMIN`
     - Description: `ADMIN`
 1. **Save**.

#### Add the Admin Group

1. In the left hand menu, select **Groups > Create group**.
1. Give the group a name like `{{< param application_name >}}AdminGroup`.
1. **Create**.

Now map a role.

1. From the group list, select the group you just created.
1. Select the **Role mapping** tab.
1. Select **Assign Role**
1. Select `ADMIN`.
1. **Assign.**

#### Add the dashboard realm roles

1. Select **Realm Roles**, and then **Create role**.
1. Name the role `dashboard-admin`.
1. **Save**.
1. Repeat the process to create a role `dashboard-dev`.

#### Add the dashboard groups

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


#### Add the group client scope

1. In the left hand menu, select **Client scopes** and **Create client scope**.
1. Name it `groups` and provide a description.
1. **Save**.

Now map the scope:
1. Select the **Mappers** tab.
1. **Add predefined mappers.**
1. Select `groups`.
1. **Add**.

#### Add new client scopes to dashboard client

1. In the left hand menu, select **Clients**, and then `dashboard`.
1. Select the **Client scopes** tab.
1. **Add client scope**.
1. Select `groups` and `{{< param application_name >}}ClientScope`.
1. **Add Default**.

### Add Client Policy

In Keycloak, _policies_ define authorization.
Rhize requires authorization for the database service.

1. In the left hand menu, select **Clients**, and then `{{< param db >}}`.
1. Select the **Authorization** tab.
1. Select **Policies > Create Policy**
1. Select **Group > Create Policy**.
1. Name the policy `{{< param application_name >}}AdminGroupPolicy`.
1. Select **Add Groups**.
1. Select `{{< param application_name >}}AdminGroup`.
1. **Add**.
1. For **Logic**, choose `Positive`.
1. **Save**.

### Add users

1. In the left hand menu, select **Users**, and **Add User**.
1. Fill in the following values:
     - **Username**: `system@{{< param domain_name >}}`.
     - **Email**: `system@{{< param domain_name >}}`.
     - **Email Verified**: `On`
     - **First name**: `system`
     - **Last name**: `{{< param brand_name >}}`
     - **Join Groups**: `{{< param application_name >}}AdminGroup`
1. **Create**.

Now create a user password:
1. Select the **Credentials** tab.
1. **Set Password**.
1. Enter a strong password.
1. For **Temporary**, choose `Off`.
1. **Save**.

Repeat this process for the following accounts:

- Audit:
    - **Username**: `{{< param application_name >}}Audit@{{< param domain_name >}}`
    - **Email**: `{{< param application_name >}}Audit@{{< param domain_name >}}`
    - **Email Verified**: `On`
    - **First name**: `Audit`
    - **Last name**: `{{< param brand_name >}}`
    - **Join Groups**: `{{< param application_name >}}AdminGroup`
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

## Enable Keycloak Audit Trail

With the `libre` realm selected:
1. Select **Realm Settings**, and then **Events**.
1. Select the tab **User event settings**.
1. Enable **Save Events** and set an expiration.
1. **Save**.
1. Repeat the process for the **Admin event settings** tab.

## Configure password policy

With the `libre` realm selected:
1. Select **Authentication** and then the **Policies** tab.
1. Select the **Password policy** tab.
1. Add your organisation's password policy.

## Configure brute-force protections

With the `libre` realm selected:
1. Select **Realm settings**  and then the **Security defenses** tab.
1. In **Brute force detection**, enable the feature and configure it to your requirements.

## Next steps

[Install services]({{< relref "services" >}}).
