---
title: Row Level Access Control
description: >-
  Instructions to configure Rhize BAAS scopemap for Row level Access Control.
weight: 200
categories: "how-to"
---

## What is Row Level Access Control?

Row Level Access Control (RLAC) is a security mechanism that restricts access to specific rows of data based on user roles and permissions. This allows organizations to enforce fine-grained access policies, ensuring that users can only access the data they are authorized to see. For example, in a contract manufacturing organization (CMO), RLAC enables the CMO to access and manage their specific data while allowing the parent company to view all data across the organization.

### Benefits of Row Level Access Control

- **Data Segmentation**: Enables organizations to partition data based on roles, ensuring that sensitive information is only accessible to authorized users.
- **Enhanced Security**: Reduces the risk of unauthorized access by enforcing strict access policies.
- **Operational Efficiency**: Allows CMOs to focus on their specific data while the parent company maintains oversight of the entire system.
- **Compliance**: Helps organizations meet regulatory requirements by controlling access to sensitive data.

## Configuring Row Level Access Control in Rhize BAAS

RLAC in Rhize BAAS is configured through the `alpha.scopemap.scopemap.json` property in the `values.yaml` file of the BAAS Helm chart. The scope map is a JSON file that defines rules, actions, jurisdictions, and resources. These rules combine OpenID Connect (OIDC) roles with resources and actions across jurisdictions (also referred to as hierarchy scopes in ISA-95).

### Example Configuration

Consider the following scenario: Acme Inc. contracts part of its supply chain to a CMO. To implement RLAC:

1. **Create an OIDC Role**: Define a role called `cmoAccess` in your OIDC provider (e.g., Keycloak).
2. **Define a Hierarchy Scope**: Create a hierarchy scope in Rhize called `CMO`. This scope is applied to objects or nodes in the graph that relate to the CMO.
3. **Add a Rule to the Scope Map**: Define a rule in the `scopemap.scopemap.json` file as follows:

```json
{
   {
     "rules": [
        {
            "id": "cmo-data-access",
            "description": "CMO data access to CMO hierarchy scoped resources and entities",
            "roles": ["cmoAccess"],
            "actions": ["query", "mutation"],
            "jurisdictions": ["CMO"]
        },
        ...other rules here...
    ],
    "actions": [
        "delete",
        "mutation",
        "query"
    ],
    ....
}
```

4. **Assign Roles to Users**: As users sign up in Keycloak, assign them the `cmoAccess` role. This grants them permission to access equipment and data within the `CMO` hierarchy scope, while restricting access to data outside this scope.
