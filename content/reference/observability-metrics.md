---
title: Observability metrics
description: Metrics from the Rhize microservices, collected by Prometheus.
weight: 350
category: "reference"
---

Rhize uses [Prometheus](https://prometheus.io/docs/introduction/overview/) to monitor metrics from many of its [microservices]({{< relref "/reference/service-config" >}}).
For the Kubernetes cluster, Rhize runs the Prometheus operator and monitors the accumulated metrics in Grafana dashboards.
Monitoring occurs granularly, on the levels of cluster, pod, and container.


## Metrics endpoints

The service metrics have endpoints at the following ports:

| Service | Available | Enabled | Port |
|---------|-----------|---------|------|
| Audit   | Y         | Y       | 8084 |
| BAAS    | Y         | Y       | 8080 |
| BPMN    | Y         | Y       | 8081 |
| Core    | Y         | Y       | 8080 |
| NATS    |           | Y       | 7777 |
| Router  | Y         |         | 9090 |
| Tempo   | Y         | Y       | 3100 |

NATS has an available endpoint through an exporter that is present on the cluster.
Router has an available endpoint that is disabled by default.

## Metrics configuration

For services where metrics are disabled by default, some configuration steps may be required.
In case you are experimenting locally, this document includes for both the cluster and for Docker.

After you enable metrics, add them into the Prometheus configuration file by pointing to that service endpoint.
For example:

```yaml
- job_name: 'rhize-application-monitoring'
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
    - targets: ['audit-demo.demo.svc.cluster.local:8084', 'baas-alpha.demo.svc.cluster.local:8080', 'bpmn-demo.demo.svc.cluster.local:8081', 'core-demo.demo.svc.cluster.local:8080', 'grafana-demo.demo.svc.cluster.local:3000', 'tempo.demo.svc.cluster.local:3100', 'nats-demo-headless.demo.svc.cluster.local:7777', 'router-demo.demo.svc.cluster.local:9090']
```

### NATS

While NATS has no available metrics endpoint, the cluster includes a [NATS Prometheus exporter](https://github.com/nats-io/prometheus-nats-exporter).
NATS metrics are exposed through port `7777`.


#### Cluster

Since the cluster already includes the exporter, no further configuration is required.
This endpoint should be connected through the NATS headless pod. For example:

`nats-demo-headless.demo.svc.cluster.local:7777`

#### Docker

To get NATS metrics in Docker, use the exporter mentioned in the preceding section.
The following is a sample docker-compose configuration for the exporter.

```yaml
services:
	# -- Other services
	nats-exporter:
    image: natsio/prometheus-nats-exporter:latest
    container_name: nats-exporter
    command: "-varz 'http://nats:5555'"
    depends_on:
      - nats
    ports:
      - 7777:7777
```

Access NATS metrics at `localhost:7777/metrics`

### Router

#### Cluster

To enable metrics, the Router Helm chart needs to have several options added or changed, as follows:
For details, refer to the [Official Apollo instructions](https://www.apollographql.com/docs/router/containerization/kubernetes/#deploy-with-metrics-endpoints).

```yaml
router:
  configuration:
	  # -- Other configuration prior
    telemetry:
      metrics:
        prometheus:
          enabled: true
          listen: 0.0.0.0:9090
          path: "/metrics"

# -- Open container ports
containerPorts:
  metrics: 9090

# -- Enable service monitor
serviceMonitor:
  enabled: true
```

You can connect to this endpoint through the router pod.
For example:

`router-demo.demo.svc.cluster.local:9090`

#### Docker


To enable Router metrics, modify its configuration file.
For details, refer to the [Official Apollo Instructions](https://www.apollographql.com/docs/router/configuration/telemetry/exporters/metrics/prometheus/).

The following is an example configuration:


```yaml
# -- Other configuration prior
telemetry:
  exporters:
     metrics:
       prometheus:
         enabled: true
         listen: 0.0.0.0:9090
         path: /metrics
```

This opens the metrics endpoint on port `9090`.
To view it externally, you must expose the port in docker-compose.
Once the port is exposed, view the metrics at `localhost:9090/metrics`

## Available Rhize microservice metrics

Several common metrics appear between Rhize microservices:
- `go`
- `process`
- `http`.


| Service | [Instrumented Prometheus Go Application](https://prometheus.io/docs/guides/go-application/) | process metrics | HTTP metrics* | Additional |
|---------|---------------------------------------------------|-----------------|---------------|------------|
| Audit   | Y                                                 | Y               | Y             |            |
| BAAS    | Y                                                 | Y               |               | Y          |
| BPMN    | Y                                                 | Y               | Y             | Y          |
| Core    | Y                                                 |                 | Y             |            |
| NATS    | Y                                                 | Y               | Y             | Y          |
| Router  |                                                   |                 |               | Y          |
| Tempo   | Y                                                 |                 |               | Y          |

{{< notice "note" >}}
HTTP metrics are noted as `promhttp`.
{{< /notice >}}

### BAAS

Additional metrics on BAAS are from [dgraph](https://dgraph.io/docs/deploy/admin/metrics/). These include two categories: Badger and Dgraph.

#### Sample

```
# HELP badger_disk_reads_total Number of cumulative reads by Badger
# TYPE badger_disk_reads_total untyped
badger_disk_reads_total 0

# HELP badger_disk_writes_total Number of cumulative writes by Badger
# TYPE badger_disk_writes_total untyped
badger_disk_writes_total 0

# HELP badger_gets_total Total number of gets
# TYPE badger_gets_total untyped
badger_gets_total 0
```

```
# HELP dgraph_alpha_health_status Status of the alphas
# TYPE dgraph_alpha_health_status gauge
dgraph_alpha_health_status 1

# HELP dgraph_disk_free_bytes Total number of bytes free on disk
# TYPE dgraph_disk_free_bytes gauge
dgraph_disk_free_bytes{dir="postings_fs"} 1.0153562112e+10

# HELP dgraph_disk_total_bytes Total number of bytes on disk
# TYPE dgraph_disk_total_bytes gauge
dgraph_disk_total_bytes{dir="postings_fs"} 1.0447245312e+10
```

### BPMN

BPMN has four metrics unique to it, shown in full in the sample below.

#### Sample

```
# HELP bpmn_execution_commands The number of BPMN commands that have started executing
# TYPE bpmn_execution_commands counter
bpmn_execution_commands 1162

# HELP bpmn_instances_started BPMN Instances started but not necessarily completed
# TYPE bpmn_instances_started counter
bpmn_instances_started 166

# HELP bpmn_queue_CommandConsumerQueue Number of BPMN Commands currently waiting to be executed
# TYPE bpmn_queue_CommandConsumerQueue gauge
bpmn_queue_CommandConsumerQueue 0

# HELP bpmn_queue_StartOnNatsMessages Number of BPMN trigger messages received from NATS
# TYPE bpmn_queue_StartOnNatsMessages gauge
bpmn_queue_StartOnNatsMessages 0
```

### NATS

NATS has two categories of metrics:
- `gnatsd`
- `jetstream`

#### Sample

```
# HELP gnatsd_connz_in_bytes in_bytes
# TYPE gnatsd_connz_in_bytes counter
gnatsd_connz_in_bytes{server_id="nats-demo-0"} 0

# HELP gnatsd_connz_in_msgs in_msgs
# TYPE gnatsd_connz_in_msgs counter
gnatsd_connz_in_msgs{server_id="nats-demo-0"} 0

# HELP gnatsd_connz_limit limit
# TYPE gnatsd_connz_limit gauge
gnatsd_connz_limit{server_id="nats-demo-0"} 1024
```

```
# HELP jetstream_server_jetstream_disabled JetStream disabled or not
# TYPE jetstream_server_jetstream_disabled gauge
jetstream_server_jetstream_disabled{cluster="nats-demo",domain="",is_meta_leader="false",meta_leader="nats-demo-1",server_id="nats-demo-0",server_name="nats-demo-0"} 0

# HELP jetstream_server_max_memory JetStream Max Memory
# TYPE jetstream_server_max_memory gauge
jetstream_server_max_memory{cluster="nats-demo",domain="",is_meta_leader="false",meta_leader="nats-demo-1",server_id="nats-demo-0",server_name="nats-demo-0"} 2.147483648e+09

# HELP jetstream_server_max_storage JetStream Max Storage
# TYPE jetstream_server_max_storage gauge
jetstream_server_max_storage{cluster="nats-demo",domain="",is_meta_leader="false",meta_leader="nats-demo-1",server_id="nats-demo-0",server_name="nats-demo-0"} 5.36870912e+10
```

### Router

All metrics provided by Router are unique to Apollo Router.

#### Sample

```
# HELP apollo_router_cache_hit_count apollo_router_cache_hit_count
# TYPE apollo_router_cache_hit_count counter
apollo_router_cache_hit_count{kind="query planner",service_name="router-demo",storage="memory"} 121802

# HELP apollo_router_cache_hit_time apollo_router_cache_hit_time
# TYPE apollo_router_cache_hit_time histogram
apollo_router_cache_hit_time_bucket{kind="query planner",service_name="router-demo",storage="memory",le="0.001"} 121802
apollo_router_cache_hit_time_bucket{kind="query planner",service_name="router-demo",storage="memory",le="0.005"} 121802
apollo_router_cache_hit_time_bucket{kind="query planner",service_name="router-demo",storage="memory",le="0.015"} 121802
```

### Tempo

Tempo has a few categories of metrics:
- `jaeger`
- `prometheus`
- `tempo`
- `tempodb`.

The Tempo documentation [details](https://grafana.com/docs/tempo/latest/metrics-generator/) what these metrics measure.

#### Sample

```
# HELP jaeger_tracer_baggage_restrictions_updates_total Number of times baggage restrictions were successfully updated
# TYPE jaeger_tracer_baggage_restrictions_updates_total counter
jaeger_tracer_baggage_restrictions_updates_total{result="err"} 0
jaeger_tracer_baggage_restrictions_updates_total{result="ok"} 0

# HELP jaeger_tracer_baggage_truncations_total Number of times baggage was truncated as per baggage restrictions
# TYPE jaeger_tracer_baggage_truncations_total counter
jaeger_tracer_baggage_truncations_total 0
```

```
# HELP prometheus_remote_storage_exemplars_in_total Exemplars in to remote storage, compare to exemplars out for queue managers.
# TYPE prometheus_remote_storage_exemplars_in_total counter
prometheus_remote_storage_exemplars_in_total 0

# HELP prometheus_remote_storage_histograms_in_total HistogramSamples in to remote storage, compare to histograms out for queue managers.
# TYPE prometheus_remote_storage_histograms_in_total counter
prometheus_remote_storage_histograms_in_total 0

# HELP prometheus_remote_storage_samples_in_total Samples in to remote storage, compare to samples out for queue managers.
# TYPE prometheus_remote_storage_samples_in_total counter
prometheus_remote_storage_samples_in_total 0
```

```
# HELP tempo_distributor_ingester_clients The current number of ingester clients.
# TYPE tempo_distributor_ingester_clients gauge
tempo_distributor_ingester_clients 0

# HELP tempo_distributor_metrics_generator_clients The current number of metrics-generator clients.
# TYPE tempo_distributor_metrics_generator_clients gauge
tempo_distributor_metrics_generator_clients 0

# HELP tempo_distributor_push_duration_seconds Records the amount of time to push a batch to the ingester.
# TYPE tempo_distributor_push_duration_seconds histogram
tempo_distributor_push_duration_seconds_bucket{le="0.005"} 0
tempo_distributor_push_duration_seconds_bucket{le="0.01"} 0
```

```
# HELP tempodb_backend_hedged_roundtrips_total Total number of hedged backend requests. Registered as a gauge for code sanity. This is a counter.
# TYPE tempodb_backend_hedged_roundtrips_total gauge
tempodb_backend_hedged_roundtrips_total 0

# HELP tempodb_blocklist_poll_duration_seconds Records the amount of time to poll and update the blocklist.
# TYPE tempodb_blocklist_poll_duration_seconds histogram
tempodb_blocklist_poll_duration_seconds_bucket{le="0"} 0
tempodb_blocklist_poll_duration_seconds_bucket{le="60"} 2012
tempodb_blocklist_poll_duration_seconds_bucket{le="120"} 2012
```

## Dashboards

A number of Grafana dashboards are pre-configured for use with Prometheus metrics.
All dashboards in Grafana use Prometheus as a data source.

You can download them from [Rhize Dashboard templates](https://github.com/libremfg/rhize-templates/tree/main/dashboards).
