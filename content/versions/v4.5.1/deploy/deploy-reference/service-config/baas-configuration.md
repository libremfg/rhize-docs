---
title: 'BAAS configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize BAAS service
aliases:
  - /reference/service-config/baas-configuration
weight: 900
---

## Scope of this page

The chart exposes almost all of Dgraph's configuration: two components (zero
and alpha), a backup system, and every Dgraph flag through `extraFlags`
and `configFile`. This page documents the OIDC settings, the scope map, and the
chart values likely to need changing.

For everything else — Dgraph flags, cluster sizing, sharding, enterprise
features — see the Dgraph documentation:

- [Dgraph deployment and configuration](https://dgraph.io/docs/deploy/)
- [Dgraph CLI reference](https://dgraph.io/docs/deploy/cli-command-reference/)
- [Encryption at rest](https://dgraph.io/docs/enterprise-features/encryption-at-rest/)

## Application configuration

baas has no single configuration value: each section below says which chart
value its settings go into.

### OIDC authentication

How baas validates users' OIDC tokens and decides what each user may do from
the scope map. Set these through the chart's `alpha.extraEnvs`.

| Value | Description |
| --- | --- |
| **`BAAS_OIDC_URL`**<br>[Required] | <ul><li>Base URL of the OIDC provider.</li><li>Default: `http://keycloak:80`</li><li>Example: `http://keycloak:80`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_REALM`**<br>[Required when `BAAS_OIDC_ENABLE_GENERIC_OIDC` is `false`] | <ul><li>Keycloak realm.</li><li>Default: `libre`</li><li>Example: `libre`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_CLIENT_ID`**<br>[Required] | <ul><li>Client ID. Also the audience expected in user tokens unless `BAAS_OIDC_CUSTOM_AUDIENCE` is set.</li><li>Example: `libreBaas`</li><li>Type: string</li></ul> |
| **`OIDC_SECRET`**<br>[Required] | <ul><li>Client secret paired with `BAAS_OIDC_CLIENT_ID`. Supply from a Kubernetes Secret through `alpha.secrets`.</li><li>Example: `Qm7xT2vLp9RcW4nZk8HbY3jDf6sGa1Ue`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_SYNC_ROLES`** | <ul><li>Pushes the roles defined in the scope map up to Keycloak so they can be assigned there. Works with Keycloak only, so it has no effect when `BAAS_OIDC_ENABLE_GENERIC_OIDC` is `true`.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`BAAS_OIDC_SCOPEMAP`**<br>[Required] | <ul><li>Path on disk to the JSON scope map described below. Set this to the path that map is mounted at, made up of the mount directory given in the `alpha.scopemap` section and the filename the map is stored under.</li><li>Default: `/dgraph/additional-config/scopemap.json`</li><li>Example: `/dgraph/additional-config/scopemap.json`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_CA_FILE`** | <ul><li>CA certificate for TLS connections to the OIDC server. This is automatically set to `/certs/ca.pem` by the chart when `alpha.caFile` is provided.</li><li>Example: `/certs/ca.pem`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_ENABLE_GENERIC_OIDC`** | <ul><li>Switches to a generic OIDC provider such as Okta rather than Keycloak-specific handling.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`BAAS_OIDC_CUSTOM_AUDIENCE`** | <ul><li>Audience to expect in user tokens in place of `BAAS_OIDC_CLIENT_ID`.</li><li>Example: `rhize`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_CUSTOM_ROLES_KEY`** | <ul><li>Claim to read roles from when using a non-Keycloak provider.</li><li>Default: `rhize.com/roles`</li><li>Example: `rhize.com/roles`</li><li>Type: string</li></ul> |
| **`BAAS_OIDC_CUSTOM_PERMISSIONS_KEY`** | <ul><li>Claim to read permissions from when using a non-Keycloak provider.</li><li>Default: `rhize.com/permissions`</li><li>Example: `rhize.com/permissions`</li><li>Type: string</li></ul> |

### `alpha.scopemap`

The scope map defines who may do what, and is the one piece of this chart you
are most likely to edit. The scope map is a single JSON document, rendered into an
`…-alpha-scopemap` ConfigMap and mounted at `/dgraph/additional-config`.

| Value | Description |
| --- | --- |
| **`alpha.scopemap`**<br>[Required] | <ul><li>Map whose single key is the filename and whose value is the JSON document. Set the value to empty to disable scope-based authorisation, which also drops the ConfigMap and the mount.</li><li>Default: the chart's own scope map</li><li>Example: see the example block below</li><li>Type: map</li></ul> |

The document has three top-level fields:

| Field | Description |
| --- | --- |
| `rules` | List of rules, each granting the roles it names a set of actions on a set of resources. The fields of a rule are in the next table. |
| `resources` | Named groups of GraphQL types, as a map of group name to a list of type names. A type has to be in a group for any rule to reach it. The default groups are listed below. |
| `jurisdictions` | Every jurisdiction a rule can grant, as dot-separated names such as `site1.area2`. The default set is just `default`. |

Each rule has these fields:

| Field | Description |
| --- | --- |
| `id` | Identifier of the rule. |
| `description` | What the rule is for. |
| `roles` | Roles the rule applies to. A user matches when their token carries any of them: a `libreBaas` client role in Keycloak, or a value of the claim named by `BAAS_OIDC_CUSTOM_ROLES_KEY` with generic OIDC. |
| `resources` | Types the rule covers. `*` covers every group, `<group>.*` every type in one group, `<group>.<Type>` one type in that group, and a type name on its own covers that type. |
| `actions` | Operations the rule allows, from `query`, `mutation`, `delete`, and `subscription`. `*` allows all four. |
| `jurisdictions` | Jurisdictions the rule grants for its resources and actions, taken from the top-level `jurisdictions` list. `*` matches every remaining level, so `site1.*` covers every jurisdiction under `site1`. They reach the schema's `@auth` rules through the `Jurisdiction` macro. |

The default scope map groups the types as follows. Each group also lists the
matching `…AggregateResult` types, and most include `Comment` and
`HierarchyScope`.

| Group | Types |
| --- | --- |
| `admin` | A single entry, `admin`. |
| `audit` | None. |
| `bpmn` | None. |
| `libre` | Platform types: access permissions, comments, environment variables, secrets, signatures and signature reasons, menus, and Libre services. |
| `material` | Material lots and sublots, and their properties. |
| `operations-definition` | Operations definitions and segments, their material bills and parameter specifications, and the equipment, material, personnel, and physical asset specifications. |
| `operations-schedule` | Operations schedules and requests, segment requirements and parameters, and the equipment, material, personnel, and physical asset requirements. |
| `operations-performance` | Operations performance, responses, and capabilities, segment responses and data, and the equipment, material, personnel, and physical asset actuals and capabilities. |
| `process-segment` | Process segments, their dependencies, parameters, and versions. |
| `resources` | The resource model: equipment, material classes, definitions, and lots, personnel, physical assets, operational locations, data sources and subscriptions, events and operations events, units of measure, and resource relationship networks. |
| `test` | Test specifications, criteria, results, and property measurements. |
| `work-definition` | Work masters and directives, workflow specifications, state models, forms, and the workflow's runtime types, such as timers, messages, and errors. |
| `work-schedule` | Work schedules and requests, job lists and orders, and work calendars. |
| `work-performance` | Work performance and responses, and job responses and their data. |

The default scope map contains one rule: `admin` can do everything
everywhere. Anything more granular has to be added. Adding a new GraphQL type to
the schema also means adding it to a group here, or no rule can reach it.

A scope map with one rule, letting the `operator` role query the types grouped
under `resources`:

```yaml
alpha:
  scopemap:
    scopemap.json: |
      {
        "rules": [
          {
            "id": "rule-001",
            "description": "Operators can read resources",
            "roles": ["operator"],
            "resources": ["resources.*"],
            "actions": ["query"],
            "jurisdictions": ["*"]
          }
        ],
        "jurisdictions": ["default"],
        "resources": {
          "resources": ["Equipment", "EquipmentClass"]
        }
      }
```

### `alpha.cdc`

Change data capture, which publishes every mutation to one destination, chosen by
`alpha.cdc.sink`.

| Value | Description |
| --- | --- |
| **`alpha.cdc.enabled`** | <ul><li>Enables change data capture.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`alpha.cdc.sink`** | <ul><li>Where changes are sent: `nats`, `kafka`, `solace`, `http`, or `file`. Only the values for that sink are used.</li><li>Default: `nats`</li><li>Example: `nats`</li><li>Type: string</li></ul> |
| **`alpha.cdc.topic`** | <ul><li>Topic changes are published to on Kafka or Solace.</li><li>Default: `dgraph-cdc`</li><li>Example: `dgraph-cdc`</li><li>Type: string</li></ul> |
| **`alpha.cdc.nats`**<br>[Required when `alpha.cdc.sink` is `nats`] | <ul><li>NATS endpoint URL. Credentials can be embedded, as in `nats://user:password@nats:4222`. Changes are published to the `libreBaas_cdc` JetStream stream.</li><li>Default: `nats://nats:4222`</li><li>Example: `nats://nats:4222`</li><li>Type: string</li></ul> |
| **`alpha.cdc.replicas`** | <ul><li>JetStream replica count of that stream.</li><li>Default: `1`</li><li>Example: `1`</li><li>Type: integer</li></ul> |
| **`alpha.cdc.kafka.brokers`**<br>[Required when `alpha.cdc.sink` is `kafka`] | <ul><li>Comma-separated list of Kafka brokers.</li><li>Example: `redpanda:9092`</li><li>Type: string</li></ul> |
| **`alpha.cdc.kafka.saslUser`** | <ul><li>SASL username. SASL is used only when both the username and password are set.</li><li>Example: `cdc`</li><li>Type: string</li></ul> |
| **`alpha.cdc.kafka.saslPassword`** | <ul><li>SASL password.</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`alpha.cdc.kafka.saslMechanism`** | <ul><li>SASL mechanism: `PLAIN`, `SCRAM-SHA-256`, or `SCRAM-SHA-512`.</li><li>Default: `PLAIN`</li><li>Example: `PLAIN`</li><li>Type: string</li></ul> |
| **`alpha.cdc.kafka.caCert`** | <ul><li>Path inside the container to a CA certificate. Setting it turns on TLS.</li><li>Example: `/certs/kafka-ca.pem`</li><li>Type: string</li></ul> |
| **`alpha.cdc.kafka.clientCert`** | <ul><li>Path inside the container to a client certificate for mutual TLS, used with `alpha.cdc.kafka.clientKey`.</li><li>Example: `/certs/kafka-client.pem`</li><li>Type: string</li></ul> |
| **`alpha.cdc.kafka.clientKey`** | <ul><li>Path inside the container to the client certificate's private key.</li><li>Example: `/certs/kafka-client.key`</li><li>Type: string</li></ul> |
| **`alpha.cdc.solace.host`**<br>[Required when `alpha.cdc.sink` is `solace`] | <ul><li>Solace broker address, `tcp://` or `tcps://` with the port.</li><li>Example: `tcp://solace:55555`</li><li>Type: string</li></ul> |
| **`alpha.cdc.solace.vpn`** | <ul><li>Solace Message VPN on the broker.</li><li>Default: `default`</li><li>Example: `default`</li><li>Type: string</li></ul> |
| **`alpha.cdc.solace.user`** | <ul><li>Solace username.</li><li>Example: `cdc`</li><li>Type: string</li></ul> |
| **`alpha.cdc.solace.password`** | <ul><li>Solace password.</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`alpha.cdc.solace.topic`** | <ul><li>Topic used when `alpha.cdc.topic` is not set.</li><li>Example: `rhize/cdc`</li><li>Type: string</li></ul> |
| **`alpha.cdc.solace.trustStore`** | <ul><li>Path inside the container to a TLS trust store directory, for a `tcps://` host.</li><li>Example: `/certs/solace`</li><li>Type: string</li></ul> |
| **`alpha.cdc.http`**<br>[Required when `alpha.cdc.sink` is `http`] | <ul><li>URL each mutation is sent to as a JSON `POST`.</li><li>Example: `http://ingest:8080/cdc`</li><li>Type: string</li></ul> |
| **`alpha.cdc.file`**<br>[Required when `alpha.cdc.sink` is `file`] | <ul><li>Directory inside the container that changes are written to as a log file.</li><li>Example: `/dgraph/cdc`</li><li>Type: string</li></ul> |

Mutations published to Kafka with SASL:

```yaml
alpha:
  cdc:
    enabled: true
    sink: kafka
    topic: dgraph-cdc
    kafka:
      brokers: redpanda:9092
      saslUser: cdc
      saslPassword: ExamplePassword123
      saslMechanism: SCRAM-SHA-256
```

## Helm chart values

The shared values documented in `shared-helm-values.md` do not
apply to this chart, which nests everything under `zero`, `alpha`,
`backups`, and `global`. The values below are the ones likely to need changing.

### Image

| Value | Description |
| --- | --- |
| **`image.registry`** | <ul><li>Registry of the container image for both zero and alpha.</li><li>Default: `registry.gitlab.com`</li><li>Example: `registry.gitlab.com`</li><li>Type: string</li></ul> |
| **`image.repository`** | <ul><li>Repository of the image.</li><li>Default: `libremfg/baas`</li><li>Example: `libremfg/baas`</li><li>Type: string</li></ul> |
| **`image.tag`** | <ul><li>Image tag. Pinned in the values file rather than tracking `appVersion`.</li><li>Default: `v4.5.0`</li><li>Example: `v4.5.0`</li><li>Type: string</li></ul> |
| **`image.pullPolicy`** | <ul><li>When the kubelet fetches the image. `Always` pulls on every pod start, which is what a moving tag such as `latest` needs. `IfNotPresent` pulls only when the tag is missing from the node. `Never` never pulls, so the image has to be on the node already.</li><li>Default: `IfNotPresent`</li><li>Example: `IfNotPresent`</li><li>Type: string</li></ul> |
| **`image.pullSecrets`** | <ul><li>Image pull secrets, which must already exist in the namespace.</li><li>Example: `[regcred-gitlab]`</li><li>Type: list</li></ul> |

### Alpha

| Value | Description |
| --- | --- |
| **`alpha.replicaCount`** | <ul><li>Number of alpha pods. Should be a multiple of `zero.shardReplicaCount` for a balanced cluster.</li><li>Default: `3`</li><li>Example: `3`</li><li>Type: integer</li></ul> |
| **`alpha.configFile`** | <ul><li>Map of filename to file contents, rendered into a ConfigMap mounted at `/dgraph/config` and passed as `DGRAPH_ALPHA_CONFIG`. The default sets `lru_mb`, the security whitelist, and telemetry. Only the first key alphabetically is passed to Dgraph.</li><li>Default: the chart's own `config.yaml`</li><li>Example: see the example block below</li><li>Type: map</li></ul> |
| **`alpha.extraFlags`** | <ul><li>Raw string spliced into the `dgraph alpha` command line. The way to reach any Dgraph flag the chart does not model.</li><li>Example: `--security whitelist=10.0.0.0/8`</li><li>Type: string</li></ul> |
| **`alpha.extraEnvs`**<br>[Required] | <ul><li>Extra container environment variables, and where the `BAAS_OIDC_*` variables have to go. A list set here replaces the chart's own rather than adding to it, so repeat every entry this deployment still wants: `DGRAPH_ALPHA_WHITELIST`, which the chart sets to `0.0.0.0:255.255.255.255` and so disables the IP whitelist entirely, and the OIDC settings that carry a default in the table above.</li><li>Default: `DGRAPH_ALPHA_WHITELIST` and the OIDC settings shown with a default above</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`alpha.extraEnvFrom`** | <ul><li>Extra `envFrom` entries referencing a ConfigMap or Secret.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`alpha.secrets.useExistingSecret`** | <ul><li>Injects `OIDC_SECRET` from an existing Kubernetes Secret.</li><li>Default: `false`</li><li>Example: `true`</li><li>Type: boolean</li></ul> |
| **`alpha.secrets.secretName`**<br>[Required when `alpha.secrets.useExistingSecret` is `true`] | <ul><li>Kubernetes Secret holding the OIDC client secret.</li><li>Example: `libre-client-secrets`</li><li>Type: string</li></ul> |
| **`alpha.secrets.secretKey`**<br>[Required when `alpha.secrets.useExistingSecret` is `true`] | <ul><li>Name of the entry within that Secret.</li><li>Example: `libreBaas`</li><li>Type: string</li></ul> |
| **`alpha.caFile`** | <ul><li>PEM CA certificate. When set, the certificate is mounted at `/certs` and `BAAS_OIDC_CA_FILE` is set to `/certs/ca.pem`. Give it as a YAML block, `alpha.caFile: \|`, with the certificate's lines indented beneath.</li><li>Example: `-----BEGIN CERTIFICATE-----…`</li><li>Type: string</li></ul> |
| **`alpha.persistence.size`** | <ul><li>Volume size per alpha pod.</li><li>Default: `10Gi`</li><li>Example: `10Gi`</li><li>Type: string</li></ul> |
| **`alpha.persistence.storageClass`** | <ul><li>Storage class. Empty uses the cluster default; `-` disables dynamic provisioning.</li><li>Example: `gp3`</li><li>Type: string</li></ul> |
| **`alpha.resources`** | <ul><li>Resource requests and limits for each alpha pod. Raise the memory request in line with the size of the data set.</li><li>Default: `2Gi` memory and `100m` CPU requested, no limits</li><li>Example: see the example block below</li><li>Type: object</li></ul> |
| **`alpha.service.type`** | <ul><li>How the Service is reached. `ClusterIP` gives an address that only works inside the cluster. `NodePort` also opens a fixed port on every node. `LoadBalancer` additionally asks the cloud provider for an external address. `ExternalName` points the Service at a DNS name instead of at pods.</li><li>Default: `ClusterIP`</li><li>Example: `ClusterIP`</li><li>Type: string</li></ul> |
| **`alpha.ingress.enabled`** | <ul><li>Creates an Ingress for the alpha HTTP endpoint. Overridden by `global.ingress` when that is enabled.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`alpha.encryption.enabled`** | <ul><li>Turns on Dgraph enterprise encryption at rest.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`alpha.encryption.file`**<br>[Required when `alpha.encryption.enabled` is `true`] | <ul><li>Map of filename to the base64 encoded encryption key, mounted at `/dgraph/enc`. The filename must match the `encryption_key_file` Dgraph setting.</li><li>Example: `{enc_key_file: RXhhbXBsZUVuY0tleTE2Ygo=}`</li><li>Type: map</li></ul> |
| **`alpha.antiAffinity`** | <ul><li>`soft` or `hard` pod anti-affinity. `soft` allows two alphas on one node, so `hard` is safer for production.</li><li>Default: `soft`</li><li>Example: `soft`</li><li>Type: string</li></ul> |
| **`alpha.initContainers.init.enabled`** | <ul><li>Runs one init container before alpha starts.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`alpha.initContainers.init.command`** | <ul><li>Command the init container runs. The default waits for a file to appear at `/dgraph/doneinit` and blocks alpha until something else writes it, so replace it with the command you want to run first.</li><li>Default: the wait-for-file command</li><li>Example: `[sh, -c, "until nc -z baas-zero-headless 5080; do sleep 2; done"]`</li><li>Type: list</li></ul> |
| **`alpha.terminationGracePeriodSeconds`** | <ul><li>How long an alpha is given to shut down. Much longer than zero's `60`, because an alpha needs time to flush.</li><li>Default: `600`</li><li>Example: `600`</li><li>Type: integer</li></ul> |

An alpha sized for a larger data set, the OIDC endpoint it needs,
and one setting passed through its own config file. The environment variables
the chart ships are repeated here, since the list replaces them:

```yaml
alpha:
  configFile:
    config.yaml: |
      lru_mb: 2048
  extraEnvs:
    - name: DGRAPH_ALPHA_WHITELIST
      value: 0.0.0.0:255.255.255.255
    - name: BAAS_OIDC_URL
      value: "http://keycloak:80"
    - name: BAAS_OIDC_REALM
      value: "libre"
    - name: BAAS_OIDC_CLIENT_ID
      value: "libreBaas"
    - name: BAAS_OIDC_SCOPEMAP
      value: /dgraph/additional-config/scopemap.json
  extraEnvFrom:
    - secretRef:
        name: my-secret
  resources:
    requests:
      memory: 8Gi
      cpu: 2
```

### Zero

| Value | Description |
| --- | --- |
| **`zero.replicaCount`** | <ul><li>Number of zero pods. Should be odd, for Raft quorum.</li><li>Default: `3`</li><li>Example: `3`</li><li>Type: integer</li></ul> |
| **`zero.shardReplicaCount`** | <ul><li>How many alpha replicas hold each data shard.</li><li>Default: `3`</li><li>Example: `3`</li><li>Type: integer</li></ul> |
| **`zero.persistence.size`** | <ul><li>Volume size per zero pod.</li><li>Default: `10Gi`</li><li>Example: `10Gi`</li><li>Type: string</li></ul> |
| **`zero.persistence.storageClass`** | <ul><li>Storage class. Empty uses the cluster default; `-` disables dynamic provisioning.</li><li>Example: `gp3`</li><li>Type: string</li></ul> |
| **`zero.resources`** | <ul><li>Resource requests and limits for each zero pod.</li><li>Default: `250Mi` memory and `50m` CPU requested, no limits</li><li>Example: see the example block below</li><li>Type: object</li></ul> |
| **`zero.service.type`** | <ul><li>How the zero Service is reached. Takes the same values as `alpha.service.type`.</li><li>Default: `ClusterIP`</li><li>Example: `ClusterIP`</li><li>Type: string</li></ul> |

A zero with a larger memory request:

```yaml
zero:
  resources:
    requests:
      memory: 1Gi
```

### Backups

Dgraph enterprise backups, run as Kubernetes CronJobs that call the alpha admin endpoint.

| Value | Description |
| --- | --- |
| **`backups.full.enabled`** | <ul><li>Creates the full backup CronJob.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`backups.full.schedule`** | <ul><li>Cron schedule for full backups, in server time. The default runs at midnight.</li><li>Default: `0 0 * * *`</li><li>Example: `0 0 * * *`</li><li>Type: string</li></ul> |
| **`backups.incremental.enabled`** | <ul><li>Creates the incremental backup CronJob.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`backups.incremental.schedule`** | <ul><li>Cron schedule for incremental backups, in server time. The default runs hourly except at midnight.</li><li>Default: `0 1-23 * * *`</li><li>Example: `0 1-23 * * *`</li><li>Type: string</li></ul> |
| **`backups.destination`**<br>[Required when `backups.full.enabled` or `backups.incremental.enabled` is `true`] | <ul><li>Where backups are written: a file path or an `s3://…` URL.</li><li>Default: `/dgraph/backups`</li><li>Example: `/dgraph/backups`</li><li>Type: string</li></ul> |
| **`backups.subpath`** | <ul><li>Subdirectory under the destination. The default embeds a `date` command so full and related incremental backups land together, which means the subpath has to be a directory name that matches the backup schedule.</li><li>Default: `dgraph_$(date +%Y%m%d)`</li><li>Example: `dgraph_$(date +%Y%m%d)`</li><li>Type: string</li></ul> |
| **`backups.nfs.enabled`** | <ul><li>Mounts an NFS export into the alpha pods for backups. Needs an existing NFS server.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`backups.nfs.server`**<br>[Required when `backups.nfs.enabled` is `true`] | <ul><li>Address of the NFS server.</li><li>Example: `nfs.example.com`</li><li>Type: string</li></ul> |
| **`backups.nfs.path`**<br>[Required when `backups.nfs.enabled` is `true`] | <ul><li>Exported path on the NFS server.</li><li>Example: `/exports/dgraph`</li><li>Type: string</li></ul> |
| **`backups.nfs.storage`** | <ul><li>Size of the NFS volume.</li><li>Default: `512Gi`</li><li>Example: `512Gi`</li><li>Type: string</li></ul> |
| **`backups.nfs.mountPath`** | <ul><li>Where the export is mounted in the alpha pods.</li><li>Default: `/dgraph/backups`</li><li>Example: `/dgraph/backups`</li><li>Type: string</li></ul> |
| **`backups.volume.enabled`** | <ul><li>Mounts an existing PVC into the alpha pods for backups.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`backups.volume.claim`**<br>[Required when `backups.volume.enabled` is `true`] | <ul><li>Name of the PVC. With more than one alpha pod the claim must be `ReadWriteMany`.</li><li>Example: `dgraph-backups`</li><li>Type: string</li></ul> |
| **`backups.volume.mountPath`** | <ul><li>Where the claim is mounted in the alpha pods.</li><li>Default: `/dgraph/backups/`</li><li>Example: `/dgraph/backups/`</li><li>Type: string</li></ul> |
| **`backups.admin.auth_token`** | <ul><li>Auth token protecting `/login` and `/admin`, which must match the alpha configuration.</li><li>Example: `exampleDgraphAuthToken123`</li><li>Type: string</li></ul> |
| **`backups.keys.s3.access`**<br>[Required when `backups.destination` is an `s3://` URL] | <ul><li>AWS access key id, injected as `AWS_ACCESS_KEY_ID`. Supply from a Kubernetes Secret.</li><li>Example: `AKIAIOSFODNN7EXAMPLE`</li><li>Type: string</li></ul> |
| **`backups.keys.s3.secret`**<br>[Required when `backups.destination` is an `s3://` URL] | <ul><li>AWS secret access key, injected as `AWS_SECRET_ACCESS_KEY`. Supply from a Kubernetes Secret.</li><li>Example: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`</li><li>Type: string</li></ul> |

### Global

| Value | Description |
| --- | --- |
| **`global.domain`** | <ul><li>Cluster DNS domain used to build the peer addresses alpha and zero use to find each other. Change the domain only on a cluster with a non-standard DNS domain.</li><li>Default: `cluster.local`</li><li>Example: `cluster.local`</li><li>Type: string</li></ul> |
| **`global.ingress.enabled`** | <ul><li>Creates one Ingress for alpha, overriding `alpha.ingress`.</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`global.ingress.alpha_hostname`**<br>[Required when `global.ingress.enabled` is `true`] | <ul><li>Hostname the Ingress routes to alpha.</li><li>Example: `baas.example.libremfg.ai`</li><li>Type: string</li></ul> |
| **`global.ingress.certResolver`** | <ul><li>Traefik certificate resolver.</li><li>Default: `production`</li><li>Example: `production`</li><li>Type: string</li></ul> |
| **`global.ingress.tls`** | <ul><li>TLS configuration for the Ingress, as a list of entries, each pairing the hostnames it covers with the Secret holding the certificate.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`global.ingress.annotations`** | <ul><li>Annotations for the Ingress.</li><li>Example: see the example block below</li><li>Type: map</li></ul> |

One Ingress for alpha, terminating TLS with an existing Secret:

```yaml
global:
  ingress:
    tls:
      - hosts:
          - baas.example.libremfg.ai
        secretName: baas-tls
    annotations:
      kubernetes.io/ingress.class: traefik
```
