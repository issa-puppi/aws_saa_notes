# Performance Monitoring
---

## Amazon CloudWatch

Amazon CloudWatch is the AWS-native **observability service** — it collects metrics, centralizes logs, triggers alarms, and enables event-driven automation across virtually every AWS service and on-premises resource.

**Four fundamental pillars of CloudWatch:**
- **Metrics** — time-series data from AWS services and custom sources
- **Logs** — centralized log storage, filtering, and analysis
- **Alarms** — threshold-based or ML-based triggers that drive automated actions
- **Events / EventBridge** — event-driven automation in response to state changes (EventBridge supersedes CloudWatch Events) Δ

| **Component** | **What It Does** | **Key Exam Hook** |
|---------------|-----------------|-------------------|
| **Metrics** | Time-series performance data from AWS services and custom sources | CPU, network, disk I/O — but NOT memory or disk usage by default |
| **Alarms** | Watch a metric; fire actions on threshold breach or anomaly | SNS notification, Auto Scaling, EC2 action |
| **Composite Alarms** | Evaluate multiple alarms with AND/OR logic | Reduce alert noise in complex systems |
| **Logs** | Ingest, store, query application and system logs | Metric Filters → metrics; Logs Insights → ad-hoc queries |
| **Dashboards** | Custom visualizations across metrics and accounts | Cross-region, cross-account views |
| **Anomaly Detection** | ML baseline for metric behavior; alarm when metric deviates | No threshold to define manually |
| **Contributor Insights** | Identify top contributors to high-cardinality metric behavior | Find busiest IPs, users, resources driving load |
| **ServiceLens** | Unified health view integrating CloudWatch + X-Ray traces | End-to-end transaction visibility |

> 💡 **Exam Tip:** "Memory usage", "disk usage", "OS-level metrics not collected by default" → requires **Unified CloudWatch Agent** installed on the instance.
<br>CloudWatch collects **infrastructure metrics** by default — host-level OS internals require the agent.

---

## CloudWatch Metrics

A **metric** is a time-ordered set of data points published to CloudWatch. Metrics are the fundamental unit of monitoring in CloudWatch.

### Key Concepts

| **Concept** | **Definition** | **Exam Notes** |
|-------------|---------------|---------------|
| **Namespace** | Container for a group of related metrics — e.g., `AWS/EC2`, `AWS/RDS` | Custom metrics use a custom namespace (e.g., `MyApp/Performance`) |
| **Dimension** | Key-value pair that identifies a metric — e.g., `InstanceId=i-1234` | Up to **10 dimensions** † per metric |
| **Metric Name** | Identifies what is being measured — e.g., `CPUUtilization` | Uniquely defined by name + namespace + dimensions |
| **Period** | Time interval over which data is aggregated — e.g., 60 seconds | Determines granularity and retention tier |
| **Statistic** | Aggregation function applied over a period | Average, Sum, Min, Max, SampleCount, pNN.NN (percentile) |
| **Resolution** | How often data is collected | Standard: 1-minute granularity; High-resolution: 1-second granularity |

**Metrics cannot be deleted** — they automatically expire after 15 months based on resolution tier. §

### Metric Data Retention Tiers

| **Resolution / Period** | **Retention Duration** | **Use Case** |
|-------------------------|------------------------|-------------|
| < 60 seconds (high-resolution custom metrics) | **3 hours** | Sub-minute application telemetry |
| 60 seconds (1 minute) | **15 days** | Standard detailed monitoring |
| 300 seconds (5 minutes) | **63 days** | Standard default monitoring |
| 3,600 seconds (1 hour) | **455 days (~15 months)** | Long-term trend analysis |

> 💡 **Exam Tips:**
> <br>"How long are CloudWatch metrics retained?" → **15 months** (455 days at 1-hour resolution)
> <br>"Sub-minute granularity for custom application metrics" → **High-resolution custom metrics** (1-second resolution, 3-hour retention)

### High-Resolution Metrics

- Published with `PutMetricData` at 1-second granularity ‡
- High-resolution alarms can be set at 10-second or 30-second periods ‡ (higher cost ¤)
- Useful for latency-sensitive applications where 1-minute granularity misses spikes
- Every `PutMetricData` API call for a custom metric incurs a charge ¤

### EC2 Default vs. Detailed Monitoring

This is a high-frequency exam distinction:

| **Monitoring Type** | **Frequency** | **Cost** | **Enabled By** |
|--------------------|---------------|----------|----------------|
| **Basic (Default)** | Every **5 minutes** | Free § | Automatic on all EC2 instances |
| **Detailed** | Every **1 minute** | Paid ¤ | Enable per instance or at launch |
| **Sub-minute** | 1–30 seconds | Paid ¤ | Requires Unified CloudWatch Agent + custom metrics |

> ⚠️ **Exam Trap:** EC2 **does not** send memory or disk utilization to CloudWatch by default — regardless of whether basic or detailed monitoring is enabled.
<br>Detailed monitoring only increases the **frequency** of the built-in EC2 metrics (CPU, network, disk I/O). Memory and disk space always require the **Unified CloudWatch Agent**.

---

## CloudWatch Alarms

A CloudWatch alarm watches a **single metric** (or a math expression on metrics) over a specified time period and performs one or more actions based on the metric value relative to a threshold.

**Alarms invoke actions only for sustained state changes** — not for momentary spikes. A state must persist for a specified number of evaluation periods before triggering. §

### Alarm States

| **State** | **Meaning** |
|-----------|------------|
| `OK` | Metric is within the threshold |
| `ALARM` | Metric has breached the threshold |
| `INSUFFICIENT_DATA` | Not enough data points to evaluate |

### Alarm Configuration

- **Threshold type:** Static threshold — or — **Anomaly Detection** (ML-based band)
- **Evaluation period:** Number of data periods to evaluate
- **Datapoints to alarm:** How many of those periods must be breaching before triggering
- **Missing data treatment:** Treat as `OK`, `ALARM`, `INSUFFICIENT_DATA`, or `ignore`

### Alarm Actions

| **Action Type** | **Examples** |
|----------------|-------------|
| **SNS notification** | Email, SMS, Lambda trigger, SQS message |
| **Auto Scaling** | Scale in or scale out an ASG |
| **EC2 actions** | Stop, terminate, reboot, or recover an EC2 instance |
| **Systems Manager OpsCenter** | Create an OpsItem for investigation |

> 💡 **Exam Tips:**
> <br>"Automatically scale out EC2 instances when CPU > 70%" → **CloudWatch Alarm → Auto Scaling policy**
> <br>"Send an alert email when a metric breaches a threshold" → **CloudWatch Alarm → SNS topic**
> <br>"EC2 instance becomes unreachable due to underlying hardware failure" → **CloudWatch Alarm EC2 Recover action**

---

## Composite Alarms

A **Composite Alarm** evaluates the states of multiple alarms using Boolean logic (`AND`, `OR`, `NOT`).

- Reduces alert noise by triggering only when a combination of conditions is true
- Example: alarm only when *both* CPU is high *and* request latency is high — avoiding false positives from either condition alone
- The composite alarm can trigger actions itself (SNS, etc.)

> 💡 **Exam Tip:** "Reduce false-positive alerts in a complex multi-metric system" → **Composite Alarms**

---

## CloudWatch Anomaly Detection ※

- CloudWatch uses **ML algorithms** to build a baseline model of a metric's expected behavior
- An anomaly detection alarm fires when the metric value falls outside a dynamically computed band
- No static threshold required — the band adjusts for time-of-day and day-of-week patterns
- You can exclude specific time windows (e.g., maintenance windows) from the training model

> 💡 **Exam Tip:** "Alarm on unusual metric behavior without knowing what 'normal' is" → **CloudWatch Anomaly Detection**

---

## CloudWatch Logs

CloudWatch Logs centralizes logs from EC2 instances, Lambda functions, CloudTrail, Route 53, VPC Flow Logs, API Gateway, and custom applications.

### Log Structure

```
Log Group → Log Stream → Log Events
```

| **Object** | **Description** | **Exam Notes** |
|------------|----------------|---------------|
| **Log Group** | Named container for log streams; retention and encryption configured here | Retention: **never expire** by default § — configurable from 1 day to 10 years |
| **Log Stream** | Sequence of log events from a single source (e.g., one EC2 instance) | Created automatically by the agent or SDK |
| **Log Event** | Individual timestamped record | The actual log message |

### Log Retention and Encryption

- Default retention: **never expires** § — always set a retention policy for cost control ¤
- Configurable per log group: 1 day to 10 years †
- **At rest:** KMS encryption (customer-managed key, configured at log group level)
- **In transit:** TLS encryption

### CloudWatch Logs Export and Streaming

| **Destination** | **Mechanism** | **Latency** | **When to Use** |
|----------------|--------------|-------------|-----------------|
| **Amazon S3** | `CreateExportTask` API | ~12 hours (up to 12 hours) | Batch archival to S3 |
| **Amazon S3 (near-real-time)** | Subscription Filter → Kinesis Data Firehose → S3 | Minutes | Near-real-time delivery to S3 or other Firehose destinations |
| **Amazon Kinesis Data Streams** | Subscription Filter → Kinesis | Real-time | Custom KCL consumers, real-time processing pipelines |
| **AWS Lambda** | Subscription Filter → Lambda | Real-time | Event-driven log processing, transformations |
| **Amazon OpenSearch Service** | Subscription Filter → OpenSearch | Real-time | Full-text log search and dashboards |

> ⚠️ **Exam Trap:** `CreateExportTask` to S3 can take up to **12 hours** — it is not real-time or near-real-time.
<br>For near-real-time S3 delivery, use a **Subscription Filter → Kinesis Data Firehose → S3** pipeline.

> 💡 **Exam Tips:**
> <br>"Stream CloudWatch Logs in real-time to Lambda for processing" → **Subscription Filter → Lambda**
> <br>"Archive logs to S3 in near real-time" → **Subscription Filter → Kinesis Data Firehose → S3**
> <br>"Full-text search across log data" → **Subscription Filter → Amazon OpenSearch Service**

---

## Metric Filters

A **Metric Filter** scans CloudWatch Logs for specific patterns and generates a CloudWatch metric from matching events.

- Define a filter pattern (e.g., `ERROR`, a specific string, or JSON field value)
- Each match increments (or sets the value of) a custom metric
- Metric can then trigger a CloudWatch Alarm → action pipeline
- **Does not retroactively scan** — only processes log events that arrive after the filter is created §

**Common pattern:** CloudTrail logs → CloudWatch Logs → Metric Filter → Alarm → SNS notification
This enables **alerting on specific API activity** (e.g., root login, security group changes).

> 💡 **Exam Tip:** "Trigger an alarm when a specific error message appears in application logs" → **Metric Filter → CloudWatch metric → Alarm → SNS**

---

## CloudWatch Logs Insights

CloudWatch Logs Insights is an interactive log query service built into CloudWatch Logs.

- Purpose-built query language optimized for log analysis
- Queries can span multiple log groups in a single query
- Results include visualization options (bar charts, time-series)
- **Pay per query** based on data scanned ¤
- Not real-time — designed for ad-hoc investigation and dashboards

> 💡 **Exam Tip:** "Ad-hoc search and analysis of logs stored in CloudWatch Logs" → **CloudWatch Logs Insights**
<br>Logs Insights is for *querying* existing logs; Subscription Filters are for *streaming* logs to other services.

---

## Unified CloudWatch Agent

The Unified CloudWatch Agent is software installed on EC2 instances and on-premises servers that collects metrics and logs not available from the hypervisor layer.

### Why It's Needed

AWS hypervisors can only see **host-level** EC2 metrics (CPU, network I/O, disk I/O at the block device level). <br>Metrics that live **inside the OS** require an in-guest agent:

| **Metric** | **Available Without Agent?** | **Available With Agent?** |
|-----------|------------------------------|--------------------------|
| CPU utilization | ✅ Yes (basic/detailed) | ✅ Yes (higher frequency) |
| Network in/out | ✅ Yes | ✅ Yes |
| Disk I/O (block device) | ✅ Yes | ✅ Yes |
| **Memory (RAM) utilization** | ❌ No | ✅ Yes |
| **Disk space / filesystem usage** | ❌ No | ✅ Yes |
| **OS-level process metrics** | ❌ No | ✅ Yes |
| **Custom application log files** | ❌ No | ✅ Yes |

### Key Properties

- **Push-based model** — the agent sends data to CloudWatch
- Works on **EC2** (Linux and Windows) and **on-premises servers** (hybrid environments)
- Configuration stored as a JSON file — can be managed via **SSM Parameter Store** for fleet-wide distribution
- Supports **StatsD** and **collectd** protocols for custom application metrics
- **Replaces** the older CloudWatch Logs agent and EC2 monitoring scripts Δ

> 🛠️ **Implementation Notes:**
> <br>**Installation:** Use the `AmazonCloudWatchAgent` SSM document to deploy at scale; or install the `.deb`/`.rpm` package manually
> <br>**IAM:** Attach the `CloudWatchAgentServerPolicy` managed policy to the instance role
> <br>**Configuration wizard:** Run `amazon-cloudwatch-agent-config-wizard` to generate the JSON config file interactively
> <br>**SSM Parameter Store:** Store the config in `/AmazonCloudWatch-linux` or `/AmazonCloudWatch-windows`; agent fetches it on start

---

## CloudWatch Dashboards

CloudWatch Dashboards provide **customizable visualizations** of CloudWatch metrics and alarms.

- **Cross-region and cross-account** visibility in a single dashboard
- Supports line graphs, stacked areas, number widgets, alarms, text widgets
- Dashboards are **global** — accessible from any region ◊
- Share dashboards with users who don't have AWS accounts (via URL) ※
- Cost: first 3 dashboards with up to 50 metrics are free; beyond that, per-dashboard monthly charge ¤

> 💡 **Exam Tip:** "Single pane of glass for metrics across multiple AWS accounts and regions" → **CloudWatch Dashboard**

---

## CloudWatch Contributor Insights ※

CloudWatch Contributor Insights analyzes log data to identify the **top N contributors** to a metric.
<br>Useful for finding the busiest resources, most frequent error sources, or heaviest API callers.

- Works with CloudWatch Logs and DynamoDB
- Define rules to identify contributors based on log fields
- Example: find the top 10 IP addresses making the most failed requests to an API

> 💡 **Exam Tip:** "Identify the top callers causing high API error rates" → **CloudWatch Contributor Insights**

---

# Distributed Tracing
---

## AWS X-Ray

AWS X-Ray is a **distributed tracing service** that helps you analyze and debug production applications, especially those built on microservices and serverless architectures.

### How It Works

- Your application code (or supported frameworks) emits **trace data** to the X-Ray daemon or API
- X-Ray assembles individual request segments into an end-to-end **trace**
- A **service map** is automatically generated, showing each component and the latency/error rates between them

### Key Concepts

| **Concept** | **Definition** |
|-------------|---------------|
| **Trace** | End-to-end record of a single request through the system |
| **Segment** | Work done by a single service for a request |
| **Subsegment** | Granular detail within a segment (e.g., a single DynamoDB call) |
| **Annotation** | Key-value pair indexed for filtering and searching traces |
| **Metadata** | Non-indexed key-value data attached to a segment |
| **Service Map** | Visual graph of components and their connections, latencies, and error rates |
| **Sampling** | X-Ray does not trace every request by default; a sampling rule controls the rate |

### Supported Integrations

- **Lambda** — automatic tracing when Active Tracing is enabled; no daemon needed
- **EC2 / ECS** — requires X-Ray daemon running alongside the application
- **Elastic Beanstalk** — X-Ray daemon available as a platform component
- **API Gateway** — enable X-Ray tracing per stage
- **SNS, SQS, DynamoDB, S3** — passive tracing (inferred segments in service map)

### CloudWatch ServiceLens ※

ServiceLens integrates **CloudWatch metrics and logs** with **X-Ray traces** into a single unified health view. 
<br>It surfaces the Service Map and trace data directly in the CloudWatch console, enabling end-to-end transaction visibility without switching tools.

> 💡 **Exam Tips:**
> <br>"Debug latency in a microservices application — which service is slow?" → **AWS X-Ray**
> <br>"End-to-end trace of a request across Lambda, API Gateway, and DynamoDB" → **AWS X-Ray**
> <br>"Trace Lambda functions without running a daemon" → **Enable Active Tracing on the Lambda function**

> 🔧 **Pro Tips:** X-Ray **sampling rules** control what percentage of requests are traced and the rate of traced requests per second. 
<br>In production, you never trace 100% of requests — default is 5% of requests plus 1 request per second per host. <br>Custom sampling rules can target specific paths or headers at higher rates for debugging.

---

# Event-Driven Monitoring
---

## Amazon EventBridge

Amazon EventBridge (formerly CloudWatch Events) is a **serverless event bus** that connects applications using events from AWS services, custom applications, and SaaS providers.

> 📚 **Learn More:** EventBridge is introduced here in the monitoring context because it replaced CloudWatch Events.
>
> - **Module 10 — Serverless Apps** — EventBridge coverage in the context of serverless architectures (Pipes, Scheduler, SaaS integrations)
>
> This section covers the core concepts and CloudWatch Events replacement; Module 10 covers deeper integration patterns.

### Core Concepts

```
Event Source → Event Bus → Event Rule (filter) → Target(s)
```

| **Concept** | **Definition** |
|-------------|---------------|
| **Event** | A JSON document describing a state change — e.g., EC2 instance state changed to `terminated` |
| **Event Bus** | Channel that receives events; the **default event bus** receives AWS service events |
| **Rule** | Pattern matching filter that routes matching events to one or more targets |
| **Target** | The service that receives the event and takes action |

### Event Sources

- **AWS services** — any state change event (EC2, S3, CodePipeline, Health, etc.)
- **Custom applications** — publish events via `PutEvents` API using a custom event bus
- **SaaS partners** — Salesforce, Zendesk, GitHub, etc. via partner event buses ※

### Supported Targets

Lambda, SNS, SQS, Kinesis Data Streams, Kinesis Data Firehose, Step Functions, ECS Tasks, API Gateway, CodePipeline, SSM Run Command, SSM Automation, CloudWatch Logs, and more.

### Scheduling

EventBridge **Scheduler** (formerly CloudWatch Events scheduled rules) enables cron-style and rate-based scheduling:
- **Rate expression** — e.g., `rate(5 minutes)` for periodic triggers
- **Cron expression** — for specific times/dates

> 💡 **Exam Tips:**
> <br>"Trigger a Lambda function every night at midnight" → **EventBridge Scheduler** (cron expression)
> <br>"Automatically start an EC2 instance when a CodePipeline stage succeeds" → **EventBridge Rule → EC2 Start**
> <br>"React to an S3 object upload event" → **EventBridge Rule** (or S3 Event Notification, depending on the target)
> <br>"Route events from one AWS account to another" → **EventBridge cross-account event routing**

### EventBridge vs. CloudWatch Events

EventBridge **is** CloudWatch Events — the same underlying service was renamed and significantly expanded. Δ

| **Feature** | **CloudWatch Events (old name)** | **Amazon EventBridge** |
|-------------|----------------------------------|------------------------|
| Default event bus | ✅ | ✅ |
| Custom event buses | ✅ (limited) | ✅ (fully supported) |
| SaaS partner integrations | ❌ | ✅ |
| Schema Registry | ❌ | ✅ |
| Pipes (point-to-point event processing) | ❌ | ✅ ※ |
| Name in console | CloudWatch Events | Amazon EventBridge |

> ⚠️ **Exam Trap:** Questions may still say "CloudWatch Events" — treat it as **EventBridge**. They are the same service.

---

# Auditing & Compliance
---

## AWS CloudTrail

AWS CloudTrail records **API activity and account events** across your AWS infrastructure. Every action taken through the Console, CLI, SDK, or higher-level AWS services generates a CloudTrail event.

**What CloudTrail answers:** *Who did what, from where, and when?*

CloudTrail is **enabled by default** on all AWS accounts from the moment they are created. § Event history (90-day rolling window) is available in the console without configuration.

### Trail Types

| **Trail Type** | **Scope** | **Delivery** |
|---------------|-----------|-------------|
| **All-region trail** | Records events from all regions | Single S3 bucket (recommended default) |
| **Single-region trail** | Records events from one region only | S3 bucket (same or different account) |
| **Organization trail** | Applied across all accounts in an AWS Organization | Central S3 bucket in management account |

> 💡 **Exam Tip:** "Centralize CloudTrail logs across all accounts in an AWS Organization" → **Organization trail** configured in the management account

### CloudTrail Event Types

| **Event Type** | **What It Captures** | **Default Logging** |
|---------------|---------------------|---------------------|
| **Management Events** (control plane) | Create/delete/modify AWS resources — `CreateBucket`, `AttachRolePolicy`, `CreateSubnet` | ✅ Enabled by default § |
| **Data Events** (data plane) | Operations *on* or *within* a resource — S3 object-level (`GetObject`, `PutObject`), Lambda invocations | ❌ Disabled by default (high volume, additional cost ¤) § |
| **Insights Events** | Unusual API call volumes or error rates — ML-based anomaly detection | ❌ Opt-in, additional cost ¤ § |

> ⚠️ **Exam Trap:** CloudTrail **management events** are on by default, but **data events** (S3 object reads/writes, Lambda invocations) are **not** — they must be explicitly enabled per trail and incur additional cost.

### CloudTrail Log Storage and Security

- Logs delivered to an **S3 bucket** (configurable prefix); optionally to **CloudWatch Logs** for real-time monitoring
- Logs are automatically encrypted with **S3 SSE (AES-256)** § — optionally encrypted with **SSE-KMS** for stronger controls
- A single KMS key can encrypt logs for a multi-region or organization trail
- **Cross-account log centralization:** configure the S3 bucket policy to allow `PutObject` from the source accounts; enable CloudTrail in each account pointing to the central bucket

### CloudTrail Log File Integrity Validation

- CloudTrail generates a **digest file** every hour containing SHA-256 hashes of delivered log files
- Digest files are signed with CloudTrail's private key
- Use the `validate-logs` CLI command to confirm that log files have not been altered, deleted, or tampered with since delivery
- Critical for **compliance** and **forensic investigations**

> 💡 **Exam Tips:**
> <br>"Who deleted the S3 bucket?" → **CloudTrail**
> <br>"Prove that CloudTrail log files have not been tampered with" → **Log file integrity validation**
> <br>"Real-time alerting on specific API activity (e.g., root login detected)" → **CloudTrail → CloudWatch Logs → Metric Filter → Alarm → SNS**

### CloudTrail Lake ※

CloudTrail Lake is a **managed data lake** for CloudTrail events that enables SQL-based querying directly within CloudTrail — without needing to export to S3 and query via Athena.

- Events are stored as an **immutable, aggregated event data store** with configurable retention (7 years max) †
- Query using SQL via the CloudTrail console, CLI, or API
- Supports multi-account, multi-region event data stores via AWS Organizations

> 🔧 **Pro Tips:** CloudTrail Lake is the modern alternative to the `CloudTrail → S3 → Athena` query pipeline for organizations that want managed, in-service querying without S3 bucket management. 
<br>At the **SAA** level, understand that it **exists**.
<br>At the **SAP** level, understand the **tradeoffs versus Athena queries**.

---

## AWS Config

> 📚 **Learn More:** AWS Config is fully covered in **Module 12 — Deployment & Management**, including Config Rules, Configuration Items, auto-remediation, conformance packs, and the full Config vs. CloudTrail comparison.
>
> - **Module 12 — Deployment & Management** — complete AWS Config coverage

**For quick exam distinction from CloudTrail:**

| **Question** | **Service** |
|-------------|------------|
| *Who made the API call to change this security group?* | **CloudTrail** |
| *What did this security group look like before the change?* | **AWS Config** |
| *Is this EBS volume compliant with our encryption policy?* | **AWS Config rule** |
| *When was this resource created and who created it?* | **CloudTrail** |

---

# Observability Platforms
---

## Amazon Managed Grafana ※

Amazon Managed Grafana is a **fully managed service** for the open-source Grafana analytics and visualization platform. 
<br>AWS handles infrastructure, scaling, upgrades, and security.

### Key Properties

- **Visualization-only** — Grafana is not a data collection service; it queries data sources and renders dashboards
- Supports **multiple data sources simultaneously** in a single dashboard
- Native integration with CloudWatch, Amazon Managed Service for Prometheus, OpenSearch, X-Ray, Timestream, Athena, and third-party sources (Datadog, Splunk, etc.)
- **SAML** and **AWS IAM Identity Center** (formerly SSO) for authentication; workspace-level access control
- Workspaces are provisioned per organization; each workspace gets its own Grafana environment

### CloudWatch + Grafana Relationship

| **Layer** | **Service** | **Role** |
|-----------|------------|---------|
| Data collection | CloudWatch (metrics, logs) | Collects and stores observability data |
| Data visualization | Amazon Managed Grafana | Queries data sources and renders dashboards |

> 💡 **Exam Tips:**
> <br>"Advanced dashboards and visualization beyond what CloudWatch natively offers" → **Amazon Managed Grafana**
> <br>"Unified dashboard combining CloudWatch metrics, X-Ray traces, and Prometheus metrics" → **Amazon Managed Grafana**

---

## Amazon Managed Service for Prometheus ※

Amazon Managed Service for Prometheus (AMP) is a **Prometheus-compatible monitoring service** for container and microservice workloads.

- Fully managed ingestion, storage, and querying of Prometheus metrics
- Compatible with open-source **PromQL** query language
- Integrates with **Amazon EKS**, **Amazon ECS**, and self-managed Kubernetes
- Scales automatically — no need to manage Prometheus server capacity
- Often paired with **Amazon Managed Grafana** for visualization

> 💡 **Exam Tip:** "Managed Prometheus-compatible metrics for Kubernetes/container workloads" → **Amazon Managed Service for Prometheus** (commonly paired with Amazon Managed Grafana)

> 🔧 **Pro Tips:** AMP is the AWS-native answer to "we run Prometheus at scale and don't want to manage the servers.<br>At the SAA level, know that it exists for containerized monitoring. 
<br>At the SAP level, understand the ingestion pipeline: EKS → `remote_write` → AMP → AMP query endpoint → Grafana.

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|-------------|
| Monitor EC2 CPU and trigger Auto Scaling | CloudWatch Metric (CPU) → Alarm → Auto Scaling Policy |
| Alert on memory or disk usage from EC2 | Unified CloudWatch Agent → custom metrics → Alarm → SNS |
| Detect and alert on specific application error in logs | CloudWatch Logs → Metric Filter → CloudWatch metric → Alarm → SNS |
| Search and analyze logs interactively | CloudWatch Logs Insights |
| Stream logs to S3 in near real-time | CloudWatch Logs Subscription Filter → Kinesis Data Firehose → S3 |
| Stream logs for real-time processing | CloudWatch Logs Subscription Filter → Lambda or Kinesis Data Streams |
| Archive logs to S3 (batch, not real-time) | `CreateExportTask` (up to 12-hour delay) |
| Alert when a metric behaves unusually without a fixed threshold | CloudWatch Anomaly Detection alarm |
| Reduce false-positive alarms in a complex system | CloudWatch Composite Alarm (AND/OR logic across multiple alarms) |
| Identify top API callers driving errors | CloudWatch Contributor Insights |
| Trigger a Lambda function on a schedule | EventBridge Scheduler (rate or cron expression) |
| React to an EC2 state change event automatically | EventBridge Rule → target (Lambda, SNS, SSM, etc.) |
| Route events from a SaaS platform to AWS | EventBridge SaaS partner event bus |
| Audit who deleted a resource and when | AWS CloudTrail (management events) |
| Alert on root login or security group changes in real-time | CloudTrail → CloudWatch Logs → Metric Filter → Alarm → SNS |
| Centralize CloudTrail logs across Organization accounts | CloudTrail Organization trail → central S3 bucket |
| Prove CloudTrail logs have not been tampered with | CloudTrail log file integrity validation |
| Query CloudTrail events with SQL without Athena | CloudTrail Lake |
| Debug latency in microservices / Lambda chains | AWS X-Ray (service map + trace waterfall) |
| Visualize metrics from CloudWatch + Prometheus + X-Ray | Amazon Managed Grafana |
| Managed Prometheus for EKS workloads | Amazon Managed Service for Prometheus (AMP) |
| Single pane of glass across multiple accounts/regions | CloudWatch Dashboard (cross-account, cross-region) |

> 🛠️ **Implementation Notes:**
> <br>**Unified CloudWatch Agent:** Install via `AmazonCloudWatchAgent` SSM document; store config in SSM Parameter Store; attach `CloudWatchAgentServerPolicy` to the instance role
> <br>**Subscription Filter for real-time streaming:** In the CloudWatch Logs console → Log Group → Subscription Filters → Create; choose Lambda, Kinesis, or OpenSearch as destination
> <br>**Metric Filter pattern syntax:** Patterns are space-delimited — `[ERROR]` matches any log event containing the word ERROR; JSON log fields use `$.fieldname` syntax
> <br>**CloudTrail to CloudWatch Logs:** In the CloudTrail trail settings, set a CloudWatch Logs log group and IAM role — CloudTrail then delivers events as they occur
> <br>**X-Ray on Lambda:** In the Lambda function configuration → Monitoring → Enable Active Tracing — no daemon required; Lambda runs the X-Ray daemon for you
> <br>**EventBridge Rule:** Console → EventBridge → Rules → Create Rule; choose event pattern (JSON filter) or schedule; add targets; no code required for routing

---

# Module Summary
---

## Key Topics
  - **Amazon CloudWatch** — core observability service: metrics, alarms, logs, dashboards, events
  - **CloudWatch Metrics** — namespaces, dimensions, statistics, resolution (standard vs. high-resolution), data retention tiers
  - **EC2 Monitoring** — basic (5-minute, free) vs. detailed (1-minute, paid) vs. sub-minute (agent required); memory and disk always require agent
  - **CloudWatch Alarms** — states (OK/ALARM/INSUFFICIENT_DATA), static vs. anomaly detection thresholds, actions (SNS/ASG/EC2), composite alarms
  - **CloudWatch Logs** — log groups, log streams, log events; retention (never expire by default); KMS encryption; export via `CreateExportTask` (slow) vs. Subscription Filters (real-time)
  - **Metric Filters** — scan logs for patterns → generate metrics → trigger alarms
  - **CloudWatch Logs Insights** — interactive query language for ad-hoc log analysis
  - **Unified CloudWatch Agent** — required for memory, disk, OS metrics, and custom log files; push-based; config via SSM Parameter Store
  - **CloudWatch Dashboards** — cross-region, cross-account visualizations
  - **CloudWatch Anomaly Detection** — ML-based metric baselines for threshold-free alarms
  - **Composite Alarms** — AND/OR logic across multiple alarms to reduce noise
  - **CloudWatch Contributor Insights** — identify top contributors from log data
  - **AWS X-Ray** — distributed tracing; traces, segments, subsegments, service map; sampling; Lambda active tracing
  - **Amazon EventBridge** — serverless event bus; supersedes CloudWatch Events; event pattern rules; scheduling; SaaS integrations; cross-account routing
  - **AWS CloudTrail** — API activity logging; management events (default on) vs. data events (opt-in); all-region vs. single-region vs. organization trails; log integrity validation; CloudTrail Lake
  - **CloudTrail → CloudWatch Logs** — real-time alerting on API activity via metric filters
  - **AWS Config** — cross-reference to Module 12; key exam distinction vs. CloudTrail
  - **Amazon Managed Grafana** — managed visualization; multi-source dashboards; pairs with CloudWatch and Prometheus
  - **Amazon Managed Service for Prometheus (AMP)** — managed Prometheus for container workloads; pairs with Grafana

---

## Critical Acronyms
  - **CW** — CloudWatch (informal abbreviation)
  - **SSE** — Server-Side Encryption
  - **KMS** — Key Management Service
  - **TLS** — Transport Layer Security
  - **SNS** — Simple Notification Service
  - **SQS** — Simple Queue Service
  - **ASG** — Auto Scaling Group
  - **EC2** — Elastic Compute Cloud
  - **ECS** — Elastic Container Service
  - **EKS** — Elastic Kubernetes Service
  - **ML** — Machine Learning
  - **API** — Application Programming Interface
  - **CLI** — Command Line Interface
  - **SDK** — Software Development Kit
  - **ARN** — Amazon Resource Name
  - **SaaS** — Software as a Service
  - **IAM** — Identity and Access Management
  - **SSO** — Single Sign-On (now AWS IAM Identity Center)
  - **SAML** — Security Assertion Markup Language
  - **AMP** — Amazon Managed Service for Prometheus
  - **PromQL** — Prometheus Query Language
  - **VPC** — Virtual Private Cloud
  - **SHA** — Secure Hash Algorithm
  - **KCL** — Kinesis Client Library
  - **HOL** — Hands-On Lab

---

## Key Comparisons
  - CloudWatch Metrics: EC2 Basic vs. Detailed vs. Sub-minute monitoring (table)
  - CloudWatch Metrics: Data retention tiers by resolution (table)
  - CloudWatch Logs: Export destinations by latency — `CreateExportTask` vs. Subscription Filters (table)
  - CloudWatch Alarm types: static threshold vs. Anomaly Detection vs. Composite Alarms
  - CloudWatch vs. CloudTrail (table — inline in Auditing section)
  - CloudTrail Event Types: Management vs. Data vs. Insights events (table)
  - CloudWatch + Grafana layered responsibility model (table)
  - CloudWatch vs. CloudTrail vs. AWS Config — three-way quick-reference (table)

---

## Top Exam Triggers
  - `Memory or disk usage from EC2 instance` → **Unified CloudWatch Agent**
  - `EC2 metrics every 5 minutes` → **Basic (default) monitoring — free**
  - `EC2 metrics every 1 minute` → **Detailed monitoring — paid**
  - `Sub-minute EC2 metrics` → **CloudWatch Agent + high-resolution custom metrics**
  - `Trigger Auto Scaling based on CPU threshold` → **CloudWatch Alarm → Auto Scaling Policy**
  - `Alert when an error pattern appears in logs` → **Metric Filter → Alarm → SNS**
  - `Search logs interactively with a query` → **CloudWatch Logs Insights**
  - `Export logs to S3 in real-time (or near-real-time)` → **Subscription Filter → Kinesis Firehose → S3**
  - `Export logs to S3 in batch (not time-sensitive)` → **`CreateExportTask`** (up to 12 hours)
  - `Stream logs to Lambda for real-time processing` → **Subscription Filter → Lambda**
  - `Alarm without knowing what "normal" looks like` → **CloudWatch Anomaly Detection**
  - `Reduce false-positive alerts across multiple correlated metrics` → **Composite Alarm**
  - `Identify top N contributors causing high error rates` → **CloudWatch Contributor Insights**
  - `Who made an API call — deleted the S3 bucket?` → **AWS CloudTrail**
  - `What did the resource configuration look like before a change?` → **AWS Config**
  - `Audit API calls across all accounts in an Organization` → **CloudTrail Organization trail**
  - `Alert on root account login in real time` → **CloudTrail → CloudWatch Logs → Metric Filter → Alarm → SNS**
  - `Prove log files were not tampered with` → **CloudTrail log file integrity validation**
  - `Query CloudTrail events with SQL (no Athena)` → **CloudTrail Lake**
  - `Data events (S3 object reads, Lambda invocations) not in CloudTrail` → **Data events are off by default — must enable per trail**
  - `Debug which microservice is causing latency` → **AWS X-Ray**
  - `End-to-end trace through API Gateway, Lambda, and DynamoDB` → **AWS X-Ray**
  - `Trigger Lambda on a cron schedule` → **EventBridge Scheduler**
  - `React to EC2 instance state change automatically` → **EventBridge Rule → target**
  - `Cross-account event routing` → **EventBridge (cross-account event bus)**
  - `Advanced multi-source dashboards (CloudWatch + Prometheus + X-Ray)` → **Amazon Managed Grafana**
  - `Managed Prometheus for Kubernetes` → **Amazon Managed Service for Prometheus (AMP)**

---

## Quick References

### [Monitoring, Logging, and Auditing Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619480#overview)

### [Monitoring, Logging, and Auditing Architecture Patterns Private Link](https://drive.google.com/drive/folders/1xssk3oWW77JrJijlRaEToUHqA9KGqA0R?usp=drive_link)

### [Monitoring, Logging, and Auditing Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346118#overview)

### [CloudWatch Cheat Sheet](https://digitalcloud.training/amazon-cloudwatch/)

### [CloudTrail Cheat Sheet](https://digitalcloud.training/aws-cloudtrail/)

### [AWS CloudWatch Agent Metrics Collection Reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html)

---

> ### Symbol Key:
> - `†` quota or limit
> - `‡` hardware/performance spec
> - `§` AWS default behavior
> - `※` feature availability (newer or expanding)
> - `¤` pricing-related
> - `◊` regional variance
> - `Δ` recently changed (older sources may describe prior behavior)
> - All flagged values are subject to change — verify against current AWS documentation before relying on them for design decisions.
