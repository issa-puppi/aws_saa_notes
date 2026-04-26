# Storage Fundamentals
---

## Storage Types Overview

Before diving into individual services, it helps to have the three storage paradigms clearly separated — the exam regularly tests your ability to match a requirement to the correct storage model.

| **Feature** | **Block Storage** | **File Storage** | **Object Storage** |
|-------------|-------------------|------------------|--------------------|
| **AWS Services** | EBS, EC2 Instance Store | EFS, FSx | S3, Glacier |
| **Access method** | Attached to instance as a disk device | Mounted via NFS (Linux) or SMB (Windows) over a network | HTTP/REST API (GET, PUT, DELETE) |
| **Data structure** | Raw fixed-size blocks | Hierarchical — files and directories | Flat — objects in buckets (prefixes simulate hierarchy) |
| **Latency / Performance** | Lowest latency, highest IOPS | Moderate latency | Higher latency (milliseconds, not microseconds) |
| **Sharing** | Single instance (exception: Multi-Attach for io1/io2) | Multi-instance, multi-AZ, concurrent access | Global — any authorized client |
| **Scalability** | Fixed at provision time (Elastic Volumes can resize) | Scales automatically (EFS) or provisioned (FSx) | Virtually unlimited |
| **Cost model** | Pay for provisioned capacity | Pay for consumed (EFS) or provisioned (FSx) | Pay for storage + requests + data transfer |
| **Persistence** | Persistent (EBS) or ephemeral (Instance Store) | Persistent | Highly durable (11 9s for S3/EFS) |
| **Typical use cases** | OS disks, relational databases, boot volumes | Shared file access, CMS, HPC, home directories | Backups, media, static assets, data lakes |
| **Key constraint** | Must be attached to EC2; AZ-bound (EBS) | Requires NFS/SMB client; Linux only (EFS) | Not a file system — no mounting |

> 💡 **Exam Tips:**
> <br>"Shared file storage across multiple EC2 instances" → **EFS** (Linux) or **FSx for Windows** (Windows/SMB)
> <br>"High-performance low-latency database disk" → **EBS (io2 / io2 Block Express)**
> <br>"Temporary cache/scratch space, highest possible I/O" → **EC2 Instance Store**
> <br>"Backup, static assets, unstructured data at any scale" → **S3**

---

# Block Storage
---

## Amazon Elastic Block Store (EBS)

Amazon Elastic Block Store (EBS) provides **persistent block storage** volumes for use with EC2 instances.
<br>EBS volumes behave like raw block devices — they can be formatted with a file system, partitioned, and used as OS disks or data volumes.

### Key Properties
  - **Persistent** — data survives instance stop, restart, and even termination (configurable)
  - **AZ-bound** — an EBS volume exists in a specific Availability Zone (AZ) and can only be attached to instances in the same AZ
  - **Network-attached** — volumes are connected to instances over AWS's internal network (not physically local)
  - EBS volume data is **replicated within the AZ** for durability
  - Designed for annual failure rate (AFR) of **0.1%–0.2%**; SLA of **99.95%**
  - Up to **5,000 EBS volumes** † per account; up to **10,000 snapshots** † per account
  - **Elastic Volumes** — resize, change type, or adjust performance of a volume while it is in use (no downtime, except for magnetic Standard type) Δ

### Attachment Rules
  - You can **attach multiple EBS volumes** to a single EC2 instance
  - **Multi-Attach** — attach one volume to up to **16 Nitro-based instances** simultaneously (io1/io2 only, same AZ) †
  - You can only **detach and reattach** within the same AZ
  - To migrate a volume to a different AZ or region: create a snapshot → create a new volume from the snapshot in the target AZ/region

### Deletion Behavior
  - **Root (boot) volume** — deleted on instance termination **by default** §
  - **Non-root data volumes** — retained on instance termination **by default** §
  - Both behaviors are configurable via the `DeleteOnTermination` attribute in the block device mapping

> ⚠️ **Exam Trap:** You **cannot decrease** an EBS volume size — only increase. When restoring from a snapshot, the new volume must be at least the size of the snapshot.

---

## EBS Volume Types — Quick Reference

| **Volume Type** | **Class** | **Max IOPS** ‡ | **Max Throughput** ‡ | **Boot Volume** | **Multi-Attach** | **Best For** |
|-----------------|-----------|---------------|---------------------|-----------------|-----------------|--------------|
| **gp3** | SSD | 16,000 | 1,000 MiB/s | ✓ | ✗ | Default choice — flexible, cost-efficient |
| **gp2** (legacy) | SSD | 16,000 | 250 MiB/s | ✓ | ✗ | Legacy general purpose; replaced by gp3 Δ |
| **io2 Block Express** | SSD | 256,000 | 4,000 MiB/s | ✓ | ✓ | Sub-ms latency, ultra-high performance, highest durability |
| **io2 / io1** | SSD | 64,000 | 1,000 MiB/s | ✓ | ✓ | I/O-intensive databases, sustained high IOPS |
| **st1** | HDD | 500 | 500 MiB/s | ✗ | ✗ | Big data, log processing, sequential throughput |
| **sc1** | HDD | 250 | 250 MiB/s | ✗ | ✗ | Cold data, lowest cost, infrequent access |

---

## EBS Volume Types — Detail

### SSD Volumes

**gp3 (General Purpose SSD)**
  - Size: 1 GiB – 16 TiB †; baseline 3,000 IOPS and 125 MiB/s included; independently scale IOPS up to 16,000 and throughput up to 1,000 MiB/s ‡
  - Durability: 99.8%–99.9% (0.1%–0.2% AFR)
  - **Best default choice** for most workloads — replaces gp2 for new volumes Δ

**gp2 (General Purpose SSD — Legacy)**
  - Size: 1 GiB – 16 TiB †; IOPS tied to volume size (3 IOPS/GiB, burst to 3,000 IOPS for volumes < 1 TiB) ‡
  - Max: 16,000 IOPS at 5.33 TiB and above ‡; max throughput 250 MiB/s ‡
  - Legacy — AWS recommends migrating to gp3 for better performance at same or lower cost Δ

**io2 Block Express**
  - Size: 4 GiB – 64 TiB †; up to 256,000 IOPS ‡ and 4,000 MiB/s ‡
  - Durability: **99.999%** (0.001% AFR) — highest durability tier
  - Sub-millisecond latency; supports Multi-Attach
  - Use case: mission-critical transactional databases, SAP HANA

**io2 / io1 (Provisioned IOPS SSD)**
  - Size: 4 GiB – 16 TiB †; up to 64,000 IOPS ‡ on Nitro instances (32,000 on others) ‡; throughput up to 1,000 MiB/s ‡
  - io2 durability: 99.999%; io1 durability: 99.8%–99.9%
  - Supports Multi-Attach; ideal for sustained high IOPS databases

### HDD Volumes

**st1 (Throughput Optimized HDD)**
  - Size: 125 GiB – 16 TiB †; max 500 IOPS ‡; max 500 MiB/s ‡; baseline 40 MiB/s/TiB, burst to 250 MiB/s/TiB ‡
  - **Cannot be a boot volume** — HDD volumes cannot serve as root/boot devices §
  - Use case: big data (MapReduce, Kafka), data warehouses, log processing, ETL — large sequential I/O

**sc1 (Cold HDD)**
  - Size: 125 GiB – 16 TiB †; max 250 IOPS ‡; max 250 MiB/s ‡; baseline 12 MiB/s/TiB, burst to 80 MiB/s/TiB ‡
  - **Cannot be a boot volume**; **lowest cost EBS option** ¤
  - Use case: cold data with infrequent access, lowest cost tier

> 💡 **Exam Tips:**
> <br>"Need more than 16,000 IOPS" → **io1, io2, or io2 Block Express**
> <br>"Highest possible IOPS and throughput on EBS" → **io2 Block Express** (256,000 IOPS)
> <br>"Cost-optimized, good default, flexible" → **gp3**
> <br>"Large sequential reads/writes, throughput-focused (not IOPS)" → **st1**
> <br>"Cheapest EBS option, cold data" → **sc1**
> <br>"HDD-backed volume as a boot disk" → **Not possible** — only SSD volumes can be boot volumes

---

## EC2 Instance Store

An **instance store** provides **ephemeral (temporary) block storage** that is physically attached to the host server running the EC2 instance.

| **Feature** | **EBS** | **EC2 Instance Store** |
|-------------|---------|------------------------|
| **Persistence** | Persistent — survives stop/start/reboot | Ephemeral — **data lost on stop, termination, or host failure** |
| **Storage location** | Network-attached (separate from host) | Physically attached to the host server |
| **Performance** | High, but network-bound | **Very high — ultra-low latency** (NVMe or SATA SSD) ‡ |
| **Detachability** | Can detach and reattach to instances in same AZ | Cannot detach or reattach |
| **Cost model** | Pay for provisioned storage ¤ | **Included in instance pricing** ¤ — no extra charge |
| **Backup** | Snapshots to S3 | No built-in backup |
| **Use cases** | OS disks, databases, long-term data | Cache, buffers, scratch data, temporary content, replicated workloads |
| **When to survive reboot** | ✓ Yes | ✓ Yes — reboot does not lose data |

  - **You can only specify instance store volumes at launch** — cannot be added after the instance is running
  - Instance store volume size is determined by the instance type ‡
  - Some types use NVMe or SATA SSD for very high random I/O performance ‡

> 💡 **Exam Tips:**
> <br>"Highest I/O performance, data can be lost, replicated across a fleet" → **Instance Store**
> <br>"Distributed database with own replication, needs max IOPS, cost-sensitive" → **Instance Store** (included in instance cost)
> <br>"Data must survive instance stop" → **EBS** (instance store loses data on stop)

---

## EBS Snapshots

**Snapshots** are point-in-time backups of EBS volumes stored durably in Amazon S3.

### Key Properties
  - **Incremental** — only changed blocks since the last snapshot are saved; you only need the most recent snapshot to restore
  - **Region-specific** — snapshots exist in a region (unlike volumes which are AZ-specific)
  - Stored in S3 internally (accessed only via EC2 API — not directly browsable in S3 console) §
  - Can be used to: create new volumes (same or larger size), migrate across AZs, migrate across regions, change encryption state

### Snapshot and Encryption Rules

| **Operation** | **Allowed?** | **Notes** |
|---------------|--------------|-----------|
| Unencrypted → Encrypted | ✓ Yes | Specify KMS key when copying the snapshot |
| Encrypted → Encrypted (same key) | ✓ Yes | Default behavior |
| Encrypted → Encrypted (new key) | ✓ Yes | Must copy the snapshot and specify new key |
| Encrypted → Unencrypted | ✗ Never | Cannot remove encryption once applied |
| Share unencrypted snapshot publicly | ✓ Yes | Make public or share with other accounts |
| Share encrypted snapshot publicly | ✗ Never | Cannot be made public |
| Share encrypted snapshot with another account | ✓ Yes (custom CMK only) | Must use non-default CMK; grant cross-account KMS key access; receiving account should re-encrypt with own CMK |

  - **Snapshots of encrypted volumes are encrypted automatically** §
  - **Volumes restored from encrypted snapshots are encrypted automatically** §
  - You **cannot change the CMK** used to encrypt an existing volume — must create a copy with a new key
  - User-defined tags are **not copied** with snapshots §
  - Max **5 snapshot copy requests** running simultaneously per destination region † per account
  - To take application-consistent snapshots of a RAID array: stop application I/O → flush caches → freeze filesystem → unmount array (or stop instance)

> ⚠️ **Exam Trap:** The encryption direction rule is asymmetric — you can always add encryption, but you can never remove it. Copying a snapshot is the only mechanism to change encryption state or KMS key.

### Snapshot → AMI → Volume Analogy

```
Snapshot  ∶  Volume  ∷  AMI  ∶  Instance
```
  - **Snapshot** — point-in-time data backup of a volume
  - **Volume** — active block storage attached to an instance
  - **AMI (Amazon Machine Image)** — a template built from one or more snapshots + configuration; used to launch new instances
  - **Instance** — a running virtual machine built from an AMI

---

## Amazon Data Lifecycle Manager (DLM)

**Amazon Data Lifecycle Manager (DLM)** automates the creation, retention, and deletion of EBS snapshots and EBS-backed AMIs.

  - Creates **automated backup schedules** — protects valuable data without manual intervention
  - Enforces **retention policies** — retain backups for compliance periods then auto-delete
  - Reduces storage costs ¤ by automatically deleting aged snapshots
  - Enables **disaster recovery policies** to back up data across regions
  - Creates **standardized AMIs** that can be refreshed on a schedule

> 💡 **Exam Tip:** "Automate snapshot lifecycle / enforce retention / reduce snapshot storage cost" → **Amazon DLM**

---

## EBS Encryption

EBS encryption uses **AES-256** with keys managed by AWS KMS (Key Management Service).

  - Encrypted data types: data at rest, data in transit between volume and instance, snapshots, volumes created from those snapshots
  - **No performance impact** — expect same IOPS on encrypted vs. unencrypted volumes §
  - All current instance families support EBS encryption
  - **Cannot enable/disable encryption on an existing volume** — must create a new encrypted volume and copy data, or take a snapshot → copy with encryption → restore
  - A **default CMK (Customer Managed Key)** is generated for the first encrypted volume; subsequent volumes use unique AES-256 keys
  - The same data key is shared by all snapshots and volumes derived from an encrypted volume
  - You can use separate CMKs per volume when creating AMIs with encrypted volumes ※

> 🛠️ **Implementation Notes:** To force all new EBS volumes in an account to be encrypted, enable **EBS encryption by default** at the account/region level — this is a one-click setting in the EC2 console.

---

## RAID on EBS

**RAID (Redundant Array of Independent Disks)** is configured at the OS level using multiple EBS volumes attached to the same EC2 instance.

| **RAID Level** | **Description** | **Performance** | **Fault Tolerance** | **Capacity Efficiency** | **AWS Recommendation** |
|----------------|-----------------|-----------------|---------------------|-------------------------|------------------------|
| **RAID 0** | Striping only | Highest (full parallel R/W) | None — one disk failure loses all data | 100% | ✓ Use for max performance |
| **RAID 1** | Mirroring only | Read ↑ / Write same | High — full copy on second disk | 50% | ✓ Use for high durability |
| RAID 5 | Striping + parity | Good | Medium (1 disk failure) | ~75% | ✗ Not recommended (parity I/O overhead degrades EBS performance) |
| RAID 6 | Striping + double parity | Moderate | High (2 disk failures) | ~67% | ✗ Not recommended |
| RAID 10 | Stripe + mirror | Very high | High | 50% | ✗ Not recommended (cost/complexity vs. managed AWS alternatives) |

  - **RAID 5 and RAID 6**: AWS explicitly discourages these on EBS because the parity I/O operations consume EBS IOPS budget, degrading performance
  - **RAID 0**: doubles throughput and IOPS when using two volumes — no durability; suitable only when data is temporary or replicated elsewhere
  - **RAID 1**: no performance gain for writes; best for critical data requiring on-disk redundancy

> 💡 **Exam Tip:** AWS recommends only **RAID 0** (performance) and **RAID 1** (durability) for EBS. RAID 5/6/10 are **not recommended** due to performance overhead and cost.

---

# File Storage
---

## Amazon Elastic File System (EFS)

Amazon Elastic File System (EFS) is a **fully managed, elastic NFS file system** for Linux-based workloads.
<br>It automatically grows and shrinks as you add and remove files — no provisioning required.

### Key Properties

| **Property** | **Detail** |
|--------------|------------|
| **Protocol** | NFS v4 / NFS v4.1 |
| **OS support** | **Linux only** — not compatible with Windows AMIs |
| **Scale** | Petabyte-scale; grows and shrinks automatically |
| **Concurrency** | Thousands of EC2 instances from multiple AZs can connect simultaneously |
| **AZ availability** | Regional: mount targets in multiple AZs; One Zone: single AZ |
| **Durability** | 11 9s (99.999999999%) across all storage classes |
| **On-premises access** | Via Direct Connect or AWS VPN only |
| **Pricing model** | Pay for what you use ¤ — no pre-provisioning |

### Storage Classes

| **Class** | **Access Pattern** | **Cost** | **Use Case** |
|-----------|--------------------|----------|--------------|
| **EFS Standard** | Frequent | Higher | Active working data, low latency |
| **EFS Infrequent Access (IA)** | Infrequent | Lower | Files not accessed regularly |
| **EFS Archive** | Rare | Lowest | Long-term archival files ※ |

  - **Lifecycle management** automatically moves files between classes based on last-access time
  - **Automatic backups** enabled by default via AWS Backup §

### Performance Modes

| **Mode** | **When to Use** |
|----------|-----------------|
| **General Purpose** (default) § | Most file systems — lowest latency |
| **Max I/O** | Tens/hundreds/thousands of instances accessing simultaneously; higher latency but higher aggregate throughput |

### Throughput Modes

| **Mode** | **Behavior** |
|----------|--------------|
| **Bursting** (default) § | Throughput scales with file system size; earns burst credits |
| **Provisioned** | Fixed throughput independent of storage size; for workloads needing consistent high throughput |
| **Elastic** ※ Δ | Automatically scales throughput up and down based on workload; recommended for unpredictable I/O |

### EFS Encryption
  - **Encryption at rest** — enabled at file system creation time; cannot be enabled after creation; uses KMS
  - **Encryption in transit** — TLS 1.2; enabled at mount time (via the Amazon EFS mount helper)

### EFS Access Control
  - **Mount targets** — VPC endpoints (one per AZ) through which EC2 instances connect; DNS name resolves to mount target IP
  - **IAM** — controls who can administer the file system and access resources via resource-based policies
  - **POSIX permissions** — standard Linux user/group/other permissions on files and directories
  - **Security Groups** — applied to mount targets; act as a firewall for NFS traffic

### EFS Replication
  - Replicates data across AWS regions for disaster recovery
  - RPO/RTO of minutes ‡

> 💡 **Exam Tips:**
> <br>"Shared Linux file storage across many EC2 instances" → **EFS**
> <br>"Mount file system from on-premises Linux servers" → **EFS via Direct Connect or VPN**
> <br>"Throughput needed regardless of file system size" → **EFS Provisioned Throughput**
> <br>"Encryption at rest must be enabled" → must be done at **EFS creation time** — cannot enable later

> ⚠️ **Exam Trap:** EFS is **Linux-only**. If a question mentions Windows instances needing shared file storage, the answer is **FSx for Windows File Server**.

---

## EFS vs EBS — Quick Comparison

| **Aspect** | **Amazon EFS** | **Amazon EBS (Provisioned IOPS)** |
|------------|----------------|-----------------------------------|
| **Availability / Durability** | Data stored redundantly across multiple AZs | Data stored redundantly within a single AZ |
| **Access** | Thousands of EC2 instances from multiple AZs concurrently | Single EC2 instance in a single AZ |
| **Per-operation latency** | Low, consistent | Lowest, consistent |
| **Throughput scale** | 10+ GB/s | Up to 2 GB/s (io2 Block Express: up to 4 GB/s) |
| **Pricing** | Pay per GB consumed | Pay for provisioned GB and IOPS |
| **Use cases** | Big data, analytics, media processing, CMS, web serving, home directories | Boot volumes, transactional and NoSQL databases, data warehousing |

---

# Managed File Systems
---

## Amazon FSx

Amazon FSx provides **fully managed file systems** for third-party file system workloads that require native compatibility with specific protocols or performance characteristics.

### FSx Service Overview

| **Service** | **Protocol** | **OS** | **Best For** |
|-------------|-------------|--------|--------------|
| **FSx for Windows File Server** | SMB | Windows (also Linux/macOS clients via SMB) | Windows workloads, AD integration, NTFS |
| **FSx for Lustre** | POSIX / Lustre | Linux | HPC, ML, video processing, S3-integrated compute |
| **FSx for NetApp ONTAP** | NFS, SMB, iSCSI | Linux + Windows | Multi-protocol, enterprise NAS, data management ※ |
| **FSx for OpenZFS** | NFS | Linux | ZFS workloads, data management, low latency ※ |

> 💡 **Exam Tip:** For the SAA-C03 exam, **FSx for Windows File Server** and **FSx for Lustre** are the primary focus. FSx for NetApp ONTAP and OpenZFS appear occasionally in scenario-matching questions.

---

## FSx for Windows File Server

**Amazon FSx for Windows File Server** provides a fully managed **native Microsoft Windows file system** accessible over the SMB (Server Message Block) protocol.

### Key Properties
  - Full support for **SMB**, **Windows NTFS**, and **Microsoft Active Directory (AD)** integration
  - Supports Windows-native features: ACLs (Access Control Lists), shadow copies (point-in-time recovery), user quotas
  - Clients: Windows, Linux (via SMB), and macOS; supports thousands of concurrent connections †
  - Integrates with **AWS Managed Microsoft AD** or **self-managed AD** for authentication

### Availability Options

| **Mode** | **Architecture** | **Use Case** |
|----------|------------------|--------------|
| **Single-AZ** | Redundant components within one AZ; synchronous replication | Dev/test, cost-optimized workloads |
| **Multi-AZ** | Active + standby file server in separate AZs; automatic failover | Production workloads requiring HA |

  - Supports **DFS (Distributed File System) Namespaces** for consolidating multiple file systems under a single namespace †
  - **Encryption at rest** using KMS; **encryption in transit** via SMB encryption

> 💡 **Exam Tip:** "Windows workloads need shared file storage with AD integration" → **FSx for Windows File Server**. It is the **only** AWS managed file system that natively supports SMB and Windows NTFS.

---

## FSx for Lustre

**Amazon FSx for Lustre** is a high-performance, POSIX-compliant parallel file system optimized for **compute-intensive workloads**.

### Key Properties
  - Designed for **machine learning (ML)**, **high-performance computing (HPC)**, **video processing**, **financial modeling**, **electronic design automation (EDA)**
  - Delivers **sub-millisecond latencies** and high aggregate throughput ‡
  - **POSIX-compliant** — Linux-native file system semantics
  - **Native S3 integration**: S3 objects are presented as files in the Lustre file system; supports linked S3 buckets for read and write access
    - Data repository association allows reading from S3 on first access and writing back automatically
    - **Not a feature of FSx for Windows File Server**

### Deployment Types

| **Type** | **Persistence** | **Use Case** |
|----------|-----------------|--------------|
| **Scratch** | Ephemeral — data not replicated; not persisted after file system deletion | Short-term processing, lowest cost ¤ |
| **Persistent** | Replicated within AZ; survives file system interruptions | Long-running workloads requiring durability |

> 💡 **Exam Tip:** "HPC / ML workload needing high throughput + S3 integration" → **FSx for Lustre**. It is the only AWS managed file system with native, transparent S3 integration.

---

# Hybrid Storage
---

## AWS Storage Gateway

**AWS Storage Gateway** bridges on-premises environments and AWS cloud storage, providing a **virtual appliance** (software or hardware) that runs on-premises and connects to AWS.

### Storage Gateway at a Glance

| **Gateway Type** | **Protocol** | **AWS Backend** | **Primary Use Case** |
|------------------|-------------|-----------------|----------------------|
| **File Gateway** | NFS / SMB | Amazon S3 | Replace on-premises NAS; files stored as S3 objects |
| **Volume Gateway (Cached)** | iSCSI | S3 + EBS Snapshots | Primary data in S3; local cache for hot data |
| **Volume Gateway (Stored)** | iSCSI | S3 (EBS Snapshots) | Primary data on-premises; async backup to S3 |
| **Tape Gateway** | iSCSI VTL | S3 / S3 Glacier | Replace physical tape libraries; virtual tape backup |

  - All modes: a **virtual gateway appliance** runs on-premises (VMware ESXi, Microsoft Hyper-V, Linux KVM, hardware appliance, or EC2)
  - All modes: a **local cache** provides low-latency access to recently used data
  - All modes: data is encrypted in transit (TLS) and at rest in S3 (SSE-S3 or SSE-KMS)

---

## File Gateway

**File Gateway** provides file-based access to objects stored in **Amazon S3**.

  - On-premises servers/apps mount the gateway as an **NFS** (Linux) or **SMB** (Windows) share
  - Files written to the gateway are stored as **S3 objects** — full S3 feature set available (lifecycle policies, versioning, replication)
  - Local cache retains recently accessed objects for low-latency reads
  - Ideal for: cloud-tiering of file shares, extending on-premises NAS to S3, migrating file data to S3

---

## Volume Gateway

**Volume Gateway** provides **iSCSI block storage** backed by S3 and EBS snapshots.

| **Mode** | **Where Primary Data Lives** | **Where Backup Goes** | **Local Storage Needed** |
|----------|------------------------------|----------------------|--------------------------|
| **Cached Volumes** | Amazon S3 (primary dataset in AWS) | EBS snapshots | Cache for frequently accessed data only |
| **Stored Volumes** | On-premises (full dataset local) | S3 as async EBS snapshots | Full dataset (1 GiB – 16 TiB) |

  - **Cached Volumes**: minimize on-premises storage footprint; primary data in S3; local cache for hot data
  - **Stored Volumes**: keep entire dataset on-premises for low-latency access; asynchronous backup snapshots go to S3 as EBS snapshots

> 💡 **Exam Tips:**
> <br>"On-premises needs block storage with backup to AWS, low latency to all data" → **Volume Gateway (Stored)**
> <br>"Minimize on-premises storage, primary data in cloud" → **Volume Gateway (Cached)**

---

## Tape Gateway

**Tape Gateway** provides a **virtual tape library (VTL)** for backup and archival applications.

  - On-premises backup software connects via **iSCSI** and sees virtual tape drives and a tape changer
  - Virtual tapes are stored in **Amazon S3** (active virtual tape library)
  - Archived tapes moved to **S3 Glacier** or **S3 Glacier Deep Archive** for long-term retention ¤
  - Integrates with leading backup applications: Veeam, Veritas Backup Exec, Commvault, NetBackup, etc.
  - Eliminates need for physical tape hardware and off-site tape management

> 💡 **Exam Tip:** "Replace physical tape backup infrastructure with cloud-backed virtual tapes" → **Tape Gateway**

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Linux EC2 instance needs a persistent disk for OS and database | **EBS gp3** (default) or **io2** (high IOPS requirement) |
| Highest possible IOPS for an I/O-intensive database | **EBS io2 Block Express** (up to 256,000 IOPS) |
| Large sequential throughput for big data / log processing | **EBS st1** (Throughput Optimized HDD) |
| Lowest cost block storage for cold/infrequent data | **EBS sc1** (Cold HDD) |
| Temporary scratch space with maximum I/O, data loss acceptable | **EC2 Instance Store** |
| Shared file storage for multiple Linux EC2 instances | **Amazon EFS** |
| Shared file storage for Windows instances with Active Directory | **Amazon FSx for Windows File Server** |
| HPC / ML compute with high throughput and S3-integrated dataset | **Amazon FSx for Lustre** |
| On-premises file share backed by S3 (NFS/SMB to cloud) | **AWS Storage Gateway — File Gateway** |
| On-premises iSCSI block volumes with async cloud backup | **AWS Storage Gateway — Volume Gateway (Stored)** |
| Move primary dataset to S3, keep hot data locally via iSCSI | **AWS Storage Gateway — Volume Gateway (Cached)** |
| Replace physical tape library with cloud-backed virtual tapes | **AWS Storage Gateway — Tape Gateway** |
| Automate EBS snapshot creation, retention, and deletion | **Amazon DLM** |
| Copy EBS volume to a different AZ | Snapshot → create new volume in target AZ |
| Copy EBS volume to a different region | Snapshot → copy snapshot to target region → create volume |
| Encrypt an existing unencrypted EBS volume | Snapshot → copy with encryption enabled → restore as new encrypted volume |
| Shared volume across multiple EC2 instances (same AZ) | **EBS Multi-Attach** (io1/io2 only, up to 16 Nitro instances) |
| High-performance striped RAID for EBS | **RAID 0** across multiple EBS volumes |

---

## HOL Notes — EBS Volume Operations

> 🛠️ **Implementation Notes:**
> <br>`sudo lsblk -e7` — list block devices, excluding loop devices
> <br>`sudo mkfs -t ext4 /dev/xvdf` — format new EBS volume with ext4
> <br>`sudo mkdir /data && sudo mount /dev/xvdf /data` — create mount point and mount
> <br>To persist across reboots: add `/dev/xvdf /data ext4 defaults,nofail 0 2` to `/etc/fstab`
> <br>Root device appears as `/dev/sda1` or `/dev/xvda` §
> <br>**Remember:** deregister AMI and delete associated snapshots when cleaning up to avoid storage charges ¤

---

# Module Summary
---

## Key Topics
  - Storage type fundamentals: block vs. file vs. object — characteristics, protocols, AWS services
  - Amazon EBS: volume types (gp3, gp2, io2 Block Express, io2/io1, st1, sc1), AZ-binding, Elastic Volumes
  - EBS vs. Instance Store: persistence, performance, use cases
  - EBS snapshots: incremental, region-specific, encryption rules, cross-account sharing
  - Amazon DLM: automated snapshot and AMI lifecycle management
  - EBS encryption: AES-256, KMS, encryption propagation, changing encryption state
  - RAID on EBS: RAID 0 (performance), RAID 1 (durability); RAID 5/6/10 not recommended
  - Amazon EFS: NFS, Linux-only, multi-AZ, storage classes (Standard, IA, Archive), performance modes, throughput modes
  - EFS encryption: at-rest (creation-time only), in-transit (TLS at mount)
  - Amazon FSx for Windows File Server: SMB, NTFS, AD integration, Single-AZ vs. Multi-AZ
  - Amazon FSx for Lustre: HPC/ML, POSIX, S3 integration, scratch vs. persistent
  - AWS Storage Gateway: File Gateway (NFS/SMB → S3), Volume Gateway Cached/Stored (iSCSI), Tape Gateway (VTL)

---

## Critical Acronyms
  - **EBS** — Elastic Block Store
  - **EFS** — Elastic File System
  - **FSx** — Amazon FSx (managed third-party file systems)
  - **DLM** — Data Lifecycle Manager
  - **NFS** — Network File System
  - **SMB** — Server Message Block
  - **NAS** — Network Attached Storage
  - **RAID** — Redundant Array of Independent Disks
  - **NTFS** — New Technology File System
  - **POSIX** — Portable Operating System Interface
  - **HPC** — High-Performance Computing
  - **ML** — Machine Learning
  - **EDA** — Electronic Design Automation
  - **iSCSI** — Internet Small Computer Systems Interface
  - **VTL** — Virtual Tape Library
  - **AES** — Advanced Encryption Standard
  - **CMK** — Customer Managed Key
  - **KMS** — Key Management Service
  - **AFR** — Annual Failure Rate
  - **IOPS** — Input/Output Operations Per Second
  - **TLS** — Transport Layer Security
  - **DFS** — Distributed File System
  - **AMI** — Amazon Machine Image
  - **SSD** — Solid-State Drive
  - **HDD** — Hard Disk Drive
  - **NVMe** — Non-Volatile Memory Express
  - **RPO** — Recovery Point Objective
  - **RTO** — Recovery Time Objective
  - **AD** — Active Directory
  - **ACL** — Access Control List

---

## Key Comparisons
  - Block vs. File vs. Object Storage (table)
  - EBS Volume Types — Quick Reference (all 6 types)
  - EBS vs. EC2 Instance Store
  - EBS Snapshot Encryption Rules (table)
  - EFS Storage Classes: Standard vs. IA vs. Archive
  - EFS Performance Modes vs. Throughput Modes
  - EFS vs. EBS (availability, access, latency, throughput)
  - FSx for Windows File Server vs. FSx for Lustre
  - Storage Gateway types: File, Volume (Cached/Stored), Tape

---

## Top Exam Triggers
  - `Shared Linux file storage, multiple EC2 instances` → **Amazon EFS**
  - `Shared Windows file storage, Active Directory` → **FSx for Windows File Server**
  - `HPC / ML workload, S3-integrated dataset` → **FSx for Lustre**
  - `Highest IOPS on EBS` → **io2 Block Express** (256,000 IOPS)
  - `Cost-optimized general purpose volume` → **gp3**
  - `Large sequential I/O, big data, logs` → **st1**
  - `Cheapest EBS, cold/infrequent data` → **sc1**
  - `HDD as boot volume` → **Not possible** — only SSD volumes can boot
  - `Maximum I/O, data loss acceptable, replicated workload` → **Instance Store**
  - `Data must survive instance stop` → **EBS** (Instance Store loses data on stop)
  - `Encrypt existing unencrypted EBS volume` → **Snapshot → copy with encryption → restore**
  - `Encrypted snapshot → share with another account` → **Custom CMK** + cross-account KMS permissions
  - `Automate snapshot retention and deletion` → **Amazon DLM**
  - `Attach one volume to multiple instances` → **EBS Multi-Attach** (io1/io2, same AZ, Nitro only)
  - `On-premises NFS/SMB file share backed by S3` → **Storage Gateway File Gateway**
  - `Replace physical tape library` → **Storage Gateway Tape Gateway**
  - `On-premises iSCSI, full data local, async backup` → **Volume Gateway (Stored Volumes)**
  - `On-premises iSCSI, primary data in S3, local cache` → **Volume Gateway (Cached Volumes)**
  - `EFS encryption at rest` → must enable at **file system creation time**
  - `EFS needs consistent throughput regardless of size` → **Provisioned Throughput mode**

---

## Quick References

### [File Storage Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619114#overview)

### [File Storage Architecture Patterns Private Link](https://drive.google.com/drive/folders/1T78ij9pjWlmh2kZRgtejVBsTtQY661cO?usp=drive_link)

### [File Storage Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346108#overview)

### [EBS Architecture Patterns Private Link](https://drive.google.com/drive/folders/1J6FITA8_V37u2TgPCuhcQpF77Q2qA7tt?usp=drive_link)

### [EBS Cheat Sheet](https://digitalcloud.training/amazon-ebs/)

### [EFS Cheat Sheet](https://digitalcloud.training/amazon-efs/)

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
