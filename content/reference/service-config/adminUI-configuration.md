---
title: 'Admin UI configuration'
categories: ["reference"]
description: List of Environmental Variables and their description
weight: 900
---

The Rhize Admin UI Environmental variables used for configuration.

## `Preact ENV Variables`

 All Preact Environmental Variables, what they do and what there default value is.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `NODE_ENV`                                  | If true will also put admin UI into debug mode. This and PREACT_APP_DEBUG. <br />(Default: false) |
| `PREACT_APP_AMPLITUDE_API_KEY`              | The Amplitude API Key. <br />(Default: None)  |
| `PREACT_APP_APOLLO_CLIENT`                  | The Apollo Client URL. <br />(Default: None, http://localhost:4000 when running locally)  |
| `PREACT_APP_APOLLO_CLIENT_ADMIN`            | The Apollo Client Admin URL. <br />(Default: None, http://localhost:4000 when running locally)  |
| `PREACT_APP_APOLLO_JSONATA_CLIENT`          | The JSONata Client URL used for running the JSONata playground. <br />(Default: none)  |
| `PREACT_APP_APPSMITH_PORTAL`                | Shows the Appsmith portal page in the admin UI if true. <br />(Default: false)  |
| `PREACT_APP_AUTH_KEYCLOAK_CLIENT_ID`        | The Keycloak Realms Client ID. <br />(Default: none, libreUI when running locally)  |
| `PREACT_APP_AUTH_KEYCLOAK_LOGOUT_URI`       | The Keycloak logout URL. <br />(Default: None, libre when running locally)  |
| `PREACT_APP_AUTH_KEYCLOAK_REALM`            | The Keycloak Realm. <br />(Default: None)  |
| `PREACT_APP_AUTH_KEYCLOAK_SECRET`           | The Keycloak Realms Client IDs Secret Key. <br />(Default: None)  |
| `PREACT_APP_AUTH_KEYCLOAK_SERVER_URL`       | The Keycloak Server URL. <br />(None, http://localhost:8080 when running)  |
| `PREACT_APP_DEBUG`                          | Will put admin UI page in debug mode if true. <br />(Default: false)  |
| `PREACT_APP_GRAPHIQL_ENABLED`               | Uses GraphiQL playground if true else uses apollo sandbox. <br />(Default: false)  |
| `PREACT_APP_LIBRE_DATA_MIGRATION_URI`       | The migration URI. This one is not being used currently in the admin UI but is commented out  |
| `PREACT_APP_LIBRE_PAGE_LIMIT`               | The libre table page size. <br />(Default: 15)  |
| `PREACT_APP_LIBRE_VERSION`                  | The libre version. <br />(Default: none)  |
| `PREACT_APP_MAPBOX_API_KEY`                 | The Mapbox access token API key. <br />(Default: none)  |
| `PREACT_APP_VERSION`                        | The schema version. <br />(Default: none)  |
| `PREACT_APP_WORK_MASTER_UI_ENABLED`         | Uses the new work master page if true, else uses old work master page.  |

## `Cypress ENV Variables`

 All Cypress Environmental Variables, what they do and what there default value is.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `CYPRESS_FRONTEND_TESTING_DOMAIN`    | The Cypress Frontend Testing Domain URL <br />            |
| `CYPRESS_LOGIN_ADMIN_EMAIL`          | The Cypress Testing Email. <br />                  |
| `CYPRESS_LOGIN_ADMIN_PASSWORD`       | The Cypress Testing Password. <br />              |

## `Deprecated ENV Variables`

 All Deprecated Environmental Variables, what they do and what there default value is.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PREACT_APP_NAME`                    | This one is not being used anywhere in the admin UI, just shows up in .env.example and Dockerfile.  Probably Deprecated                  |
| `PREACT_APP_PRODUCTION`              | This one is not being used anywhere in the admin UI, just shows up in Dockerfile. Probably Deprecated                   |