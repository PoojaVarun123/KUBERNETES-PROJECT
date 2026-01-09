Monitoring detects and alerts on known issues using predefined metrics, while observability enables teams to understand and debug complex, 
unknown problems using metrics, logs, and traces.
-------------------------------------------------
Metrics – trends and health
Logs – detailed events
Traces – request flow across services
-------------------------------------------------
| Tool          | Port | What You Access   |
| ------------- | ---- | ----------------- |
| Prometheus    | 9090 | Metrics & queries |
| Grafana       | 3000 | Dashboards        |
| Elasticsearch | 9200 | Log storage API   |
| Kibana        | 5601 | Log UI            |
| Logstash      | 5044 | Log ingestion     |
--------------------------------------------------
Prometheus is a pull-based monitoring system consisting of a server that scrapes metrics from targets, stores them in a 
time-series database, evaluates alerts, and exposes data via PromQL, typically visualized using Grafana.
---
Kubernetes Cluster
 ├── Prometheus Operator
 ├── Prometheus Server
 ├── Alertmanager
 ├── Grafana
 ├── Node Exporter
 ├── kube-state-metrics
 ├── CRDs (ServiceMonitor, PodMonitor, etc.)
 └── Prebuilt Dashboards & Alerts
---
In managed Kubernetes, node and workload metrics are fully available via kubelet, cAdvisor, and kube-state-metrics, while control plane 
metrics are managed and exposed by the cloud provider through their native monitoring services rather than directly by Prometheus.
---
Container → cAdvisor → kubelet → Prometheus
Node → node-exporter → Prometheus
K8s API → kube-state-metrics → Prometheus
----------------------------------------
| Layer                | Exporter / Source      | Metric Category   | Important Metrics                                                         | What It Tells You          | Used For           |
| -------------------- | ---------------------- | ----------------- | ------------------------------------------------------------------------- | -------------------------- | ------------------ |
| **Node**             | **Node Exporter**      | CPU               | `node_cpu_seconds_total`                                                  | CPU usage per node/core    | Node saturation    |
|                      |                        | Memory            | `node_memory_MemAvailable_bytes`                                          | Free memory                | OOM risk           |
|                      |                        | Disk              | `node_filesystem_avail_bytes`                                             | Disk free space            | Disk pressure      |
|                      |                        | Disk I/O          | `node_disk_io_time_seconds_total`                                         | Disk latency               | Slow I/O           |
|                      |                        | Network           | `node_network_receive_bytes_total`<br>`node_network_transmit_bytes_total` | Node bandwidth             | Network saturation |
|                      |                        | Network Errors    | `node_network_receive_errs_total`                                         | Packet loss                | NIC issues         |
| **Container / Pod**  | **cAdvisor (kubelet)** | CPU               | `container_cpu_usage_seconds_total`                                       | Container CPU usage        | Pod scaling        |
|                      |                        | Memory            | `container_memory_working_set_bytes`                                      | Real memory usage          | OOM debugging      |
|                      |                        | Network           | `container_network_receive_bytes_total`                                   | Pod traffic                | Traffic spikes     |
|                      |                        | Filesystem        | `container_fs_usage_bytes`                                                | Container disk usage       | Storage issues     |
| **Kubernetes State** | **kube-state-metrics** | Pod Status        | `kube_pod_status_phase`                                                   | Pod lifecycle state        | Crash detection    |
|                      |                        | Restarts          | `kube_pod_container_status_restarts_total`                                | Container restarts         | Stability          |
|                      |                        | Deployments       | `kube_deployment_status_replicas_available`                               | Healthy replicas           | Scaling health     |
|                      |                        | Node Conditions   | `kube_node_status_condition`                                              | Node readiness             | Cluster health     |
|                      |                        | Requests / Limits | `kube_pod_container_resource_requests`                                    | Resource allocation        | Capacity planning  |
| **Application**      | **App Exporters**      | Traffic           | `http_requests_total`                                                     | Request volume             | Load               |
|                      |                        | Latency           | `http_request_duration_seconds_bucket`                                    | Response time (P95/P99)    | User experience    |
|                      |                        | Errors            | `http_requests_total{status=~"5.."}`                                      | Error rate                 | Reliability        |
| **Autoscaling**      | **metrics-server**     | CPU               | Pod CPU usage                                                             | Scale decisions            | HPA                |
|                      |                        | Memory            | Pod memory usage                                                          | Scale decisions            | HPA                |
| **API Server**       | **Control Plane**      | Latency           | `apiserver_request_duration_seconds_bucket`                               | API responsiveness         | Cluster health     |
|                      |                        | Errors            | `apiserver_request_total{code=~"5.."}`                                    | API failures               | Stability          |
| **External**         | **Blackbox Exporter**  | Availability      | `probe_success`                                                           | Endpoint up/down           | Uptime             |
|                      |                        | Latency           | `probe_duration_seconds`                                                  | Network + app latency      | SLA                |
|                      |                        | HTTP              | `probe_http_status_code`                                                  | Response code              | External health    |
| **Service Mesh**     | **Istio / Linkerd**    | Traffic           | `istio_requests_total`                                                    | Service calls              | Dependency mapping |
|                      |                        | Latency           | `istio_request_duration_milliseconds_bucket`                              | Service-to-service latency | Microservices      |
| **Tracing**          | **Tempo / Jaeger**     | Request Path      | Trace spans                                                               | End-to-end latency         | Root cause         |
SLI → measured metric
SLO → internal target
Error Budget → allowed failure
SLA → customer promise
----------------------------------------------
Site reliability Engineer
Site Reliability Engineering is a discipline that applies software engineering principles to operations.
The goal of SRE is to build scalable and highly reliable systems.
SRE teams use SLIs, SLOs, and error budgets to measure and manage reliability.
They automate operations, reduce manual work, and improve system resilience.
SRE balances feature velocity with stability using data-driven decisions.
It focuses on observability, incident management, and continuous improvement.”
---
Build Monitoring & Alerts
✅ Define SLOs and track error budgets
✅ Automate deployments and rollbacks
✅ Handle incidents and on-call rotations
✅ Perform postmortems (blameless)
✅ Improve system design for reliability
---
Incident management is a core responsibility of SRE teams.
SREs define SLIs and SLOs to detect incidents early and prioritize impact.
On-call rotations ensure 24/7 coverage for rapid response to production issues.
During incidents, SREs focus on service restoration first, not root cause.
After resolution, they conduct blameless postmortems to prevent recurrence.
Error budgets help decide when to pause feature releases and focus on reliability.
---
User experience → SLI
System capability → SLO
Business/legal risk → SLA
---
When defining SLIs, SLOs, and SLAs, teams consider user experience, business impact, system reliability, and cost.
SLIs focus on measurable signals like availability, latency, error rate, and throughput.
SLOs are set based on realistic system behavior and error budgets.
SLAs are defined more conservatively because they are customer-facing and legally binding.
Alerting, historical performance, and recovery capability are also key factors.”
--------------------------------------------------
Availability – How to Calculate

Availability measures the percentage of time (or requests) a service is usable.
Method 1: Time-Based Availability (Classic)

Formula
Availability (%) = (Uptime / Total Time) × 100

Example
Total time in a month = 30 days = 43,200 minutes
Downtime = 43 minutes
Availability = (43,200 − 43) / 43,200 × 100
             ≈ 99.9%
✔ Used for infrastructure & legacy SLAs
---
Method 2: Request-Based Availability (Modern SRE – Preferred)

Availability = (Successful Requests / Total Requests) × 100
Total requests = 1,000,000
Failed requests = 1,000
Availability = 999,000 / 1,000,000 × 100
             = 99.9%
✔ Preferred for microservices & APIs
---
2️⃣ Latency – How to Calculate
Latency measures how long requests take to respond.
Basic Latency Measurement
Latency = Response Time − Request Time
Percentile-Based Latency (Production Standard)
Instead of averages, we use percentiles.
Metric	Meaning
p50	50% of requests are faster than this
p95	95% of requests are faster
p99	99% of requests are faster

p95 latency = 300ms
➡️ 95% of requests complete within 300ms
---
3️⃣ Latency SLI Example
SLI
Percentage of requests completed under 300ms

Total requests = 1,000,000
Requests ≤300ms = 980,000
Latency SLI = 980,000 / 1,000,000 × 100
            = 98%
----------------------------------------------------
In a blameless postmortem, we use SLIs to measure impact, SLOs and error budgets to assess reliability, and SLAs to understand 
customer commitments.
----
SLI → measures performance
SLO → target for SLI
Error Rate → actual failures
Error Budget → allowed failures
SLA → customer promise
---
SLIs measure service performance, SLOs define reliability targets, error budgets allow controlled failure, and SLAs are customer-facing guarantees.”
