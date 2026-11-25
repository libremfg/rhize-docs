---
title: 'TypeScript host service configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize typescript-host-service
aliases:
  - /reference/service-config/typescript-host-service-configuration
weight: 900
---


Configure the Typescript-host service through its Helm chart.

## Application configuration

Everything in this section goes into the chart's `typescriptHostServiceConfig`
value, which becomes typescript-host-service's configuration file. Override individual keys with the environment variable listed for it,
supplied through the chart's `envVars` or `additionalSecrets`.

| Value | Description |
| --- | --- |
| **`port`** | <ul><li>Port the Restate HTTP endpoint binds to, and the port advertised to Restate during registration.</li><li>Environment variable: `RHIZE_TSHOST_PORT`</li><li>Default: the chart's `service.port`</li><li>Example: `9081`</li><li>Type: integer</li></ul> |
| **`runtime.adminUrl`**<br>[Required] | <ul><li>Restate admin API typescript-host-service registers itself with at startup.</li><li>Environment variable: `RHIZE_TSHOST_RUNTIME_SERVICE_URL`</li><li>Default: `http://runtime:9070`</li><li>Example: `http://restate:9070`</li><li>Type: string</li></ul> |
| **`runtime.deploymentName`** | <ul><li>Hostname Restate is told to call back on, combined with `port` to form the registered URI. Derived from the pod hostname, so override it when the Kubernetes Service name differs from the Deployment name.</li><li>Environment variable: `RHIZE_TSHOST_RUNTIME_DEPLOYMENT_NAME`</li><li>Default: the Deployment name</li><li>Example: `typescript-host-service`</li><li>Type: string</li></ul> |
| **`jsonata.cacheEnabled`** | <ul><li>Caches compiled JSONata expressions. Turning the cache off recompiles every expression on every call.</li><li>Environment variable: `RHIZE_TSHOST_JSONATA_CACHE_ENABLED`</li><li>Default: `true`</li><li>Example: `true`</li><li>Type: boolean</li></ul> |
| **`jsonata.cacheItems`** | <ul><li>Maximum number of compiled expressions held in the cache.</li><li>Environment variable: `RHIZE_TSHOST_JSONATA_CACHE_ITEMS`</li><li>Default: `1000`</li><li>Example: `1000`</li><li>Type: integer</li></ul> |
| **`jsonata.cacheAge`** | <ul><li>Maximum age of a cache entry in milliseconds. The default is 24 hours.</li><li>Environment variable: `RHIZE_TSHOST_JSONATA_CACHE_AGE`</li><li>Default: `86400000`</li><li>Example: `86400000`</li><li>Type: integer</li></ul> |
| **`grpc.listener`** | <ul><li>Address and port the gRPC server binds to.</li><li>Environment variable: `RHIZE_TSHOST_GRPC_LISTENER`</li><li>Default: `0.0.0.0:` followed by the chart's `gRPCService.port`</li><li>Example: `0.0.0.0:9082`</li><li>Type: string</li></ul> |

## Helm chart values

Values shared by every chart are documented in
`shared-helm-values.md`. This chart exposes an HTTP port and a gRPC
port on one Service, and has no `serviceAccount` or
`serviceMonitor` values.

| Value | Description |
| --- | --- |
| **`typescriptHostServiceConfig`** | <ul><li>The application configuration, rendered into the `typescript-host-service-config` ConfigMap as `config.yaml` and mounted at `/app/config`.</li><li>Example: see the example block below</li><li>Type: object</li></ul> |
| **`envVars`** | <ul><li>Map of environment variable names to values passed to the container.</li><li>Example: see the example block below</li><li>Type: map</li></ul> |
| **`additionalSecrets`** | <ul><li>List of entries that each carry one value from a Kubernetes Secret into an environment variable: `name` is the variable the service reads, `secretName` is the Secret to take the value from, and `secretKey` is the name of the entry within that Secret.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`service.port`** | <ul><li>HTTP port of the Service and the container.</li><li>Default: `9081`</li><li>Example: `9081`</li><li>Type: integer</li></ul> |
| **`service.targetPort`** | <ul><li>Name of the HTTP container port, which the Service sends HTTP traffic to.</li><li>Default: `http`</li><li>Example: `http`</li><li>Type: string</li></ul> |
| **`service.protocol`** | <ul><li>Protocol of the HTTP port.</li><li>Default: `TCP`</li><li>Example: `TCP`</li><li>Type: string</li></ul> |
| **`service.name`** | <ul><li>Name of the HTTP port on the Service.</li><li>Default: `http`</li><li>Example: `http`</li><li>Type: string</li></ul> |
| **`gRPCService.port`** | <ul><li>gRPC port of the Service and the container.</li><li>Default: `9082`</li><li>Example: `9082`</li><li>Type: integer</li></ul> |
| **`gRPCService.targetPort`** | <ul><li>Name of the gRPC container port, which the Service sends gRPC traffic to.</li><li>Default: `grpc`</li><li>Example: `grpc`</li><li>Type: string</li></ul> |
| **`gRPCService.protocol`** | <ul><li>Protocol of the gRPC port.</li><li>Default: `TCP`</li><li>Example: `TCP`</li><li>Type: string</li></ul> |
| **`gRPCService.name`** | <ul><li>Name of the gRPC port on the Service.</li><li>Default: `grpc`</li><li>Example: `grpc`</li><li>Type: string</li></ul> |

The cache settings in the configuration file, the deployment name overridden by
a variable, and the Restate URL taken from the `restateAdminUrl` entry of a
Secret named `libre-secrets`:

```yaml
typescriptHostServiceConfig:
  jsonata:
    cacheEnabled: true
    cacheItems: 1000
envVars:
  RHIZE_TSHOST_RUNTIME_DEPLOYMENT_NAME: "typescript-host-service"
additionalSecrets:
  - name: RHIZE_TSHOST_RUNTIME_SERVICE_URL
    secretName: libre-secrets
    secretKey: restateAdminUrl
```
