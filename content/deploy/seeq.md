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

### Download
Zip files containing the Rhize Connector are distributed at a dedicated [repository](https://github.com/libremfg/rhize-seeq-connector/releases).

## Rhize Compatibility
Each release of the Rhize Connector is designed to align with the corresponding version of the Rhize platform for full compatibility.

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
    - Assign roles as relevant in your **scopemap**.
    - Alternatively, assign **libreBaas** query roles:
        - `resources:query`
        - `work-schedule:query`
        - `work-performance:query`
        - `operations-schedule:query`
        - `operations-performance:query`
        
    Roles can be filtered to only show **libreBaas** roles by using the search.
6. Select the **Credentials** tab and copy the **Client secret**.

> The Client ID and Client Secret are both necessary for authenticating the Rhize Connector.

### API URL
The API URL defines how to connect to Rhize's database. Commonly this is a domain with the `/graphql` path.

## Configuration

### Max Results Per Request
This determines the number of samples to query per request. For Rhize, this determines the limit applied to the history query when fetching samples. It is recommended to keep this value at around `10,000`.

### Additional Configuration

This is an example configuration.

```json
{
    "ApiUrl" : "http://localhost:8080/graphql",
    "AuthUrl" : "https://localhost:8090/",
    "ClientId" : "seeq",
    "ClientSecret" : "Dh8tdWmsBi9MB830Zmarj89yrC95mVSX",
    "Realm" : "libre",
    "Overfetch" : true,
    "HistoryRetries" : 0
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
| Overfetch | true | Boolean | Determines if the connector should try to query samples beyond the given bounds, so Seeq can interpolate data. |
| HistoryRetries | 0 | Integer | How many times the connector should try to query samples, in the case of a "table busy" error. |

## Known Issues
There are no known issues for the Rhize Connector. Please report any issues you find to our [support portal](https://libremfg.atlassian.net/servicedesk/customer/portal/1) or to our support email: support@libremfg.atlassian.net.
