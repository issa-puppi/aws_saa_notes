## Relational vs Non-Relational Databases

| **Feature**   | **Relational** | **Non-Relational** |
|---------------|----------------|--------------------|
| **Structure** | Tables, rows and columns | Key-value pairs, documents, graphs, or wide-column |
| **Schema** | **Rigid** | **Flexible** (NoSQL) |
| **Rules**  | Enforced **within database** | Typically **outside of database** <br>(within application code) |
| **Scalability** | Typically scales **vertically <br>(scale-up)** | Always scales **horizontally <br>(scale-out)** |
| **Querying**    | Supports **complex queries and joins** | **Unstructured or semi-structured** <br>Supports **any schema** |
| **Examples**    | Amazon RDS, Oracle, <br>MySQL, PostgreSQL , IBM DB2 | Amazon DynamoDB, MongoDB, <br>Redis, Cassandra, Neo4j |

### Key Differences
  - How data is **managed**
  - How data is **stored**

---

## Relational Databases

- SQL is used for defining the structure of the database and its elements
- SQL provides the tools for inserting, updating, deleting, and querying data within the database table
- Data is stored in tables with rows and columns
- Each table has a fixed schema that defines the structure of the data
  - **Examples:** Amazon RDS, MySQL, PostgreSQL, Oracle, SQL Server

---

## Non-Relational Databases

- Can be key-value, document, graph, or wide-column stores
- Do not require a fixed schema
- Allow for flexible data models 
- Can handle unstructured or semi-structured data

---

### Key-Value Stores
  - Store data as a collection of key-value pairs
  - `clientid: john123`
  - **Examples:** DynamoDB, Redis

---

### Graph Databases
  - Store data as nodes, edges, and properties
    - **Nodes** represent entities 
      - e.g., people, products
    - **Edges** represent relationships between nodes 
      - e.g., "friend of", "purchased"
    - **Properties** provide additional information about nodes and edges 
      - e.g., name, age, purchase date
  - **Examples:** Amazon Neptune, Neo4j

---

### Document Databases
  - Store data as documents (e.g., JSON, BSON)
  - Each document can have a different structure
  - **Examples:** MongoDB, CouchDB

---

### Wide-Column Stores
  - Store data in tables, rows, and dynamic columns
  - Each row can have a different set of columns
  - **Examples:** Apache Cassandra, HBase

---

## Opperational vs Analytical Databases

| **Feature**   | **Operational / Transactional** | **Analytical** |
|---------------|---------------------------------|----------------|
| **Workload Type** | Online Transaction Processing (**OLTP**) | Online Analytical Processing (**OLAP**) |
| **Purpose** | Manage **day-to-day operations** | Analyze **volume data for insights** |
| **Data source** | Primary application data | Derived from OLTP DBs |
| **Data structure** | Highly **normalized** | **Denormalized** / optimized for queries |
| **Workload** | **Simple** queries, **short** transactions | **Complex** queries, **long** transactions |
| **Latency** | **Low-latency** (real-time) | **High-latency** (batch/analytics) |
| **Relational <br> Examples** | Amazon RDS, Aurora, Oracle, <br>IBM DB2, MySQL, PostgreSQL | Amazon Redshift, Teradata, HP Vertica |
| **Non-Relational <br>Examples** | DynamoDB, MongoDB, <br>Cassandra, Neo4j, HBase | Amazon Athena, Amazon EMR, <br> Amazon S3, Amazon MapReduce |

### Key Differences
  - **Use cases**
  - How database is **optimized**

---

### Short Memory Note
  - **OLTP** is to run the business, **OLAP** is to analyze the business
  - **OLTP** is write-heavy, **OLAP** is read-heavy
  - Analytical databases tend to be data warehouses or data lakes

---

### Example Case

- An **operational database** recives data from applications 
- It then feeds data into **Amazon Redshift** for **analytics** and **reporting**

---

## AWS Databases

| **Data Store** | **Use Case** |
|----------------|--------------|
| **Database on EC2** | • Need **full control** over instance and database <br> • **Custom or unsupported** database in RDS |
| **Amazon RDS** | • Need **traditional managed relational database** <br> • e.g., Oracle, PostgreSQL, Microsoft SQL, MariaDB, MySQL <br> • Data is well-formed and **structured** |
| **Amazon Aurora** | • High performance, **managed relational database** <br> • Compatible with MySQL and PostgreSQL <br> • Auto-scaling, high availability, and durability |
| **Amazon DynamoDB** | • **Fully managed, serverless NoSQL** database <br> • Low-latency, high I/O needs, **massive scale** <br> • Dynamic scaling, flexible schema |
| **Amazon Redshift** | • **Data warehousing** <br> • Analytics on **large datasets** <br> • Optimized for **complex queries** |
| **Amazon Elasticache** | • **In-memory** database for **caching** and **real-time apps** <br> • Fast temporary data storage for small datasets |
| **Amazon Keyspace** | • **Managed Apache Cassandra** service <br> • **Wide-column NoSQL** database for large-scale applications |
| **Amazon Neptune** | • **Managed graph** database service <br> • Optimized for **highly connected data** and **graph queries** |

---

### Shorthand Flows for Easy Recall
  - `Full control` → Database on EC2
  - `Managed SQL` → Amazon RDS
  - `Cloud-optimized` or `High performance managed SQL` → Amazon Aurora
  - `Fully managed, serverless NoSQL` or `Massive scale` → Amazon DynamoDB
  - `Data warehousing` or `Large scale analytics` → Amazon Redshift
  - `In-memory caching` or `Ultra-low latency` → Amazon Elasticache
  - `Wide-column NoSQL` or `Cassandra` → Amazon Keyspace
  - `Graph database` or `Highly connected data` → Amazon Neptune

---

## Amazon RDS

- Managed relational database service
- Supports multiple database engines 
  - MySQL, PostgreSQL, Oracle, SQL Server, MariaDB
- Runs on EC2 instances managed by AWS
  - Just like EC2, uses EBS volumes for storage
  - Uses EBS snapshots for backups
- A DB instance can contain multiple user-created databases 
  - You must choose your DB type and version when creating an RDS instance
- RDS handles routine database tasks such as:
  - Backups
  - Patching
  - Scaling
  - Replication
  - High availability

---

## RDS Database Engines

| **Database Engine** | **Description** | **Use Cases** |
|---------------------|-----------------|---------------|
| **Amazon Aurora** | Cloud-optimized relational DB <br> MySQL/PostgreSQL compatible <br> High performance, auto-scaling storage | • High throughput apps<br> • High availability (Multi-AZ by design)<br> • When better performance than standard RDS is needed |
| **MySQL** | Popular open-source relational database | • Web applications<br> • CMS (WordPress, etc.)<br> • E-commerce |
| **PostgreSQL** | Advanced open-source relational DB <br> With complex queries and extensions | • Geospatial (PostGIS)<br> • Analytics workloads<br> • Complex queries |
| **Oracle** | Enterprise commercial DB <br> With advanced features and licensing options <br> ("BYOL" or included) | • Enterprise apps<br> • Legacy systems<br> • Mission-critical workloads |
| **Microsoft SQL Server** | Commercial DB with strong Microsoft ecosystem integration | • .NET applications<br> • Microsoft stack environments<br> • BI tools |
| **MariaDB** | MySQL-compatible open-source fork <br> With performance improvements <br> Remains free under **GNU GPL** | • MySQL replacement<br> • Cost-sensitive apps<br> • Web workloads |


* **GNU General Public License (GPL)** 
  - Is a widely used free software license that guarantees end users the freedom to run, study, share, and modify the software
  - Software licensed under the GPL can be freely used, modified, and distributed, but any derivative work must also be licensed under the GPL
  - This ensures that the software remains free and open for all users

---

## RDS Scaling Types

### Scaling Up (Vertical)
  - RDS instances scale up by **changing the instance type**
    - This increases **CPU, memory, and network capacity**
  - Database must shut down and restart to apply changes, causing downtime
  - Is required for better writing performance

---

### Scaling Out (Horizontal)
  - RDS instances scale out by **adding read replicas**
    - This increases **read capacity**
  - Read replicas can be promoted to standalone instances
  - Is required for better reading performance

---

### Multi-AZ Deployments
  - RDS instances can be deployed across multiple Availability Zones (AZs) for high availability and durability
  - In a Multi-AZ deployment, RDS automatically creates a **synchronous standby replica** in a different AZ
    - Can also handle **asynchronous read replicas** in the same or different AZs for read scaling
  - If the **primary instance** fails, RDS automatically fails over to the **standby replica** with minimal downtime

---

## RDS Backups and Recovery

- **Automated backups:** 
  - Automated backups are enabled by default
  - Allow point-in-time recovery within the **backup retention period** (0 to 35 days)

- **Manual snapshots:**
  - Backs up the entire DB instance, not just individual databases
  - Can be retained indefinitely until manually deleted (no retention period)

- **Single vs Multi-AZ Snapshots:**
  - For **Single-AZ** deployments, there is a **brief downtime** during snapshot creation
  - For **Multi-AZ** deployments, snapshots are taken from the standby replica, so there is **no downtime**
  - For **Multi-AZ SQL Server**, I/O activity is briefly suspended on primary instance, causing a **brief downtime** during snapshot creation
  - For **Multi-AZ MariaDB, MySQL, PostgreSQL and Oracle**, the snapshot is taken from the standby replica, so there is **no downtime**

---

## RDS Maintenance and Patching

- OS and DB patching can require taking the database offline
- These tasks take place during a **specified maintenance window**
  - By default, there is a configured weekly window 
  - You can modify the window to fit your schedule

---

## RDS Security

- We run RDS instances within a **VPC** for network isolation
- Each database has an **IP address** and **DNS name** for connectivity
  - A **public** IP allows access to the internet
  - A **private** IP allows access only within the VPC
- Each RDS instance has a **security group** to control in/outbound traffic
  - According to best pracices, RDS and App SG should be separate, and only allow necessary traffic between them

---

## Encryption
  - RDS supports encryption at rest using **AWS KMS** keys or **AES-256** encryption
    - AES-256 is very secure with minimal performance impact (hence, the default)
  - RDS supports encryption in transit using **SSL/TLS**
  - Encryption is enabled at the time of instance creation and cannot be disabled later
  - For Oracle and SQL Server, you can use **Transparent Data Encryption (TDE)** for encryption at rest
    - But this may have a performance impact
  
---

## RDS Security Can and Can'ts
  - You **can't** have:
    - An **encrypted** read replica of an **unencrypted** DB instance
    - An **unencrypted** read replica of an **encrypted** DB instance
  - Read replicas must have the same encryption settings as the source DB instance
    - The **same KMS key** is used if in the **same region** as the primary
    - A **different KMS key** is used if in a **different region** than the primary
  - You **can't** restore an **unencrypted** backup or snapshot to an **encrypted** DB instance
  - You **can't** restore an **encrypted** backup or snapshot to an **unencrypted** DB instance

---

## Can You Encrypt an Unencrypted RDS Instance?
  - **No**, you **cannot** encrypt an existing unencrypted RDS instance directly

  - But you can:
    1. Create a **snapshot** of the unencrypted RDS instance
    2. Copy the snapshot and **enable encryption** during the copy process
    3. Restore the encrypted snapshot to a new RDS instance with a **new endpoint**
  
  - This is **NOT** the same database
    - It **IS** a copy of the data within the original database
    - But it is a **new RDS instance** with a **new endpoint**
    - You have to update any apps or services to point to the **new endpoint**

---

## Amazon Aurora
  - Cloud-optimized relational database service
  - Compatible with MySQL and PostgreSQL
  - Up to 5x faster than standard MySQL and 3x faster than standard PostgreSQL
  - Features a distributed, fault-tolerant, self-healing storage system
    - Automatically scales storage up to 128 TB per instance as needed

---

### Amazon Aurora Fault Tolerance and Availability
  - Aurora automatically replicates data across multiple Availability Zones (AZs) 
    - Aurora replicas are in the same region as the primary instance
    - Is fault-tolerant across 3 AZs and 6 copies of data
      - Makes up a single logical volume for the database
  - Aurora automatically detects and recovers from failures
  - Up to 15 read replicas with sub-10ms latency for read scaling
  - Replicas are independent end points
    - Can be promoted to primary in case of failure or for read/write workloads
    - Can set priority for replicas to control failover order

---

## Amazon Aurora Key Features

| **Aurora Feature** | **Description** |
|--------------------|-----------------|
| **High Performance and Scalability** | Offers high performance, self-healing storage that can auto-scale up to 128 TB, offers point-in-time recovery, and supports continuous backup to Amazon S3 |
| **DB Compatibility** | Compatible with MySQL and PostgreSQL open-source databases |
| **Aurora Replicas** | In-region read scaling and failover target (up to 15 replicas with sub-10ms latency) |
| **Cross-Region/<br>MySQL Replicas** | Global read scaling and disaster recovery (up to 5 replicas with seconds-level latency) |
| **Global Database** | Cross-region cluster with read scaling (fast replication / low latency reads) <br> Can remove secondary and promote to primary |
| **Serverless** | On-demand, auto-scaling configuration for infrequent, intermittent, or unpredictable workloads |

---

## Amazon Aurora Deployment Options

- **Aurora Replicas** for read scaling and high availability within the same region
- **Cross-Region/MySQL Replicas** for global read scaling and disaster recovery
- **Aurora Global Database** for globally distributed applications with fast replication and low-latency reads across multiple regions
- **Aurora Serverless** for on-demand, auto-scaling configuration for infrequent, intermittent, or unpredictable workloads

---

## Aurora vs MySQL Replicas

| **Feature** | **Aurora Replicas** | **Cross-Region/MySQL Replicas** |
|-------------|---------------------|--------------------|
| **Number of Replicas** | Up to 15 | Up to 5 |
| **Replication Type** | Asynchronous (miliseconds) | Asynchronous (seconds) |
| **Performance Impact on Primary** | Low (replicas are independent endpoints) | Higher (replicas share resources with primary) |
| **Replica Location** | In-Region | In-Region or Cross-Region |
| **Act as Failover Target** | Yes (no data loss) | Yes (potentially minutes of data loss) |
| **Automatic Failover** | Yes (built-in, fast) | No (manual or Multi-AZ, potentially minutes of downtime) |
| **Replication Lag** | Minimal (milliseconds) | Can be significant (seconds or more) |
| **Support for user-defined replication delay** | No | Yes (can set replication delay) |
| **Support for different data or schema on replicas** | No (replicas are read-only copies of primary) | Yes (read-only replicas, but can be configured differently from primary) |

---

## Aurora Global Database

- For globally distributed applications with fast replication and low-latency reads across multiple regions
- Writes are performed in the primary region and replicated to secondary regions
- Secondary regions can be promoted to primary with full read/write capabilities in < 1 minute
- A secondary region that uses **Aurora storage layer**
- Apps can connect to the cluster **Reader Endpoint** for read operations and **Writer Endpoint** for write operations
- Secondary regions can be configured with **Write Forwarding** 
  - Allows writes to be forwarded to the primary region, enabling read/write capabilities in secondary regions without promotion
  - Useful for global applications that require low-latency writes in multiple regions without the need for full failover capabilities

---

## Aurora Serverless

- On-demand, auto-scaling configuration for infrequent, intermittent, or unpredictable workloads
  - Capcity automatically adjusts based on application needs
- Each **Aurora Capacity Unit (ACU)** provides a specific amount of processing and memory resources 
  - Connects to a **router fleet** that manages connections and routes them to the appropriate resources

- **Example use cases:**
  - Infrequently used applications
  - New applications with unknown workloads
  - Development and testing environments
  - Variable workloads with unpredictable traffic patterns
  - Multitenant applications with varying resource needs

---

## Amazon Aurora Multi-Master
  - Aurora configuration that allows **multiple instances to accept write operations**
  - Designed for **high availability and fault-tolerant write workloads**

---

### Key capabilities
  - **Multi-AZ write capability**
    - Multiple DB instances across AZs can handle writes simultaneously
  - **Strong consistency (read-after-write)**
    - Changes are immediately visible after commit
  - **High availability**
    - No failover needed for writes (no single writer bottleneck)
  - **Automatic conflict detection and resolution**
    - Handles concurrent writes across instances

---

### Compared to standard Aurora:
  - Standard Aurora:
    - Single writer + multiple read replicas
    - Replicas are read-only
  - Multi-Master:
    - Multiple writers
    - All nodes can read/write

---

### Use cases
  - Applications requiring **continuous write availability**
  - Systems that cannot tolerate failover delays
  - Distributed applications writing across AZs
  - High-throughput write workloads

---

### Limitations / considerations
  - More complex conflict handling for concurrent writes
  - Not as commonly used as single-writer Aurora
  - Region and engine support may be limited

---

### Key characteristic
  - Eliminates the **single-writer bottleneck** in traditional Aurora

---

## RDS Proxy
  - Fully managed database proxy for RDS and Aurora
  - Highly available across multiple AZs
  - Improves scalability, resilience, and security of database connections

---

### How it works:
  - Sits between your application and the database
  - Maintains a pool of reusable database connections (connection pooling)
  - Routes and manages connections efficiently

---

### Key Capabilities:
  - Reduces number of open connections to the database
  - Reduces overhead of opening/closing connections
  - Protects database from connection storms (e.g., Lambda scaling)
  - Improves application resilience during failover
  - Integrates with IAM authentication and AWS Secrets Manager

---

### Use Cases:
  - Serverless applications (e.g., AWS Lambda)
  - Applications with high or unpredictable connection counts
  - Workloads experiencing connection exhaustion
  - Improving failover handling for RDS/Aurora

---

### Notes / Limitations:
  - Does NOT cache query results (not a replacement for ElastiCache)
  - Adds a small amount of latency (extra network hop)
  - Does NOT replace read replicas or scaling strategies
  
---

## Amazon ElastiCache
  - Fully managed in-memory data store and cache service
    - **In-memory** = data is stored in RAM for ultra-low latency and high throughput
    - Implements **Redis** and **Memcached** engines
  - Is a **key-value** store 
  - Can be put in front of databases like RDS or DynamoDB 
    - To cache frequently accessed data and reduce latency
    - To offload read traffic from the database and improve performance
  - Run on EC2 instances managed by AWS
    - Must choose instance family/type when creating an ElastiCache cluster
    - ElastiCache handles routine tasks such as patching, scaling, and replication

---

## Memcached vs Redis

| **Feature** | **Memcached** | **Redis<br>(Cluster Mode Disabled)** | **Redis<br>(Cluster Mode Enabled)** |
|-------------|---------------|--------------------------------------|-------------------------------------|
| **Persistence** | **No** (in-memory only) | **Yes** (RDB snapshots, AOF logs) | **Same as cluster disabled** |
| **Data Types** | **Simple** (key-value strings) | **Complex** (strings, lists, sets, hashes, sorted sets) | **Same as cluster disabled** |
| **Data Partitioning** | **Yes** (client-side sharding) | **No** | **Yes** (sharding across nodes) |
| **Encryption** | **No** | **Yes** <br> In-transit (TLS) <br> At-rest encryption (KMS/AES) | **Same as cluster disabled** |
| **High Availability** | **No** (no replication or failover) | **Yes** (replication + failover) | **Same as cluster disabled** |
| **Multi-AZ** | **Yes** <br> Places nodes in multiple AZs <br> No replication or failover | **Yes** (auto-failover) <br> Uses read replicas (0-5 per shard) | **Same as cluster disabled** |
| **Scaling** | **Yes** <br> Up (node type) <br> Out (add nodes) |  **Yes** <br> Up (node type) <br> Out (add replicas) |  **Yes** <br> Up (node type) <br> Out (add shards) |
| **Multithreading** | **Yes** | **No** (single-threaded core) | **No** (each shard is single-threaded) |
| **Backup/Restore** | **No** | **Yes** (auto and manual snapshots) | **Same as cluster disabled** |
| **Use Cases** | • Simple caching <br> • Session storage <br> • Ephemeral data | • Caching <br> • Real-time analytics <br> • Pub/Sub <br> • Leaderboards <br> • Complex data structures | **Same as cluster disabled** <br>+ large-scale datasets <br> (requiring sharding and horizontal scaling) |

---

### Quick Memory Note
  - **If a question says:**
    - `Simple cache, no persistence` → **Memcached**
    - `Need HA / failover / persistence` → **Redis**
    - `Need sharding / massive scale` → **Redis (cluster enabled)**
    - `Need encryption` → **Redis only**

---

### Key Takeaways
  - **Memcached** = simple, fast, disposable
  - **Redis** = powerful, persistent, highly available
  - **Redis Cluster** = Redis at scale

---

## ElastiCache Scaling

### Memcached
  - **Horizontal scaling** – add/remove nodes (client-side sharding)
  - **Vertical scaling** – change node type  
    - May cause cache loss (no replication; data is ephemeral)
    - No built-in data migration or failover

---

### Redis

  - **Cluster mode disabled**:
    - **Vertical scaling** – change node type (may involve node replacement / brief disruption)
    - **Horizontal scaling (read)** – add read replicas (up to 5) for read scaling and high availability
    - Single primary node → write throughput is limited

  - **Cluster mode enabled**:
    - **Vertical scaling** – change node type (per shard)
    - **Horizontal scaling (write + read)** – add/remove shards (true partitioning)
    - **Online resharding** – redistribute data across shards with minimal downtime
    - **Offline resharding** – used for more complex changes (may require downtime)
    - Each shard = primary + replicas (HA (high availability) per shard)

---

## Use Cases for ElastiCache

| **Requirement** | **Example Use Case** |
|-----------------|----------------------|
| Data is **frequently accessed** <br> Benefits from **low-latency retrieval** | • Session data <br> • User profiles <br> • Product catalogs |
| App can tolerate: <br> **eventual consistency** <br> or **stale data** | • Caching results of expensive database queries <br> • Caching API responses |
| Data is **expensive** <br> or **slow to compute/fetch** | • Complex calculations <br> • ML inference results <br> • External API responses |
| Need **ultra-low latency access**<br> (microseconds–milliseconds) | • Real-time analytics <br> • Gaming leaderboards |
| Need to **offload read pressure** | • High-traffic web applications reducing load on RDS/Aurora |
| Require **scalable in-memory performance** <br> for reads (and sometimes writes) | • Bursty traffic <br> • Real-time applications |
| Often used for storing **session state** data | • User sessions in web applications <br> • Shopping carts <br> • Game state |

---

## Real-World Applications for ElastiCache

| **Use Case** | **Engine Choice** | **Enabled Features** |
|--------------|-------------------|----------------------|
| Web session store or <br> Load-balanced Apps | Redis | Persistence, replication, high availability |
| Database caching | Memcached <br> or Redis | Memcached for simple caching<br> Redis for persistence and HA |
| Leaderboards | Redis | Sorted sets, persistence, replication |
| Real-time dashboards <br> (IoT Data, Analytics, Monitoring) | Redis | Streams, persistence, replication |
| Pub/Sub messaging | Redis | Pub/Sub, real-time notifications, <br>chat systems, event-driven updates |
| Simple key-value <br> Caching at scale | Memcached | Client-side sharding, multithreading, horizontal scaling |
| Stateless web app caching | Memcached | Ephemeral storage, no persistence needed |
| High-throughput <br> Read-heavy workloads | Memcached | Multithreading, low latency |
| Short-lived or <br> disposable data | Memcached | No persistence, fast eviction |

---

## Amazon DynamoDB
  - Fully managed, serverless NoSQL database service
  - Key-value and document data models
  - Push-button scaling 
  - Virtually unlimited throughput and storage
  - Single-digit millisecond latency at any scale

---

## DynamoDB Structure
  - **Tables**: collections of items (similar to tables in RDS)
  - **Items**: individual records (similar to rows in RDS)
  - **Attributes**: key-value pairs that describe an item (similar to columns in RDS)
  - **Primary Key**:
    - **Partition key** → uniquely identifies an item (simple primary key)
    - **Partition key + Sort key** → composite key for grouping and ordering items
  - **Secondary Indexes**:
    - **Global Secondary Index (GSI)** → query using different partition/sort keys (separate throughput, eventually consistent by default)
    - **Local Secondary Index (LSI)** → same partition key, different sort key (created at table creation, strongly consistent reads supported)

---

## DynamoDB TTL 
  - Time to Live (TTL) allows automatic deletion of expired items
  - You specify a TTL attribute (timestamp) for each item
  - No extra cost and does not use WCU/RCU capacity
    - **WCU** = Write Capacity Units
    - **RCU** = Read Capacity Units
  - Helps reduce storage costs and manage data lifecycle

---

## DynamoDB Key Features

| **Feature** | **Benefit** |
|-------------|-------------|
| **Serverless** | Fully managed, no servers to provision, automatic scaling |
| **Highly Available** | Multi-AZ by default, 99.99% SLA (99.999% with Global Tables) |
| **NoSQL (Key-Value + Document)** | Flexible schema, supports semi-structured data |
| **Horizontal Scaling** | Automatic partitioning, scales to millions of requests per second |
| **DynamoDB Streams** | Captures item-level changes (up to 24 hours), enables event-driven architectures (e.g., Lambda triggers) |
| **DAX (DynamoDB Accelerator)** | In-memory cache for DynamoDB, microsecond latency for reads |
| **Consistency & Transactions** | Strongly consistent or eventually consistent reads; supports ACID transactions |
| **Backup & Restore** | Point-in-time recovery (up to 35 days), on-demand backups |
| **Global Tables** | Multi-region, multi-active replication with low-latency reads/writes |

---

## DynamoDB - HOL Notes
  -  `aws dynamodb batch-write-item --request-items file://items.json` → batch write operation for multiple items
  -  `aws dynamodb scan --table-name <table_name>` → retrieves all items from a table (can be expensive for large tables)
  -  `aws dynamodb query --table-name <table_name> --key-condition-expression "<key_condition_expression>"` → retrieves items based on primary key values (more efficient than scan)
  - `aws dynamodb update-item --table-name <table_name> --key <key> --update-expression "<update_expression>"` → updates an existing item based on its primary key
  - `aws dynamodb delete-item --table-name <table_name> --key <key>` → deletes an item based on its primary key
  - `aws dynamodb create-table --table-name <table_name> --attribute-definitions <attribute_definitions> --key-schema <key_schema> --provisioned-throughput <provisioned_throughput>` → creates a new DynamoDB table with specified attributes, key schema, and throughput settings

---

## DynamoDB Streams

### How it Works
  1. App Inserts/Updates/Deletes an item in DynamoDB
  2. A record is written to the DynamoDB Stream (captures item-level changes)
  3. A Lambda function is triggered by the stream event
  4. The Lambda function processes the change 
    - Updates a search index (e.g., Elasticsearch)
    - Sends a notification (e.g., SNS)
    - Monitoring and Debugging (e.g., CloudWatch Logs)
    - Additional processing (e.g., data transformation, enrichment)

---

### Key Takeaways
  - Creates **time-ordered** sequence of **item-level** changes in a DynamoDB table
    - Stored in logs for up to 24 hours
  - Can configure stream to capture:
    - **KEYS_ONLY** – Only **primary key attributes**
    - **NEW_IMAGE** – Entire item **after modification**
    - **OLD_IMAGE** – Entire item **before modification**
    - **NEW_AND_OLD_IMAGES** – Both **before and after modification**

---

## DynamoDB Accelerator (DAX)
  - Fully managed, in-memory cache for DynamoDB
  - Improves performance from milliseconds to microseconds
  - Can be read-through or write-through cache
    - Used to improved **READ** and **WRITE** performance 
  - Does not require application changes (DAX client SDK handles caching logic)
  - Does require an IAM role for permissions and a DAX cluster to be created

---

## DAX vs ElastiCache

  | **Feature** | **DAX** | **ElastiCache** |
  |-------------|---------|-----------------|
  | **Integration** | Designed for DynamoDB | **General-purpose** cache for **any database or application** |
  | **Code Changes** | **No application changes** needed <br>(DAX client SDK) | **Requires application changes** to integrate with cache |
  | **Management** | Fully managed | More management overhead <br>(e.g., cache invalidation, consistency) |
  | **Use Cases** | Caching for DynamoDB workloads | Caching for any database or application <br>(e.g., RDS, Aurora, custom apps) |

---

## DynamoDB Global Tables
  - Multi-region, multi-active replication for DynamoDB tables
  - Provides low-latency reads and writes across multiple regions
  - Uses **asynchronous replication** to replicate data between regions
  - Offers **99.999% availability** and **99.999% durability**
  - Supports up to **5 regions** per global table
  - Each replica table stores the same data and can be read/written independently
  - Use logic in the app to failover to another region 
    - e.g. Route 53 health checks and failover routing policies

---

## What is a Data Lake?
  - Centralized repository that allows you to store all your structured and unstructured data at any scale
  - Can store data in its original format without needing to structure it first
  - Enables you to run different types of analytics (e.g., SQL queries, big data processing, machine learning) 
  - Can create dashboards and visualizations to gain insights from the data
  - Often built on top of Amazon S3 for scalable and cost-effective storage

---

## Data Warehouses vs Data Lakes

| **Characteristic** | **Data Warehouse** | **Data Lake** |
|--------------------|--------------------|---------------|
| **Data Type** | Relational, structured data from transactional systems, operational databases, and line of business applications | Non-relational, unstructured, semi-structured or structured data from various sources (e.g., logs, social media, IoT devices) |
| **Schema** | Designed prior to data ingestion (schema-on-write) | Written at the time of analysis (schema-on-read) |
| **Price/Performance** | Optimized for fast query performance on structured data (higher cost) | Optimized for low-cost storage of large volumes of data (lower cost) |
| **Data Quality** | Highly curated and cleaned data <br> Serves as central source of truth for analytics | Raw, unprocessed data <br> May require additional processing and cleaning before analysis |
| **Users** | Business analysts | Data scientists, data developers, and analysts |
| **Analytics** | SQL-based analytics, batch reporting, BI and visualizations | Machine learning, big data processing, Predictive analytics, data discovery and profiling |
| **Examples** | Amazon Redshift, Snowflake, Google BigQuery | Amazon S3 with Athena, AWS Lake Formation, Databricks |

---

## Amazon Redshift
  - Fast, fully managed data warehouse service
    - Can also use read replicas for operational analytics workloads
    - Works off of live data from RDS or DynamoDB using **Redshift Spectrum**
  - Uses columnar storage and **massively parallel processing (MPP)** for high performance
    - Analyzes large volumes of data using **SQL** and **standard BI (Business Intelligence)** tools
  - Used for **Online Analytical Processing (OLAP)** workloads
  - Uses **EC2 instances for compute** and **EBS for storage**
  - Always maintains **three copies** of data for durability and availability
  - Maintains **continuous/incremental backups** to S3 for **point-in-time recovery**

---

### Use Cases for Redshift
  - **Complex queries and analytics** on **large datasets** of structured or semi-structured data
  - **Frequently accessed data** that needs a **consistent, highly structured schema** for analysis
  - Use **Spectrum** for **direct access of S3 objects** in data lake
  - Managed data warehouse solution with:
    - Automated provisioning, configuration, scaling, and maintenance
    - Data durability and availability with replication and backups
    - Scales with simple API calls and supports standard SQL and BI tools
    - Exabyte-scale query capability with columnar storage and MPP architecture   

---

## Amazon Elastic MapReduce (EMR)
  - Fully managed cluster platform
    - Simplifies running big data frameworks
      - e.g., Apache Hadoop, Apache Spark, HBase, Presto, Flink
  - Used for processing data for analytics, machine learning, and business intelligence
  - Can also be used for transforming and moving larg volumes of data
  - Performs extract, transform, load (ETL) operations on data
    - Connects to sources like:
      - Amazon S3
      - Amazon Glacier
      - Amazon Redshift
      - Amazon DynamoDB
      - Amazon RDS
      - Hadoop Distributed File System (HDFS)

---

## Amazon Kinesis
  - Fully managed service for real-time data streaming and analytics
  - **Amazon Kinesis Data Streams** – collects, processes, and analyzes streaming data in real time
    - Sources include:
      - Website clickstreams
      - Application logs
      - IoT telemetry data
      - Social media feeds
  - **Amazon Kinesis Data Firehose** – fully managed service for loading streaming data into data lakes, data stores, and analytics services
  - **Amazon Kinesis Data Analytics** – real-time analytics on streaming data using SQL or Apache Flink
  - **Amazon Kinesis Video Streams** – captures, processes, and stores video streams for analytics and machine learning applications
    - Not tested on the SAA exam, but good to know for real-world applications

---

## Amazon Kinesis Data Streams
  - Producers send data to Kinesis, data stored in shards (ordered sequence of records)
    - Default retention period is 24 hours (up to 365 days with extended retention)
  - Consumeers read and process data from shards in real time (milliseconds latency)
    - Can use **Kinesis Client Library (KCL)** or **AWS Lambda** for processing
    - Can support up to 1000 PUT records per second per shard
    - Saved into another AWS service (e.g., S3, Redshift, Elasticsearch) or custom applications
  - Order is maintained for records within a shard, but not across shards
  - A partion can be specified with `PutRecord` to group data by shard

---

### Kinesis Client Library (KCL)
  - Helps to consume and process data from **Kinesis Data Streams**
  - Automatically handles load balancing, checkpointing, and error handling
  - Enumerates shards and instantiates a record processor for each managed shard
  - **Each shard** is processed by **only one KCL worker at a time**
    - Only one corresponding record processor instance is active for a given shard at any time
    - If a worker fails, KCL automatically reassigns the shard to another worker and restarts processing from the last checkpoint
    - Checkpointing allows KCL to track progress and ensure at-least-once processing of records
  - One worker **CAN** process multiple shards
    - A shard cannot be processed by multiple workers simultaneously
    - **Record processors** map to **one shard at a time** 

  ---
  
## Kinesis Data Firehose
  - Fully managed service for loading streaming data into data lakes, data stores, and analytics services
  - Producers send data to Firehose
  - Firehose buffers incoming data and delivers it to [configured destinations](https://docs.aws.amazon.com/firehose/latest/dev/create-name.html#:~:text=Here%20is%20a%20list%20of,send%20data%20directly%20to%20Firehose.)
    - e.g., S3, Redshift, Elasticsearch, Splunk, HTTP endpoints
    - Can optionally be transformed using AWS Lambda before delivery
  - Near real-time delivery (~60 seconds latency) 
  - Automatically scales to match incoming data volume
  - Provides error handling and retry mechanisms for failed deliveries
    
---

## Kinesis Data Analytics
  - Real-time analytics on streaming data using SQL or Apache Flink
  - Can perform filtering, aggregation, and transformation of streaming data
  - Provides analytics for coming in from: 
    - Kinesis Data Streams and Kinesis Data Firehose
  - Can output results to:
    - Kinesis Data Streams
    - Kinesis Data Firehose
    - AWS Lambda
    - Custom applications

---

## Amazon Athena and AWS Glue

### Amazon Athena
  - Serverless interactive query service for analyzing data in S3 using standard SQL
  - No infrastructure to manage, pay per query based on data scanned
  - Point Athena to a Data Lake in S3 and start querying using SQL
  - Integrates with AWS Glue Data Catalog for metadata management
  - Can query data in various formats (e.g., CSV, JSON, Parquet, ORC) 
    - Supports complex data types (e.g., arrays, maps, structs)
  - Can point to other sources like Redshift Spectrum, RDS, DynamoDB using federated queries and Lambda connectors

---

### AWS Glue
  - Fully managed **ETL (Extract, Transform, Load) service**
  - Catalogs data sources, transforms data, and loads it into data stores
    - Metadata repository (**Glue Data Catalog**) for data discovery and schema management
  - Integrates with Amazon Athena for querying transformed data in S3
  - Works with various data sources:
    - Data lakes in S3
    - Datawarehouses like Redshift
    - Data stores like RDS, DynamoDB and EC2 databases
  - Can use a **crawler** to automatically discover and catalog data in S3
    - Crawler can infer schema and create tables in the Glue Data Catalog
  - Can create **ETL jobs** to transform and move data between sources and targets
    - Jobs can be scheduled or triggered by events (e.g., new data in S3)
  - Other alternative is Apache Hive on EMR
    - But Glue is serverless and fully managed
    - Hive on EMR requires managing a cluster and is not serverless

---

## Optimizing Athena Performance
  - **Partition your data** – partition data in S3 based on common query filters (e.g., date, region)
  - **Bucket your data** – bucket data within a single partition
  - **Use compression** – AWS recommends using either Apache Parquet or ORC 
  - **Optimize file sizes** – aim for files between 100 MB and 1 GB for optimal performance
  - **Use columnar formats** – Parquet and ORC are popular columnar data stores
  - **Optimize ORDER BY and GROUP BY** – these operations can be expensive, so use them judiciously
  - **Use appropriate functions** – use built-in functions and avoid complex expressions when possible
  - **Only select necessary columns** – avoid using `SELECT *` and only select the columns you need for your query

---

## Amazon OpenSearch Service (Elasticsearch)

### Overview
- Fully managed search and analytics service based on OpenSearch
- Provides **real-time search, analytics, and visualization** at scale
- Spirited successor to Amazon Elasticsearch Service (Amazon ES)
- Commonly used for:
  - Log analytics (ELK-style workloads)
  - Application monitoring / observability
  - Full-text search (websites, apps)
  - Security analytics (SIEM)

---

### Deployment Model
- Create an **OpenSearch Domain** (managed cluster)
- Provisioned via:
  - AWS Management Console
  - API
  - CLI

- You configure:
  - Number of instances (nodes)
  - Instance types
  - Storage options
  - Availability Zones (Multi-AZ)

---

### Domain (Key Concept)
- A **Domain = OpenSearch cluster + configuration**
- Includes:
  - Compute (nodes)
  - Storage
  - Security settings
  - Access endpoint (HTTPS)

---

### Storage Tiers
- **Hot storage** → actively queried data
- **UltraWarm** → less frequently accessed data (lower cost)
- **Cold storage** → rarely accessed, lowest cost tier

---

### Data Ingestion
- Data is ingested from multiple sources:
  - **Kinesis Data Firehose** → streaming ingestion
  - **Logstash** → ingestion pipelines
  - **OpenSearch API** → direct indexing
  - Custom apps / services

---

### Query & Visualization
- Search and analyze data using:
  - OpenSearch Query DSL
  - SQL

- Visualization via:
  - **OpenSearch Dashboards (Kibana)**

---

### Networking (VPC vs Public)
- Deploy:
  - **Inside a VPC (recommended)**
    - Private access only
    - Controlled via security groups
    - Requires VPN / proxy / internal access to connect

  - **Public endpoint**
    - Accessible over internet (restricted via policies)

---

### VPC Considerations
- Secure intra-VPC communication
- Cannot use IP-based access policies (use security groups instead)

---

### VPC Limitations
- Cannot switch between:
  - VPC deployment ↔ public endpoint
- Cannot deploy in VPCs with **dedicated tenancy**
- Cannot move domain to a different VPC after creation
  - Can modify subnets and security groups

---

### Security

- **Encryption**
  - Encryption at rest
  - Encryption in transit (TLS)

---

### Access Control Models

- **Resource-based policies (Domain Access Policy)**
  - Attached directly to the OpenSearch domain
  - Control who can access the domain and allowed actions

- **Identity-based policies (IAM)**
  - Attached to users, groups, or roles (principals)
  - Define permissions for interacting with OpenSearch

- **IP-based policies**
  - Restrict access to specific IPs or CIDR ranges
  - Common for public endpoints
  - **Not supported** for VPC-based domains

---

### Authentication

- **SAML Federation**
  - Integrate with on-premises identity providers (e.g., Active Directory)

- **Amazon Cognito**
  - User authentication via Cognito user pools
  - Supports social identity providers (Google, Facebook, etc.)
  - Common for securing OpenSearch Dashboards access

---

### Fine-Grained Access Control (FGAC)
- Role-based access control (RBAC)
- Security at:
  - Index level
  - Document level
  - Field level
- Multi-tenancy support in OpenSearch Dashboards
- Supports HTTP basic authentication (OpenSearch & Dashboards)

---

### Availability & Durability
- Multi-AZ support (up to 3 AZs)
- High availability and fault tolerance

---

### Backup & Recovery
- Automated snapshots to S3
- Manual snapshots for point-in-time recovery

---

### Key Characteristic
- Optimized for **search and indexing**, not transactional workloads

---

## ELK Stack 
  - Stands for **Elasticsearch, Logstash, Kibana**
  - Commonly used for log analytics and observability
  - Logstash → Elasticsearch → Kibana
    - **Logstash** → data collection and transformation
    - **Elasticsearch** → search and analytics engine
    - **Kibana** → visualization and dashboards
  - Use cases include:
    - Visualizing application and infrastructure logs
    - Troubleshooting and monitoring
    - Security analytics 
    - SIEM (Security Information and Event Management)
  
---

## OpenSearch Best Practices

### High Availability & Fault Tolerance
  - Deploy data nodes across **3 Availability Zones (AZs)** for maximum availability
  - Use **equal distribution of nodes across AZs**
    - Prefer instance counts in **multiples of 3**
  - If 3 AZs are not available:
    - Use **2 AZs with balanced node distribution**

---

### Cluster Configuration
  - Use **3 dedicated master nodes**
    - Prevents split-brain and improves cluster stability
  - Configure **at least 1 replica per index**
    - Enables failover and improves read performance

---

### Security Best Practices
  - Deploy domain **inside a VPC** for network isolation
  - Apply **restrictive resource-based policies**
    - Or use **fine-grained access control (FGAC)**
  - Enable:
    - **Encryption at rest**
    - **Encryption in transit**
    - **Node-to-node encryption** (for sensitive data)

---

### General Guidance
  - Balance nodes evenly across AZs to avoid uneven load
  - Design for failure (assume node/AZ loss)

---

## AWS Batch
  - Fully managed batch processing service
  - Efficiently runs hundreds to thousands of batch computing jobs
  - A job is a unit of work such as:
    - Shell script
    - Executable
    - Docker container image
  - A job is submitted to a job queue until scheduled to run on a compute environment
    - Launch Batch Job → Job Definition → Job Queue → Compute Environment (EC2 or Fargate)
  - Launches, manages and scales compute resources (EC2 or Fargate) based on job requirements
  - Compute environments can contain managed and unmanaged resources
    
---

## Amazon QuickSight
  - Fully managed **business intelligence (BI) and data visualization** service
  - Used to create:
    - Interactive dashboards
    - Reports
    - Visualizations for analytics and business insights

  - Serverless, highly scalable, and pay-per-session pricing model
    - SPICE engine enables fast, in-memory query performance

---

### Key Features
  - **SPICE (Super-fast, Parallel, In-memory Calculation Engine)**
    - Improves query performance
    - Reduces load on underlying data sources
  - Interactive dashboards with filtering and drill-down capabilities
  - Auto-refresh and scheduled data updates
  - Machine learning insights (anomaly detection, forecasting)
  - Row-level security (restrict data per user/group)

---

### Integrations
  - Works with AWS analytics stack:
    - Athena (query S3 data)
    - Redshift (data warehouse)
    - S3 (data lake)
  - IAM for authentication and access control
  - Integrates with data sources:
    - Amazon S3
    - Amazon Athena
    - Amazon Redshift
    - Amazon RDS / Aurora
    - On-premises databases (via connectors)

---

### Common Use Cases
  - Business intelligence dashboards
  - Data visualization for analytics pipelines
  - Reporting on data from Athena / Redshift
  - Embedding dashboards into applications

---

### Key Characteristics
  - Visualization layer in the data analytics stack
  - Does not store large datasets (relies on sources or SPICE cache)

---

## AWS Data Exchange
  - Fully managed **data marketplace** for discovering and subscribing to third-party datasets
  - Provides access to external data for:
    - Analytics, applications, and machine learning

  - Supports multiple **data delivery types**:
    - **Data files** (S3: CSV, JSON, Parquet)
    - **Data tables** (query via Redshift)
    - **Data APIs**

---

### Integrations 
  - Integrates directly with AWS analytics and data services: 
    - Amazon S3 (data lakes)
    - Amazon Redshift (analytics)
    - Applications and ML workflows

  - Automatically delivers new and updated datasets to **Amazon S3**

  - Supports secure data sharing and access control:
    - Authentication (IAM)
    - Governance and access control
    - Encryption at rest and in transit

---

### Benefits
  - **Large dataset marketplace** with many providers and products
  - **Centralized data procurement**
    - Exchange data publicly or privately
    - Simplified billing and contracts
  - **Seamless AWS integration**
    - Native integration with analytics and ML services
  - **Ease of use**
    - Self-service data access
    - Supports files, tables, and APIs
  - **Secure and compliant**
    - IAM integration and encryption
---

### Common Use Cases
  - Enrich internal datasets with external data
  - Access industry datasets for analytics / ML
  - Build applications using third-party data

---

## Other Database Services

### DocumentDB
  - Fully managed document database service
  - Compatible with MongoDB workloads
    - Can migrate MongoDB using AWS Database Migration Service (DMS)
  - Uses JSON-like documents with flexible schemas
  - Uses a distributed, fault-tolerant storage system
  - Supports:
    - Auto-scaling storage (up to 64 TB per cluster)
    - Millions of requests per second (low latency)
    - 15 replicas across 3 AZs for high availability

---

### Amazon Keyspaces (for Apache Cassandra)
  - Fully managed NoSQL database service for Cassandra workloads
  - Compatible with Apache Cassandra APIs and CQL (Cassandra Query Language)
    - Can migrate Cassandra using AWS Database Migration Service (DMS)
  - Serverless, auto-scaling, highly available, and durable database service
  - Supports:
    - Auto-scaling storage and throughput
    - Thousands of requests per second with single-digit millisecond latency
    - Virtually unlimited throughput and storage
    - Replication across multiple AZs for high availability (99.99% SLA)

---

## Amazon Neptune
  - Fully managed graph database service
  - Can build and run identity, knowledge, fraud and other graph applications
  - Deploy high performance graph applications using popular open-source graph models like:
    - Gremlin (property graph model)
    - openCypher (property graph model)
    - SPARQL (RDF graph model)
  - Supports:
    - Up to 15 database replicas
    - Fault-tolerant and self-healing storage with replication across multiple AZs
    - DB volumes that grow in increments of 10 GB up to 64 TB
    - Greater than 99.99% availability

---

### Amazon QLDB (Quantum Ledger Database)
  - Fully managed ledger database service
  - Provides a transparent, immutable, and cryptographically verifiable transaction log
  - Built-in immutable journal that tracks all changes to data and history of changes over time
    - Journal is append-only and cannot be modified or deleted
  - Uses cryptographic hashing to ensure data integrity and create consice summary od history (hash chain)
    - Generated using SHA-256 algorithm, stored in the journal, and can be used to verify data integrity and history
  - Serverless, auto-scaling, highly available, and durable database service
  - Use cases include:
    - Financial transactions
    - Supply chain tracking
    - Identity management
    - Any application that requires an immutable and verifiable record of transactions

---

## Other Analytics Services

### Amazon Timestream
  - Fully managed time series database service
  - Designed for storing and analyzing time series data 
    - e.g., IoT telemetry, application monitoring, operational analytics
  - Serverless, auto-scaling, highly available, and durable database service
  - Faster and cheaper than RDS for time series workloads 
  - Supports:
    - Auto-scaling storage and throughput
    - Millions of writes per second with single-digit millisecond latency
    - Built-in functions for time series analysis (e.g., smoothing, interpolation, forecasting)
    - Data retention policies to automatically expire old data

---

### AWS Data Pipeline
  - Fully managed ETL service for orchestrating data workflows
  - Processes and moves data between different AWS services and on-premises data sources
  - Define data-driven workflows (data pipelines) that can be scheduled and monitored
  - Results can be stored in services such as:
    - Amazon S3
    - Amazon RDS
    - Amazon DynamoDB
    - Amazon EMR

---

### AWS Lake Formation
  - Fully managed service for building and managing data lakes
    - Takes days to set up a secure data lake with Lake Formation vs. weeks or months with manual setup
  - Simplifies the process of setting up a secure data lake in Amazon S3
  - Data can be collected from various sources (e.g., databases, streaming data, on-premises data)
    - Stores data in a central repository (S3) for analytics and machine learning
  - Security can be applied at column, row, and cell levels 
  - Provides tools for:
    - Data ingestion
    - Cataloging
    - Access control
    - Data transformation
  - Integrates with analytics services like:
    - Amazon Athena
    - Amazon Redshift
    - Amazon EMR
    - Apache Spark
    - Amazon Quicksight
  - Builds on top of the capabilities availiable in AWS Glue

---

### Amazon Managed Streaming for Apache Kafka (MSK)
  - Fully managed service for running Apache Kafka workloads
  - Simplifies the setup, scaling, and management of Kafka clusters
  - Provides a secure and highly available environment for ingesting and processing streaming data in real-time
  - Provisions, manages and maintains Apache Kafka clusters and Apache ZooKeeper nodes
  - Integrates with other AWS services for data processing and analytics
    - e.g., Kinesis Data Firehose, Lambda, Redshift, S3
  - Security levels include:
    - VPC Network Isolation
    - AWS IAM for control plane API Authorization
    - Encryption at rest 
    - Encryption in transit (TLS)
    - TLS based certificate-based authentication
    - SASL/SCRAM authentication secured by AWS Secrets Manager

---

## Quick References

### [Database and Analytics Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619340#overview)

### [Database and Analytics Architecture Patterns Private Link](https://drive.google.com/drive/folders/1NZnyqF50lkyf2CHqk703dftlyXVcr-MA?usp=drive_link)

### [AWS Database and Analytics Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346114#overview)

### [Amazon RDS Cheat Sheet](https://digitalcloud.training/amazon-rds/)

### [Amazon Aurora Cheat Sheet](https://digitalcloud.training/amazon-aurora/)

### [Amazon DynamoDB Cheat Sheet](https://digitalcloud.training/amazon-dynamodb/)

### [Amazon Elasticache Cheat Sheet](https://digitalcloud.training/amazon-elasticache/)

### [Amazon Redshift Cheat Sheet](https://digitalcloud.training/amazon-redshift/)

### [Amazon EMR Cheat Sheet](https://digitalcloud.training/amazon-emr/)

### [Amazon Kinesis Cheat Sheet](https://digitalcloud.training/amazon-kinesis/)

### [Amazon Athena Cheat Sheet](https://digitalcloud.training/amazon-athena/)

### [Amazon Glue Cheat Sheet](https://digitalcloud.training/aws-glue/)

---