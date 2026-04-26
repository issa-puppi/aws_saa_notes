# Database Fundamentals
---

## Database Types Overview

| **Category** | **Model** | **Schema** | **Scaling** | **Query** | **AWS Services** |
|--------------|-----------|------------|-------------|-----------|-----------------|
| **Relational** | Tables, rows, columns | Rigid (schema-on-write) | Vertical (scale up) | SQL — complex joins, transactions | RDS, Aurora |
| **Key-Value** | Key → value pairs | Flexible (schema-on-read) | Horizontal (scale out) | Simple lookups by key | DynamoDB, ElastiCache |
| **Document** | JSON / BSON documents | Flexible | Horizontal | Document queries, nested fields | DocumentDB |
| **Graph** | Nodes, edges, properties | Flexible | Horizontal | Traversal queries (relationships) | Neptune |
| **Wide-Column** | Tables with dynamic columns | Semi-flexible | Horizontal | CQL (Cassandra Query Language) | Keyspaces |
| **In-Memory** | Key-value in RAM | N/A | Horizontal / vertical | Sub-millisecond lookups | ElastiCache |
| **Ledger** | Immutable journal (append-only) | Fixed | Managed | SQL-like | QLDB |
| **Time Series** | Timestamped measurements | Semi-flexible | Managed | Time-series functions | Timestream |

---

## Operational vs. Analytical Databases

| **Feature** | **Operational / Transactional (OLTP)** | **Analytical (OLAP)** |
|-------------|----------------------------------------|----------------------|
| **Workload type** | Online Transaction Processing | Online Analytical Processing |
| **Purpose** | Run the day-to-day business | Analyze the business; derive insights |
| **Data source** | Primary application data | Derived from OLTP systems |
| **Data structure** | Highly normalized | Denormalized / optimized for queries |
| **Queries** | Simple, short, high-frequency | Complex, long-running, low-frequency |
| **Latency** | Low-latency (real-time) | Higher latency (batch/analytical) |
| **Relational examples** | RDS, Aurora, MySQL, PostgreSQL | Redshift, Teradata |
| **Non-relational examples** | DynamoDB, MongoDB, Cassandra | Athena, EMR, Redshift Spectrum |

  - **OLTP** = run the business (**write-heavy, real-time**)
  - **OLAP** = analyze the business (**read-heavy, complex queries**)
  - Analytical systems typically **read** from OLTP sources
  - Operational databases **feed** into data warehouses (e.g., RDS → Redshift)

---

## AWS Database Services — Quick Selection Guide

| **Requirement** | **Service** |
|-----------------|-------------|
| Full control over instance and database engine | **Database on EC2** |
| Managed relational DB (structured, well-formed data) | **Amazon RDS** |
| High-performance managed relational DB, MySQL/PostgreSQL compatible | **Amazon Aurora** |
| Fully managed serverless NoSQL, massive scale, low latency | **Amazon DynamoDB** |
| In-memory caching, ultra-low latency | **Amazon ElastiCache** |
| Data warehousing, OLAP, complex SQL analytics | **Amazon Redshift** |
| Full-text search, log analytics, observability | **Amazon OpenSearch Service** |
| Managed graph database, highly connected data | **Amazon Neptune** |
| Managed document database, MongoDB-compatible | **Amazon DocumentDB** |
| Managed Cassandra (wide-column), CQL-compatible | **Amazon Keyspaces** |
| Immutable ledger, cryptographically verifiable transaction log | **Amazon QLDB** |
| Time series data (IoT telemetry, metrics) | **Amazon Timestream** |

---

# Relational Databases
---

## Amazon Relational Database Service (RDS)

Amazon RDS is a **fully managed relational database service** for running OLTP workloads.
<br>RDS manages: security/patching, automated backups, software updates, scaling, Multi-AZ replication, and failover.

### Key Properties
  - Supports engines: **MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Amazon Aurora**
  - Runs on **EC2 instances managed by AWS** — uses **EBS volumes** for storage
  - **No access to the underlying EC2 instance** (no root access, no OS login) §
  - DB instances accessed via **endpoints** (DNS names)
  - Default limit: **40 DB instances** per account (only 10 Oracle or SQL Server without BYOL) †
  - RDS is an **OLTP** service — not suited for OLAP; use Redshift for analytics
  - Maintenance windows configurable — some operations require brief offline period

### RDS Database Engines

| **Engine** | **Key Notes** |
|------------|--------------|
| **MySQL** | Popular open-source; web apps, WordPress, e-commerce |
| **PostgreSQL** | Advanced open-source; geospatial (PostGIS), complex queries |
| **MariaDB** | MySQL-compatible fork; open-source (GNU GPL); performance improvements |
| **Oracle** | Enterprise commercial; BYOL or license-included; TDE encryption supported |
| **Microsoft SQL Server** | Commercial; .NET stack, BI tools; TDE encryption supported |
| **Amazon Aurora** | AWS-proprietary; MySQL/PostgreSQL compatible; higher performance (see below) |

---

## RDS Scaling

| **Scaling Type** | **How** | **Impact** | **Use For** |
|------------------|---------|------------|-------------|
| **Vertical (scale up)** | Change instance type | Brief downtime to apply | More CPU, memory, network — required for write performance |
| **Horizontal (scale out)** | Add read replicas | No downtime | Read scaling only — not write scaling |
| **Storage auto-scaling** | Automatically expands EBS when approaching limit | No downtime | Avoid storage full events |

---

## RDS Multi-AZ Deployments

  - **Synchronous standby replica** automatically created in a different AZ
  - **Automatic failover** — RDS promotes standby to primary on failure; DNS endpoint updated automatically
  - **Multi-AZ is for high availability, NOT for read scaling** — standby cannot serve read traffic §
  - Snapshots taken from **standby** (no I/O impact on primary for MariaDB, MySQL, PostgreSQL, Oracle)
  - Exception: **SQL Server Multi-AZ** — I/O briefly suspended on primary during snapshot

> ⚠️ **Exam Trap:** Multi-AZ standby is **not** a read replica — it does not serve traffic. For read scaling, you need **read replicas**.

---

## RDS Read Replicas

  - **Asynchronous replication** from primary to read replicas — slight replication lag possible
  - Used for **read scaling** — offload `SELECT` queries from primary
  - Up to **5 read replicas** per DB instance † (MySQL, MariaDB, PostgreSQL, Oracle, SQL Server)
  - Read replicas require **automated backups enabled** on the primary (retention > 0)
  - Each read replica has its **own DNS endpoint**
  - Can be in **same AZ, different AZ, or different region** (cross-region read replicas use asynchronous replication)
  - Can be **promoted to a standalone DB instance** (becomes its own primary — breaks replication)
  - Read replicas can be multi-AZ enabled
  - A read replica of an encrypted instance is **encrypted using the same KMS key** (same region) or **different KMS key** (different region)

> 💡 **Exam Tips:**
> <br>`"Reduce read load on primary database"` → **RDS Read Replica**
> <br>`"DR to another region, can be promoted to primary"` → **Cross-region RDS Read Replica**
> <br>`"Automatic failover with no data loss"` → **RDS Multi-AZ** (synchronous)

---

## RDS Backups and Recovery

| **Type** | **What It Covers** | **Retention** | **Notes** |
|----------|-------------------|---------------|-----------|
| **Automated backups** | Entire DB instance + transaction logs | 0–35 days (default 7) † | Enables point-in-time recovery to any second in retention window; stored in S3; cannot be used after instance is deleted |
| **Manual snapshots** | Entire DB instance at a point in time | Indefinitely (until manually deleted) | User-initiated; persists after instance deletion; good for before major changes |

  - Restored DBs always create a **new RDS instance with a new DNS endpoint**
  - Backup window is configurable; brief I/O suspension during backup (single-AZ only)

---

## RDS Encryption

  - Encryption at rest: **AWS KMS** — AES-256; minimal performance impact; supported for all engines
  - Encryption in transit: **SSL/TLS** — RDS generates a certificate per instance
  - All encrypted elements: DB instance storage, automated backups, read replicas, snapshots
  - **Encryption must be enabled at instance creation** — cannot enable encryption on an existing unencrypted instance

### Encryption Rules

| **Operation** | **Allowed?** |
|---------------|-------------|
| Unencrypted → Encrypted (new instance from encrypted snapshot copy) | ✓ Yes |
| Encrypted → Unencrypted | ✗ Never |
| Encrypted read replica of unencrypted primary | ✗ Never |
| Unencrypted read replica of encrypted primary | ✗ Never |
| Cross-region read replica — same KMS key | ✗ Not possible (different region requires different KMS key) |

### Encrypting an Existing Unencrypted RDS Instance
  1. Create a **snapshot** of the unencrypted instance
  2. **Copy the snapshot** and enable encryption during the copy
  3. **Restore** the encrypted snapshot to a **new RDS instance**
  4. Update application endpoints to point to the new instance

> ⚠️ **Exam Trap:** This creates a **new DB instance** with a **new endpoint** — the existing instance is not modified.

---

## RDS Security

  - Deploy in a **VPC** — use **private subnets** for DB instances (best practice)
  - **Security groups** control inbound/outbound DB traffic
  - **DB subnet groups** — a collection of subnets (≥ 2 AZs) designated for RDS instances
  - **IAM database authentication** — authenticate to MySQL or PostgreSQL using an IAM authentication token instead of a password; traffic encrypted via SSL; managed centrally via IAM
  - RDS does **not support resource-based policies** — uses identity-based IAM policies §

---

## RDS Proxy

**Amazon RDS Proxy** is a fully managed database proxy that sits between your application and RDS/Aurora, maintaining a **pool of reusable database connections**.

  - Reduces connection overhead and protects against **connection storms** (e.g., Lambda scaling events)
  - Improves **failover time** — applications reconnect to the proxy, not directly to the DB
  - Integrates with **IAM authentication** and **AWS Secrets Manager**
  - Highly available across multiple AZs
  - **Does NOT cache query results** — not a replacement for ElastiCache
  - Does NOT replace read replicas — it manages connections to existing endpoints

> 💡 **Exam Tip:** `"Lambda functions overwhelming RDS with too many connections"` → **RDS Proxy**
<br>RDS Proxy pools and multiplexes connections so thousands of Lambda invocations share a small set of DB connections.

---

## Amazon Aurora

Amazon Aurora is an **AWS-proprietary relational database engine** that is MySQL and PostgreSQL compatible with significantly higher performance and availability than standard RDS engines.

### Key Properties
  - **5× faster than MySQL, 3× faster than PostgreSQL** ‡ (standard RDS)
  - **Distributed, fault-tolerant, self-healing storage** — data automatically striped across hundreds of storage nodes
  - Storage scales automatically up to **128 TB** per instance †
  - **6 copies of data across 3 AZs** (2 copies per AZ) — can handle loss of **2 copies without impacting write availability**, loss of **3 copies without impacting read availability**
  - Each 10 GB storage chunk replicated 6 ways across 3 AZs
  - Continuous backup to S3 — point-in-time recovery to any second within retention period (up to 35 days †)
  - Automated backups have **no impact on DB performance**

### Aurora Endpoints
  - **Writer Endpoint** — always points to the current primary instance (auto-updates on failover)
  - **Reader Endpoint** — load-balances reads across all Aurora Replicas
  - **Custom Endpoints** — route to a subset of instances (e.g., analytics vs. app replicas)

### Aurora Replica Types

| **Feature** | **Aurora Replicas** | **MySQL Read Replicas** |
|-------------|--------------------|-----------------------|
| **Max replicas** | Up to **15** | Up to **5** |
| **Replication lag** | Milliseconds (asynchronous) | Seconds (asynchronous) |
| **Performance impact on primary** | Low | Higher |
| **Replica location** | In-region only | In-region or cross-region |
| **Failover target** | ✓ Yes — **no data loss** | ✓ Yes — potentially minutes of data loss |
| **Automatic failover** | ✓ Yes — fast, built-in | ✗ No — manual |
| **User-defined replication delay** | ✗ No | ✓ Yes |
| **Different schema/data from primary** | ✗ No (read-only copies) | ✓ Yes (configurable) |

---

## Aurora Deployment Options

### Aurora Global Database
  - Single Aurora cluster spanning **multiple AWS regions**
  - **Storage-based replication** — typical replication lag **< 1 second** globally ‡
  - Secondary regions can be promoted to full read/write in **< 1 minute** (DR failover)
  - **Write Forwarding** — secondary regions can forward writes to the primary without promotion
  - Up to **5 secondary regions** †

### Aurora Serverless
  - **On-demand, auto-scaling** Aurora — capacity adjusts automatically based on application load
  - Scales in **Aurora Capacity Units (ACUs)**
  - Connects via a **router fleet** — no direct instance management
  - **Pay per second** for capacity consumed while active ¤
  - Use cases: infrequent/intermittent workloads, new apps with unknown scale, dev/test, variable traffic, multi-tenant apps

### Aurora Multi-Master
  - **Multiple writer instances** across AZs — eliminates single-writer bottleneck
  - All nodes can process read/write operations simultaneously
  - **Strong consistency (read-after-write)**; automatic conflict detection and resolution
  - No failover needed for writes — a writer failure does not require promotion
  - More complex conflict handling; less common than single-writer Aurora

### Aurora Auto Scaling
  - Dynamically adjusts number of Aurora Replicas based on connection count or CPU utilization
  - Scales read capacity in/out automatically — removes unneeded replicas when load drops ¤

> 💡 **Exam Tips:**
> <br>`"Cloud-optimized, high performance MySQL/PostgreSQL"` → **Amazon Aurora**
> <br>`"Global low-latency reads, < 1 second replication, DR promotion < 1 min"` → **Aurora Global Database**
> <br>`"Unpredictable/intermittent workload, pay only when active"` → **Aurora Serverless**
> <br>`"Continuous write availability across AZs, no failover"` → **Aurora Multi-Master**

---

# In-Memory Caching
---

## Amazon ElastiCache

Amazon ElastiCache is a **fully managed in-memory data store and caching service** supporting Redis and Memcached engines.
<br>Stores data in **RAM** for sub-millisecond latency — ideal for offloading read traffic from databases.

### Key Properties
  - **Key-value store** — not a full relational or document database
  - Can be placed in front of RDS, Aurora, DynamoDB to cache frequently accessed data
  - Runs on EC2 instances managed by AWS — must choose instance type
  - **Cannot be accessed from the internet** or from EC2 instances in other VPCs §
  - Available as **on-demand or reserved** instances — **not Spot** §
  - Billed by node size and hours of use ¤
  - Accessed via **endpoints** (per-node or cluster endpoint)

---

## ElastiCache Engines — Memcached vs. Redis

| **Feature** | **Memcached** | **Redis (Cluster Mode Disabled)** | **Redis (Cluster Mode Enabled)** |
|-------------|---------------|-----------------------------------|---------------------------------|
| **Persistence** | No — in-memory only | Yes — RDB snapshots, AOF logs | Same as disabled |
| **Data types** | Simple strings | Complex: strings, lists, sets, hashes, sorted sets | Same as disabled |
| **High availability / failover** | No | Yes — replication + automatic failover | Same as disabled |
| **Multi-AZ** | Yes (nodes in multiple AZs; no replication) | Yes (auto-failover with read replicas 0–5) | Same as disabled |
| **Encryption (at rest + in transit)** | No | Yes — TLS + KMS | Same as disabled |
| **Data partitioning / sharding** | Yes (client-side) | No | Yes — shards across nodes |
| **Backup / restore** | No | Yes — automated and manual snapshots | Same as disabled |
| **Multithreading** | Yes — multi-core/thread | No — single-threaded core | No — single-threaded per shard |
| **Pub/Sub messaging** | No | Yes | Yes |
| **HIPAA compliance** | No | Yes ※ | Yes ※ |
| **Use case** | Simple caching, session store, ephemeral data | Caching, real-time analytics, pub/sub, leaderboards, complex data structures | All Redis use cases at large scale requiring sharding |

### Quick Selection

| **Need** | **Engine** |
|----------|------------|
| Simple cache, no persistence, max throughput | **Memcached** |
| HA, failover, persistence | **Redis** |
| Encryption required | **Redis** |
| Sharding / massive horizontal scale | **Redis (Cluster Mode Enabled)** |
| Pub/Sub, leaderboards, sorted sets | **Redis** |
| Multithreaded high-throughput caching | **Memcached** |

---

## ElastiCache Scaling

| **Engine** | **Vertical** | **Horizontal** |
|------------|-------------|----------------|
| **Memcached** | Change node type (may cause cache loss — no replication) | Add/remove nodes (client-side sharding) |
| **Redis (Cluster Disabled)** | Change node type | Add read replicas (up to 5) for read scaling |
| **Redis (Cluster Enabled)** | Change node type per shard | Add/remove shards; online resharding |

---

## ElastiCache Use Cases

| **Requirement** | **Engine** | **Why** |
|-----------------|------------|---------|
| Offload read traffic from RDS/Aurora | Memcached or Redis | Cache query results; reduce DB load |
| Session state storage for load-balanced web apps | Redis | Persistence + HA; session survives server loss |
| Gaming leaderboards | Redis | Sorted sets with atomic updates |
| Real-time dashboards, streaming analytics | Redis | Streams, fast in-memory updates |
| Pub/Sub messaging, chat, event-driven updates | Redis | Native pub/sub support |
| Simple stateless caching at scale | Memcached | Multi-threaded, horizontal scaling |
| Short-lived / disposable data | Memcached | No persistence, fast eviction |

> 💡 **Exam Tips:**
> <br>`"Offload read pressure from database, frequently accessed data"` → **ElastiCache**
> <br>`"Session state storage for stateless web tier"` → **ElastiCache (Redis preferred for HA)**
> <br>`"Need encryption with ElastiCache"` → **Redis only** — Memcached does not support encryption

---

## Amazon MemoryDB for Redis ※

Amazon MemoryDB for Redis is a **Redis-compatible, durable, in-memory database service** designed to be used as a **primary database** rather than a cache layer.
<br>Unlike ElastiCache for Redis — which sits in front of a database and tolerates data loss on cache eviction — MemoryDB stores data in a **Multi-AZ transactional log**, guaranteeing durability even through node failures.

### Key Properties

| **Property** | **Detail** |
|-------------|-----------|
| **Compatibility** | Full Redis API and data structures — no application code changes required ‡ |
| **Durability** | Data persisted to a **Multi-AZ transactional log** — survives node failures ‡ |
| **Read latency** | Microsecond reads ‡ |
| **Write latency** | Single-digit millisecond writes ‡ |
| **Deployment** | Multi-AZ with automatic failover |
| **Scaling** | Scales from GBs to hundreds of TBs |

### MemoryDB vs. ElastiCache for Redis

| **Dimension** | **MemoryDB for Redis** | **ElastiCache for Redis** |
|--------------|----------------------|--------------------------|
| **Primary role** | Primary durable database | Cache / session store in front of a database |
| **Durability** | Multi-AZ transactional log — no data loss | Best-effort — cache miss causes DB fallback |
| **Data loss on failure** | None | Possible — eviction and node failure can cause loss |
| **Use case** | Microservices data store, leaderboards, gaming, real-time apps needing Redis + durability | Read offload, session caching, rate limiting |
| **Cost** | Higher ¤ | Lower ¤ |

> 💡 **Exam Tip:** `"Need Redis-compatible database with full durability as the primary data store"` → **Amazon MemoryDB for Redis**.
> <br>`"Cache to offload relational DB reads"` → **ElastiCache for Redis** — do not confuse the two.
> <br>**The key distinction:** MemoryDB = Redis as a database (durable). ElastiCache = Redis as a cache (fast, tolerable loss).

---

# NoSQL Databases
---

## Amazon DynamoDB

Amazon DynamoDB is a **fully managed, serverless NoSQL database** offering single-digit millisecond performance at any scale.

### Key Properties
  - **Serverless** — no instances to provision or manage; AWS handles all infrastructure
  - Stores **three geographically distributed replicas** of each table across 3 AZs §
  - Data stored on **SSD storage** ‡
  - **Push-button scaling** — scale read/write throughput without downtime
  - **Multi-AZ by default** — 99.99% SLA; **99.999%** with Global Tables

### DynamoDB Data Model

  - **Table** — collection of items (like a table in RDS)
  - **Item** — a single record (like a row); **max size: 400 KB** †
  - **Attribute** — key-value pair describing an item (like a column); schema is flexible — items in the same table can have different attributes
  - Can store pointers to S3 objects for items > 400 KB

### Primary Keys

| **Type** | **Composition** | **Use Case** |
|----------|----------------|-------------|
| **Partition key (simple)** | Single attribute hashed to determine storage partition | When each item has a naturally unique identifier |
| **Composite key (partition + sort)** | Partition key groups items; sort key orders within the group | When multiple items share a partition key (e.g., user ID + timestamp) |

  - Best practice: choose a **high-cardinality partition key** to distribute data evenly across partitions
  - Hot key / hot partition problem: excessive access to one partition key → throttling

### Secondary Indexes

| **Index Type** | **Partition Key** | **Sort Key** | **Consistency** | **When Created** |
|----------------|-------------------|--------------|-----------------|-----------------|
| **Global Secondary Index (GSI)** | Different from table's | Optional, can differ | Eventually consistent only | Any time |
| **Local Secondary Index (LSI)** | Same as table's | Different from table's | Eventually or strongly consistent | Table creation only |

---

## DynamoDB Capacity Modes

| **Mode** | **Behavior** | **Cost Model** | **Use Case** |
|----------|-------------|----------------|-------------|
| **Provisioned** | You specify RCUs and WCUs; auto-scaling available | Pay for provisioned capacity ¤ | Predictable, steady workloads |
| **On-Demand** | Scales automatically; no capacity planning | Pay per request ¤ | Unpredictable, spiky, new workloads |

  - **RCU (Read Capacity Unit)**: 1 strongly consistent read/sec or 2 eventually consistent reads/sec for items up to 4 KB
  - **WCU (Write Capacity Unit)**: 1 write/sec for items up to 1 KB
  - Throttling at 3,000 RCU or 1,000 WCU for a single partition key value — use high-cardinality keys

---

## DynamoDB Consistency Models

  - **Eventually consistent reads** — default §; may return stale data; uses less RCU capacity
  - **Strongly consistent reads** — always returns most recent data; uses more RCU; not supported on GSIs; may have higher latency; unavailable during network outages (returns HTTP 500)

---

## DynamoDB TTL

  - **Time to Live (TTL)** — specify a timestamp attribute per item; items are automatically deleted when the timestamp expires
  - **No extra cost** — does not consume WCU/RCU capacity
  - Useful for: session expiry, log cleanup, temporary data, compliance-based retention policies

---

## DynamoDB Streams

  - Captures **time-ordered, item-level changes** (inserts, updates, deletes) in a DynamoDB table
  - Records retained for **24 hours** †
  - **View types** configurable per stream:

| **View** | **Content** |
|----------|------------|
| `KEYS_ONLY` | Only primary key attributes |
| `NEW_IMAGE` | Entire item after modification |
| `OLD_IMAGE` | Entire item before modification |
| `NEW_AND_OLD_IMAGES` | Full before and after snapshot |

  - Primary use: trigger **Lambda functions** for event-driven architectures (e.g., update search indexes, send notifications, cross-region replication before Global Tables)

---

## DynamoDB Accelerator (DAX)

**DAX** is a **fully managed, in-memory cache for DynamoDB** that improves read performance from milliseconds to **microseconds**.

  - **Read-through and write-through** cache — used for both READ and WRITE performance
  - **No application code changes required** — uses the DAX client SDK, which is a drop-in replacement for the DynamoDB SDK
  - Requires an IAM role and a DAX cluster deployment

### DAX vs. ElastiCache

| **Feature** | **DAX** | **ElastiCache** |
|-------------|---------|-----------------|
| **Integration** | DynamoDB-specific | General-purpose — any database or app |
| **Application changes** | None (DAX SDK is a drop-in) | Required (cache logic in application) |
| **Management overhead** | Lower | Higher (cache invalidation, consistency) |
| **Use case** | DynamoDB read acceleration | RDS, Aurora, custom app caching |

---

## DynamoDB Global Tables

  - **Multi-region, multi-active replication** — each region's table is an independent read/write replica
  - **Asynchronous replication** between regions
  - **99.999% availability and 99.999% durability** †
  - Use application-level logic (e.g., Route 53 health checks + failover routing) to route to healthy regions
  - All replicas support read **and** write operations

> 💡 **Exam Tips:**
> <br>`"Single-digit millisecond NoSQL at any scale"` → **DynamoDB**
> <br>`"DynamoDB microsecond reads, no code changes"` → **DAX**
> <br>`"DynamoDB event-driven processing on item changes"` → **DynamoDB Streams + Lambda**
> <br>`"Multi-region, multi-active DynamoDB"` → **DynamoDB Global Tables**
> <br>`"Session state storage for serverless apps"` → **DynamoDB** (or ElastiCache)

---

# Data Warehousing
---

## Data Warehouse vs. Data Lake

| **Characteristic** | **Data Warehouse** | **Data Lake** |
|--------------------|--------------------|---------------|
| **Data type** | Structured, relational | Unstructured, semi-structured, or structured |
| **Schema** | Schema-on-write (defined before ingestion) | Schema-on-read (applied at query time) |
| **Cost / performance** | Optimized for fast query performance (higher cost) | Optimized for low-cost storage (lower cost) |
| **Data quality** | Curated, cleaned — central source of truth | Raw, unprocessed — may need cleaning |
| **Primary users** | Business analysts | Data scientists, developers |
| **Analytics type** | SQL, BI tools, batch reporting | ML, big data, predictive analytics, data discovery |
| **AWS examples** | Amazon Redshift | Amazon S3 + Athena, AWS Lake Formation |

---

## Amazon Redshift

Amazon Redshift is a **fast, fully managed petabyte-scale data warehouse** for OLAP analytics.

### Key Properties
  - **OLAP** — not suited for OLTP (high-frequency small transactions)
  - Uses **columnar storage** — data stored by column rather than by row; ideal for analytics; fewer I/Os per query
  - **Massively Parallel Processing (MPP)** — queries distributed across all nodes in the cluster
  - **10× faster than traditional SQL databases** ‡; PostgreSQL-compatible (JDBC/ODBC)
  - Uses **EC2 instances for compute** and **EBS for storage**
  - **Single AZ** only — but you can restore snapshots to another AZ ◊
  - Always maintains **3 copies of data**: original, replica on compute nodes, backup on S3
  - **Continuous/incremental backups** to S3; streaming restore; backups across regions
  - Cannot ingest large amounts of data in **real time** — use Kinesis for real-time ingestion

### Redshift Spectrum
  - Query data **directly in S3** (data lake) without loading it into Redshift
  - Extends Redshift SQL queries to S3 objects (Parquet, ORC, CSV, JSON)
  - Works with **live data from RDS or DynamoDB** via external tables

> 💡 **Exam Tips:**
> <br>`"Data warehouse, complex SQL analytics on large datasets"` → **Amazon Redshift**
> <br>`"Query S3 data lake directly using Redshift SQL"` → **Redshift Spectrum**
> <br>`"Redshift + real-time data"` → not a match — Redshift is not real-time; use Kinesis for ingestion then load into Redshift via Firehose

---

# Streaming & Analytics
---

## Streaming & Analytics — Service Overview

| **Service** | **Purpose** | **Key Characteristic** |
|-------------|------------|----------------------|
| **Kinesis Data Streams** | Real-time streaming, custom consumer processing | Durable, ordered, replayable; you manage consumers |
| **Kinesis Data Firehose** | Fully managed stream delivery to destinations | Near real-time (~60s); no consumer code; auto-scaling |
| **Kinesis Data Analytics** | Real-time analytics on streams using SQL or Flink | Queries Kinesis Streams or Firehose as input |
| **Amazon EMR** | Big data processing (Hadoop, Spark, Presto) | EC2-based clusters; access to OS; petabyte-scale ETL |
| **Amazon Athena** | Serverless SQL queries on S3 | No infra; pay per query; uses Glue Data Catalog |
| **AWS Glue** | Managed ETL, data catalog | Serverless; discovers schema; generates ETL code |
| **Amazon OpenSearch** | Full-text search, log analytics | Real-time search and visualization (Kibana/Dashboards) |
| **Amazon QuickSight** | BI dashboards and visualization | Serverless; SPICE engine; pay-per-session |

---

## Amazon Kinesis

Amazon Kinesis is a family of services for **real-time data streaming and analytics**.

### Kinesis Data Streams

**Kinesis Data Streams** enables real-time processing of large-scale streaming data by custom consumers.

| **Property** | **Value** |
|--------------|-----------|
| **Throughput unit** | Shard: **1 MB/s write, 2 MB/s read** ‡ |
| **Write rate per shard** | 1,000 PUT records/second ‡ |
| **Record size** | Up to **1 MB** per record † |
| **Default retention** | **24 hours** §; extendable up to **365 days** † |
| **Default shard limit** | 500 shards per account † (can be increased) |
| **Replication** | Synchronously replicated across **3 AZs** |
| **Ordering** | Guaranteed **within a shard** — not across shards |
| **Scaling** | Manual: shard split (increase) or shard merge (decrease) |

  - **Partition key** in `PutRecord` determines which shard receives the record — use high-cardinality keys for even distribution
  - **Multiple consumers** can read the same stream concurrently — reads are non-destructive
  - Data can be **replayed** — consumers can re-read past records within the retention window
  - Stores data for consumer processing; **not a delivery service** — consumers must read actively

### Kinesis Client Library (KCL)
  - Manages shard enumeration, checkpointing, load balancing, and error handling
  - **One shard → one KCL record processor** (one worker at a time per shard)
  - One worker **can** process multiple shards; one shard **cannot** be processed by multiple workers simultaneously
  - Checkpointing ensures **at-least-once** processing on worker failure

### Kinesis Data Firehose

**Kinesis Data Firehose** is a **fully managed delivery service** that captures, optionally transforms, and loads streaming data into destinations.

  - **No consumer code required** — Firehose manages delivery automatically
  - **Near real-time** (~60 seconds latency) ‡ — not real-time like Data Streams
  - Auto-scales to match incoming data volume
  - Optional **Lambda transformation** before delivery
  - Destinations: **S3, Redshift, OpenSearch, Splunk, HTTP endpoints**
  - Can use **Kinesis Data Streams as a source**

### Kinesis Data Analytics

  - Real-time analytics on streaming data using **SQL or Apache Flink**
  - Input sources: Kinesis Data Streams or Kinesis Data Firehose
  - Output targets: Kinesis Data Streams, Kinesis Data Firehose, Lambda, custom apps
  - Use cases: filtering, aggregation, transformation of streaming data

### Kinesis vs. Firehose

| **Aspect** | **Kinesis Data Streams** | **Kinesis Data Firehose** |
|------------|--------------------------|--------------------------|
| **Management** | You build and manage consumers | Fully managed — no consumer code |
| **Latency** | Real-time (milliseconds) | Near real-time (~60 seconds) |
| **Data retention** | 24 hours – 365 days (replay possible) | Up to 24 hours in buffer only |
| **Consumers** | Multiple custom consumers (KCL, Lambda, EC2) | Automated delivery to destinations |
| **Use case** | Complex custom processing, replay, ordering | Simple load into S3/Redshift/OpenSearch |

> 💡 **Exam Tips:**
> <br>`"Real-time streaming, multiple consumers, replay"` → **Kinesis Data Streams**
> <br>`"Load streaming data into S3/Redshift, fully managed"` → **Kinesis Data Firehose**
> <br>`"Real-time SQL analytics on a stream"` → **Kinesis Data Analytics**

---

## Amazon Elastic MapReduce (EMR)

Amazon EMR is a **fully managed cluster platform** for running big data frameworks at scale.

  - Simplifies running: **Apache Hadoop, Apache Spark, HBase, Presto, Flink**
  - Processes data for analytics, ML, BI, and ETL workloads
  - Runs in **one Availability Zone** within a VPC ◊
  - Uses **EC2 instances** for cluster nodes; also supports **EKS** and **AWS Outposts**
  - **You have SSH access** to the underlying EC2 instances (unlike RDS) 🛠️
  - Most common use cases: log analysis, financial analysis, ETL, Spark ML
  - Run at **petabyte-scale** at less than half the cost of on-premises Hadoop ‡

> 💡 **Exam Tip:** `"Run Hadoop/Spark big data workloads, managed cluster"` → **Amazon EMR**
<br>EMR is the answer when the question mentions Hadoop, Spark, Presto, or HBase as the processing framework.

---

## Amazon Athena

Amazon Athena is a **serverless, interactive query service** for analyzing data in S3 using standard SQL.

  - **No infrastructure to manage** — AWS handles all compute
  - **Pay per query** — charged per TB of data scanned ¤; use columnar formats to reduce cost
  - Powered by **Presto** — open-source distributed SQL query engine
  - Natively integrated with **AWS Glue Data Catalog** for schema management
  - Supports: CSV, JSON, ORC, Apache Parquet, Avro
  - **Federated queries** — query data in DynamoDB, Redshift, RDS, and other sources using Lambda connectors
  - Queries run in parallel automatically — most results in seconds even on large datasets

### Optimizing Athena Performance
  - **Partition data** in S3 by common query filters (e.g., date, region) — reduces data scanned
  - **Use columnar formats** — Parquet and ORC are highly recommended; far fewer bytes scanned
  - **Compress data** — reduces storage and scan costs
  - **Optimize file sizes** — 100 MB – 1 GB per file for best performance
  - **Avoid `SELECT *`** — select only needed columns
  - **Bucket data** within partitions for further optimization

> 💡 **Exam Tip:** `"Serverless SQL queries on S3 data lake, no ETL required"` → **Amazon Athena**
<br>If the question mentions querying S3 directly with SQL, Athena is almost always the answer.

---

## AWS Glue

AWS Glue is a **fully managed, serverless ETL service** that discovers, catalogues, cleans, and moves data.

  - **Glue Data Catalog** — central metadata repository; stores schemas, table definitions, partition information; shared across Athena, EMR, Redshift Spectrum
  - **Crawlers** — automatically discover data in S3, RDS, DynamoDB, Redshift and populate the Data Catalog with schemas and partition info; can run on schedule, on-demand, or event-triggered
  - **ETL Jobs** — automatically generates Scala or Python code for Apache Spark; jobs transform and move data between sources and targets; scheduled or event-triggered
  - **Alternative to Apache Hive on EMR** — Glue is serverless (no cluster to manage); Hive on EMR requires managing a cluster

> 💡 **Exam Tip:** `"Discover and catalog data schemas in S3, prepare data for Athena/Redshift"` → **AWS Glue**
<br>Glue is the data preparation and cataloging layer; Athena is the query layer; they are commonly used together.

---

## Amazon OpenSearch Service

**Amazon OpenSearch Service** (successor to Amazon Elasticsearch Service) is a **fully managed search and analytics engine** based on OpenSearch (open-source fork of Elasticsearch).

### Key Properties
  - Optimized for **real-time search, full-text search, log analytics, and observability** — not transactional workloads
  - Create an **OpenSearch Domain** = managed cluster (nodes, storage, security, access endpoint)
  - Visualization via **OpenSearch Dashboards** (successor to Kibana)
  - Supports up to **3 AZs** for high availability — recommend **3 dedicated master nodes** and nodes in multiples of 3

### Storage Tiers
  - **Hot** — actively queried data (fastest, most expensive)
  - **UltraWarm** — less frequently accessed (lower cost)
  - **Cold** — rarely accessed (lowest cost)

### Data Ingestion Sources
  - Kinesis Data Firehose, Logstash, OpenSearch API, custom services

### Access Control
  - Resource-based policies (domain access policy), identity-based IAM policies, IP-based policies
  - **IP-based policies not supported for VPC domains** — use security groups instead
  - **Fine-Grained Access Control (FGAC)** — RBAC at index, document, and field level
  - Authentication: SAML federation (on-premises AD), Amazon Cognito

### Networking
  - **VPC deployment recommended** — private access via security groups; cannot switch between VPC and public endpoint after creation
  - Cannot deploy in VPCs with **dedicated tenancy**

### ELK Stack Context
  - **ELK = Elasticsearch + Logstash + Kibana** — classic log analytics architecture
  - On AWS: Kinesis Firehose / Logstash → OpenSearch → OpenSearch Dashboards
  - Use cases: application log analysis, infrastructure monitoring, security analytics (SIEM)

---

# Additional Database Services
---

## Additional Database Services — Overview

| **Service** | **Model** | **Compatibility** | **Key Differentiator** |
|-------------|-----------|------------------|----------------------|
| **Amazon DocumentDB** | Document (JSON) | MongoDB API | Managed MongoDB-compatible <br> Up to 64 TB auto-scaling<br> 15 replicas across 3 AZs |
| **Amazon Keyspaces** | Wide-column | Apache Cassandra (CQL) | Managed Cassandra<br> Serverless<br> Thousands of requests/sec at single-digit ms latency |
| **Amazon Neptune** | Graph | Gremlin, openCypher, SPARQL | Managed graph DB<br> Up to 15 replicas<br> 99.99%+ availability<br> Highly connected data |
| **Amazon QLDB** | Ledger | PartiQL (SQL-like) | Immutable, cryptographically verifiable journal<br> SHA-256 hash chain<br> Append-only |
| **Amazon Timestream** | Time series | SQL-like | Serverless<br> IoT/metrics/telemetry<br> Faster and cheaper than RDS for time series |

---

## Amazon DocumentDB

  - Fully managed **document database** compatible with MongoDB workloads and drivers
  - Stores data as JSON-like documents with **flexible schemas**
  - Distributed, fault-tolerant storage; auto-scales up to **64 TB** per cluster †
  - Supports **millions of requests per second** with low latency
  - Up to **15 replicas** across **3 AZs** for high availability
  - Migrate MongoDB workloads using **AWS Database Migration Service (DMS)**

---

## Amazon Keyspaces (for Apache Cassandra)

  - Fully managed, **serverless** NoSQL service compatible with **Apache Cassandra** APIs and CQL
  - **Auto-scales** storage and throughput; **virtually unlimited** storage
  - Single-digit millisecond latency; **99.99% SLA** †
  - Replicates data across **multiple AZs** for high availability
  - Migrate Cassandra workloads using **AWS DMS**

---

## Amazon Neptune

  - Fully managed **graph database** — optimized for highly connected data and traversal queries
  - Supported graph models: **Gremlin** (property graph), **openCypher** (property graph), **SPARQL** (RDF)
  - Up to **15 replicas** †; fault-tolerant self-healing storage replicated across multiple AZs
  - DB volumes grow in **10 GB increments** up to **64 TB** †
  - **> 99.99% availability** †
  - Use cases: identity graphs, fraud detection, knowledge graphs, recommendation engines, social networks

---

## Amazon QLDB (Quantum Ledger Database)

  - Fully managed **ledger database** — transparent, immutable, cryptographically verifiable transaction log
  - **Append-only journal** — data cannot be modified or deleted; complete history preserved
  - **SHA-256 cryptographic hashing** — each transaction generates a hash; hash chain enables verification of full history
  - Serverless, auto-scaling, highly available
  - Use cases: financial transactions, supply chain tracking, identity management, audit trails requiring tamper-proof history

---

## Amazon Timestream

  - Fully managed **time series database** — designed for IoT telemetry, application monitoring, operational analytics
  - Serverless, auto-scaling, highly durable
  - **Faster and more cost-effective than RDS** for time series workloads ‡
  - Supports millions of writes per second at single-digit millisecond latency ‡
  - Built-in time series functions: smoothing, interpolation, forecasting
  - Automatic data retention policies — move data between tiers as it ages

---

# Other Analytics & Data Services
---

## Other Analytics Services — Overview

| **Service** | **Purpose** | **Key Characteristic** |
|-------------|------------|----------------------|
| **Amazon QuickSight** | BI dashboards and visualization | Serverless; SPICE in-memory engine; pay-per-session |
| **AWS Batch** | Batch job processing | Managed; EC2 or Fargate; hundreds to thousands of jobs |
| **AWS Lake Formation** | Build and manage data lakes | Simplifies S3 data lake setup; fine-grained security |
| **Amazon MSK** | Managed Apache Kafka | Migrate Kafka workloads to AWS without code changes |
| **AWS Data Pipeline** | Orchestrate ETL data workflows | Scheduled pipeline between AWS services and on-premises |
| **AWS Data Exchange** | Third-party data marketplace | Subscribe to and consume external datasets |

---

## Amazon QuickSight

  - Fully managed **business intelligence (BI) and visualization service**
  - **Serverless**, highly scalable, **pay-per-session** pricing model ¤
  - **SPICE (Super-fast, Parallel, In-memory Calculation Engine)** — accelerates queries; reduces load on source databases
  - Connects to: Athena, Redshift, S3, RDS/Aurora, on-premises databases
  - Features: interactive dashboards, ML insights (anomaly detection, forecasting), row-level security, scheduled refresh

> 💡 **Exam Tips:**
> <br>`"BI dashboards and visualization on top of Athena, Redshift, or S3 data lake"` → **Amazon QuickSight**
> <br>`"Accelerate QuickSight dashboard queries without hitting the database"` → **SPICE in-memory engine**
> <br>`"Business users need self-service dashboards on AWS analytics data"` → **QuickSight** (not Athena — Athena is SQL query tool, QuickSight is the dashboard layer)

---

## AWS Batch

  - Fully managed **batch processing service** — runs hundreds to thousands of batch jobs efficiently
  - A **job** = unit of work (shell script, executable, Docker container)
  - Jobs submitted to a **job queue** → scheduled onto a **compute environment** (EC2 or Fargate)
  - Batch manages compute provisioning, scaling, and teardown automatically
  - Flow: **Launch Batch Job → Job Definition → Job Queue → Compute Environment**

> 💡 **Exam Tip:** `"Run batch computing workloads at scale without managing compute infrastructure"` → **AWS Batch**.
> <br>`"Select compute for data processing"` → use **EMR** for Hadoop/Spark framework jobs; use **Batch** for arbitrary Docker-containerized batch jobs.
> <br>**Key distinction:** EMR = managed big data framework (Hadoop, Spark). Batch = managed job scheduler for any Docker workload.

---

## AWS Lake Formation

  - Fully managed service for **building and managing secure data lakes** on Amazon S3
  - Takes **days** vs. weeks/months for manual setup
  - Security at **column, row, and cell level** — fine-grained access control
  - Integrates with: Athena, Redshift, EMR, Apache Spark, QuickSight
  - **Builds on top of AWS Glue** — uses Glue crawlers, ETL, and Data Catalog
  - Tools provided: data ingestion, cataloging, access control, data transformation

> 💡 **Exam Tips:**
> <br>`"Build and secure a data lake on S3 with fine-grained access control"` → **AWS Lake Formation**
> <br>`"Apply column-level or row-level security to a data lake"` → **Lake Formation** (not S3 bucket policies — those only work at the object level)
> <br>`"Centralize data access governance across Athena, Redshift Spectrum, and EMR"` → **Lake Formation** acts as the single permissions layer across these services

---

## Amazon Managed Streaming for Apache Kafka (MSK)

  - Fully managed service for running **Apache Kafka** workloads on AWS
  - Provisions, manages, and scales Kafka clusters and Apache ZooKeeper nodes
  - **Use when migrating existing Kafka workloads** to AWS without code changes
  - Integrates with: Kinesis Data Firehose, Lambda, Redshift, S3
  - Security: VPC network isolation, IAM, encryption at rest and in transit (TLS), certificate-based auth, SASL/SCRAM via Secrets Manager

> 💡 **Exam Tip:** `"Migrate Apache Kafka workloads to AWS without code changes"` → **Amazon MSK**
<br>For new streaming workloads on AWS, consider Kinesis. MSK is the migration path for existing Kafka architectures.

---

## AWS Data Pipeline

  - Fully managed **ETL orchestration service** for processing and moving data between AWS services and on-premises sources
  - Define **data-driven, scheduled workflows** (pipelines) that can be monitored
  - Output targets: S3, RDS, DynamoDB, EMR

---

## AWS Data Exchange

  - Fully managed **data marketplace** for discovering and subscribing to third-party datasets
  - Supports: data files (S3: CSV, JSON, Parquet), data tables (Redshift), data APIs
  - Automatically delivers new/updated datasets to S3
  - Integrates with: S3, Redshift, analytics and ML workflows
  - Security: IAM, encryption at rest and in transit

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Managed relational DB, structured OLTP data | **Amazon RDS** |
| High-performance MySQL/PostgreSQL, cloud-optimized | **Amazon Aurora** |
| Automatic failover with no data loss for RDS | **RDS Multi-AZ** |
| Read scaling for RDS — offload SELECT queries | **RDS Read Replicas** |
| Lambda exhausting database connections | **RDS Proxy** |
| Encrypt an existing unencrypted RDS instance | Snapshot → copy with encryption → restore to new instance |
| Global low-latency reads, DR in < 1 minute | **Aurora Global Database** |
| Unpredictable/intermittent DB workload | **Aurora Serverless** |
| Continuous writes across AZs, no failover delay | **Aurora Multi-Master** |
| DynamoDB microsecond read latency, no code changes | **DAX** |
| DynamoDB event-driven processing on item changes | **DynamoDB Streams + Lambda** |
| Multi-region, multi-active DynamoDB | **DynamoDB Global Tables** |
| Offload read traffic from database, session state | **ElastiCache** |
| HA caching with failover, persistence | **ElastiCache Redis** |
| Simple caching, multi-threaded, max throughput | **ElastiCache Memcached** |
| Data warehouse, complex SQL analytics | **Amazon Redshift** |
| Query S3 data lake with SQL (Redshift cluster) | **Redshift Spectrum** |
| Real-time streaming, multiple consumers, replay | **Kinesis Data Streams** |
| Load streaming data to S3/Redshift, fully managed | **Kinesis Data Firehose** |
| Real-time SQL analytics on a stream | **Kinesis Data Analytics** |
| Run Hadoop/Spark big data processing | **Amazon EMR** |
| Serverless SQL queries directly on S3 | **Amazon Athena** |
| Discover schemas, build ETL jobs for data lake | **AWS Glue** |
| Full-text search, log analytics, ELK-style workloads | **Amazon OpenSearch Service** |
| MongoDB-compatible managed document DB | **Amazon DocumentDB** |
| Cassandra-compatible managed wide-column DB | **Amazon Keyspaces** |
| Highly connected data, graph traversal | **Amazon Neptune** |
| Immutable, cryptographically verifiable transaction log | **Amazon QLDB** |
| IoT telemetry, time series metrics | **Amazon Timestream** |
| Migrate Kafka to AWS without code changes | **Amazon MSK** |
| BI dashboards on AWS analytics data | **Amazon QuickSight** |
| Batch job processing at scale | **AWS Batch** |
| Build secure S3 data lake with fine-grained access | **AWS Lake Formation** |

---

## HOL Notes — DynamoDB CLI Operations

> 🛠️ **Implementation Notes:**
> <br>`aws dynamodb batch-write-item --request-items file://items.json` — batch write multiple items
> <br>`aws dynamodb scan --table-name <table>` — full table scan (expensive on large tables; prefer Query)
> <br>`aws dynamodb query --table-name <table> --key-condition-expression "<expr>"` — efficient primary key query
> <br>`aws dynamodb update-item --table-name <table> --key <key> --update-expression "<expr>"` — update item
> <br>`aws dynamodb delete-item --table-name <table> --key <key>` — delete by primary key

---

## Login References

  - **IAM User Login**
    https://ijpc-training.signin.aws.amazon.com/console
    Username: `ijpc-training`

  - **Root Account Login**
    https://console.aws.amazon.com/
    Use the **root email option**

---

# Module Summary
---

## Key Topics
  - Database type fundamentals: relational, key-value, document, graph, wide-column, in-memory, ledger, time series
  - OLTP vs. OLAP (operational vs. analytical)
  - Data warehouse vs. data lake
  - AWS database selection guide
  - RDS: engines, Multi-AZ (HA, not read scaling), read replicas (read scaling, async), backups, encryption rules, security, RDS Proxy
  - Aurora: 6 copies across 3 AZs, Aurora Replicas vs. MySQL Replicas, Global Database, Serverless, Multi-Master
  - ElastiCache: Redis vs. Memcached, cluster modes, use cases
  - MemoryDB for Redis ※ — Redis-compatible durable primary database; Multi-AZ transactional log; microsecond reads; contrast: MemoryDB = durable DB, ElastiCache = cache layer
  - DynamoDB: data model, partition/composite keys, GSI/LSI, capacity modes (provisioned/on-demand), consistency models, TTL, Streams, DAX, Global Tables
  - Redshift: OLAP, columnar storage, MPP, Spectrum, single-AZ with snapshot restore
  - Kinesis: Data Streams (real-time, durable, replayable), Firehose (delivery, near-real-time), Data Analytics (SQL/Flink)
  - EMR: Hadoop/Spark clusters on EC2, SSH access, single AZ
  - Athena: serverless SQL on S3, Presto, pay per query, Glue integration
  - AWS Glue: ETL, Data Catalog, crawlers, Spark code generation
  - OpenSearch: search/analytics, Dashboards (Kibana), ELK stack, FGAC, VPC vs. public
  - Additional services: DocumentDB, Keyspaces, Neptune, QLDB, Timestream
  - Other analytics: QuickSight, AWS Batch, Lake Formation, MSK, Data Pipeline, Data Exchange

---

## Critical Acronyms
  - **RDS** — Relational Database Service
  - **OLTP** — Online Transaction Processing
  - **OLAP** — Online Analytical Processing
  - **Multi-AZ** — Multi-Availability Zone
  - **TDE** — Transparent Data Encryption
  - **DMS** — Database Migration Service
  - **DAX** — DynamoDB Accelerator
  - **GSI** — Global Secondary Index
  - **LSI** — Local Secondary Index
  - **RCU** — Read Capacity Unit
  - **WCU** — Write Capacity Unit
  - **ACU** — Aurora Capacity Unit
  - **MPP** — Massively Parallel Processing
  - **KCL** — Kinesis Client Library
  - **KPL** — Kinesis Producer Library
  - **ETL** — Extract, Transform, Load
  - **ELK** — Elasticsearch, Logstash, Kibana (now OpenSearch, Logstash, Dashboards)
  - **FGAC** — Fine-Grained Access Control
  - **SIEM** — Security Information and Event Management
  - **SPICE** — Super-fast Parallel In-memory Calculation Engine (QuickSight)
  - **QLDB** — Quantum Ledger Database
  - **MSK** — Managed Streaming for Apache Kafka
  - **CQL** — Cassandra Query Language
  - **RDF** — Resource Description Framework (Neptune graph model)
  - **BYOL** — Bring Your Own License
  - **GNU GPL** — GNU General Public License
  - **JDBC** — Java Database Connectivity
  - **ODBC** — Open Database Connectivity
  - **VPC** — Virtual Private Cloud
  - **KMS** — Key Management Service
  - **SSD** — Solid-State Drive
  - **MPP** — Massively Parallel Processing
  - **RBAC** — Role-Based Access Control

---

## Key Comparisons
  - Relational vs. Non-Relational Databases
  - OLTP vs. OLAP
  - Data Warehouse vs. Data Lake
  - AWS Database Selection Guide
  - RDS Multi-AZ vs. Read Replicas
  - Aurora Replicas vs. MySQL Read Replicas
  - ElastiCache Memcached vs. Redis vs. Redis Cluster Mode
  - DynamoDB GSI vs. LSI
  - DynamoDB Provisioned vs. On-Demand Capacity
  - DynamoDB Eventually Consistent vs. Strongly Consistent Reads
  - DAX vs. ElastiCache
  - Kinesis Data Streams vs. Kinesis Data Firehose
  - Streaming & Analytics Service Overview

---

## Top Exam Triggers
  - `OLTP managed relational database` → **Amazon RDS**
  - `High-performance MySQL/PostgreSQL, cloud-optimized` → **Amazon Aurora**
  - `Automatic failover, no data loss, synchronous` → **RDS/Aurora Multi-AZ**
  - `Read scaling, offload SELECT queries` → **RDS Read Replicas** (async)
  - `Lambda + RDS connection exhaustion` → **RDS Proxy**
  - `Global DB, < 1s replication, < 1 min DR promotion` → **Aurora Global Database**
  - `Intermittent/unpredictable DB workload, pay-per-use` → **Aurora Serverless**
  - `Multi-writer Aurora, continuous write availability` → **Aurora Multi-Master**
  - `Encrypt existing unencrypted RDS instance` → snapshot → copy with encryption → restore new instance
  - `Serverless NoSQL, single-digit ms, massive scale` → **DynamoDB**
  - `DynamoDB microsecond reads, no code changes` → **DAX**
  - `DynamoDB event-driven processing` → **DynamoDB Streams + Lambda**
  - `Multi-region, multi-active DynamoDB` → **DynamoDB Global Tables**
  - `In-memory caching, offload DB reads` → **ElastiCache**
  - `Cache with HA, persistence, encryption` → **ElastiCache Redis**
  - `Simple cache, no persistence needed` → **ElastiCache Memcached**
  - `Redis-compatible primary database with full durability` → **Amazon MemoryDB for Redis**
  - `Data warehouse, complex SQL on petabytes` → **Amazon Redshift**
  - `Query S3 data lake with Redshift SQL` → **Redshift Spectrum**
  - `Real-time streaming, multiple consumers, replay` → **Kinesis Data Streams**
  - `Load streaming data to S3/Redshift/OpenSearch` → **Kinesis Data Firehose**
  - `Serverless SQL queries on S3, no ETL` → **Amazon Athena**
  - `Schema discovery and ETL for data lake` → **AWS Glue**
  - `Hadoop/Spark managed clusters` → **Amazon EMR**
  - `Log analytics, full-text search, ELK` → **Amazon OpenSearch Service**
  - `Graph database, highly connected data` → **Amazon Neptune**
  - `MongoDB-compatible managed DB` → **Amazon DocumentDB**
  - `Cassandra-compatible managed DB` → **Amazon Keyspaces**
  - `Immutable, verifiable ledger/audit trail` → **Amazon QLDB**
  - `IoT telemetry, time series metrics` → **Amazon Timestream**
  - `Migrate Kafka workloads to AWS` → **Amazon MSK**
  - `BI dashboards on analytics data` → **Amazon QuickSight**

---

## Quick References

### [Database and Analytics Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619340#overview)

### [Database and Analytics Architecture Patterns Private Link](https://drive.google.com/drive/folders/1NZnyqF50lkyf2CHqk703dftlyXVcr-MA?usp=drive_link)

### [AWS Database and Analytics Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346114#overview)

### [Amazon RDS Cheat Sheet](https://digitalcloud.training/amazon-rds/)

### [Amazon Aurora Cheat Sheet](https://digitalcloud.training/amazon-aurora/)

### [Amazon DynamoDB Cheat Sheet](https://digitalcloud.training/amazon-dynamodb/)

### [Amazon ElastiCache Cheat Sheet](https://digitalcloud.training/amazon-elasticache/)

### [Amazon Redshift Cheat Sheet](https://digitalcloud.training/amazon-redshift/)

### [Amazon EMR Cheat Sheet](https://digitalcloud.training/amazon-emr/)

### [Amazon Kinesis Cheat Sheet](https://digitalcloud.training/amazon-kinesis/)

### [Amazon Athena Cheat Sheet](https://digitalcloud.training/amazon-athena/)

### [Amazon Glue Cheat Sheet](https://digitalcloud.training/aws-glue/)

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
