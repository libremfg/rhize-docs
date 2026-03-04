---
title: Export Keycloak events
description: Guide to export events from Keycloak
---

Keycloak stores User and Admin event data in its database. This information can be valuable for your audits.

This guide shows you how to export your Keycloak events to a file.
To read Keycloak event data, use its [Admin CLI](https://docs.redhat.com/en/documentation/red_hat_build_of_keycloak/22.0/html/server_administration_guide/admin_cli). You can access the CLI from within the Keycloak's container.

## Prerequisites

Ensure you have the following:
- The ability to run commands in a Keycloak container or pod.
- A Keycloak admin username and password.

## Procedure

To export Keycloak events, first open a shell in your Keycloak container or pod. For example, in Kubernetes and Docker:

{{< tabs items="Kubernetes,Docker" >}}

{{% tab "kubernetes" %}}
```sh
kubectl exec -it keycloak_pod_name -n namespace_name -- /bin/sh
```
{{% /tab %}}

{{% tab "Docker" %}}
```sh
docker exec -it keycloak_container_name /bin/sh
```

{{% /tab %}}

{{< /tabs >}}

Then follow these steps:

1. Change to the directory where the script for the Admin CLI is. This directory is by default `/opt/bitnami/keycloak/bin`.
3. Run `./kcadm.sh get realms/libre/events --server http://localhost:8080 --realm master --user <ADMIN>`. Replace `<ADMIN>` with the Keycloak admin username.
  If the Keycloak port differs from the default, replace `:8080` with the configured port number.
4. When prompted, enter the Keycloak admin password.


On success, event data prints to the console.

## Write event data to file

The event output can be long.
You can use the following commands write the data to a file (replacing `<ADMIN_PW>` with the Keycloak admin password).

{{< tabs items="Kubernetes,Docker" >}}
{{% tab Kubernetes %}}

Set Credentials
```shell
kubectl exec -it keycloak_pod_name -n namespace_name -- sh -c "export HOME=/opt/keycloak/data && /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user user"
```

Export Events
```shell
kubectl exec -it keycloak_pod_name -n namespace_name -- sh -c "export HOME=/opt/keycloak/data && /opt/keycloak/bin/kcadm.sh get realms/libre/events --config /opt/keycloak/data/.keycloak/kcadm.config" > output.json
```

{{% /tab %}}

{{% tab docker %}}

Set credentials
```shell
docker exec -it keycloak sh -c "/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin"
```

Export Events
```shell
docker exec -it keycloak sh -c "/opt/keycloak/bin/kcadm.sh get realms/libre/events" > output.json
```

{{% /tab %}}
{{< /tab >}}
