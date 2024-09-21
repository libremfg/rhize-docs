---
title: Export keycloak events
description: Guide to export events from Keycloak
menu:
  main:
    parent: maintain
    identifier:
---

Keycloak stores User and Admin event data in its database. You can retrieve use this information for auditing.

To read Keycloak event data, use its Admin CLI. You can access the CLI from within the Keycloak's container.

## Prerequisites

Ensure you have the following:
- The ability to run commands in a Keycloak container or pod.
- A keycloak admin username and password.

## Procedure

To export Keycloak events, first open a shell in your Keycloak container or pod. For example, in Kubernetes and Docker:

{{< tabs >}}

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


On success, event data **prints** to the console.

## Next Steps

The event output can be long, so consider writing it to a file.
For example, you can try the following commands, replacing `<ADMIN_PW>` with the Keycloak admin password.

{{< tabs >}}
{{% tab Kubernetes %}}

```shell
kubectl exec -it keycloak_pod_name -n namespace_name -- \
    /bin/sh -c "cd /opt/bitnami/keycloak/bin && (echo "<ADMIN_PW>" \
    | ./kcadm.sh get realms/libre/events --server http://localhost:8080 \
    --realm master --user admin)" \
    | sed '1,2d' \
    | jq '.' > output.json
```

{{% /tab %}}

{{% tab docker %}}

```shell
docker exec -it keycloak_container_name \
    /bin/sh -c "cd /opt/bitnami/keycloak/bin && (echo "<ADMIN_PW>" \
    | ./kcadm.sh get realms/libre/events --server http://localhost:8080 \
    --realm master --user admin)" \
    | sed '1,2d' \
    | jq '.' > output.json
```

{{% /tab %}}
{{< /tab >}}
