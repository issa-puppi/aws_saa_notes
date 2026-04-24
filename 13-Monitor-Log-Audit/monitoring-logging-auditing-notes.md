# Monitoring, Logging, and Auditing
---

## Amazon CloudWatch
  - Performance monitoring and observability service for AWS resources and applications

### Use Cases
  - Collect and track metrics (AWS + on-premises)
  - Monitor logs and troubleshoot issues
  - Improve performance and resource utilization
  - Trigger automated actions (scaling, notifications)
  - Build dashboards and visualize system health

### Core Components
  - **Metrics**: Time-series performance data
  - **Alarms**: Trigger actions based on thresholds
  - **Logs**: Centralized log storage and analysis
  - **Dashboards**: Custom visualizations
  - **Events (EventBridge)**: Event-driven automation and integration
    - Formerly CloudWatch Events

---

## CloudWatch Metrics
  - Time-series data collected from AWS services and custom sources

### Key Concepts
  - **Namespace**: Container for metrics (e.g., AWS/EC2)
  - **Dimensions**: Key-value identifiers (e.g., InstanceId)
  - **Statistics**: Aggregations (Average, Sum, Min, Max)
  - **Resolution**: How often data is collected
    - **Standard**: 1 minute
    - **High-resolution**: 1 second (higher cost)

### EC2 Metrics Monitoring
  - How often AWS sends EC2 data to CloudWatch
    - **Default** → **5 minutes (free)**
    - **Detailed** → **1 minute (paid)**
    - **Sub-minute** requires:
      - CloudWatch Agent + custom metrics

### Custom / System Metrics
  - Require **CloudWatch Agent**
  - Includes:
    - Memory usage
    - Disk usage
    - OS-level metrics

### Key Details (Exam)
  - Metrics retained for **15 months**
  - High-resolution metrics cost more

---

## CloudWatch Alarms
  - Monitor metrics and trigger automated actions

### Types
  - Metric Alarms
  - Composite Alarms

### States
  - `OK`, `ALARM`, `INSUFFICIENT_DATA`

### Configuration
  - Threshold + evaluation periods + statistic + period
  - Supports:
    - Static thresholds
    - **Anomaly detection (ML-based)**

### Actions
  - SNS notifications
  - Auto Scaling
  - EC2 actions (stop, terminate, reboot, recover)

### Key Behavior
  - Evaluates over time (not single datapoint)
  - Supports missing data handling

### Pro Insight
  - Composite alarms reduce alert noise in complex systems

### Exam Triggers
  - `Trigger scaling` → Alarm + Auto Scaling
  - `Send alert` → Alarm + SNS

---

## CloudWatch Logs
  - Centralized service for application and system logs

### Log Structure
  - Log Group → Log Stream → Log Event

### Features
  - Retention policies (default: never expire)
  - KMS encryption (at rest) + TLS (in transit)
  - Metric Filters → logs → metrics
  - Logs Insights → query logs

### Real-Time Processing
  - **Subscription Filters**
    - Stream logs to:
      - Lambda
      - Kinesis
      - OpenSearch

### Pro Insight
  - Subscription filters enable **event-driven log pipelines**
  - Metric filters enable **alerting from logs**

### Exam Triggers
  - `Search logs` → Logs Insights
  - `Real-time logs` → Subscription Filters
  - `Logs to metrics` → Metric Filters

---

## Unified CloudWatch Agent
  - Installed on EC2 and on-prem servers

### Capabilities
  - Collect:
    - Memory
    - Disk
    - OS metrics
  - Send:
    - Metrics + Logs to CloudWatch

### Architecture
  - **Push-based model** (agent sends data)

### Configuration
  - JSON config file
  - Can be stored in SSM Parameter Store

### Additional Support
  - StatsD / collectd integration for custom metrics

### Key Insight
  - Replaces:
    - CloudWatch Logs agent
    - Monitoring scripts

### Exam Trigger
  - `Need memory/disk metrics` → Agent

---

# Event-Driven Architecture
---

## EventBridge
  - Event-driven service for reacting to AWS events

### Key Concepts
  - Event → Rule → Target

### Features
  - Event filtering
  - Schema registry
  - Cross-account event routing

### Sources
  - AWS services
  - Custom applications
  - SaaS integrations

### Targets
  - Lambda, SNS, Step Functions, Kinesis

### Pro Insight
  - EventBridge enables **loosely coupled architectures**
  - Supports **cross-account and cross-region routing**

### Exam Triggers
  - `Event-based automation` → EventBridge
  - `Scheduled jobs` → EventBridge

---

# Auditing & Compliance
---

## AWS CloudTrail
  - Records API calls and account activity

### Features
  - Stores logs in S3
  - Event history (90 days)
  - Log integrity validation
  - Multi-account (Organization trail)

### Pro Insight
  - Integrates with CloudWatch Logs for **real-time monitoring**
  - Can trigger alerts on API activity

### Exam Triggers
  - `Who did what?` → CloudTrail
  - `Track API calls` → CloudTrail

---

## AWS Config
  - Tracks configuration changes over time

### Features
  - Resource history + relationships
  - Compliance rules
  - Drift detection
  - Auto-remediation

### Pro Insight
  - Works with:
    - AWS Organizations
    - Conformance Packs (grouped rules)
  - Enables **continuous compliance**

### Exam Triggers
  - `Compliance` → Config
  - `Auto fix` → Config + remediation

---

## Amazon Managed Grafana
  - Fully managed service for **visualizing and analyzing metrics and logs**

### Features
  - Integrates with:
    - CloudWatch
    - Prometheus
    - OpenSearch
    - Other data sources

  - Provides:
    - Pre-built dashboards
    - Custom dashboards
    - Advanced visualization capabilities

  - Supports:
    - Role-based access control (IAM integration)
    - Multi-data source dashboards

### Key Insight
  - Grafana is used for **visualization and observability**, not data collection
  - Works alongside:
    - CloudWatch → collects data
    - Grafana → visualizes data

### Exam Triggers
  - `Advanced dashboards / visualization` → Grafana
  - `Visualize metrics across multiple sources` → Grafana

---

# Module Summary
---

## Key Comparisons

| **Concept** | **Tracks** | **Service** |
|--------|--------|--------|
| **Performance** | CPU, memory | CloudWatch Metrics |
| **Alerts** | Threshold actions | CloudWatch Alarms |
| **Logs** | App/system logs | CloudWatch Logs |
| **Events** | Resource changes | EventBridge |
| **API activity** | Who did what | CloudTrail |
| **Config state** | Compliance/drift | AWS Config |
| **Visualization** | Metrics and logs | Amazon Managed Grafana |

---

## Common Exam Scenarios

- `Need memory/disk metrics` → CloudWatch Agent
- `Trigger scaling` → CloudWatch Alarm
- `Process logs real-time` → Logs + Subscription Filters
- `Audit API calls` → CloudTrail
- `Detect drift` → AWS Config
- `React to event` → EventBridge
- `Visualize across sources` → Grafana

---

## Quick References

### [AWS CloudWatch Agent Metrics Collection Reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html)

### [Monitoring, Logging, and Auditing Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619480#overview)

### [Monitoring, Logging, and Auditing Architecture Patterns Private Link](https://drive.google.com/drive/folders/1xssk3oWW77JrJijlRaEToUHqA9KGqA0R?usp=drive_link)

### [Monitoring, Logging, and Auditing Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346118#overview)

### [Cloud Watch Cheat](https://digitalcloud.training/amazon-cloudwatch/)

### [AWS CloudTrail](https://digitalcloud.training/aws-cloudtrail/)

---