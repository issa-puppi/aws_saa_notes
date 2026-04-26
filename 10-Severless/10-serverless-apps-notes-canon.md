# Serverless & Event-Driven Architecture
---

## Event-Driven Architecture

**Event-driven architecture (EDA)** is a software design pattern where components communicate by producing and reacting to events rather than by direct calls.

| **Component** | **Role** | **AWS Examples** |
|---------------|----------|-----------------|
| **Event** | A change in state or occurrence | S3 object upload, EC2 state change, user action, schedule trigger |
| **Event Producer** | Generates and publishes events | S3, EC2, custom application, SaaS integration |
| **Event Channel** | Transmits events from producers to consumers | SQS (queue), SNS (topic), EventBridge (bus), Kinesis (stream) |
| **Event Consumer** | Listens for and reacts to events | Lambda function, SQS subscriber, HTTP endpoint |
| **Event Processing** | Logic applied to events: filtering, transformation, routing | Lambda, Step Functions, EventBridge rules |

  - Producers and consumers are **decoupled** — each can scale, fail, and deploy independently
  - Processing must often be **idempotent** — the same event processed multiple times produces the same result (necessary because queues and streams may deliver events more than once)

---

## Serverless Computing

With **serverless** architecture, AWS manages all underlying infrastructure — no instances to provision, patch, or scale.

| **Characteristic** | **Detail** |
|--------------------|------------|
| **No server management** | AWS provisions and operates all compute infrastructure |
| **Automatic scaling** | Scales with demand — to zero when idle, to thousands of concurrent executions under load |
| **Pay-per-use** | Billed on actual execution time and resources consumed, not idle capacity ¤ |
| **High availability** | Built-in — no configuration required |
| **AWS serverless services** | Lambda, Fargate, API Gateway, SQS, SNS, EventBridge, DynamoDB, S3, Step Functions, Aurora Serverless |

---

# Compute
---

## AWS Lambda

AWS Lambda is a **serverless compute service** that runs code in response to events and automatically manages the underlying compute resources.
<br>Lambda is the core execution engine for event-driven and serverless architectures on AWS.

### Key Properties
  - **No server management** — AWS handles all infrastructure, OS, and runtime patching
  - **Scales out, not up** — each invocation gets its own isolated execution environment; Lambda scales by running more parallel instances, not by increasing the size of one instance §
  - Code is stored in **Amazon S3** and encrypted at rest §
  - Lambda assumes an **IAM execution role** to interact with other AWS services
  - Supported runtimes: Node.js, Python, Java, Go, Ruby, .NET, custom runtimes via Lambda Layers
  - **AWS SDK** is available in every Lambda function by default §

### Limits and Sizing

| **Parameter** | **Value** |
|---------------|-----------|
| **Max execution timeout** | 15 minutes (900 seconds) † — default is 3 seconds § |
| **Memory** | 128 MB – 10,240 MB (in 1 MB increments) † |
| **CPU allocation** | Proportional to memory — no direct CPU configuration ‡ |
| **Ephemeral storage (`/tmp`)** | 512 MB – 10,240 MB † |
| **Deployment package (zip)** | 50 MB compressed / 250 MB uncompressed † |
| **Default concurrent executions** | 1,000 per region † (can be increased via support) |

> 💡 **Exam Tip:** Lambda "scales out" — it runs more parallel instances for concurrent events, not a larger single instance.
<br>This is why idempotency matters: the same event may trigger multiple invocations.

---

## Lambda Invocation Types

| **Type** | **Trigger Examples** | **Behavior** | **Error Handling** |
|----------|---------------------|--------------|-------------------|
| **Synchronous** | API Gateway, CLI, SDK, ALB | Caller waits for function to complete; response returned directly | Client-side — caller handles retries |
| **Asynchronous** | S3, SNS, CloudWatch Events/EventBridge | Event queued; Lambda returns 202 immediately; function processes in background | Lambda retries up to **2 additional times** (3 total); failed events can go to a **DLQ or Lambda Destination** |
| **Event Source Mapping** | SQS, Kinesis Data Streams, DynamoDB Streams | Lambda **polls** the source; processes records in batches | Built-in retry per source type; SQS Standard has no ordering; Kinesis/DynamoDB preserve order per shard/partition |

> ⚠️ **Exam Traps:**
> <br>Async invocations retry **2 times** (3 attempts total) — not unlimited
> <br>S3 and SNS invoke Lambda **asynchronously** — configuration is on the source side
> <br>SQS, Kinesis, and DynamoDB Streams use **Event Source Mapping** — Lambda polls these; configuration is on the Lambda side

---

## Lambda Concurrency

  - **Default account limit**: 1,000 concurrent executions per region † (soft limit — can be increased)
  - **Burst concurrency limits** ‡ (initial burst before +500/minute scaling kicks in):
    - **3,000** — US East (N. Virginia), US West (Oregon), EU (Ireland)
    - **1,000** — Asia Pacific (Tokyo), EU (Frankfurt)
    - **500** — all other regions
  - After the burst limit is reached, concurrency scales by **+500 instances per minute**
  - **Throttling**: when limit is exceeded, Lambda returns HTTP **429 `TooManyRequestsException`**
    - Synchronous: returns throttle error 429 immediately to caller
    - Asynchronous: retries automatically, then routes to DLQ if retries exhausted

### Reserved and Provisioned Concurrency

| **Type** | **What It Does** | **Use Case** |
|----------|-----------------|--------------|
| **Reserved Concurrency** | Guarantees a maximum number of concurrent executions for a specific function; no other functions can use this allocation | Isolate a critical function; prevent runaway scaling |
| **Provisioned Concurrency** ※ | Pre-initializes execution environments; eliminates cold starts | Latency-sensitive applications needing consistent sub-ms startup |

---

## Lambda Versions and Aliases

  - **`$LATEST`** — the mutable, always-current version of the function code; can be edited
  - **Numbered versions** — published, immutable snapshots (1, 2, 3…); each has its own ARN
  - A **qualified ARN** includes the version suffix (e.g., `arn:...:function:myFunc:2`)
  - An **unqualified ARN** points to `$LATEST`

| **Concept** | **Properties** |
|-------------|----------------|
| **Version** | Immutable snapshot of code + config + dependencies; unique ARN |
| **Alias** | Mutable named pointer to a specific version; static ARN; can be used as event trigger target |
| **Traffic shifting** | Aliases can split traffic between two versions by weight — enables **blue/green** and **canary deployments** (does not work directly on `$LATEST`) |

> 💡 **Exam Tip:** `Lambda canary / blue-green deployment` → **Lambda alias with traffic shifting weights**
<br>You cannot split traffic using `$LATEST` directly — publish a version first, then create an alias.

---

## Lambda VPC Access

By default, Lambda runs in an AWS-managed VPC and **cannot access resources in your private VPC** (RDS, ElastiCache, private EC2).
<br>To access private VPC resources:
  - Configure the function with **VPC subnet IDs** and **security group IDs**
  - Lambda creates **Elastic Network Interfaces (ENIs)** in the specified subnets
  - The function then operates as if it were within the VPC

> ⚠️ **Exam Trap:** Lambda in a VPC **loses internet access** unless the VPC has a NAT Gateway for private subnets.
<br>Lambda in a VPC cannot reach the internet via an Internet Gateway directly — it needs a NAT Gateway in a public subnet.

---

## Lambda Layers and Dependencies

  - **Lambda Layers** — a distribution mechanism for libraries, custom runtimes, or configuration shared across multiple functions
  - Package external dependencies (X-Ray SDK, database clients, etc.) into a layer and attach to functions
  - Upload zip to Lambda if < 50 MB compressed; use S3 for larger packages †
  - Native libraries must be compiled on **Amazon Linux**

---

# Application Integration
---

## Application Integration — Service Overview

| **Service** | **Pattern** | **Delivery** | **Best For** |
|-------------|------------|--------------|--------------|
| **Amazon SQS** | Queue (point-to-point) | Pull-based (consumer polls) | Decoupling services; buffering; at-least-once processing |
| **Amazon SNS** | Pub/Sub (fan-out) | Push-based (broker delivers) | Fan-out to multiple subscribers; notifications |
| **Amazon EventBridge** | Event bus (event-driven) | Push-based (rule-matched) | AWS service events, SaaS events, custom app events, routing |
| **AWS Step Functions** | Orchestration (workflow) | Managed state machine | Multi-step workflows; coordinating Lambda + services |
| **Amazon MQ** | Message broker | Push/pull (protocol-based) | Migrating JMS/AMQP/STOMP apps without code rewrites |
| **Amazon SWF** | Workflow (legacy) | Task-based | Human-in-the-loop workflows; long-running (> 1 year) processes |
| **Amazon Kinesis** | Streaming | Pull-based (consumer reads shards) | Real-time streaming; ordered, replayable event streams |

## Kinesis vs. SQS vs. SNS — Key Differentiators

These three services overlap in the "event channel" role and are frequently compared on the exam. 
<br>The differences in **delivery model, ordering, persistence, and consumer model** are the primary discriminators.

| **Property** | **Amazon Kinesis** | **Amazon SQS** | **Amazon SNS** |
|--------------|-------------------|----------------|----------------|
| **Delivery model** | **Pull** — consumers read from shards | **Pull** — consumers poll the queue | **Push** — broker delivers to subscribers |
| **Consumer model** | Multiple applications can read the **same stream concurrently** — reads are non-destructive | Single consumer per message — message deleted after processing | Multiple subscribers receive the same message simultaneously |
| **Ordering** | Guaranteed **at the shard level** — related records routed to the same shard via partition key | **Standard**: best-effort; **FIFO**: strict ordering | No ordering guarantee |
| **Message persistence / replay** | Records persist in the stream (default 24 hrs, up to 365 days ‡) — consumers can **re-read past records** | Messages deleted after successful consumption — no replay | Messages not persisted — delivered immediately; lost after failed retries |
| **Throughput model** | Must **provision throughput via shards** — each shard: 1 MB/s write, 2 MB/s read ‡ | **Dynamic scaling** — Standard: near-unlimited TPS | No provisioning required — scales automatically |
| **Multi-consumer** | Yes — many consumers, limited by shard read capacity | No — one consumer per message (multi-consumer = competing consumers) | Yes — all subscribers receive a copy |
| **Use case** | Real-time analytics, log processing, IoT streams, ordered replayable events | Decoupled queuing, task buffering, retry-safe processing | Notifications, fan-out, alerting |

>📚 **Learn More:** Kinesis is covered conceptually here for comparison only.
>
> - **Module 11 — Databases & Analytics** — full Kinesis coverage (Data Streams, Data Firehose, Data Analytics)

---

## Amazon Simple Queue Service (SQS)

Amazon Simple Queue Service (SQS) is a **fully managed message queuing service** that decouples the components of a distributed application.

### Key Properties
  - **Pull-based** — consumers poll the queue; not push-based §
  - **Single consumer per message** — once consumed and deleted, a message is gone
  - Enables loose coupling between producers and consumers; producer and consumer can scale independently
  - Acts as a **buffer** between a web tier and application tier — absorbs traffic spikes

---

## SQS Queue Types

| **Feature** | **Standard Queue** | **FIFO Queue** |
|-------------|-------------------|----------------|
| **Ordering** | Best-effort (messages may arrive out of order) | Strict FIFO — messages delivered in send order |
| **Delivery** | At-least-once (duplicates possible) | Exactly-once processing (deduplication) |
| **Throughput** | Nearly unlimited TPS † | 300 TPS without batching; 3,000 TPS with batching † |
| **Use case** | Maximum throughput; order not critical | Order-sensitive workflows; financial transactions |
| **Required params** | — | `MessageGroupId`, `MessageDeduplicationId` |

  - **`MessageGroupId`** — tags a message as belonging to a specific ordered group within the queue
  - **`MessageDeduplicationId`** — deduplication token; prevents duplicate processing within a 5-minute window

### SQS Key Configurations

| **Setting** | **Description** | **Default / Limit** |
|-------------|-----------------|---------------------|
| **Visibility Timeout** | Time a message is invisible to other consumers after being read; if not deleted in time, becomes visible again | Default: 30 seconds §; max: 12 hours † |
| **Message Retention Period** | How long messages stay in the queue if not consumed | Default: 4 days §; max: 14 days † |
| **Maximum Message Size** | Max size of a single message | 256 KB † |
| **Dead-Letter Queue (DLQ)** | Receives messages that failed processing after a configurable number of attempts (`maxReceiveCount`) | Works with Standard and FIFO |
| **Delay Queue** | Postpones delivery of new messages for a set time | Up to 15 minutes † |
| **Long Polling (`WaitTimeSeconds`)** | Consumer waits up to 20 seconds for messages; eliminates empty responses | 0 = short polling §; up to 20 seconds |

> 💡 **Exam Tips:**
> <br>`Message processed multiple times / consumer not deleting in time` → **increase Visibility Timeout**
> <br>`Reduce empty responses and API costs` → **SQS Long Polling** (set `WaitTimeSeconds` > 0)
> <br>`Messages failing repeatedly, need to isolate failures` → **Dead-Letter Queue (DLQ)**
> <br>`Order-sensitive processing, no duplicates` → **SQS FIFO**

> ⚠️ **Exam Trap:** SQS is **pull-based** — consumers poll the queue. SNS is **push-based** — the broker delivers to subscribers. This distinction drives the fan-out architecture pattern.

---

## Amazon Simple Notification Service (SNS)

Amazon Simple Notification Service (SNS) is a **fully managed pub/sub messaging service** for fan-out notification delivery.

### Key Properties
  - **Push-based** — SNS delivers messages to all subscribed endpoints immediately §
  - **Publisher → Topic → Subscribers** model; one message, many recipients
  - Messages are stored durably across multiple AZs before delivery
  - **Data is not persisted** after delivery — if a subscriber is unavailable, retries occur but messages are not stored indefinitely
  - Up to **10 million subscriptions** per topic †
  - Up to **100,000 topics** per account †

---

## SNS Subscriber Types

| **Subscriber Target** | **Notes** |
|-----------------------|-----------|
| SQS queue | Most common — enables fan-out + durable buffering |
| Lambda function | Asynchronous invocation |
| HTTP / HTTPS endpoint | Webhooks, third-party services |
| Email / Email-JSON | Human notification |
| SMS | Mobile text messaging |
| Mobile push (APNS, GCM, ADM) | App-level push notifications |

---

## SNS + SQS Fan-Out Pattern
  - Subscribe **multiple SQS queues** to a single SNS topic
  - One SNS publish → multiple SQS queues receive independent copies
  - Each queue can have its own consumer processing independently
  - Enables parallel, decoupled processing of the same event

> 💡 **Exam Tip:** `"Process same event in multiple independent ways"` → **SNS fan-out to multiple SQS queues**
<br>This pattern is the canonical answer for "decouple and parallelize processing of a single upstream event."

---

## Amazon EventBridge

**Amazon EventBridge** (formerly CloudWatch Events) is a **serverless event bus** that routes events from AWS services, custom applications, and SaaS integrations to target services based on matching rules.

### Event Flow

```
Event Source → Event Bus → Rule (pattern match / schedule) → Target(s)
```

| **Component** | **Description** |
|---------------|-----------------|
| **Event Source** | AWS service, custom application, or integrated SaaS (Zendesk, Datadog, etc.) |
| **Event Bus** | Receives and routes events; three types: **Default** (AWS services), **Custom** (your apps), **Partner** (SaaS integrations) |
| **Rule** | Matches events by pattern or runs on a schedule; can fan out to multiple targets |
| **Target** | Where matched events are sent: Lambda, SQS, SNS, Step Functions, EC2, HTTP endpoints, etc. |

  - Rules can filter events by content using **event patterns**
  - **Schema Registry** — EventBridge can discover and store event schemas; generate code bindings ※
  - Formerly named **CloudWatch Events** Δ — rebranded to reflect broader capabilities; still handles scheduled rules

> 💡 **Exam Tip:** `"Route events from AWS services to Lambda / SQS / Step Functions based on patterns"` → **Amazon EventBridge**
<br>EventBridge is the modern, preferred event routing service — use it over CloudWatch Events for new architectures.

---

## EventBridge Scheduler ※

**EventBridge Scheduler** is a fully managed, serverless scheduling service for triggering AWS service targets on a one-time or recurring basis — replacing the older CloudWatch Events scheduled rules.
<br>It decouples scheduling logic from application code and scales to millions of scheduled invocations without managing infrastructure.

### Schedule Types

| **Type** | **Description** | **Example** |
|----------|----------------|-------------|
| **Rate-based** | Recur at a fixed frequency | Every 5 minutes, every 2 hours |
| **Cron-based** | Complex calendar schedules | Every weekday at 8 AM UTC |
| **One-time** | Fire exactly once at a specific datetime | Trigger on 2025-03-15 at 14:00 UTC |

### Key Properties

- Targets: Lambda, SQS, SNS, Step Functions, ECS Task, CodePipeline, EventBridge event buses, and more — **over 270 AWS services** as targets ※
- **Flexible time windows** — allow executions to start within a defined window (e.g., ±15 minutes) to avoid thundering-herd spikes ¤
- **Timezone support** — schedules can be expressed in any IANA timezone, not just UTC ※
- Supports **retry policies** and **dead-letter queues (DLQ)** for failed invocations
- IAM role on the scheduler grants permission to invoke the target on your behalf

> 💡 **Exam Tips:**
> <br>`"Trigger a Lambda function every 5 minutes"` → **EventBridge Scheduler** (rate expression) or **EventBridge Rule** (both are valid)
> <br>`"Schedule a one-time action at a specific future date and time"` → **EventBridge Scheduler** (one-time schedule)
> <br>`"Invoke a target millions of times per day on different schedules"` → **EventBridge Scheduler** scales to millions; CloudWatch Events had limits

---

## AWS Step Functions

**AWS Step Functions** is a managed **workflow orchestration service** that coordinates distributed application components as a series of visual steps using state machines.

  - Define workflows in **Amazon States Language (ASL)** — a JSON-based language
  - Visual console automatically graphs each step in execution order
  - Handles **retries, error handling, branching, and parallel execution** natively
  - Scales the underlying compute automatically

---

## State Machine Types

| **Type** | **Execution Model** | **Use Case** |
|----------|--------------------|-----------  |
| **Standard Workflows** | Exactly-once, durable; up to 1 year; full history visible in console | Long-running workflows, order processing, ETL pipelines |
| **Express Workflows** | At-least-once; up to 5 minutes; higher throughput, lower cost | High-volume, short-duration event processing, IoT, streaming |

> 💡 **Exam Tip:** `"Coordinate multiple Lambda functions and AWS services with error handling and retries"` → **AWS Step Functions**
<br>Step Functions eliminates the need to write coordination logic in application code.

---

## Amazon MQ

**Amazon MQ** is a **managed message broker service** for Apache ActiveMQ and RabbitMQ.

  - Use when migrating existing messaging applications that use **industry-standard protocols**: JMS, NMS, AMQP, STOMP, MQTT, WebSocket
  - Enables migration **without rewriting application code**
  - For **new** applications, AWS recommends SQS and SNS over Amazon MQ

> 💡 **Exam Tip:** `"Existing app uses JMS/AMQP/STOMP, need to migrate to AWS without code changes"` → **Amazon MQ**
<br>For new cloud-native apps, SQS and SNS are simpler and more cost-effective.

---

## Amazon Simple Workflow Service (SWF)

**Amazon SWF** is a **fully managed state tracker and task coordinator** for distributed workflows that involve external processes, long-running tasks, or human decision points.
<br>SWF tracks state and assigns tasks via API — your code implements the logic, not a visual state machine.

### Key Properties
  - **Activity workers** — execute tasks (perform the actual work); poll SWF for task assignments
  - **Deciders** — implement workflow logic (branching, sequencing, retry decisions); also poll SWF
  - **Exactly-once task assignment** — SWF guarantees that a task is assigned to exactly one activity worker at a time; prevents duplicate execution
  - Suitable for steps that take **> 500 milliseconds** and require state tracking across retries
  - Supports workflows running up to **1 year** †
  - Use when workflow steps involve **external systems, human approvals, or procedural processes** that cannot be modeled purely in code

---

## Step Functions vs. SWF

| **Aspect** | **AWS Step Functions** | **Amazon SWF** |
|------------|----------------------|----------------|
| **Model** | Visual state machine (ASL/JSON) | Programmatic — logic in activity worker / decider code |
| **Task assignment** | AWS manages — Lambda / service integrations called directly | Exactly-once task assignment via polling workers |
| **Human tasks** | Supported via wait states + callbacks | Native — core design intent |
| **External processes** | Via activity tasks and callbacks | Native — designed for external process integration |
| **Max duration** | Standard: 1 year †; Express: 5 minutes † | 1 year † |
| **AWS recommendation** | ✓ **Preferred for all new applications** Δ | Legacy — migrate to Step Functions when possible |
| **Complexity** | Lower — AWS handles orchestration | Higher — decider logic must be written and maintained |
| **Use case** | Orchestrating Lambda + AWS services in visual workflows | Human-enabled workflows; external systems with exact-once guarantees |

> 💡 **Exam Tips:**
> <br>`"Human-in-the-loop workflow, external processes"` → both SWF and Step Functions are candidates — SWF if exact-once task assignment is required; Step Functions for new builds
> <br>`"New workflow application on AWS"` → **AWS Step Functions** (AWS's stated recommendation for new apps)
> <br>`"Activity workers and deciders"` → **Amazon SWF** — these are SWF-specific named concepts

  - **AWS recommends Step Functions for all new applications** Δ — SWF is considered legacy

---

# API Management
---

## Amazon API Gateway

Amazon API Gateway is a **fully managed service** for creating, deploying, maintaining, monitoring, and securing APIs at any scale.
<br>Together with Lambda, API Gateway forms the application-facing layer of the AWS serverless infrastructure.

### Key Properties
  - Exposes **HTTPS endpoints only** — does not support unencrypted HTTP §
  - Handles: traffic management, authorization, throttling, caching, monitoring, version management
  - CloudFront is used as the public endpoint for edge-optimized APIs
  - Supports **API keys** and **Usage Plans** for tracking and throttling per client

---

## API Types

| **API Type** | **Description** | **Use Case** |
|--------------|-----------------|--------------|
| **REST API** | Full-featured; HTTP resources and methods; supports caching, transforms, usage plans | Standard API workloads with full feature set |
| **HTTP API** | Simplified, lower cost, lower latency; supports OIDC/OAuth2 natively ※ | Simple proxy APIs, microservices, lower overhead |
| **WebSocket API** | Persistent two-way connection; route keys and routes | Chat apps, real-time dashboards, live notifications |

---

## API Gateway Endpoint Types

| **Endpoint Type** | **Description** | **Best For** |
|------------------|-----------------|--------------|
| **Edge-Optimized** (default) § | Requests routed through CloudFront POPs globally | Geographically distributed clients |
| **Regional** | Deployed in a specific region; no CloudFront | Clients in the same region; pair with Route 53 latency routing for multi-region |
| **Private** | Accessible only via VPC interface endpoint (ENI) | Internal APIs within a VPC |

---

## API Gateway Integration Types

| **Backend** | **Integration Type** |
|-------------|---------------------|
| Lambda function | **Lambda Proxy** (pass-through; Lambda handles request/response) or **Lambda Custom** (API Gateway transforms request/response using mapping templates) |
| HTTP endpoint | **HTTP Proxy** or **HTTP Custom** |
| AWS service directly | **AWS Service integration** (e.g., write directly to SQS, DynamoDB) |

---

## API Gateway Stages and Deployments

  - A **deployment** is a snapshot of the API's resources and methods; must be created and associated with a stage to be accessible
  - A **stage** is a named reference to a deployment lifecycle state (e.g., `dev`, `test`, `prod`, `v2`)
  - **Stage variables** — environment variable equivalents for API Gateway; passed to Lambda via the `context` object; used to point stages at different Lambda aliases
  - **Canary deployments** — deploy a new version to a configurable percentage of traffic on a stage; test before full rollout

---

## API Gateway Caching

  - Cache endpoint responses for a configurable TTL to reduce backend calls and improve latency
  - **Default TTL: 300 seconds** § (minimum: 0, maximum: 3,600 seconds †)
  - **Cache size**: 0.5 GB – 237 GB †; defined per stage; can be encrypted
  - Clients can invalidate the cache by sending `Cache-Control: max-age=0` header
  - Cache settings can be overridden per method

---

## API Gateway Throttling

  - **Account-level defaults** per region (all APIs combined) †:
    - Steady-state rate: **10,000 requests per second (RPS)**
    - Maximum concurrent requests: **5,000**
    - Burst: **5,000 RPS**
  - Exceeding limits returns **HTTP 429 `TooManyRequestsException`**
  - Clients should implement retries with **exponential backoff** on 429 responses

### Throttling Hierarchy (most specific wins)
  1. Per-client per-method limits (usage plan)
  2. Per-client limits (usage plan)
  3. Per-method default limits (stage settings)
  4. Account-level defaults

---

## API Gateway Authorization

| **Method** | **How It Works** | **Use Case** |
|------------|-----------------|--------------|
| **IAM roles and policies** | SigV4-signed requests; IAM identity must have `execute-api:Invoke` permission | AWS services, internal AWS clients |
| **Amazon Cognito User Pools** | Validates JWT token from Cognito; no custom code | Web/mobile apps with user sign-in |
| **Lambda Authorizer** | Custom Lambda function validates token (JWT, OAuth2, API key) and returns IAM policy | Custom auth schemes, third-party identity providers |

  - **API keys** are for **identification and usage tracking only** — they are **not** a security/authentication mechanism §

> ⚠️ **Exam Trap:** API keys are **not** authentication — they track usage for rate limiting and billing. For real security, use IAM, Cognito, or a Lambda authorizer.

---

## API Gateway — Additional Features

  - **CORS (Cross-Origin Resource Sharing)** — API Gateway handles OPTIONS preflight requests and adds `Access-Control-Allow-Origin` headers; must be enabled when browser clients from a different domain call the API
  - **Mapping templates** — transform request/response payloads using Velocity Template Language (VTL); rename parameters, modify body, add headers, convert JSON ↔ XML
  - **Usage Plans** — define who can access API stages and at what rate; associated with API keys; control throttle and quota per client

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Run code in response to events without managing servers | **AWS Lambda** |
| Lambda function needs to access a private RDS database | Lambda with **VPC configuration** (subnet IDs + security groups) + NAT Gateway for internet access |
| Canary deployment for a Lambda function | **Lambda alias with traffic shifting weights** (e.g., 95%/5%) |
| Lambda cold start latency is unacceptable | **Provisioned Concurrency** |
| Decouple a web tier from an app tier, handle traffic spikes | **Amazon SQS** between tiers |
| Order-sensitive message processing, no duplicates | **SQS FIFO queue** |
| Fan out one event to multiple independent processing pipelines | **SNS topic → multiple SQS queues** (fan-out pattern) |
| Replace on-premises tape library with virtual tapes | Storage Gateway Tape Gateway (Module 8) |
| Route AWS service events to Lambda or other targets by pattern | **Amazon EventBridge** |
| Coordinate multi-step workflow with error handling and retries | **AWS Step Functions** |
| Migrate existing JMS/AMQP message broker to AWS without code changes | **Amazon MQ** |
| Expose Lambda functions as an HTTP API | **Amazon API Gateway + Lambda** |
| Restrict API access to within a VPC | **API Gateway Private Endpoint** + VPC interface endpoint |
| Per-client rate limiting on an API | **API Gateway Usage Plans + API Keys** |
| Authenticate API users via username/password with JWT | **Amazon Cognito User Pools** authorizer on API Gateway |
| Custom token validation on an API (e.g., third-party OAuth) | **API Gateway Lambda Authorizer** |
| Reduce Lambda invocations and improve API latency | **API Gateway Caching** |
| Real-time two-way communication (chat, live dashboard) | **API Gateway WebSocket API** |

---

# Module Summary
---

## Key Topics
  - Event-driven architecture: producers, channels, consumers, idempotency
  - Serverless characteristics: no server management, pay-per-use, automatic scaling
  - Lambda: invocation types (synchronous, asynchronous, event source mapping), concurrency (burst limits, reserved, provisioned), versions and aliases (traffic shifting), VPC access, layers
  - Application integration services: SQS, SNS, EventBridge, Step Functions, MQ, SWF
  - SQS: Standard vs. FIFO, visibility timeout, DLQ, delay queue, long polling
  - SNS: pub/sub, push delivery, fan-out with SQS, subscriber types
  - EventBridge: event bus types (default/custom/partner), rules, targets
  - EventBridge Scheduler ※ — rate/cron/one-time schedules; 270+ targets; replaces CloudWatch Events scheduled rules; flexible time windows; DLQ support
  - Step Functions: state machines, Standard vs. Express workflows
  - API Gateway: REST/HTTP/WebSocket API types, endpoint types (edge/regional/private), integration types, stages, caching, throttling, authorization, CORS

---

## Critical Acronyms
  - **EDA** — Event-Driven Architecture
  - **SQS** — Simple Queue Service
  - **SNS** — Simple Notification Service
  - **SWF** — Simple Workflow Service
  - **MQ** — Amazon MQ (managed message broker)
  - **DLQ** — Dead-Letter Queue
  - **FIFO** — First In, First Out
  - **TPS** — Transactions Per Second
  - **RPS** — Requests Per Second
  - **ASL** — Amazon States Language
  - **VTL** — Velocity Template Language
  - **CORS** — Cross-Origin Resource Sharing
  - **JWT** — JSON Web Token
  - **OIDC** — OpenID Connect
  - **API** — Application Programming Interface
  - **REST** — Representational State Transfer
  - **POP** — Point of Presence (CloudFront)
  - **ENI** — Elastic Network Interface
  - **IAM** — Identity and Access Management
  - **TTL** — Time to Live
  - **ARN** — Amazon Resource Name
  - **SDK** — Software Development Kit
  - **CLI** — Command Line Interface
  - **ALB** — Application Load Balancer

---

## Key Comparisons
  - Serverless Services Overview (SQS, SNS, EventBridge, Step Functions, MQ, SWF, Kinesis)
  - Lambda invocation types: Synchronous vs. Asynchronous vs. Event Source Mapping
  - Lambda Reserved vs. Provisioned Concurrency
  - Lambda Versions vs. Aliases
  - SQS Standard vs. FIFO
  - SQS Short Polling vs. Long Polling
  - SNS vs. SQS (push vs. pull, fan-out vs. point-to-point)
  - Kinesis vs. SQS vs. SNS (three-way differentiator table)
  - Step Functions vs. SWF
  - Step Functions Standard vs. Express Workflows
  - API Gateway REST API vs. HTTP API vs. WebSocket API
  - API Gateway Endpoint Types: Edge-Optimized vs. Regional vs. Private
  - API Gateway Authorization: IAM vs. Cognito vs. Lambda Authorizer

---

## Top Exam Triggers
  - `Serverless compute, event-driven` → **AWS Lambda**
  - `Lambda needs access to private VPC resource` → **Lambda VPC config + NAT Gateway for internet**
  - `Lambda canary / blue-green deployment` → **Lambda alias with traffic shifting**
  - `Lambda cold start latency unacceptable` → **Provisioned Concurrency**
  - `Multiple consumers read same data stream, replay old records` → **Amazon Kinesis** (not SQS — see Module 11)
  - `Decouple application tiers, buffer traffic spikes` → **Amazon SQS**
  - `Ordered messages, no duplicates` → **SQS FIFO**
  - `Reduce empty poll responses, lower SQS cost` → **SQS Long Polling**
  - `Messages failing repeatedly, need isolation` → **Dead-Letter Queue (DLQ)**
  - `Fan out single event to multiple consumers` → **SNS → multiple SQS queues**
  - `Route AWS service / SaaS events by pattern` → **Amazon EventBridge**
  - `Schedule a Lambda or Step Functions execution (one-time or recurring)` → **EventBridge Scheduler**
  - `Multi-step workflow with retries and error handling` → **AWS Step Functions**
  - `New workflow application on AWS` → **AWS Step Functions** (AWS's stated recommendation for new apps)
  - `Activity workers and deciders` → **Amazon SWF** — SWF-specific named concepts
  - `Human-in-the-loop, exact-once task assignment` → **Amazon SWF**
  - `Migrate JMS/AMQP broker without code changes` → **Amazon MQ**
  - `Expose HTTP API backed by Lambda` → **API Gateway + Lambda**
  - `API only accessible from within VPC` → **API Gateway Private Endpoint**
  - `Per-client API rate limiting` → **Usage Plans + API Keys**
  - `Authenticate API with Cognito user pool` → **Cognito User Pool authorizer**
  - `Custom token / third-party auth on API` → **Lambda Authorizer**
  - `API keys = authentication?` → **No — identification and tracking only**
  - `Two-way real-time API (chat, dashboard)` → **API Gateway WebSocket API**

---

## Quick References

### [Serverless Services Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619266#overview)

### [Serverless Services Architecture Patterns Private Link](https://drive.google.com/drive/folders/1jiizmhK-9yIGh0RBnKT6ZwZzPyksM0x7?usp=drive_link)

### [Serverless Services Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346112#overview)

### [AWS Lambda Cheat Sheet](https://digitalcloud.training/aws-lambda/)

### [AWS API Gateway Cheat Sheet](https://digitalcloud.training/amazon-api-gateway/)

### [AWS Application Integration Services Cheat Sheet](https://digitalcloud.training/aws-application-integration)

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
