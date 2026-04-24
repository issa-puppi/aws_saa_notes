## Types of Storage

### Block Storage
  - Data is stored in **fixed-size blocks**
  - Each block has a **unique identifier**
  - **Used for:** 
    - databases
    - virtual machines
    - applications that require low-latency access to data
  - **Examples:**
    - Amazon EBS
    - Amazon EC2 instance store
  - HDD and SSD are block storage devices
    - The OS sees a **volume** as a single block storage device
    - Volumes consist of multiple blocks
    - The OS reads and writes data to the volume at the block level
    - Volumes can be partitioned and formatted with a file system
    - Disks can be internal or network-attached (e.g., EBS volumes)

### File Storage
  - Mounted as a file system on block storage
    - For remote file storage, the file system is mounted over a network share
  - Data is **hierarchically organized** in **directories and files**
  - **NAS (Network Attached Storage)** Server provides file storage over a network
  - **Used for:**
    - content management
    - media processing
    - home directories
    - shared file storage for applications
  - **Examples:**
    - Amazon EFS (Elastic File System)
      - Amazon NFS (Network File System)
    - Amazon FSx for Windows File Server
    - Amazon FSx for Lustre
  
### Object Storage
  - Objects are stored in a **flat structure** (no hierarchy)
    - Can mimic a directory structure using **prefixes and delimiters**
  - Objects can be files, images, videos, or any unstructured data
    - Each object consists of **data, metadata, and a unique identifier**
  - **HTTP protocol** is used with **REST API**
    - e.g., `GET`, `PUT`, `POST`, `SELECT`, `DELETE`
  - **Used for:**
    - backup and restore
    - archiving
    - big data analytics
    - content distribution
  - **Examples:**
    - Amazon S3 
    - Amazon Glacier

---

## Block vs File vs Object Storage At-a-Glance

| **Feature**       | **Block Storage**           | **File Storage**          | **Object Storage**               |
|-------------------|-----------------------------|---------------------------|----------------------------------|
| **Access Method** | Attached to instance (disk) | Mounted via network file system | API (HTTP/HTTPS & REST)    |
| **Structure**     | Raw blocks (user managed)   | Hierarchical (files/dirs)  | Flat (objects in buckets)       |
| **Performance**   | Low latency, high IOPS      | Moderate latency           | Higher latency                  |
| **Scalability**   | Limited (per volume)        | Scales (system dependent)  | Virtually unlimited             |
| **Cost**          | Provisioned (pay for capacity & IOPS) | Pay for storage (elastic) | Pay for storage + requests + transfer |
| **Sharing**       | Usually single instance     | Multi-instance access      | Global access (permissions)     |
| **Persistence**   | Persistent (if configured)  | Persistent                 | Highly durable                  |
| **Use Cases**     | OS disks, databases         | Shared storage, CMS        | Backups, media, static assets   |
| **AWS Examples**  | EBS, EC2 Instance Store     | EFS (NFS), FSx             | S3, Glacier                     |
| **Key Note**      | Must attach to EC2          | Requires mounting to OS    | Not a file system (no mounting) |

---

## EBS Deployment

- EBS volumes are **attached to EC2 instances** and appear as block devices (disks)
- EBS volumes are deployed in a specific **Availability Zone (AZ)** 
  - EBS volumes can be **detached and reattached** to other instances in the same AZ
  - EBS volumes cannot be attached to instances in different AZs

---

## EBS Multi-Attach

- Allows a single EBS volume to be attached to **multiple EC2 instances** within the same AZ
- Only supported for io1 and io2 volume types to connect to up to 16 Nitro-based EC2 instances

---

## Amazon EBS SSD-Backed Volume Types

| **Feature** | **gp3 <br>(General Purpose SSD)** | **gp2 <br>(General Purpose SSD - Legacy)** | **io2 Block Express** | **io2 / io1 <br>(Provisioned IOPS SSD)** |
|------------|------------------------------|----------------------------------------|----------------------|--------------------------------------|
| **Durability** | 99.8%–99.9%<br>(0.1%–0.2% AFR) | 99.8%–99.9%<br>(0.1%–0.2% AFR) | 99.999%<br>(0.001% AFR) | 99.8%–99.9%<br>(0.1%–0.2% AFR) |
| **Use Cases** | General workloads, low-latency apps, dev/test | Legacy general workloads | Sub-ms latency, ultra-high performance workloads | I/O-intensive DB workloads, sustained high IOPS |
| **Volume Size** | 1 GiB – 64 TiB | 1 GiB – 16 TiB | 4 GiB – 64 TiB | 4 GiB – 16 TiB |
| **Max IOPS** | 80,000 | 16,000 (burst-based) | 256,000 | 64,000 |
| **Max Throughput** | 2,000 MiB/s | 250 MiB/s (size-dependent) | 4,000 MiB/s | 1,000 MiB/s |
| **Performance Model** | Provisioned (independent IOPS & throughput) | Burst model (tied to volume size) | Provisioned, ultra-high performance | Provisioned IOPS |
| **EBS Multi-Attach** | Not supported | Not supported | Supported | Supported (io1/io2 only) |
| **Boot Volume** | Supported | Supported | Supported | Supported |
| **Key Notes** | Best default choice, flexible & cost-efficient | Legacy, largely replaced by gp3 | Highest performance & durability | High performance but less advanced than Block Express |

---

## Amazon EBS HDD-Backed Volume Types

| **Feature** | **st1 <br>(Throughput Optimized HDD)** | **sc1 <br>(Cold HDD)** |
|-------------|----------------------------------------|------------------------|
| **Durability** | 99.8%–99.9%<br>(0.1%–0.2% AFR) | 99.8%–99.9%<br>(0.1%–0.2% AFR) |
| **Use Cases** | Big data, data warehouses, log processing (frequently accessed) | Infrequently accessed data, lowest-cost storage |
| **Volume Size** | 125 GiB – 16 TiB | 125 GiB – 16 TiB |
| **Max IOPS** | 500 | 250 |
| **Max Throughput** | 500 MiB/s | 250 MiB/s |
| **Performance Model** | Throughput optimized (not IOPS-focused) | Throughput optimized (lowest cost tier) |
| **EBS Multi-Attach** | Not supported | Not supported |
| **Boot Volume** | Not supported | Not supported |
| **Key Notes** | Good for large sequential workloads, not low-latency | Cheapest EBS option, for cold data only |

---

## Amazon EBS Key Points

- EBS Volumes are **persistent block storage** that can be attached to EC2 instances
  - EBS Volumes exist independently of EC2 instances and can be detached and reattached
  - EBS Volumes do not need to be attached to an instance to exist, but they must be attached to be used
- You can attach multiple EBS volumes to a single EC2 instance 
- You can attach multiple EC2 instances to a single EBS volume using Multi-Attach (io1/io2 only)
- EBS volumes must be in the same AZ as the EC2 instance they are attached to
- Root EBS volumes are automatically deleted when the EC2 instance is terminated (by default), but you can change this behavior
  - Non-root EBS volumes are not deleted when the EC2 instance is terminated (by default), but you can change this behavior

---

## EBS Copying, Sharing, and Snapshots

- You can create **snapshots** of EBS volumes, which are point-in-time backups stored in Amazon S3
- Snapshots can be used to create new EBS volumes or to restore existing volumes
- You can copy EBS snapshots across regions by: 
  - Copying the snapshot to another region directly
  - Creating an AMI from the snapshot and then copying the AMI to another region
    - Use this method to have the same setup configuration in the new region

---

## [Rules for EBS Copying](https://drive.google.com/drive/folders/1J6FITA8_V37u2TgPCuhcQpF77Q2qA7tt?usp=drive_link)

1. Snapshots are the "control point"
  - You can copy snapshots across regions
  - Change encryption 
  - Be shared with other accounts
2. Copy = "transformation layer", so when you "copy" you can:
  - Change region
  - Change encryption key
  - Change unencrypted → encrypted
3. Encryption rules are asymmetrical:
  - Encrypted → Unencrypted: **Never allowed**
  - Unencrypted → Encrypted: **Allowed** (must specify KMS key)
  - Encrypted → Encrypted: **Allowed** (can specify new KMS key or use same key)
4. Snapshot **∶** Volume **∷** AMI **∶** Instance
  - A **Snapshot** is a point-in-time **data backup** of a volume
  - An **AMI** is a **template** built from one or more snapshots + configuration (used to launch new instances)
  - A **Volume** is **active block storage** attached to an instance
  - An **Instance** is a **running virtual machine** using block storage

---

## Amazon Data Lifecycle Manager (DLM)

  - Automates the creation, retention, and deletion of EBS snapshots and EBS-backed AMIs
  - **DLM helps with the following:**
    - Protects valuable data by automating backups 
    - Creates standardized AMIs that can be refreshed regularly
    - Retain Backups as required by auditors or internal compliance 
    - Reduce storage costs by automatically deleting old backups
    - Can also create disaster recovery policies to back up data

---

## EBS vs Instance Store

| **Feature** | **EBS** | **Instance Store** |
|-------------|---------|--------------------|
| **Storage Type** | Persistent block storage | Ephemeral block storage |
| **Persistence** | Data persists independently of EC2 lifecycle | Data lost when instance stops, terminates, or host fails |
| **Attachment** | Can detach and reattach to other instances | Cannot be detached or reattached |
| **Scope** | Must be in same AZ as EC2 | Tied to the specific host server |
| **Durability** | Replicated within AZ (snapshots stored in S3) | No replication, no backup by default |
| **Storage Location** | Network-attached | Physically attached (local disks) |
| **Performance** | High, but network-bound | Very high, ultra-low latency |
| **Use Cases** | OS disks, databases, long-term data | Cache, buffers, temporary data |
| **Cost Model** | Pay for provisioned storage | Included with instance (no extra cost) |

**Note:** Default behavior for **Instance Store** is to lose data on stop/terminate for the root volume, conversely data volumes default to persist on stop but lose data on terminate. This can be changed by modifying the instance's block device mapping to specify `DeleteOnTermination` for each volume as needed.

---

## HOL Notes - Create and Attach EBS Volume

- `sudo lsblk` lists block devices and their mount points
  - adding `-e7` excludes loop devices (e.g., `/dev/loop0`, `/dev/loop1`, etc.) from the output, showing only actual block devices like EBS volumes
- `sudo mkfs -t ext4 /dev/xvdf` formats the new EBS volume with the ext4 file system
- `sudo mkdir /data` creates a mount point directory for the new volume
- `sudo mount /dev/xvdf /data` mounts the new EBS volume to the `/data` directory
- `sudo nano /etc/fstab` opens the fstab file to add an entry for the new volume, ensuring it mounts automatically on reboot (makes it persistent)
  - Add the line: `/dev/xvdf /data ext4 defaults,nofail 0 2`
    - `defaults` uses default mount options
    - `nofail` allows the system to boot even if the volume is missing
    - `0` means do not dump (backup) this file system
    - `2` means this file system should be checked after root (which is 1)

- Remember to deregister AMI and delete snapshots when cleaning up to avoid unnecessary costs

---

## RAID Implementation with EBS

- **RAID (Redundant Array of Independent Disks):**
  - A data storage technology that combines multiple physical disks into a single logical unit for improved performance, redundancy, or both
  - Must configure RAID at the OS level using multiple EBS volumes attached to the same EC2 instance

### Common RAID levels:
  - **RAID 0 (striping):** 
    - Data is split across multiple disks for improved performance
    - 2 or more disks required
    - No redundancy (if one disk fails, all data is lost)

  - **RAID 1 (mirroring):**
    - Data is duplicated across two disks for redundancy
    - 2 disks required
    - If one disk fails, the other has a complete copy of the data

  - **These next RAID configurations are not recommended for AWS**

  - **RAID 5 (striping with parity):**
    - Data and parity information are striped across three or more disks
    - Provides fault tolerance and improved read performance
    - Not recommended for AWS due to performance issues during rebuilds

  - **RAID 6 (striping with double parity):**
    - Similar to RAID 5 but with two parity blocks for extra fault tolerance
    - Requires at least 4 disks
    - Not recommended for AWS due to performance issues during rebuilds

  - **RAID 10 (striping + mirroring):**
    - Combines RAID 0 and RAID 1 (RAID 1+0)
    - Requires at least 4 disks
    - Provides both redundancy and improved performance
    - Not recommended for AWS due to cost and complexity

---

## RAID Configurations At-a-Glance

| RAID | Description | Performance | Fault Tolerance | Capacity | Use Case |
|------|-------------|-------------|-----------------|----------|----------|
| RAID 0 | Striping | Very high | None ❌ | 100% | Max performance, no durability |
| RAID 1 | Mirroring | Read ↑, Write = | High ✅ | 50% | High durability |
| RAID 5 | Striping + parity | Good | Medium ✅ | ~75% | Balanced storage, rare in AWS |
| RAID 6 | Striping + double parity | Moderate | High (2 failures) ✅ | ~67% | High durability, rare in AWS |
| RAID 10 | Stripe + mirror | Very high | High ✅ | 50% | High perf + durability |

---

## Amazon EFS (Elastic File System)

- Fully managed, scalable file storage service for use with AWS Cloud services and on-premises resources
- **Regional file systems** have mount targets in multiple AZs for high availability and durability
  - Instances connect to a mount target in the same AZ for optimal performance
- **One zone file systems** have a single mount target in one AZ, which can be used for testing or non-critical workloads
  - Is possible to connect to a one zone file system from instances in other AZs
- EFS supports the NFS protocol, allowing multiple EC2 instances to access the same file system concurrently
- Only supports Linux-based EC2 instances (no Windows support)
- User Access is controlled through POSIX permissions and AWS Identity and Access Management (IAM) policies

### Key Features of Amazon EFS:
  - **Data consistency:** write operations for regional file systems are durably stored across multiple AZs
  - **File locking:** NFS client applications can use NFS v4 file locking for read/write access control
  - **Storage classes:** there are 3 options:
    - **EFS Standard:** uses SSDs for low latency performance
    - **EFS Infrequent Access (IA):** lower cost for infrequently accessed files, but with higher latency
    - **EFS Archive:** lowest cost for rarely accessed files (archival)
  - **Durability:** all storage classes offer 11 9s of durability
  - **EFS Replication:** data is replicated across regions for disaster recovery (RPO/RTO of minutes)
  - **Automatic Backups:** EFS integrates with AWS Backup for scheduled backups
  - **Performance Options:** 
    - **Provisioned Throughput:** allows you to specify a throughput level independent of storage size
    - **Bursting Throughput:** throughput scales with the amount of data stored (default)

---

## Amazon FSx 

- Fully managed file storage service for third-party file systems
- **Amazon FSx for Windows File Server:** 
  - Provides a fully managed native Microsoft Windows file system 
  - Full support for SMB protocol, Windows NTFS and Active Directory integration
    - **SMB (Server Message Block)** is a network file sharing protocol used by Windows for file and printer sharing
      - How Windows clients access FSx for Windows File Server file systems
    - **NTFS (New Technology File System)** is the file system used by Windows operating systems
  - Supports Windows-native file system features:
    - Access Control Lists (ACLs)
    - Shadow copies for point-in-time recovery
    - User quotas for storage management
    - NTFS file systems that can be accessed using SMB protocol 
      - Can connect from Windows, Linux, and macOS clients
      - Supports thousands of concurrent connections
  - **Single-AZ:** replicates data within one AZ (redundant components)
  - **Multi-AZ:** file systems include an active and standby file server in separate AZs for automatic failover 

- **Amazon FSx for Lustre:** 
  - High-performance file system optimized for compute-intensive workloads such as:
    - Machine learning
    - High-performance computing (HPC)
    - Video processing
    - Financial modeling
    - Electronic design automation (EDA)
  - Works natively with Amazon S3, for access to S3 objects as files in the Lustre file system
  - Your S3 objects are presented as files in the Lustre file system
    - Linked file system enables read and write access to S3 objects
    - Not a feature of FSx for Windows File Server 
  - Provides a **POSIX-compliant (LINUX) file system** 

---

## Storage Gateway

[![Storage Gateway]](../assets/AWS-console/aws-storage-gateway-diagram.png)

- File system is mounted via NFS or SMB protocol to on-premises servers, applications, or users
- Local cache provides low-latency access to recently accessed data, while the full dataset is stored in AWS
- A virtual gateway appliance runs on premises and connects to AWS Storage Gateway service

- **File Gateway** is a type of Storage Gateway that provides file-based access to objects in Amazon S3
  - Supports NFS and SMB protocols for file access
  - Files are stored as objects in Amazon S3, with metadata stored in AWS Storage Gateway
  - Provides a local cache for recently accessed data to improve performance

- **Volume Gateway** is a type of Storage Gateway that provides block-based access to data in Amazon S3
  - Supports iSCSI protocol for block storage access 
  - Volumes are stored as Amazon EBS snapshots in Amazon S3, with metadata stored in AWS Storage Gateway
  - Provides a local cache for recently accessed data to improve performance
  - **Two main types of modes for Volume Gateway:**
    - **Cached Volumes:** primary data is stored in Amazon S3, with a local cache for frequently accessed data
    - **Stored Volumes:** primary data is stored on-premises, with asynchronous backups to Amazon S3

- **Tape Gateway** is a type of Storage Gateway that provides **virtual tape library (VTL)** functionality for backup and archival workloads
  - Supports iSCSI protocol for block storage access 
  - Virtual tapes are stored as Amazon S3 objects, with metadata stored in AWS Storage Gateway
  - Provides a local cache for recently accessed data to improve performance

---

## Quick References

### [File Storage Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619114#overview)

### [File Storage Architecture Patterns Private Link](https://drive.google.com/drive/folders/1T78ij9pjWlmh2kZRgtejVBsTtQY661cO?usp=drive_link)

### [File Storage Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346108#overview)

### [EBS Cheat Sheet](https://digitalcloud.training/amazon-ebs/)
### [EFS Cheat Sheet](https://digitalcloud.training/amazon-efs/)

---
