# Foundations
---

## Stateless vs Stateful Applications

  - **Stateless** — no stored session state; each request is independent
    - No reliance on previous requests
    - Examples: weather websites, web servers, REST APIs, microservices
  - **Stateful** — maintains session or application state across requests
    - Requests may depend on previous interactions
    - Examples: shopping carts, databases, file systems, applications with session data
    - State is commonly managed using cookies, sessions, or tokens

> 💡 **Exam Tips:** 
<br>**Stateless workloads** are easier to scale **horizontally** because any instance can handle any request. 
<br>**Stateful workloads** either need **vertical scaling** or an **externalized session store** (DynamoDB, ElastiCache) to scale horizontally.

---

## Scaling Up vs Scaling Out

  - **Scaling Up (Vertical Scaling)** — increase resources (CPU, RAM, storage) of a single instance
    - Limited by the largest available instance size
    - Improves per-instance performance but reduces flexibility
    - Common for relational databases (RDS) where horizontal scaling is non-trivial
  - **Scaling Out (Horizontal Scaling)** — add more instances to distribute load
    - Improves fault tolerance and availability
    - More flexible and typically more cost-effective
    - Foundation for **Auto Scaling Groups (ASGs)**

### Decision Examples
  - **EC2 with MySQL DB on it** → Scale UP (single-instance DB)
  - **EC2 with static website content** → Scale OUT (stateless workload)

### Key Takeaways
  - **Scaling out** → high availability and fault tolerance
  - **Scaling up** → increased performance per instance

---

## High Availability vs Fault Tolerance

| **Aspect** | **High Availability (HA)** | **Fault Tolerance (FT)** |
|------------|------------------------------|----------------------------|
| **Goal** | Minimize service interruption | No service interruption |
| **Design** | No single point of failure (redundancy) | Specialized hardware with instantaneous failover |
| **Recovery time** | Seconds to minutes | None (zero downtime) |
| **Replication** | Synchronous or asynchronous | Synchronous required |
| **Failover model** | Active-passive | Active-active |
| **Data loss potential** | Possible small loss (RPO > 0) | None (RPO = 0) |
| **Cost** ¤ | Lower | Higher |
| **Example AWS services** | ELB, EC2 Auto Scaling, Route 53, RDS Multi-AZ | Multi-region active-active, redundant power, RAID 1, synchronous DB replication |

### Note on Availability Zones (AZs)
Think of an AZ as a single data center. 
<br>If that AZ goes down, all resources in it become unavailable. 
<br>Deploying across **multiple AZs** is the foundation of HA design on AWS.

> 💡 **Exam Tip:** **Multi-AZ deployments** are how you achieve HA on AWS — for compute (ASG across AZs), databases (RDS Multi-AZ), and load balancers (ELB across AZs). Single-AZ is rarely the right answer on the exam.

---

## Durability vs Availability

| **Durability** | **Availability** |
|----------------|--------------------|
| Protection against data loss / corruption | Measurement of uptime |
| Expressed as "9s" of durability | Expressed as % of time per year |
| **S3 Standard offers 11 9's** ‡ (`99.999999999%`) durability | **RDS Multi-AZ** typically delivers `99.95% – 99.99%` ‡ availability |
| Storing 10 million objects in S3 → expected to lose **one object every 10,000 years** | An S3 bucket has lower availability than durability (designed for 99.99%) |

> ⚠️ **Exam Trap:** Durability and availability are **not the same thing**. A service can be highly durable (won't lose data) but temporarily unavailable (can't reach it right now). S3 is the canonical example.

---

# Auto Scaling
---

## Amazon EC2 Auto Scaling

EC2 Auto Scaling **automatically launches and terminates instances** to maintain availability and match capacity to demand.

### Key Properties
  - Scaling is **horizontal** — scales out (adds) and in (removes)
  - Provides **elasticity and scalability**
  - Responds to:
    - **EC2 status checks** (instance impairment)
    - **CloudWatch metrics** (CPU, network, custom)
    - **ELB health checks** (when integrated with a load balancer)
  - Can scale based on **demand (performance)** or on a **schedule**
  - Works with **EC2, ECS, and EKS**

### Common Integrations
  - **CloudWatch** — metrics and scaling triggers
  - **Elastic Load Balancing** — distributes traffic across instances
  - **EC2 Spot Instances** — cost optimization within ASGs
  - **VPC** — multi-AZ deployment for HA

> 💡 **Exam Tip:** "Highly available, elastically scalable web tier" → **Auto Scaling Group across multiple AZs behind an Application Load Balancer**. This pattern shows up constantly.

---

## Auto Scaling Groups (ASGs)

An **ASG** is a collection of EC2 instances managed together for scaling and HA.

### Capacity Settings
  - **Minimum** — ASG never goes below this size
  - **Maximum** — ASG never goes above this size
  - **Desired** — target number; ASG adjusts to meet this when scaling triggers fire

### Scaling Policies
Define **when, how, and by how much** the ASG scales. Configured per ASG and tied to triggers (metrics, schedules, or manual actions).

### Termination Policies
When scaling in, ASG decides which instance to terminate based on configurable policies — defaults include longest-running, oldest launch template, closest to next billing hour.

---

## ASG Lifecycle Hooks

Lifecycle hooks **pause instance state transitions** during scale-out or scale-in to allow custom actions — such as bootstrapping software, running scripts, or draining connections — before the instance enters or leaves service.
<br>Without a lifecycle hook, ASG transitions instances immediately. With a hook, the instance is held in a **wait state** for a configurable period while your automation runs.

### How They Work

| **Transition** | **Hook State** | **Common Use Case** |
|---------------|---------------|---------------------|
| **Scale-out (launch)** | `Pending:Wait` → (action) → `Pending:Proceed` → `InService` | Install software, register with a config management system, warm up a cache |
| **Scale-in (terminate)** | `Terminating:Wait` → (action) → `Terminating:Proceed` → `Terminated` | Deregister from a load balancer, drain in-flight requests, copy logs to S3 |

- The hook sends a **notification to SNS, SQS, or EventBridge** when triggered — your automation polls or subscribes to receive the signal
- The instance remains in the wait state until your code calls `CompleteLifecycleAction` with `CONTINUE` or `ABANDON`, or until the **heartbeat timeout** expires (default: 1 hour §, max: 48 hours †)
- If the heartbeat expires without a `CompleteLifecycleAction` call, ASG uses the **default result** (`CONTINUE` or `ABANDON`) you configured on the hook

> 💡 **Exam Tips:**
> <br>`"Run a custom script before an instance joins the ASG fleet"` → **Lifecycle hook on scale-out (Pending:Wait)**
> <br>`"Drain in-flight requests before an instance is terminated"` → **Lifecycle hook on scale-in (Terminating:Wait)**
> <br>`"Ensure automation infrastructure integrity during Auto Scaling events"` → **Lifecycle hooks + SNS/SQS/EventBridge notification**

---

## ASG Warm Pools ※

A **Warm Pool** maintains a configurable number of pre-initialized instances in a stopped or running state, ready to be quickly promoted to `InService` when the ASG needs to scale out.
<br>This eliminates the cold-start delay caused by bootstrapping a new instance from scratch on every scale-out event.

- Warm pool instances complete their bootstrap (user data, software install) once — then sit in `Warmed:Stopped` or `Warmed:Running` state until needed
- When ASG scales out, it promotes instances from the warm pool first (seconds), then launches new cold instances if the pool is exhausted
- Warm pool size is configurable; stopped instances cost less than running instances ¤

> 💡 **Exam Tip:** `"Reduce scale-out latency for an ASG when instances take a long time to bootstrap"` → **ASG Warm Pool**.
> <br>This is the modern answer to the pattern: "pre-warm instances ahead of traffic spikes."

---

## Launch Templates vs Launch Configurations

ASGs need a definition of what an instance should look like. Two options:

| **Aspect** | **Launch Template** Δ | **Launch Configuration** (legacy) |
|------------|--------------------------|-------------------------------------|
| Status | **Recommended, current** § | Deprecated for new ASGs Δ |
| Versioning | Yes (multiple versions per template) | No (immutable, must replace) |
| Mixed instances / Spot | Yes | Limited |
| Capacity reservations | Yes | No |
| Tenancy / placement groups | Yes | Limited |
| T2/T3 Unlimited mode | Yes | No |
| Newer instance features | Yes | No |

### Common Configuration Includes
  - AMI and instance type
  - EBS volumes
  - Security groups
  - Key pair
  - IAM instance profile
  - User data
  - Purchasing options (On-Demand vs Spot)
  - Termination protection
  - Placement group, capacity reservation, tenancy (Launch Template only)

> ⚠️ **Exam Trap:** Launch Configurations are **deprecated** Δ — AWS no longer adds new EC2 features to them. Always answer with **Launch Templates** for new ASGs.

---

## ASG Health Checks

ASGs replace instances that fail health checks. Two sources:

| **Health Check Source** | **What's Checked** |
|---------------------------|----------------------|
| **EC2** § | EC2 system + instance status checks |
| **ELB** | EC2 status checks **plus** ELB target health (application-layer) |

  - **ELB health checks** are application-aware — they detect cases where the OS is fine but the app is unresponsive
  - The ASG must be **attached to a load balancer's target group** to use ELB health checks

### Health Check Grace Period
  - Time after launch before health checks start counting
  - Prevents premature termination of instances still bootstrapping
  - Default: 300 seconds; tune based on your bootstrap time

> 💡 **Exam Tip:** "ASG keeps replacing instances that are actually fine, just still booting" → **Increase the health check grace period**.

---

## Types of Auto Scaling

| **Type** | **Trigger** | **Use Case** |
|----------|-------------|---------------|
| **Manual** | You change capacity directly | Operator-driven adjustments |
| **Dynamic** | CloudWatch metrics | Reactive scaling to real demand |
| **Predictive** ※ | ML forecasts based on historical patterns | Proactive scaling before predictable spikes |
| **Scheduled** | Time/date | Known recurring patterns (business hours, batch windows) |

---

## Dynamic Scaling Policies

Dynamic scaling has three sub-types:

### Target Tracking
  - Maintain a metric at a **target value** (e.g., 50% CPU utilization)
  - ASG adjusts capacity to keep the metric on target
  - **AWS recommends a 1-minute † metric frequency** for responsiveness
  - Instance metrics are **not counted** until the **warm-up period** has expired
  - Simplest to configure — usually the right starting point

### Simple Scaling
  - Single threshold triggers a single scaling action
  - Example: "If CPU > 70% for 5 minutes, add 2 instances"
  - **Cooldown period** of 300 seconds † (default) prevents rapid back-to-back scaling
  - Less flexible than step scaling

### Step Scaling
  - **Multiple thresholds** trigger different responses
  - Example: "CPU > 70% → add 2 instances; CPU > 90% → add 4 instances"
  - More responsive to sudden, varied demand changes
  - Preferred for workloads with **uneven scaling needs**

### Scheduled Scaling
  - Scale by **time and date**, not metrics
  - Example: scale out at 8 AM, scale in at 6 PM
  - Useful for predictable patterns (business hours, lunch rush, end-of-month batches)

> 💡 **Exam Tips:** 
<br>"Maintain a metric at target value" → **Target Tracking** 
<br>"Different scaling responses based on severity" → **Step Scaling** 
<br>"Predictable daily/weekly patterns" → **Scheduled Scaling** 
<br>"Use ML to forecast and pre-scale before traffic arrives" → **Predictive Scaling**

> 🔧 **Pro Tip:** **Combining Predictive + Dynamic** is the AWS-recommended pattern for production 
<br>**Predictive** handles the forecastable baseline,
<br>**Dynamic** catches the unforecastable spikes.

---

# Load Balancing
---

## Elastic Load Balancing (ELB)

**ELB** automatically distributes incoming application traffic across multiple targets in one or more AZs.

### Supported Targets
  - **EC2 instances**
  - **ECS containers**
  - **IP addresses** (in or outside the VPC, including on-premises)
  - **AWS Lambda functions** (ALB only)
  - **Other Application Load Balancers** (NLB only)

### Key Properties
  - Provides **high availability and fault tolerance**
  - Performs **health checks** — routes traffic only to healthy targets
  - Supports **multi-AZ** deployment
  - Can be **internet-facing** or **internal** (private)
  - Uses **target groups** for routing

> 💡 **Exam Tip:** ELB and ASG together provide the canonical **HA + elasticity** pattern: 
<br>**ELB** distributes traffic across healthy instances,
<br>**ASG** replaces failed instances and adjusts capacity.

---

## Types of ELB

AWS offers **four** types of load balancer. ALB and NLB are by far the most exam-relevant.

### Application Load Balancer (ALB) — Layer 7
  - **HTTP / HTTPS** traffic
  - Routes based on **request content** (path, host, headers, query string, source IP) ※
  - **Supports HTTP/2 and gRPC** ※
  - Targets: **instances, IPs, Lambda functions, containers**
  - Best for **web applications and microservices**

### Network Load Balancer (NLB) — Layer 4
  - **TCP / UDP / TLS** traffic
  - Routes based on **IP protocol data**
  - **Ultra-low latency**, millions of requests per second ‡
  - Supports **static IPs and Elastic IPs** per AZ
  - **TLS offloading at scale** ※
  - Optimized for **sudden, volatile traffic patterns** ※
  - Targets: **instances, IPs, ALBs**
  - Best for **TCP/UDP apps, gaming, IoT, real-time**, and when **static IPs are required**

### Gateway Load Balancer (GWLB) — Layer 3
  - Used in front of **third-party virtual appliances** (firewalls, IDS/IPS, deep packet inspection)
  - Listens for **all packets on all ports** at Layer 3
  - Uses the **GENEVE protocol** on port 6081 ‡ to exchange traffic with appliances
  - Targets: **instances, IPs**
  - Centralized inspection / monitoring across VPCs

### Classic Load Balancer (CLB) — Layer 4 + Layer 7 (legacy)
  - **Legacy**, replaced by ALB and NLB
  - Basic load balancing, no advanced routing
  - **Not recommended for new applications**
  - Still supported but de-emphasized on the modern exam

> 💡 **Exam Tip:** When the question is between ALB and NLB: 
<br>**HTTP/HTTPS, content-based routing** → **ALB** 
<br>**TCP/UDP, ultra-low latency, static IP** → **NLB** 
<br>**Third-party security appliances (firewall, IDS/IPS)** → **GWLB**

---

## Application Load Balancer (ALB) vs Network Load Balancer (NLB)

| **Aspect** | **ALB** | **NLB** |
|------------|----------|----------|
| OSI Layer | 7 (HTTP/HTTPS) | 4 (TCP/UDP/TLS) |
| Target types | Instance, IP, Lambda | Instance, IP, ALB |
| Target group protocol | HTTP / HTTPS | TCP / UDP / TLS / TCP_UDP |
| Health check protocol | HTTP / HTTPS only | Any (TCP, HTTP, HTTPS) |
| Static / Elastic IP | No | **Yes** (one per AZ) |
| Advanced routing rules | **Yes** (path, host, headers, query, source IP) | No |
| Supports Lambda targets | Yes | No |
| Supports ALB as target | No | Yes |
| Performance focus | Flexibility | Ultra-low latency, very high throughput ‡ |
| TLS termination | Yes | Yes |
| Self-signed cert allowed | Yes | No (must be public ACM cert) |

> ⚠️ **Exam Trap:** "Need static / whitelistable IPs for the load balancer" → **NLB only**. 
<br>ALB IPs are dynamic and AWS-managed.

---

## ELB Components

Three things define how an ELB routes traffic:

### Target Groups
  - **Target type** — instance, IP, Lambda, ALB
  - **Target protocol and port**
  - **VPC and registered targets**
  - **Health check settings** — protocol, path, interval, thresholds
  - Multiple target groups allow **content-based routing** to different backend pools

### Listeners
  - **Protocol and port** the LB listens on
  - **Routing rules** — how traffic maps to target groups
  - **SSL/TLS certificate** (for HTTPS/TLS listeners)
  - You can have multiple listeners on different ports (e.g., 80 and 443) but **only one listener per port per LB**

### Network Mappings
  - Defines which **AZs and subnets** the LB operates in
  - The ELB **deploys nodes in each AZ (subnet)** it's mapped to

---

## ALB Advanced Routing

ALB supports several content-based routing modes ※:

| **Routing Type** | **Example** |
|--------------------|--------------|
| **Path-based** | `/api/*` → Target Group A, `/images/*` → Target Group B |
| **Host-based** | `api.example.com` → TG A, `www.example.com` → TG B |
| **HTTP header-based** | Match on custom headers |
| **HTTP method-based** | Different routes for `GET` vs `POST` |
| **Query string parameter-based** | `?env=prod` → TG A |
| **Source IP-based** | Internal IPs → TG A, external → TG B |

### Other ALB Capabilities
  - **Targets can be outside the VPC** — on-premises, other accounts, other regions
  - **Cross-account targets** ※ via VPC peering or Transit Gateway

---

## What Source IP Does the App See?

When an app behind a load balancer reads the request's source IP, what it sees depends on the LB type and target type:

| **Load Balancer** | **Target Type** | **Source IP App Sees** | **Original Client IP Preserved?** |
|---------------------|------------------|----------------------------|-------------------------------------|
| **CLB / ALB** | Any | Private IP of the LB's ENI | **No** — use `X-Forwarded-For` header to recover |
| **NLB (TCP/TLS)** | Instance ID | **Original client IP** | **Yes** |
| **NLB (TCP/TLS)** | IP address | Private IP of NLB node | No |
| **NLB (UDP / TCP_UDP)** | Any | **Original client IP** | **Yes** |

  - **`X-Forwarded-For`** ※ — HTTP header added by ALB/CLB to capture the original client IP
  - **VPC Endpoint or AWS Global Accelerator with NLB** — source IP becomes the private IP of the NLB nodes

> 💡 **Exam Tip:** "Need to log or filter on real client IPs at the application layer" → **NLB with Instance ID targets** preserves the source IP. <br>With ALB, use **`X-Forwarded-For`**.

> 📚 **Learn More:** This is a quick ELB-side reference.
>
> - **[AWS Knowledge Center — capture client IPs behind ELB](https://aws.amazon.com/premiumsupport/knowledge-center/elb-capture-client-ip-addresses/)** — full explanation across LB / target type combinations

---

## Cross-Zone Load Balancing

Controls whether ELB nodes distribute traffic **across all AZs** or **only to targets in their own AZ**.

| **State** | **Behavior** | **Default §** |
|-----------|---------------|---------------|
| **Enabled** | Each ELB node distributes to **all targets in all enabled AZs** | **ALB**: always enabled |
| **Disabled** | Each ELB node distributes only to targets in **its own AZ** | **NLB / GWLB**: disabled by default |

### Example — Cross-Zone DISABLED
  - **AZ1**: 1 ELB node, 3 targets · **AZ2**: 1 ELB node, 2 targets
  - DNS distributes 50/50 between the two ELB nodes
  - **AZ1 targets**: each gets 1/3 of AZ1 traffic → ~16.6% of total each
  - **AZ2 targets**: each gets 1/2 of AZ2 traffic → 25% of total each
  - **Uneven load** because AZ counts differ

### Example — Cross-Zone ENABLED
  - Same setup: AZ1 with 3 targets, AZ2 with 2 targets
  - Each of the 5 targets gets **20% of total traffic**
  - **Even load** regardless of AZ distribution

> 💡 **Exam Tip:** "Uneven instance counts across AZs, want even traffic distribution" → **Enable cross-zone load balancing** (or use ALB, where it's always enabled).

> ⚠️ **Exam Trap:** Cross-zone load balancing for **NLB has data transfer charges** ¤ between AZs when enabled. 
<br>ALB does not charge for cross-zone traffic. Consider cost when enabling on NLB.

---

# Sessions & Security
---

## Session State Storage

For applications that need session continuity (logins, shopping carts) across instance failures, store session state **externally**:

| **Service** | **Why** |
|--------------|----------|
| **Amazon DynamoDB** | Serverless key-value store; session ID → session data |
| **Amazon ElastiCache** (Redis or Memcached) | Sub-millisecond in-memory store; ideal for session caches |

  - Both are key-value stores well-suited to session lookup patterns
  - Externalizing state makes the **app tier stateless** — instances become interchangeable

> 📚 **Learn More:** This is a quick reference on storing session state.
>
> - **Module 11 — Databases & Analytics** — full DynamoDB and ElastiCache coverage including consistency models, capacity modes, and use case selection

---

## Sticky Sessions (Session Affinity)

**Sticky sessions** route a user's subsequent requests to the **same target instance** they hit first.

### Mechanism
  - ELB issues a **cookie** that binds the client to a specific instance
  - Cookie lifetime is configurable: **load-balancer-controlled** or **application-controlled**
  - Useful for stateful applications that store session data **locally** on the instance

### Drawbacks
  - **Uneven load distribution** — popular users / sessions concentrate on specific instances
  - **Reduced fault tolerance** — if the bound instance fails, session state is **lost**
  - Generally an **anti-pattern** for modern designs — externalizing state is preferred

> 💡 **Exam Tip:** "Once authenticated, user must not re-authenticate even if an instance fails" → **External session store (DynamoDB or ElastiCache)**, not sticky sessions.

> ⚠️ **Exam Trap:** Sticky sessions **don't survive instance failure** — if the bound instance dies, the user's local session data is lost. 
<br>Use sticky sessions + an external store for resiliency.

### Cookies for Client-Side Session Data
  - Session data can be stored on the client in **cookies** for the cookie lifetime or until browser close
  - Less secure than server-side storage
  - If the session crashes locally, session data is lost
  - Useful for simple apps where session loss is acceptable

---

## [Secure Sockets Layer (SSL) / Transport Layer Security (TLS)](https://drive.google.com/drive/folders/1fhLgTPllTvhq5RkJCbhdo1NmmnAqB4Md?usp=drive_link)

  - **SSL** — Secure Sockets Layer; predecessor to TLS
  - **TLS** — Transport Layer Security; modern, secure protocol for in-transit encryption

### SSL/TLS Termination at the Load Balancer
The LB decrypts incoming TLS, then either:
  - Forwards traffic **unencrypted** to backend instances (Layer 7 ALB), OR
  - **Re-encrypts** to backend instances using a separate cert

### ALB SSL/TLS
  - Can use **self-signed certificates** — fine for dev/test, not production
  - Production: use **AWS Certificate Manager (ACM)** or imported public certs
  - With L7 ALB, a **new connection** is established with the backend instance
  - Self-signed or private CA certs allowed for backend connections

### NLB SSL/TLS
  - **Public certificate required** § — must be from **ACM** (or imported public CA)
  - Self-signed certificates **not allowed**
  - Certificate must be in the **same region** as the NLB ◊
  - **Single encrypted connection** end-to-end (no decrypt/re-encrypt at LB)

### AWS Certificate Manager (ACM)
  - Provides **free public certificates** ¤ for use with AWS services
  - Auto-renewing
  - Integrates with ELB, CloudFront, API Gateway

> 💡 **Exam Tip:** "Need TLS termination on a load balancer with public ACM cert" → **ALB or NLB** depending on Layer 7 vs Layer 4 needs. 
<br>**NLB** **requires** public ACM; 
<br>**ALB** allows self-signed for dev.

> 📚 **Learn More:** This is a quick reference on TLS at the load balancer.
>
> - **Module 14 — Security** — full ACM coverage, certificate management, and TLS architecture patterns

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| HA and elastic scalability for web servers | **EC2 Auto Scaling + ALB across multiple AZs** |
| Low-latency UDP connections to a gaming app pool | **NLB with a UDP listener** |
| Clients must whitelist static IPs for the load balancer | **NLB with static / Elastic IPs per AZ** |
| EC2 ASG application requires DR across regions | **Second-region ASG with capacity 0; copy snapshots cross-region (Lambda or DLM)** |
| App must scale by larger increments for big traffic spikes vs small ones | **Step Scaling policy** with larger capacity increase at higher thresholds |
| Scale EC2 behind an ALB based on requests per instance | **Target Tracking on `ALBRequestCountPerTarget`** |
| Authenticated users must not re-authenticate if an instance fails | **External session store — DynamoDB or ElastiCache** |
| Deploying IDS/IPS virtual appliances that need horizontal scaling | **Gateway Load Balancer in front of the appliances** |
| Distribute traffic evenly across uneven AZ instance counts | **Enable cross-zone load balancing** (or use ALB) |
| Capture original client IP at the application layer behind ALB | Use the **`X-Forwarded-For` header** |
| Capture original client IP behind NLB | Use **NLB with Instance ID targets** (preserves source IP for TCP/TLS) |
| ASG keeps replacing healthy-but-still-booting instances | **Increase the health check grace period** |

---

## HOL Lab Notes — User Data Web Server

  - **`yum`** is for Amazon Linux 2; doesn't work on Amazon Linux 2023
  - **`dnf`** is the package manager for Amazon Linux 2023
  - Provide both in user-data scripts for cross-version compatibility

### HTTP vs HTTPS in Lab Setups
  - Default web server bootstrap covers **HTTP only**
  - **HTTPS** requires:
    - Apache listening on **port 443**
    - A valid **TLS certificate + private key**
    - **Security group rule** allowing inbound 443
  - Most modern browsers **auto-redirect HTTP → HTTPS**, which causes lab pages to fail to load if the server isn't configured for HTTPS — a common issue with self-signed certs or HTTP-only setups

### Activity History
The ASG **Activity History** view in the console shows scale-out and scale-in events triggered by CloudWatch metrics. 
<br>Manually terminating an instance triggers a scale-out event as the ASG replaces the missing capacity.

![Auto Scaling](../../assets/HOL-labs/web-server-auto-scaling.png)S

---

# Module Summary
---

## Key Topics
  - Stateless vs stateful applications
  - Vertical vs horizontal scaling
  - High availability vs fault tolerance
  - Durability vs availability
  - EC2 Auto Scaling Groups (ASGs) — min, max, desired capacity
  - Launch Templates (preferred) vs Launch Configurations (deprecated)
  - ASG health checks — EC2 vs ELB; grace period
  - Auto Scaling types — Manual, Dynamic, Predictive, Scheduled
  - Dynamic scaling policies — Target Tracking, Simple, Step
  - ASG Lifecycle Hooks — pause instance transitions (Pending:Wait, Terminating:Wait); SNS/SQS/EventBridge notification; custom bootstrap or drain logic
  - ASG Warm Pools ※ — pre-initialized instances eliminate cold-start delay on scale-out
  - Elastic Load Balancing — ALB, NLB, GWLB, CLB
  - ELB components — Target Groups, Listeners, Network Mappings
  - ALB advanced routing — path, host, header, query, source IP
  - Source IP preservation across LB / target type combinations
  - Cross-zone load balancing — enabled by default for ALB, disabled for NLB/GWLB
  - Session state — sticky sessions vs externalized state stores
  - SSL/TLS termination — ALB vs NLB certificate requirements
  - Architecture patterns combining ASG + ELB across AZs

---

## Critical Acronyms
  - **ASG** — Auto Scaling Group
  - **ELB** — Elastic Load Balancing
  - **ALB** — Application Load Balancer
  - **NLB** — Network Load Balancer
  - **GWLB** — Gateway Load Balancer
  - **CLB** — Classic Load Balancer (legacy)
  - **TG** — Target Group
  - **HA** — High Availability
  - **FT** — Fault Tolerance
  - **RPO** — Recovery Point Objective
  - **RTO** — Recovery Time Objective
  - **DR** — Disaster Recovery
  - **AZ** — Availability Zone
  - **DLM** — Data Lifecycle Manager
  - **SSL** — Secure Sockets Layer
  - **TLS** — Transport Layer Security
  - **ACM** — AWS Certificate Manager
  - **GENEVE** — Generic Network Virtualization Encapsulation (used by GWLB)
  - **IDS / IPS** — Intrusion Detection / Prevention System
  - **SNI** — Server Name Indication (for hosting multiple TLS certs on one LB)

---

## Key Comparisons
  - Stateless vs Stateful applications
  - Scaling Up vs Scaling Out
  - High Availability vs Fault Tolerance
  - Durability vs Availability
  - Launch Templates vs Launch Configurations
  - ALB vs NLB
  - ALB vs NLB vs GWLB vs CLB
  - Target Tracking vs Simple vs Step Scaling
  - Sticky Sessions vs Externalized Session State
  - Cross-zone Enabled vs Disabled
  - Source IP behavior across CLB / ALB / NLB / target type

---

## Top Exam Triggers
  - `HA + elastic scaling for web tier` → **ASG + ALB across multiple AZs**
  - `HTTP/HTTPS with path or host-based routing` → **Application Load Balancer**
  - `TCP/UDP with ultra-low latency` → **Network Load Balancer**
  - `Static / whitelistable IP for load balancer` → **NLB with Elastic IPs per AZ**
  - `UDP traffic to gaming/IoT/voice app` → **NLB with UDP listener**
  - `Third-party firewall / IDS / IPS appliances` → **Gateway Load Balancer**
  - `Maintain CPU at 50% across the fleet` → **Target Tracking scaling policy**
  - `Larger scaling response for bigger spikes` → **Step Scaling policy**
  - `Predictable daily/weekly traffic patterns` → **Scheduled Scaling**
  - `ML-forecasted scaling before anticipated spike` → **Predictive Scaling**
  - `Session continuity across instance failures` → **External session store (DynamoDB / ElastiCache)**, not sticky sessions
  - `Original client IP needed by app behind ALB` → **`X-Forwarded-For` header**
  - `Original client IP needed by app behind NLB` → **Instance ID target type** (TCP/TLS)
  - `Even traffic across uneven AZ instance counts` → **Enable cross-zone LB** (or use ALB)
  - `ASG keeps killing instances still booting` → **Increase health check grace period**
  - `Run custom script before instance joins fleet` → **ASG Lifecycle Hook (scale-out)**
  - `Drain requests before instance is terminated` → **ASG Lifecycle Hook (scale-in)**
  - `Reduce scale-out latency for slow-bootstrapping instances` → **ASG Warm Pool**
  - `New ASG configuration` → **Launch Template** (Launch Configurations deprecated)
  - `Multi-region DR for ASG-based app` → **Second region ASG capacity 0** + cross-region snapshot copy
  - `Scale on requests per instance behind ALB` → **Target Tracking on `ALBRequestCountPerTarget`**

---

## Quick References

### [ELB Use Cases](https://drive.google.com/drive/folders/1trzy3C57bU4lpfxE-VnznUMfi2meAa8b?usp=drive_link)

### [ASG & ELB Architecture Patterns Private Link](https://drive.google.com/drive/folders/1CAXbFCIvNFT3s__yGGmJK_xmFT69tDUU?usp=drive_link)

### [ASG & ELB Exam Cram](https://drive.google.com/drive/folders/1trzy3C57bU4lpfxE-VnznUMfi2meAa8b?usp=drive_link)

### [ASG & ELB Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346098#overview)

### [ASG & ELB Cheat Sheet](https://digitalcloud.training/auto-scaling-and-elastic-load-balancing/)

---

> ### Symbol Key:
> - `†` quota or limit 
> - `‡` hardware/performance spec 
> - `§` AWS default behavior
> - `※` feature availability 
> - `¤` pricing-related 
> - `◊` regional variance
> - `Δ` recently changed (older sources may describe prior behavior)
> - All flagged values are subject to change — verify against current AWS documentation before relying on them for design decisions.