---
title: 'Connecting to Seeq'
date: '2025-08-24T21:46:50-07:00'
categories: ["how-to"]
description: How to use Seeq with Rhize
weight: 600
icon: search
---

The Rhize Connector enables Seeq to access data from Rhize.

> [!NOTE]
> Requires Rhize v4.1.0+

## Rhize Compatibility
Each release of the Rhize Seeq Connector is designed to align with the corresponding version of the Rhize platform for full compatibility.

## Prerequisites
You must gather some information and setup a Keycloak client to configure a connection to your Rhize instance.

### Keycloak
The Rhize Connector requires a client configured for it in order to communicate with other Rhize services.

1. In the side menu, select **Clients > create client.**
2. Configure the **General Settings:**
    - **Client Type:** OpenID Connect
    - **Client ID:** seeq
    **Name** and **Description** can be anything.
3. Configure the **Capability config:**
    - **Client Authentication:** On
    - **Authorization:** On
    - For **Authentication flow,** enable:
        - Direct access grants
        - Implicit flow

    > Ensure that **Standard flow** in **Authentication flow** is disabled.
4. Select **Next**, then **Save**.
5. Select the **Service accounts roles** tab, then **Assign role:**
    - Change the filter to **Filter by clients.**
    - Assign **libreBaas** query roles:
        - `resources:query`
        - `work-schedule:query`
        - `work-performance:query`
        - `operations-schedule:query`
        - `operations-performance:query`
        
    Roles can be filted to only show **libreBaas** roles by using the search.
6. Select the **Credentials** tab and copy the **Client secret**.

> The Client ID and Client Secret are both necessary for authenticating the Rhize Connector.

### API URL
The API URL defines how to connect to Rhize's database. Commonly this is a domain with the `/graphql` path.

## Configuration
This is an example configuration.

```json
{
    "ApiUrl" : "http://localhost:8080/graphql",
    "AuthUrl" : "https://localhost:8090/",
    "ClientId" : "seeq",
    "ClientSecret" : "Dh8tdWmsBi9MB830Zmarj89yrC95mVSX",
    "Realm" : "libre",
}
```

### Standard Rhize Additional Configuration
| Property Name | Default Value | Data Type | Description |
|:---|:---|:---|:---|
| ApiUrl | null | String | The url to Rhize's backend. |
| AuthUrl | null | String | The url to Keycloak. |
| ClientId | null | String | The ID for the configured Seeq client. |
| ClientSecret | null | String | The secret for the configured Seeq client. |
| Realm | null | String | The realm for Rhize's Keycloak configuration. |

## Known Issues
There are no known issues for the Rhize Connector. Please report any issues you find to our [support portal](https://libremfg.atlassian.net/servicedesk/customer/portal/1) or to our support email: support@libremfg.atlassian.net.

