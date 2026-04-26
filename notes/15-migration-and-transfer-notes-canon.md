# Migration Strategy
---

## The 7 Rs of Migration

The **7 Rs** are the canonical framework for categorizing how an application moves to the cloud.
<br>They range from least effort (retire or retain) to most effort and highest cloud-native value (refactor).
<br>The exam uses them to match a business scenario to the right migration approach.

| **Strategy** | **What It Means** | **Effort** | **AWS Tools / Examples** |
|-------------|-------------------|-----------|--------------------------|
| **Retire** | Decommission — the app is no longer needed | None | — |
| **Retain** | Keep on-premises for now; revisit later | None | — |
| **Relocate** | Move infrastructure without modification — lift and shift at the hypervisor/platform level | Minimal | VMware Cloud on AWS; move VMs wholesale |
| **Rehost** | Move OS and application to a new host without code changes — classic lift and shift | Low | AWS MGN, VM Import/Export |
| **Replatform** | Minor optimizations with no core architecture changes — same app, better platform | Moderate | RDS instead of self-managed DB; Elastic Beanstalk instead of bare EC2 |
| **Repurchase** | Replace with a different product — usually a SaaS solution | Moderate | Salesforce, ServiceNow, Workday replacing custom apps |
| **Refactor** | Re-architect to cloud-native; redesign for serverless, containers, managed services | High | Lambda + API GW + DynamoDB replacing monolithic app |

> 💡 **Exam Tips:**
> <br>"Migrate servers to AWS as quickly as possible with no code changes" → **Rehost** (MGN)
> <br>"Move a self-managed database to Amazon RDS with minimal changes" → **Replatform**
> <br>"Redesign the application as serverless microservices" → **Refactor**
> <br>"Move VMware VMs to AWS without modifying them" → **Relocate**

> ⚠️ **Exam Trap:** **Rehost** and **Relocate** both sound like "lift and shift."
<br>**Rehost** moves the OS and application to EC2 — a new host in the cloud.
<br>**Relocate** moves the entire virtualization platform (VMware) — no changes at any layer.

---

# Discovery & Planning
---

## AWS Application Discovery Service

AWS Application Discovery Service helps enterprise customers **plan migration projects** by gathering information about their on-premises data centers before any migration begins.
<br>It collects server utilization data and dependency mapping — the critical first steps for deciding what to migrate, in what order, and at what scale.

### Discovery Methods

| **Method** | **Deployment** | **Target** | **Data Collected** |
|-----------|---------------|-----------|-------------------|
| **Discovery Connector** (agentless) | OVA file deployed in VMware vCenter | VMware VMs only | VM inventory, CPU/memory/disk utilization, configuration history |
| **Discovery Agent** (agent-based) | Installed per server (Windows / Linux) | VMware VMs and physical servers | System config, performance, running processes, **network connections between systems** |

- Collected data is stored in an **encrypted Application Discovery data store**
- Data can be exported as **CSV** for TCO (Total Cost of Ownership) analysis ¤
- Data automatically flows into **AWS Migration Hub** for visualization and tracking
- Data can be saved to **Amazon S3** and queried with **Amazon Athena** or **Amazon QuickSight**

> 💡 **Exam Tips:**
> <br>"Discover on-premises server inventory and performance metrics before migrating" → **AWS Application Discovery Service**
> <br>"VMware environment — discover without installing agents on every VM" → **Discovery Connector** (agentless, vCenter OVA)
> <br>"Physical servers and mixed VMware — need process-level and network dependency data" → **Discovery Agent**

---

## AWS Migration Hub

AWS Migration Hub is the **central dashboard for tracking migration progress** across all AWS and partner migration tools.
<br>It provides a single location to monitor the status of every server and application as they move through the migration lifecycle.

### Key Properties

- Collects migration status updates from integrated tools: **MGN, DMS, CloudEndure**, and AWS partner solutions
- Displays a network visualization of server dependencies discovered by Application Discovery Service
- Tracks migrations into **any AWS region** — the Hub itself is global ◊
- Does not perform migrations itself — it **aggregates and displays** status

> 💡 **Exam Tip:** "Single pane of glass to track the status of all in-flight server and database migrations" → **AWS Migration Hub**

---

# Server Migration
---

## AWS Application Migration Service (MGN)

AWS Application Migration Service (MGN) is the **primary AWS service for lift-and-shift server migration** — moving physical, virtual, and cloud servers to AWS with minimal downtime.
<br>It replaces the older AWS Server Migration Service (SMS) and supports both agent-based and agentless replication. Δ

### How It Works

1. **Install the AWS Replication Agent** on each source server (on-premises, VMware, Hyper-V, or another cloud)
2. MGN continuously replicates **block-level data** to a staging area in AWS (a low-cost replication server)
3. When ready, launch **test instances** to validate the migration without impacting the source
4. Perform a **final sync**, then **cut over** — launching production EC2 instances from the replicated data
5. Cutover window is measured in **minutes** (vs. hours with the legacy SMS)

### Key Properties

- **Continuous block-level replication** — source server stays live throughout; minimal data loss risk
- **Agentless option** — the **MGN vCenter Client** (OVA) enables agentless snapshot-based replication for VMware environments; agent-based is preferred for CDP (continuous data protection)
- EC2 instances are launched from **launch templates** — configurable before cutover
- Integrates with **CloudFormation** for migrating entire application groups in **migration waves**
- Can migrate **virtual and physical servers**
- Integrates with **AWS Migration Hub** for tracking

### MGN vs. SMS (Legacy)

| **Feature** | **AWS MGN** | **AWS SMS (deprecated)** |
|------------|------------|--------------------------|
| **Replication type** | Continuous block-level | Incremental snapshot-based |
| **Cutover window** | Minutes | Hours |
| **Recommended?** | ✅ Yes — AWS recommended | ❌ No — AWS recommends migrating to MGN |
| **CDP support** | Yes (agent-based) | No |

> 💡 **Exam Tips:**
> <br>"Lift-and-shift server migration with minimal downtime" → **AWS MGN**
> <br>"Minimize the cutover window during server migration" → **MGN** (continuous replication → minutes of final sync)
> <br>"Migrate an entire application stack of web + app + DB servers together" → **MGN migration waves with CloudFormation**

---

# Database Migration
---

## AWS Database Migration Service (DMS)

AWS Database Migration Service (DMS) migrates databases to AWS **quickly and securely**, keeping the source database fully operational during the migration to minimize application downtime.
<br>It supports both one-time migrations and ongoing continuous replication.

### Migration Types

| **Migration Type** | **Definition** | **SCT Required?** | **Example** |
|-------------------|---------------|-------------------|-------------|
| **Homogeneous** | Same engine on source and target | ❌ No | Oracle → Oracle, MySQL → RDS MySQL, SQL Server → RDS SQL Server |
| **Heterogeneous** | Different engine on source and target | ✅ Yes — convert schema with SCT first | Oracle → Aurora, Microsoft SQL Server → RDS MySQL |

### Key Capabilities

- **Source stays live** during migration — near-zero downtime §
- **CDC (Change Data Capture)** — continuously captures and applies ongoing changes from the source to the target, keeping them in sync during the migration window
- Supports migrations **to and from** most commercial and open-source databases
- Targets include: **Aurora, RDS, Redshift, DynamoDB, DocumentDB, S3**
- Also used for **continuous data replication** beyond initial migration: DR, dev/test environments, data consolidation

### DMS Use Cases

| **Use Case** | **Pattern** |
|-------------|------------|
| On-premises database → Amazon RDS or Aurora | Standard one-time migration + CDC for cutover |
| Cloud to cloud | EC2 database → RDS; RDS → Aurora |
| Database consolidation | Multiple source DBs → single target DB |
| Continuous replication to data warehouse | RDS → Redshift (streaming via DMS) |
| Development/test environment | Replicate production to a dev copy |

> 💡 **Exam Tips:**
> <br>"Migrate a database with minimal downtime — source must stay live" → **AWS DMS with CDC**
> <br>"Migrate Oracle to Amazon Aurora" → **SCT** (schema conversion) + **DMS** (data migration)
> <br>"Continuously replicate data from RDS to Redshift for analytics" → **AWS DMS**

---

## AWS Schema Conversion Tool (SCT)

AWS SCT is a **desktop application** that converts a source database schema — tables, views, stored procedures, functions — to a schema compatible with the target AWS database engine.
<br>It is **required for heterogeneous migrations** where source and target engines differ.

### SCT vs. DMS

| **Tool** | **Role** | **When to Use** |
|---------|---------|----------------|
| **SCT** | Converts the database schema (DDL) | Heterogeneous migrations — run SCT first |
| **DMS** | Migrates the actual data (DML) | All migrations — runs after schema is ready |

- SCT handles **smaller, simpler conversions** for standard databases
- SCT also handles **complex data warehouse migrations** (e.g., Oracle data warehouse → Redshift) — DMS is not used for these large warehouse migrations
- SCT generates a **migration assessment report** showing which objects can be auto-converted and which require manual intervention

> 💡 **Exam Tip:** "Migrate Oracle to Aurora" → **SCT first** (convert schema) → **DMS** (migrate data).
<br>Homogeneous migrations (Oracle → Oracle, MySQL → MySQL) do not need SCT.

---

# Data Transfer
---

## AWS DataSync

AWS DataSync is a **secure, online data movement service** that automates and accelerates transferring data between on-premises storage systems and AWS storage services — or between AWS storage services.
<br>It handles scheduling, bandwidth throttling, encryption in transit, and data integrity verification automatically.

### Supported Sources and Destinations

DataSync can copy data between any of the following:
- **On-premises:** NFS shares, SMB shares, Hadoop Distributed File System (HDFS), self-managed object storage
- **Edge devices:** AWS Snowcone (with DataSync agent pre-installed)
- **AWS storage:** Amazon S3 (all storage classes), Amazon EFS, Amazon FSx (Windows, Lustre, OpenZFS, NetApp ONTAP)

### Key Properties

- Requires a **DataSync agent** — software installed on an on-premises server (or on Snowcone) that connects to the on-premises storage system
- Transfers are **encrypted in transit with TLS**
- **Data integrity verification** in transit and at rest — detects and retries corrupted transfers
- Supports **scheduling and bandwidth throttling** — transfers can run off-peak without saturating the network
- Provides visibility via **CloudWatch metrics, logs, and EventBridge events**

### DataSync vs. Storage Gateway

| **Service** | **Purpose** | **Pattern** |
|------------|------------|------------|
| **DataSync** | One-time or periodic bulk data transfer | Migrate or sync data from on-prem to AWS |
| **Storage Gateway** | Ongoing hybrid access to AWS storage | On-prem applications access AWS storage transparently |

> 📚 **Learn More:** Storage Gateway is covered in full in Module 8 — File Storage.
>
> - **Module 8 — File Storage** — File Gateway, Volume Gateway (Cached/Stored), Tape Gateway

> 💡 **Exam Tips:**
> <br>"Migrate or sync large datasets from on-premises NFS/SMB to S3 or EFS" → **AWS DataSync**
> <br>"Automate scheduled data transfers from on-premises to AWS with bandwidth control" → **DataSync**
> <br>"Copy data between two AWS storage services (EFS to FSx, S3 to EFS)" → **DataSync**

---

## AWS Transfer Family

AWS Transfer Family provides a **fully managed file transfer service** that supports SFTP, FTPS, and FTP protocols, with Amazon S3 or Amazon EFS as the backend storage.
<br>It lets organizations migrate their file transfer workflows to AWS without changing client-side applications, tools, or scripts — the endpoint DNS name changes, but nothing else does.

### Supported Protocols

| **Protocol** | **Full Name** | **Security** |
|-------------|--------------|-------------|
| **SFTP** | Secure File Transfer Protocol (SSH-based) | Encrypted |
| **FTPS** | FTP over SSL/TLS | Encrypted |
| **FTP** | File Transfer Protocol | ⚠️ Unencrypted — use only in trusted networks |
| **AS2** ※ | Applicability Statement 2 (B2B messaging) | Encrypted |

### Key Properties

- Backend storage: **Amazon S3** or **Amazon EFS**
- Integrates with existing **authentication systems** — Active Directory, LDAP, Cognito, custom Lambda authorizers
- DNS routing with **Amazon Route 53** — clients point to the Transfer Family endpoint, not AWS infrastructure directly
- Once data is in S3 or EFS, it is available to all AWS analytics, ML, and processing services

> 💡 **Exam Tips:**
> <br>"Managed SFTP service backed by S3" → **AWS Transfer Family**
> <br>"Migrate SFTP workflows to AWS without changing client software or scripts" → **Transfer Family**
> <br>"Partners need to submit files via SFTP and the data must land in S3" → **Transfer Family**

---

## AWS Snow Family

The AWS Snow Family consists of **physical edge computing and offline data transfer devices** for moving large volumes of data to AWS when network transfer is too slow, too expensive, or not available.
<br>All devices use **256-bit encryption (managed with KMS)** and tamper-resistant enclosures with a TPM (Trusted Platform Module).

### Snow Family Devices

| **Device** | **Usable Storage** | **Compute** | **Scale** | **Best For** |
|-----------|-------------------|------------|---------|-------------|
| **Snowcone** | 8 TB HDD (14 TB SSD variant) ‡ | 2 vCPUs, 4 GB RAM | TB scale | Smallest device — edge locations, IoT, ruggedized environments |
| **Snowball Edge Storage Optimized** | ~80 TB usable ‡ | 40 vCPUs, 80 GB RAM | Petabyte scale | Large-scale data transfer; local storage in remote locations |
| **Snowball Edge Compute Optimized** | ~42 TB usable ‡ + optional GPU | 52 vCPUs, 208 GB RAM | Petabyte scale | ML inference, video processing, edge compute with optional GPU |
| **Snowmobile** | Up to **100 PB** per vehicle ‡ | N/A — transfer only | Exabyte scale | Data center migrations at exabyte scale |

### Key Properties

- **Snowcone** — smallest and most portable; DataSync agent pre-installed; can transfer data offline (ship the device) or online (run DataSync over the network)
- **Snowball Edge** — both variants support **block storage** and **Amazon S3-compatible object storage**; can run **EC2-compatible compute** and **Lambda functions** at the edge
- **Snowmobile** — an **exabyte-scale data transfer service** delivered in a 45-foot ruggedized shipping container pulled by a semi-trailer truck; suited for migrating entire data centers
- Devices use the **Snowball Client** — software installed locally to identify, compress, encrypt, and transfer data to the device

### When to Use Snow vs. Online Transfer

The key exam decision: **Is it faster (time + cost) to ship a device than to transfer over the network?**

A rough rule of thumb: if transferring over a 1 Gbps link would take more than a week, a Snow device is likely better.

| **Scenario** | **Recommended Approach** |
|-------------|--------------------------|
| < 1 TB, good network | Online: DataSync or S3 Transfer Acceleration |
| Tens of TB, limited or slow network | **Snowball Edge** |
| Hundreds of TB to PB scale | **Snowball Edge** (multiple devices) |
| EB scale — moving entire data center | **Snowmobile** |
| Edge location, no reliable internet | **Snowcone or Snowball Edge** |

> 💡 **Exam Tips:**
> <br>"50 TB of data to transfer, only a 1 Gbps link available, urgent timeline" → **AWS Snowball**
> <br>"Migrate an entire data center — multiple petabytes" → **AWS Snowmobile**
> <br>"Collect and process data at a remote edge location with no internet" → **Snowcone or Snowball Edge Compute Optimized**
> <br>"Run ML inference at the edge on Snowball" → **Snowball Edge Compute Optimized** (with optional GPU)

> ⚠️ **Exam Trap:** Snowball devices do **not** connect directly to S3 — data is transferred to the device locally, the device is shipped to AWS, and AWS imports the data into S3.
<br>For online transfer (where the device has connectivity), use the DataSync agent on Snowcone.

### Optimizing Snowball Transfer Performance

When transferring millions of small files, performance degrades because each file incurs overhead. Best practices:
1. **Batch small files** before copying
2. **Run multiple copy operations simultaneously** — separate terminal sessions, separate Snowball client instances
3. **Copy from multiple workstations** in parallel
4. **Transfer directories**, not individual files
5. Use the **latest Mac or Linux Snowball client**

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|-------------|
| Discover on-premises server inventory before migrating | AWS Application Discovery Service |
| Discover VMware VMs without installing agents on each | Discovery Connector (agentless, OVA in vCenter) |
| Discover physical servers + network dependency maps | Discovery Agent (agent-based, per server) |
| Track all migration progress in a single dashboard | AWS Migration Hub |
| Lift-and-shift server migration with minimal downtime | AWS Application Migration Service (MGN) |
| Migrate an entire application stack in a coordinated wave | MGN migration waves + CloudFormation templates |
| Migrate a MySQL database to Amazon Aurora (same engine) | AWS DMS — homogeneous migration (no SCT needed) |
| Migrate an Oracle database to Amazon Aurora PostgreSQL | SCT (schema conversion) → DMS (data migration) + CDC |
| Migrate an Oracle data warehouse to Amazon Redshift | SCT (warehouse conversion) → DMS for data load |
| Keep source and target in sync during migration window | DMS with CDC (Change Data Capture) |
| Automate bulk transfer from on-premises NFS to Amazon S3 | AWS DataSync with DataSync agent |
| Sync data between two AWS storage services (EFS to FSx) | AWS DataSync |
| Provide managed SFTP endpoint backed by Amazon S3 | AWS Transfer Family (SFTP) |
| Transfer 80 TB of data — only a 1 Gbps internet link | AWS Snowball Edge |
| Migrate an entire data center — exabyte scale | AWS Snowmobile |
| Collect and process sensor data at a remote site | Snowcone or Snowball Edge Compute Optimized |
| Slow Snowball transfer due to millions of small files | Batch files + multiple parallel copy operations |
| Private dedicated connection for ongoing hybrid traffic | AWS Direct Connect (Module 5) |
| Encrypted connection over internet for hybrid access | AWS Site-to-Site VPN (Module 5) |
| Speed up global uploads to S3 from distributed users | S3 Transfer Acceleration (Module 6) |
| Ongoing hybrid file access to S3 from on-premises apps | AWS Storage Gateway — File Gateway (Module 8) |

---

## HOL Notes — Migration CLI Operations

> 🛠️ **Implementation Notes:**
> <br>**Application Discovery Service:** Enable in the Migration Hub console → deploy the OVA connector in VMware vCenter, or install the Discovery Agent on each server; data populates in the Migration Hub automatically
> <br>**MGN Setup:** In the MGN console → replication settings → install the AWS Replication Agent on source servers → monitor replication lag → launch test instances → perform final sync → cutover
> <br>**DMS Task:** Create a replication instance → define source and target endpoints → create a migration task; choose "Migrate existing data and replicate ongoing changes" for full-load + CDC
> <br>**SCT:** Install the SCT application locally → connect to source DB → run the schema assessment report → apply automatic conversions → resolve flagged items manually → export to target
> <br>**DataSync:** Create a DataSync agent in the console → activate the agent running on-premises → create a source location (NFS/SMB/etc.) → create a destination location (S3/EFS/FSx) → create and start a task

---

# Module Summary
---

## Key Topics
  - **The 7 Rs of Migration** — Retire, Retain, Relocate, Rehost, Replatform, Repurchase, Refactor; ordered by effort; Rehost vs. Relocate distinction
  - **AWS Application Discovery Service** — pre-migration discovery; Discovery Connector (agentless VMware) vs. Discovery Agent (agent-based, physical + VMware); data flows to Migration Hub and S3
  - **AWS Migration Hub** — central tracking dashboard for all migration tools; does not perform migrations; global service
  - **AWS Application Migration Service (MGN)** — continuous block-level replication; agent-based (preferred) and agentless (vCenter); minutes-long cutover; replaces SMS Δ; migration waves + CloudFormation
  - **AWS DMS** — database migration with near-zero downtime; source stays live; CDC for ongoing sync; homogeneous vs. heterogeneous; targets include Aurora, RDS, Redshift, DynamoDB, S3
  - **AWS SCT** — schema conversion for heterogeneous migrations; run before DMS; generates migration assessment report; handles complex data warehouse conversions
  - **AWS DataSync** — automated online data transfer; agent-based; NFS/SMB/HDFS/object storage → S3/EFS/FSx; TLS encryption; scheduling + bandwidth control
  - **AWS Transfer Family** — managed SFTP/FTPS/FTP/AS2; S3 or EFS backend; no client changes required; Route 53 for DNS routing
  - **AWS Snow Family** — physical offline transfer devices; KMS encryption; Snowcone (TB, edge), Snowball Edge (PB, Storage or Compute Optimized), Snowmobile (EB, data center migrations); Snowball transfer optimization best practices

---

## Critical Acronyms
  - **MGN** — AWS Application Migration Service (Application Migration Service)
  - **SMS** — AWS Server Migration Service (legacy, deprecated in favor of MGN) Δ
  - **DMS** — AWS Database Migration Service
  - **SCT** — AWS Schema Conversion Tool
  - **CDC** — Change Data Capture
  - **TCO** — Total Cost of Ownership
  - **NFS** — Network File System
  - **SMB** — Server Message Block
  - **HDFS** — Hadoop Distributed File System
  - **SFTP** — Secure File Transfer Protocol
  - **FTPS** — FTP over SSL/TLS
  - **FTP** — File Transfer Protocol
  - **AS2** — Applicability Statement 2
  - **TPM** — Trusted Platform Module
  - **TLS** — Transport Layer Security
  - **KMS** — Key Management Service
  - **DDL** — Data Definition Language (schema)
  - **DML** — Data Manipulation Language (data)
  - **CDP** — Continuous Data Protection
  - **OVA** — Open Virtualization Appliance (VMware deployment format)
  - **EFS** — Elastic File System
  - **FSx** — Amazon FSx (managed third-party file systems)
  - **EC2** — Elastic Compute Cloud
  - **S3** — Simple Storage Service
  - **VPN** — Virtual Private Network
  - **DR** — Disaster Recovery

---

## Key Comparisons
  - The 7 Rs of Migration — ordered by effort with tools/examples (table)
  - Discovery Connector vs. Discovery Agent — deployment, targets, data collected (table)
  - MGN vs. SMS — replication type, cutover window, CDP (table)
  - DMS migration types — homogeneous vs. heterogeneous, SCT requirement (table)
  - SCT vs. DMS — role and when to use (table)
  - Snow Family devices — storage, compute, scale, best for (table)
  - Online vs. offline transfer decision guide — by volume and network (table)
  - DataSync vs. Storage Gateway — migration vs. hybrid access (inline)

---

## Top Exam Triggers
  - `Migrate servers to AWS with no code changes` → **Rehost — AWS MGN**
  - `Move VMware VMs to AWS without any modification` → **Relocate**
  - `Move a self-managed database to RDS with minor changes` → **Replatform**
  - `Redesign as serverless/microservices` → **Refactor**
  - `Discover on-premises server dependencies before migrating` → **Application Discovery Service**
  - `Agentless discovery in VMware vCenter` → **Discovery Connector**
  - `Track progress of all migrations in one place` → **AWS Migration Hub**
  - `Lift-and-shift with minimal downtime, minutes-long cutover` → **AWS MGN**
  - `Migrate Oracle to Aurora — different engines` → **SCT (schema) + DMS (data)**
  - `Migrate MySQL to RDS MySQL — same engine` → **DMS only (no SCT)**
  - `Keep source and target in sync during migration` → **DMS CDC**
  - `Source database must stay live during migration` → **DMS**
  - `Convert Oracle data warehouse schema for Redshift` → **SCT**
  - `Automate bulk transfer from on-premises NFS to S3` → **DataSync**
  - `Transfer between two AWS storage services (EFS to FSx)` → **DataSync**
  - `Managed SFTP service backed by S3` → **AWS Transfer Family**
  - `50 TB to transfer, slow internet, urgent` → **AWS Snowball Edge**
  - `Exabyte-scale data center migration` → **AWS Snowmobile**
  - `Edge computing + data collection, no internet` → **Snowcone or Snowball Edge Compute Optimized**
  - `Snowball transfer slow due to small files` → **batch files + multiple parallel copy operations**

---

## Quick References

### [Migration and Transfer Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619608#overview)

### [Migration and Transfer Architecture Patterns Private Link](https://drive.google.com/drive/folders/1vlwd2zXFFVC62_9Id4esho2q0D24pk8Z?usp=drive_link)

### [Migration and Transfer Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346122#overview)

### [AWS Migration Services Cheat Sheet](https://digitalcloud.training/aws-migration-services/)

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
