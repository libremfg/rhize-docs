---
title: 'Admin UI configuration'
categories: ["reference"]
description: List of Evnironmental Variables and their description
weight: 900
---

The Rhize Admin UI Evnironmental variables used for configuration.

## `Preact ENV Variables`

 All Preact Environmental Variables, what they do and what there default value is.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `NODE_ENV`                                  | I dont know what this one is used for  |
| `PREACT_APP_AMPLITUDE_API_KEY`              | The Amplitude API Key. (Default: 30)  |
| `PREACT_APP_APOLLO_CLIENT`                  | The Apollo Client URL. <br />(Default: None, but typically http://localhost:4000 when running locally)  |
| `PREACT_APP_APOLLO_CLIENT_ADMIN`            | The Apollo Client Admin URL. <br />(Default: None, but typically http://localhost:4000 when running locally)  |
| `PREACT_APP_APOLLO_JSONATA_CLIENT`          | The Jsonata Client URL used for running the jsonata playground. <br />(Default: none)  |
| `PREACT_APP_APPSMITH_PORTAL`                | Shows the appsmith portal page in the admin ui if true. <br />(Default: false)  |
| `PREACT_APP_AUTH_KEYCLOAK_CLIENT_ID`        | The Keycloak Realms Client ID. <br />(Default: 30)  |
| `PREACT_APP_AUTH_KEYCLOAK_LOGOUT_URI`       | The Keycloaks logout URL. <br />(Default: 30)  |
| `PREACT_APP_AUTH_KEYCLOAK_REALM`            | The Keycloak Realm. <br />(Default: none)  |
| `PREACT_APP_AUTH_KEYCLOAK_SECRET`           | The Keybloack Realms Client IDs Secret Key. <br />(Default: none)  |
| `PREACT_APP_AUTH_KEYCLOAK_SERVER_URL`       | The Keycloak Server URL. <br />(None, but typically http://localhost:8080 when running)  |
| `PREACT_APP_DEBUG`                          | Will put admin ui page in debug mode if true. <br />(Default: false)  |
| `PREACT_APP_GRAPHIQL_ENABLED`               | Uses graphiql playground if true else uses apollo sandbox. <br />(Default: false)  |
| `PREACT_APP_LIBRE_DATA_MIGRATION_URI`       | This one is not being used currently in the admin ui but is commented out  |
| `PREACT_APP_LIBRE_PAGE_LIMIT`               | The libre table page size. <br />(Default: 15)  |
| `PREACT_APP_LIBRE_VERSION`                  | The libre version. <br />(Default: none)  |
| `PREACT_APP_MAPBOX_API_KEY`                 | I dont know what this one is. <br />(Default: none)  |
| `PREACT_APP_VERSION`                        | The schema version. <br />(Default: none)  |
| `PREACT_APP_WORK_MASTER_UI_ENABLED`         | Uses the new work master page if true, else uses old work master page.  |

## `Cypress ENV Variables`

 All Cypress Environmental Variables, what they do and what there default value is.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `CYPRESS_FRONTEND_TESTING_DOMAIN`    | The Cypress Frontend Testing Domain url <br />            |
| `CYPRESS_LOGIN_ADMIN_EMAIL`          | The Cypress Testing Email. <br />                  |
| `CYPRESS_LOGIN_ADMIN_PASSWORD`       | The Cypress Testing Password. <br />              |

## `Deprecated ENV Variables`

 All Deprecated Environmental Variables, what they do and what there default value is.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PREACT_APP_NAME`                    | This one is not being used anywhere in the admin ui.  Probably Deprecated                  |
| `PREACT_APP_PRODUCTION`              | This one is not being used anywhere in the admin ui. Probably Deprecated                   |