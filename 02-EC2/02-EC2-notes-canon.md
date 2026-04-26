# Compute
---

## Amazon Elastic Compute Cloud (EC2)

Amazon EC2 provides **resizable virtual servers** running in AWS data centers. 
<br>Each virtual server is called an **instance**, and you have full control at the operating system layer (root/admin access).

### Key Properties
  - EC2 instances run **Linux, Windows, or macOS** ※ (macOS on dedicated hardware)
  - Instances connect to the network via an **Elastic Network Interface (ENI)**
  - Instances are launched inside a **Virtual Private Cloud (VPC)**, in either:
    - **Public subnets** — have a route to the internet via an **Internet Gateway (IGW)**
    - **Private subnets** — no direct internet route; reach the internet via a **NAT Gateway** in a public subnet
  - **Amazon Elastic Block Store (EBS)** provides persistent block storage for instances
  - Instances are **flexible** — can be resized, stopped, started, hibernated, rebooted, or terminated

### Customer Responsibility (Shared Responsibility)
The customer manages everything **inside the instance**:
  - Operating system and patching
  - Installed software and runtimes
  - Application configuration
  - Security configuration (e.g., firewall rules inside the OS, in addition to security groups)

AWS manages everything **below the instance**:
  - Physical host hardware
  - Hypervisor
  - Networking infrastructure
  - Power and physical security

### Pricing Notes
  - Cost depends on instance type ¤, runtime, attached storage, and data transfer
  - **Inbound** data transfer is free §
  - **Outbound** data transfer is charged ¤
  - Data transfer **between instances in the same AZ** via private IP is free
  - Data transfer **between AZs** or **between regions** incurs charges ¤

> 💡 **Exam Tip:** Stopping and starting an EC2 instance generally moves it to a **different underlying physical host**. <br>Use this if status checks fail or planned host maintenance is announced.

---

## EC2 Instance Types & Families

Different instance families are optimized for different workloads. 
<br>Larger sizes provide proportionally more hardware capability.

| **Category** | **Purpose** | **Example Families** ‡ Δ |
|--------------|-------------|----------------------------|
| **General Purpose** | Balanced compute, memory, networking | `t`, `m`, `mac` |
| **Compute Optimized** | High CPU performance | `c` |
| **Memory Optimized** | High memory performance | `r`, `x`, `z` |
| **Storage Optimized** | High disk throughput / IOPS | `i`, `d`, `h` |
| **Accelerated Computing** | GPU, FPGA, custom accelerators | `p`, `g`, `inf`, `trn`, `f` |

### Naming Convention — `m5.large`
  - `m` = family (general purpose)
  - `5` = generation number
  - `large` = size

> ⚠️ **Exam Trap:** `m` stands for **general purpose**, not memory-optimized. Memory-optimized starts with `r` or `x`.

### Burstable Instances (T-family)
  - T-family instances (`t2`, `t3`, `t4g`) provide **baseline CPU performance** with the ability to **burst above baseline** using accumulated CPU credits
  - **T2/T3 Unlimited** ¤ — can burst beyond credit balance for an additional charge

> 🔧 **Pro Tip:** AWS releases new instance generations frequently. 
<br>Always select the latest generation that meets your needs — they're typically faster *and* cheaper per unit performance than predecessors.

---

## [Current Instance Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) 

Instance types change frequently as AWS releases new generations and deprecates older ones. Always refer to the official documentation for the most up-to-date information on available instance types and their specifications.

---

## EC2 Instance Lifecycle

### [Lifecycle States](https://drive.google.com/file/d/19YNMOOoC6z_GHbI1An7X5gQpWqvEr-Im/view?usp=drive_link)

<!--![EC2 Lifecycle Diagram](../assets/2-EC2/ec2-lifecycle.png)-->

  - **Pending** — instance is being launched
  - **Running** — instance is active and accessible
  - **Rebooting** — instance is restarting
  - **Stopping** — instance is being stopped
  - **Stopped** — instance is stopped, can be restarted
  - **Shutting-down** — instance is being terminated
  - **Terminated** — instance is permanently deleted, cannot be restarted

### Stopping EC2 Instances
  - **EBS-backed instances only** — instance store-backed instances cannot be stopped, only terminated
  - **No charge** for stopped instances ¤ (EBS volumes still incur storage charges)
  - **EBS volumes remain attached**
  - **Data in RAM is lost**
  - **Public IPv4** address is released § (unless using an Elastic IP)
  - **Private IPv4 and IPv6** addresses are retained
  - Instance is migrated to a different underlying host on next start

### Hibernating EC2 Instances
  - Saves the contents of RAM to the **EBS root volume**
  - Must be enabled at launch time — cannot enable later §
  - Supported only on certain instance types and AMIs ※
  - On resume:
    - Root volume is restored
    - RAM contents are reloaded
    - Previously running processes resume
    - Instance retains its instance ID
  - Storage charges apply ¤ for the EBS space used to save RAM

### Rebooting EC2 Instances
  - Equivalent to an OS reboot
  - **DNS name and all IPv4/IPv6 addresses retained**
  - **No billing impact**
  - Best practice: reboot via EC2 console/API rather than OS reboot — AWS-initiated reboots use the same underlying mechanism

### Retiring EC2 Instances
  - AWS may retire an instance if the underlying hardware fails irreparably
  - AWS notifies customers in advance
  - On the retirement date, AWS will stop or terminate the instance
  - Customer can stop, start, or migrate proactively

### Terminating EC2 Instances
  - **Permanent deletion** — cannot be recovered
  - **Root EBS volumes are deleted by default** §
  - Other attached volumes follow their `Delete on Termination` flag
  - **Termination protection** can be enabled to prevent accidental termination

### Recovering EC2 Instances
  - **CloudWatch alarms** can trigger auto-recovery if a system status check fails
  - **Auto-recovery** Δ is now built into most modern instance types — recovered instance is identical to the original (same instance ID, IPs, metadata)
  - Applies when the instance becomes impaired due to **AWS-side hardware/platform issues**

> 💡 **Exam Tips:** 
<br>**Reboot** preserves IPs and DNS — billing unaffected. 
<br>**Stop/Start** moves to a new host and releases the public IPv4 (unless EIP). 
<br>**Terminate** is permanent — root volume deleted by default.

---

## AWS Nitro System

The **Nitro System** is the underlying platform for modern EC2 instances. 
<br>It offloads virtualization functions from software to dedicated hardware.

### Key Properties
  - Provides **performance close to bare metal** for virtualized instances
  - **Specialized hardware** components include:
    - Nitro cards for VPC, EBS, and instance storage
    - Nitro card controller
    - Nitro security chip
    - Nitro hypervisor
  - Enables features like **ENA**, **EFA**, **Nitro Enclaves**, larger network bandwidth (up to 100+ Gbps ‡), and dense storage instances
  - Supports many **virtualized and bare metal** instance types
  - Most current-generation instance families run on Nitro Δ

> 💡 **Exam Tip:** "Need close-to-bare-metal performance, EFA, or high-performance networking" → **Choose a Nitro-based instance type.**

---

## Nitro Enclaves

**Nitro Enclaves** provide **isolated compute environments** for highly sensitive workloads.

### Key Properties
  - Run on **isolated and hardened virtual machines** carved out from the parent EC2 instance
  - **No persistent storage**, no interactive access, no external networking
  - Use **cryptographic attestation** to ensure only authorized code runs
  - Integrate with **AWS KMS** for secure key management

### Use Cases
  - Personally identifiable information (PII)
  - Healthcare data
  - Financial transactions
  - Intellectual property data

> 💡 **Exam Tip:** "Process highly sensitive data on EC2 with hardware-level isolation" → **Nitro Enclaves**.

---

## Status Checks

EC2 instances have **two automatic status checks**, run every minute. 
<br>Each returns pass or fail; overall instance status is **OK** if all pass, **impaired** otherwise.

### System Status Check
  - **AWS-managed issues** — `StatusCheckFailed_System`
  - Indicates problems requiring **AWS** to repair:
    - Loss of network connectivity
    - Loss of system power
    - Software/hardware issues on the physical host

### Instance Status Check
  - **Customer-managed issues** — `StatusCheckFailed_Instance`
  - Indicates problems requiring **your** action:
    - Failed boot configuration
    - Exhausted memory
    - Corrupted file system
    - Incompatible kernel

### Status Check Actions
CloudWatch alarms can trigger automatic actions on failure:
  - **Recover** the instance (system check failures only)
  - **Stop** the instance (EBS-backed only)
  - **Terminate** the instance (blocked if termination protection enabled)
  - **Reboot** the instance

  - Status checks **cannot be disabled or deleted** — they're built in
  - You can create or remove the **alarms** triggered by status checks

> 💡 **Exam Tip:** "Auto-recover instance if AWS hardware fails" → **CloudWatch alarm on `StatusCheckFailed_System` with the `Recover` action**.

---

## Monitoring

EC2 instances are monitored through **Amazon CloudWatch** for:
  - CPU utilization
  - Disk I/O
  - Network traffic
  - Status check failures
  - Custom application metrics (via CloudWatch Agent)

### Monitoring Frequency ¤
  - **Basic (default §)** — 5-minute periods, no extra charge
  - **Detailed** — 1-minute periods, chargeable per metric per instance

### CloudWatch Agent
  - Collects **in-guest** OS-level metrics (memory, disk usage, processes) that aren't visible to AWS
  - Collects **logs** from instances
  - Works on EC2 and on-premises servers
  - Can be installed manually or deployed via AWS Systems Manager

> 📚 **Learn More:** This is a quick EC2-side reference.
>
> - **Module 13 — Monitoring, Logging & Auditing** — full CloudWatch coverage including metrics, logs, dashboards, and alarms
>
> CloudWatch alarms tied to EC2 status checks are the standard auto-recovery pattern — covered in depth in Module 13.

---

# Storage
---

## Amazon Elastic Block Store (EBS)

EBS volumes are **persistent block storage** that appears as local drives on the instance — but is actually **network-attached** behind the scenes.

### Key Properties
  - Volumes exist within a **single Availability Zone** §
  - **Automatically replicated** within that AZ for durability
  - Can be **detached and reattached** to other instances in the same AZ
  - **Persist independently** of the instance unless explicitly deleted
  - Snapshots can be taken and stored in **Amazon S3** (covered in Module 6)
  - Can be **encrypted at rest** using AWS KMS §

### Pricing
  - Charged based on **provisioned size, type, and IOPS/throughput** ¤
  - You pay for what you provision, not what you use § (with the exception of `gp3` which separates IOPS/throughput from size)

> ⚠️ **Exam Trap:** EBS volumes are **bound to a single AZ**. To move data to another AZ: 
<br>Take a snapshot → copy to that AZ → create a new volume from the snapshot

---

## EBS Volume Types

| **Volume Type** | **Use Case** | **Min/Max Size** † | **Max IOPS / Volume** ‡ | **Max Throughput** ‡ | **Multi-Attach** ※ |
|-----------------|--------------|--------------------|----------------------|---------------------|---------------------|
| **gp3 (General Purpose SSD)** | Most workloads, dev/test, boot volumes | 1 GiB – 16 TiB | 16,000 | 1,000 MiB/s | No |
| **gp2 (General Purpose SSD)** | Boot volumes, low-latency apps (legacy) | 1 GiB – 16 TiB | 16,000 | 250 MiB/s | No |
| **io2 (Provisioned IOPS SSD)** | High-performance / critical databases | 4 GiB – 16 TiB | 256,000 | 4,000 MiB/s | Yes |
| **io1 (Provisioned IOPS SSD)** | High-IOPS databases (older gen) | 4 GiB – 16 TiB | 64,000 | 1,000 MiB/s | Yes |
| **st1 (Throughput Optimized HDD)** | Big data, log processing, streaming | 125 GiB – 16 TiB | 500 | 500 MiB/s | No |
| **sc1 (Cold HDD)** | Archival, infrequent access | 125 GiB – 16 TiB | 250 | 250 MiB/s | No |
| **Magnetic (legacy)** | Legacy workloads only | 1 GiB – 1 TiB | 40–200 | 90 MiB/s | No |

### Boot Volume Eligibility
  - **gp3 / gp2 / io2 / io1 / Magnetic** — can be boot volumes
  - **st1 / sc1** — **cannot** be boot volumes

### Multi-Attach
  - Only **io1 / io2** support EBS Multi-Attach (single volume attached to multiple Nitro instances in the same AZ)
  - Useful for clustered/HA workloads with shared storage

> 💡 **Exam Tips:** 
<br>**gp3** is the default recommendation for most workloads — better price/performance than gp2. 
<br>**io2/io1** for sustained IOPS over 16,000 or low-latency-critical databases. 
<br>**st1** for big data / log processing (sequential workloads). 
<br>**sc1** for archival / cold storage on EBS. 
<br>Only **io1/io2** support Multi-Attach.

---

## EBS vs Instance Store

| **Aspect** | **EBS Volume** | **Instance Store** |
|------------|----------------|---------------------|
| **Storage type** | Network-attached block storage | Physically attached to host server |
| **Persistence** | Persistent — survives instance stop/terminate | Ephemeral — data lost on stop/terminate/host failure |
| **Performance** | Good, network-bound | Very high, local SSD/NVMe |
| **Stopping the instance?** | Allowed (data preserved) | Not supported — instance store-backed instances can only be terminated |
| **Replication** | Replicated within AZ | Not replicated — single-host-only |
| **Snapshots** | Yes, to S3 | No |
| **Use case** | Most workloads, root volumes | High-IOPS scratch space, caches, buffers |

---

## Instance Store (Ephemeral Storage)

Instance store volumes are **temporary storage physically attached to the host server**.

### Key Properties
  - **Non-persistent** — data lost when the instance:
    - Stops (note: instance store-backed instances can't be stopped)
    - Terminates
    - Underlying host fails
  - **Reboot does NOT lose data** — only stop/terminate/host failure
  - Provides **very high I/O performance** ‡ — ideal for low-latency workloads
  - Size and availability depend on the instance type

### Use Cases
  - Buffers and caches
  - Scratch / temporary data
  - Distributed file systems where redundancy is at the application layer

> ⚠️ **Exam Traps:** 
<br>Instance store data **survives reboot** but is lost on **stop, terminate, or host failure**. 
<br>EBS-backed instances can be stopped without data loss.

---

# Networking
---

## Elastic Network Interfaces (ENIs)

An **ENI** is a virtual network card that attaches an EC2 instance to a VPC subnet.

### Key Properties
  - Every instance gets a **primary ENI (`eth0`)** by default §
  - Cannot be moved or detached from the primary
  - **Secondary ENIs** can be added/removed
  - ENI is bound to **a single AZ** — cannot move across AZs
  - Can have:
    - One **primary private IPv4** address
    - **Secondary private IPv4** addresses
    - One **public IPv4** address (auto-assigned in public subnets §)
    - One **Elastic IP** per private IPv4
    - One or more **IPv6** addresses ※
    - One or more **security groups** (max 5 † per ENI)
    - A **MAC address**
    - A **source/destination check flag**

### Attachment Modes
  - **Hot attach** — to a running instance
  - **Warm attach** — to a stopped instance
  - **Cold attach** — at launch

> ⚠️ **Exam Trap:** If you attach a **second ENI**, AWS will not auto-assign a public IPv4 to the primary — you'd need to use an **Elastic IP** for stable public access.

  - Adding multiple ENIs **does not increase aggregate network bandwidth** — bandwidth is per-instance, not per-ENI

---

## ENI vs ENA vs EFA

| **Adapter** | **Purpose** | **Performance** | **Instance Compatibility** |
|-------------|-------------|-----------------|----------------------------|
| **ENI (Elastic Network Interface)** | Standard virtual NIC | Baseline | All instance types |
| **ENA (Elastic Network Adapter)** | **Enhanced networking** — higher bandwidth, lower latency, higher PPS | Up to 100+ Gbps ‡ | Supported instance types only |
| **EFA (Elastic Fabric Adapter)** | **HPC / ML / MPI** workloads — OS bypass for low-latency inter-node communication | Application-level highest | Supported instance types only |

  - **MPI (Message Passing Interface)** — standardized way for processes to communicate in parallel/distributed systems
  - **NCCL (NVIDIA Collective Communications Library)** — GPU collective communications used in distributed ML

> 💡 **Exam Tips:** 
<br>"High-performance computing, MPI, ML cluster training" → **EFA**. 
<br>"Higher bandwidth and lower latency than standard" → **ENA**. 
<br>"Standard networking for any instance" → **ENI**.

---

## IP Addressing

| **Type** | **Behavior** | **Cost** ¤ |
|----------|--------------|-------------|
| **Public IPv4** | Dynamic; **released when instance stops**; auto-assigned in public subnets § | Charged when assigned to running instance Δ |
| **Private IPv4** | Static within the VPC; retained across stop/start; used for internal traffic | Free |
| **Elastic IP (EIP)** | **Static public IPv4**; can be remapped between instances/ENIs in same region | Charged when **allocated but not attached** to a running instance |
| **IPv6** ※ | Globally routable when enabled on the VPC; retained across stop/start | Free for the address itself; data transfer charges apply |

  - You can associate **one Elastic IP per private IPv4** (and vice versa)
  - All addresses **remain attached to the ENI** when it's detached or moved
  - **BYOIP** ※ — you can bring your own publicly routable IPv4/IPv6 ranges to AWS

### Stop/Start vs Reboot — IP Behavior

  - **Reboot** — all IPs retained (public IPv4, private, IPv6)
  - **Stop/Start** — public IPv4 **released**; private IPv4 / IPv6 retained
  - **Stop/Start with EIP** — EIP retained
  - **Terminate** — all IPs released; EIP returned to your account pool but stays allocated (and chargeable)

> 💡 **Exam Tips:** 
<br>"Need a stable public IP across stops/starts" → **Elastic IP**. 
<br>"EIP allocated but not attached" → **You're being charged**. 
<br>"Single instance with static public IP that must remap on failure" → **EIP + remap to failover instance**.

---

## NAT Gateways and NAT Instances

Both let instances in **private subnets** initiate **outbound** internet traffic without being directly internet-reachable.

### NAT Gateway (Recommended)
  - **Created in a public subnet**, with an Elastic IP attached
  - **NAT Gateway ID** must be in the **route table of the private subnet**
  - **Fully managed by AWS** — high availability within an AZ
  - **Elastic scalability up to 45 Gbps** ‡
  - **No security groups** (instances behind it use their own SGs)
  - **No SSH access**, no port forwarding, no inbound connections

### NAT Instance (Legacy)
  - **EC2 instance** pre-configured to perform NAT — uses the `amzn-ami-vpc-nat` AMI from the AWS Marketplace
  - **Must disable source/destination checks** on the instance
  - Less scalable, less available — failover requires scripts or auto-scaling
  - **Requires manual management** — patching, monitoring, OS-level upkeep
  - Can support **port forwarding** and **inbound connections**
  - Can double as a **bastion host** if configured properly

### NAT Gateway vs NAT Instance

| **Feature** | **NAT Gateway** | **NAT Instance** |
|-------------|-----------------|--------------------|
| Managed by | AWS | You |
| Scalability | Elastic up to 45 Gbps ‡ | Manual (instance type) |
| HA within AZ | Built-in | Scripted/auto-scaled |
| Multi-AZ HA | Deploy one per AZ | Deploy one per AZ |
| Security Groups | None — uses NACL only | Required |
| SSH access | No | Yes |
| Bastion host capability | No | Yes |
| Port forwarding | No | Yes (manual config) |
| Pricing ¤ | Per-hour + per-GB processed | EC2 instance price |

> 💡 **Exam Tip:** "Need redundant outbound internet path for instances in private subnets across multiple AZs" → **Deploy a NAT Gateway in each AZ and update each AZ's route table**.

> 🛠️ **Implementation Notes — Setting up a NAT Gateway:** 
<br>1. Create a NAT Gateway in the public subnet (allocate an EIP). 
<br>2. In the **private subnet's route table**, add a route: `0.0.0.0/0` → `<NAT Gateway ID>`. 
<br>3. Test from the private instance with `ping google.com` (kill with `Ctrl+C`). 
<br>NAT Gateway is **billed per hour and per GB processed** ¤ — delete when done.

---

## Bastion / Jump Hosts

A **bastion host** (or jump box) is an EC2 instance in a **public subnet** used to securely SSH/RDP into instances in **private subnets**.

### Key Properties
  - Acts as a **gateway** — provides controlled access without exposing private instances to the internet
  - Use **security groups** to restrict source IPs/CIDRs that can reach the bastion
  - Use **auto-scaling group (size 1)** for HA — replaces a failed bastion automatically
  - Best practice: deploy in **two AZs** with EIPs and auto-scaling
  - Alternative: **AWS Systems Manager Session Manager** Δ — agent-based, no inbound ports, no bastion needed, fully audited via CloudTrail

> 🔧 **Pro Tip:** Modern AWS deployments often replace bastion hosts entirely with **Systems Manager Session Manager**. It removes the need for inbound SSH/RDP, eliminates the bastion as an attack surface, and provides full session logging — increasingly the SAP-recommended pattern.

> 🛠️ **Implementation Notes — Connecting via Bastion:** 
<br>`ssh -i <key.pem> ec2-user@<bastion-public-ip>` to reach the bastion. 
<br>From the bastion, `ssh -i <key.pem> ec2-user@<private-instance-private-ip>` to reach the private instance. 
<br>Use SSH agent forwarding (`-A`) or copy the key to the bastion (less secure).

---

## EC2 Placement Groups

Placement groups control how EC2 instances are physically placed relative to each other to optimize for **performance, isolation, or both**.

### [Cluster Placement Group](https://drive.google.com/file/d/13pclSgdSyeQuh7A1lfk4lBaor05_JJSX/view?usp=drive_link)
<!--![Cluster Diagram](../assets/2-EC2/cluster-placement-group.png)-->

  - Packs instances **close together within a single AZ**
  - Provides **low-latency, high-throughput** networking between instances
  - Ideal for **tightly coupled, HPC, big data** workloads
  - Pairs well with **EFA**

### [Partition Placement Group](https://drive.google.com/file/d/11Az7_CfuMm99vqNDVFN7YCfIDdr5TsA2/view?usp=drive_link)
<!--![Partition Diagram](../assets/2-EC2/partition-placement-group.png)-->

  - Spreads instances across **logical partitions**, each on separate racks (separate hardware, network, power)
  - **No two partitions share underlying hardware**
  - Up to **7 † partitions per AZ**
  - Can span **multiple AZs**
  - Ideal for **large distributed and replicated** workloads — Hadoop, Cassandra, HBase, Kafka, HDFS

### [Spread Placement Group](https://drive.google.com/file/d/1d-CwcIxBAETaNxRJPr-mGWwT-DS318Ip/view?usp=drive_link)
<!--![Spread Diagram](../assets/2-EC2/spread-placement-group.png)-->

  - Strictly places **each instance on distinct underlying hardware**
  - Reduces **correlated failure** risk
  - Limit: **7 † instances per AZ**
  - Ideal for **small numbers of critical instances** that must be isolated from each other

### Placement Group Comparison

| **Strategy** | **Goal** | **Span** | **Best For** |
|--------------|----------|----------|---------------|
| **Cluster** | Low latency, high throughput | Single AZ | HPC, tightly coupled apps |
| **Partition** | Isolate impact of hardware failure | Single or multi-AZ (up to 7 partitions/AZ) | Distributed/replicated big data |
| **Spread** | Minimize correlated failures | Single or multi-AZ (max 7 instances/AZ) | Small critical clusters |

### Placement Group Rules
  - An instance can be in **only one placement group at a time**
  - **Cannot merge** placement groups
  - **Cannot reserve capacity for a placement group** itself (use Capacity Reservations on individual instances)
  - **Dedicated Hosts not supported** in partition placement groups
  - Best practice: keep instance types **homogeneous** within a placement group
  - Best performance is achieved using **private IP addresses** within the group

> 💡 **Exam Tips:** 
<br>"Tightly coupled HPC, low latency required" → **Cluster placement group + EFA**. 
<br>"Distributed NoSQL DB on separate hardware racks" → **Partition placement group**. 
<br>"Small critical fleet, eliminate correlated hardware failure" → **Spread placement group**.

---

# Configuration & Access
---

## Amazon Machine Images (AMIs)

An **AMI** provides the template (OS, software, configuration) used to launch an EC2 instance.

### AMI Components
  - A **template for the root volume** (OS, application server, applications)
  - **Launch permissions** — which AWS accounts can use the AMI
  - **Block device mapping** — volumes attached at launch

### Key Properties
  - AMIs are **regional** — to use an AMI in another region, **copy** it across (via console, CLI, or API)
  - **Snapshot-backed** — AMIs are backed by EBS snapshots stored in S3 §
  - Can be **public, private, or shared** with specific accounts
  - **Custom AMIs** — capture a customized instance into a reusable image (golden image pattern)
  - **AMI deregistration** doesn't delete the underlying snapshots — must clean those up separately

### Volume Types Backing AMIs
  - **EBS-backed** — root volume from an EBS snapshot; can stop/start the instance
  - **Instance store-backed** — root volume from a template in S3; cannot be stopped, only terminated

### Key Pairs
  - Used to securely connect to EC2 instances
  - Consist of a **public key** (stored by AWS) and a **private key file** (kept by you)
  - For **Linux**: SSH using the private key
  - For **Windows**: decrypt the auto-generated administrator password using the private key
  - **Lost private keys cannot be recovered** — you'd need to detach the root volume, mount it on another instance, and reconfigure access

> 💡 **Exam Tip:** "Need to launch identical instances across regions" → **Copy AMI to each region**, then launch from the regional copy.

---

## EC2 User Data

**User data** is a script that runs **automatically when an instance launches for the first time**.

### Key Properties
  - Runs as **root** (Linux) or **Local System** (Windows)
  - Executes **only on first launch** by default §
  - Can be **shell scripts, cloud-init directives, or PowerShell** (Windows)
  - **Limited to 16 KB †** in raw form (before base64 encoding)
  - **Automatically base64-encoded** when supplied via console or AWS CLI
  - **Not encrypted** — never put secrets directly in user data

### Common Uses
  - Install packages, patches
  - Configure services
  - Run initialization / bootstrap scripts
  - Pull from a configuration management system (Chef/Puppet/Ansible)

> 🛠️ **Implementation Notes — User data via CLI:** 
<br>`aws ec2 run-instances --instance-type t3.micro --image-id ami-xxxx --user-data file://user_data.sh` 
<br>The script is uploaded as a file reference; AWS handles base64 encoding.

---

## Instance Metadata Service (IMDS)

The **Instance Metadata Service** provides instance information from inside the running instance.

  - Accessible only **from within the instance** at the **link-local address** `http://169.254.169.254/`
  - Two URL paths:
    - **Metadata**: `http://169.254.169.254/latest/meta-data/`
    - **User data**: `http://169.254.169.254/latest/user-data`
  - **Not encrypted** — data is plaintext

### IMDSv1 vs IMDSv2

| **Aspect** | **IMDSv1** | **IMDSv2** |
|------------|------------|--------------|
| Authentication | None — simple GET request | **Session token** required (PUT then GET) |
| Security | Vulnerable to SSRF attacks | Protected against SSRF and host header attacks |
| Status | Legacy | **Default for new launches** § Δ |

  - IMDSv2 uses a **session token** retrieved with `PUT` then included as a header on subsequent `GET` requests
  - **Default EC2 launch settings** Δ now disable IMDSv1 — IMDSv2 is the recommended secure mode

> ⚠️ **Exam Trap:** Default settings on new launches now **disable IMDSv1**. If application code relies on the older simple `GET` approach, it must be updated for IMDSv2.

> 🛠️ **Implementation Notes — IMDSv1 (legacy, simple):** 
<br>`curl http://169.254.169.254/latest/meta-data/instance-id` 
<br>`curl http://169.254.169.254/latest/meta-data/ami-id` 
<br>`curl http://169.254.169.254/latest/meta-data/local-ipv4` 
<br>`curl http://169.254.169.254/latest/meta-data/public-ipv4` 
<br>End any path with `/` to list available sub-categories.

> 🛠️ **Implementation Notes — IMDSv2 (token-based):** 
<br>**Step 1 — Get a session token:** 
<br>`TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")` 
<br>**Step 2 — Use the token:** 
<br>`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id`

### Practical Use Cases
  - Bootstrap scripts read metadata to self-configure
  - Display instance info on a webpage (combined with user data for HTML generation)
  - Tagging or configuration logic based on environment
  - Discovering peer instances within a placement group or AZ

---

## Access Keys vs IAM Roles for EC2

Applications running on EC2 need credentials to call AWS APIs. There are two ways to provide them:

### Access Keys (Avoid for EC2)
  - **Long-term credentials** for programmatic access
  - Less secure — must be rotated regularly, never committed to code
  - Stored as **plain text** in the AWS console, must be saved at creation §
  - **Saved in `~/.aws/credentials`** if `aws configure` is used — leaving them on disk is a security risk

### IAM Roles (Recommended)
  - **Temporary credentials** auto-rotated by AWS
  - Attached via an **instance profile**
  - **No credentials on disk** — apps call STS via metadata to get fresh creds
  - **Only one IAM role per instance at a time**
  - Can be **attached, modified, or replaced at any time** Δ — used to require launch-time

> 💡 **Exam Tip:** "EC2 instance needs to access an S3 bucket / DynamoDB table / etc." → **IAM role attached via instance profile**, never access keys.

> 🛠️ **Implementation Notes — Access keys (when unavoidable):** 
<br>`aws configure` — prompts for access key, secret key, region, output format. 
<br>`cat ~/.aws/credentials` — shows the keys in plaintext (this is why you must protect/remove this file). 
<br>`aws s3 ls` — list S3 buckets using configured credentials. 
<br>**Deactivate** to disable an access key temporarily; **delete** to remove permanently.

---

## Tags & Resource Groups

### Tags
  - Metadata as **key-value pairs** attached to AWS resources
  - Used for organization, cost allocation, automation, access control
  - **Up to 50 † tags per resource**
  - Can be enforced via **AWS Config rules** or via **SCPs in AWS Organizations**

### Resource Groups
  - **Logical groupings of resources defined by tags**
  - Provide a consolidated view (metrics, alarms, configuration) across tagged resources
  - Useful for managing application stacks that span multiple services

> 💡 **Exam Tip:** "Track costs per project / department / environment" → **Cost allocation tags** + AWS Cost Explorer / Cost Allocation Reports.

---

## Common Ports

  - **Port 22 (SSH)** — Linux remote shell
  - **Port 3389 (RDP)** — Windows remote desktop
  - **Port 80 (HTTP)** — web traffic
  - **Port 443 (HTTPS)** — secure web traffic
  - **Port 25 (SMTP)** — email send
  - **Port 53 (DNS)** — DNS queries
  - **Port 3306 (MySQL/MariaDB)** — relational DB
  - **Port 5432 (PostgreSQL)** — relational DB
  - **Port 1433 (MSSQL)** — relational DB
  - **Port 1521 (Oracle)** — relational DB

These must be allowed in the **security group** for traffic to reach the instance.

---

# Pricing
---

## EC2 Pricing Models

| **Model** | **Commitment** | **Discount vs On-Demand** ¤ | **Best For** |
|-----------|----------------|------------------------------|---------------|
| **On-Demand** | None | 0% | Short-term, unpredictable workloads, dev/test |
| **Reserved Instances (RI)** | 1 or 3 years | Up to ~72% † | Steady-state, predictable workloads, reserved capacity |
| **Savings Plans** | 1 or 3 years (consistent $ commit) | Up to ~72% † | Flexible, multi-service commitment |
| **Spot Instances** | None — can be reclaimed | Up to **90%** † | Fault-tolerant, interruptible, batch, big data, CI/CD |
| **Dedicated Instances** | None or RI | None or RI rate + $2/hr/region † | Compliance/regulatory, no shared hardware |
| **Dedicated Hosts** | On-demand or reservation | Per-host pricing | Server-bound licensing (per-socket, per-core), full host visibility |

### Billing Notes
  - **Per-second billing** (1-min minimum) for Amazon Linux, Windows, RHEL, Ubuntu/Ubuntu Pro
  - **Per-hour billing** for some Linux distros (SUSE, older Ubuntu) ¤
  - **EBS volumes** billed per second (1-min minimum) regardless of OS
  - Instances are billed only when in **running** state — stop or terminate to halt charges

> 💡 **Exam Tips:** 
<br>"Cheapest option for fault-tolerant batch / big data workloads that can withstand interruption" → **Spot Instances**. 
<br>"Steady-state production with predictable usage" → **Reserved Instances or Savings Plans**.

---

## Reserved Instances (RIs)

  - Commit to **1 or 3 years** for significant discount
  - Three payment options: **All Upfront**, **Partial Upfront**, **No Upfront** ¤
  - **Standard RI** — bigger discount, less flexibility
  - **Convertible RI** — smaller discount, can change family/OS/tenancy via `ExchangeReservedInstances` API
  - **Zonal RI** (specific AZ) — provides **capacity reservation** in that AZ
  - **Regional RI** (no AZ specified) — discount applies anywhere in region, no capacity reservation
  - **Billed whether running or not**
  - Can be **sold on the Reserved Instance Marketplace** if no longer needed

### Standard vs Convertible

| **Aspect** | **Standard RI** | **Convertible RI** |
|------------|------------------|---------------------|
| Discount ¤ | Higher (~40–60%) | Lower (~31–54%) |
| Change AZ, instance size, networking | Yes | Yes |
| Change family, OS, tenancy, payment | **No** | **Yes** |
| Marketplace resale | Yes | No (most cases) |
| API to modify | `ModifyReservedInstances` | `ExchangeReservedInstances` |

> ⚠️ **Exam Trap:** RIs are **billed whether running or not** — don't think of them as "pay only when used." 
<br>The discount applies to running matching instances, but the commitment is the commitment.

---

## On-Demand Capacity Reservations

  - **Reserve compute capacity** in a specific AZ without long-term commitment
  - **Any duration** — hours, days, months
  - Mitigates risk of being unable to launch On-Demand capacity (e.g., during DR events, end-of-quarter spikes)
  - **No term commitment**, **no upfront payment** — billed at On-Demand rate while reserved
  - Specify: **AZ, instance type, tenancy, platform/OS, count**
  - Can be **combined** with Savings Plans / RIs to get both capacity guarantee and discount

---

## Capacity Blocks for ML

  - **Reserve large blocks of GPU capacity** in a specific AZ for a specific time window
  - Use cases:
    - ML model training and fine-tuning
    - ML experiments and prototyping
  - Pay only for the reserved time window ¤

---

## AWS Savings Plans

Flexible pricing with a commitment to a **consistent dollar amount per hour** over 1 or 3 years.

| **Plan Type** | **Scope** | **Savings vs On-Demand** ¤ |
|---------------|-----------|------------------------------|
| **Compute Savings Plan** | EC2 + Fargate + Lambda, any region/family/OS/tenancy | Up to ~66% † |
| **EC2 Instance Savings Plan** | Specific instance family in specific region | Up to ~72% † |
| **SageMaker Savings Plan** | Amazon SageMaker AI | Up to ~64% † |

> 💡 **Exam Tip:** **Compute Savings Plans** are typically the more flexible / future-proof choice — coverage extends across EC2, Fargate, and Lambda automatically.

---

## EC2 Spot Instances

  - **Unused EC2 capacity** at up to **90% †** discount
  - **2-minute interruption notice** § when AWS reclaims capacity for On-Demand or Reserved demand
  - Notification surfaced via **instance metadata** and **CloudWatch Events / EventBridge**
  - Instances are **not interrupted by competing bids** Δ — pricing is now based on long-term supply/demand, not bidding
  - Can configure **Spot interruption behavior**: terminate (default §), stop, or hibernate

### Spot Fleet vs EC2 Fleet

| **Type** | **Description** |
|----------|-----------------|
| **Spot Instance** | One or more individual Spot instances |
| **Spot Fleet** | A collection of Spot (and optionally On-Demand) instances launched and maintained to a target capacity |
| **EC2 Fleet** | Single API call that launches a mix of On-Demand, Reserved, and Spot instances across instance types/AZs |

### Best Practices
  - Diversify across **multiple instance types, sizes, and AZs** (each is a separate "Spot pool")
  - Use **Spot for stateless / fault-tolerant** workloads — never for stateful production
  - Combine with **Auto Scaling Groups** that mix Spot and On-Demand for resilience

> 💡 **Exam Tip:** "Compute-intensive cost-sensitive distributed workload, can withstand interruption" → **Spot Instances**.

---

## Dedicated Instances vs Dedicated Hosts

| **Characteristic** | **Dedicated Instance** | **Dedicated Host** |
|---------------------|-------------------------|----------------------|
| Physical isolation from other AWS customers | Yes | Yes |
| Per-instance billing | Yes (subject to $2/region/hr † fee) | — |
| Per-host billing | — | Yes |
| Visibility of sockets, cores, host ID | No | **Yes** |
| Affinity between host and instance | No | **Yes** |
| Targeted instance placement | No | **Yes** |
| Automatic instance placement | Yes | Yes |
| Add capacity via allocation request | No | Yes |
| Useful for per-socket/per-core licensing | No | **Yes** |

  - **Dedicated Hosts** ¤ are more expensive but provide hardware visibility for license compliance (e.g., Oracle, Windows Server BYOL)
  - **Dedicated Instances** are simpler and cheaper but lack host-level visibility
  - Both are isolated from other customers' workloads

### [Dedicated Hosts vs Dedicated Instances](https://drive.google.com/file/d/1GXdeacHzN83KTfu2kZT3vosyTr46tcwj/view?usp=drive_link)
<!--![Dedicated Hosts vs Dedicated Instances Diagram](../assets/2-EC2/dedicated-hosts-vs-dedicated-instances.png)-->  

> 💡 **Exam Tips:** 
<br>"Database with per-socket licensing requirement" → **Dedicated Hosts**. 
<br>"Security-sensitive app, no shared tenancy, per-instance billing OK" → **Dedicated Instances**. 
<br>"Need to guarantee capacity in a specific AZ" → **Capacity Reservation** (or Zonal RI).

---

# In Practice
---

## High Availability for Compute

  - Keep AMIs **up to date** for rapid failover and consistent recovery
  - **Copy AMIs to other regions** for DR staging
  - Prefer **horizontally scalable architectures** — risk spread across many small instances rather than a few big ones
  - **Reserved Instances** are the only way to **guarantee capacity** when needed (Capacity Reservations also work)
  - **Auto Scaling + Elastic Load Balancing** (Module 3) is the standard recovery pattern
  - **Route 53 health checks** can redirect traffic away from failed endpoints
  - For HA bastions: **two AZs, auto-scaling group of 1 per AZ, EIPs**

---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Run a configuration script the first time an instance launches | Add the script to the instance's **user data** |
| Tightly coupled HPC needs low latency between nodes | **Cluster placement group + EFA** in a single AZ |
| LoB application with weekly bursts — most cost-effective | **Reserved/Savings Plans** for baseline + **Spot** for bursts |
| Single instance with static public IP that must remap on failure | Attach an **Elastic IP**, remap on failover |
| EC2 fleet in private subnets across multiple AZs needs redundant outbound internet | **NAT Gateway in each AZ**, update each AZ's route table |
| Engineers must SSH into private-subnet instances from remote locations | **Bastion host in public subnet**, or **SSM Session Manager** Δ (preferred) |
| Eliminate risk of correlated hardware failures across a fleet | **Spread placement group** across distinct underlying hardware |
| Application requires enhanced networking | Choose an instance type that supports **ENA**, ensure ENA module installed and enabled |
| Need close-to-bare-metal performance, EFA, high-perf networking | Use a **Nitro-based** instance type |
| Process highly sensitive data with hardware isolation | **Nitro Enclaves** |
| Server-bound software licensing requires visibility into sockets/cores | **Dedicated Hosts** |
| Stateless distributed workload at lowest cost, can tolerate interruption | **Spot Fleet** with diversification across instance types/AZs |

---

## EC2 Pricing Use Cases

| **Scenario** | **Best Pricing Model** |
|--------------|--------------------------|
| Developer working on small project for several hours, no interruption | **On-Demand** |
| Steady-state, business-critical, continuous demand | **Reserved Instances** (or Compute Savings Plan) |
| Compute-intensive, cost-sensitive, can tolerate interruption | **Spot Instances** |
| Need to guarantee capacity is available in a specific AZ | **On-Demand Capacity Reservation** (or Zonal RI) |
| Database with per-socket licensing | **Dedicated Hosts** |
| Security-sensitive app needs dedicated hardware, per-instance billing | **Dedicated Instances** |
| ML model training requiring large GPU blocks for finite duration | **Capacity Blocks for ML** |
| Mixed workload across EC2, Fargate, Lambda | **Compute Savings Plan** |

---

## Migration into EC2

### AWS Application Migration Service (MGN) Δ
  - **Current AWS-recommended migration service** — replaced AWS Server Migration Service (SMS), which is deprecated Δ
  - Lift-and-shift migration of physical, virtual, and cloud servers to EC2
  - Continuous block-level replication; minimal cutover downtime
  - Supports a wide range of source platforms

### VM Import/Export
  - Migrate VMs from VMware, Microsoft Hyper-V, Citrix XEN to EC2 (or convert EC2 to VM images for export)
  - Used via the **API or CLI** only — not the console
  - Stop the VM before generating the image

### AWS Server Migration Service (SMS) Δ
  - **Predecessor** to AWS MGN; **deprecated** — use MGN instead

> 📚 **Learn More:** This is a quick EC2-side reference.
>
> - **Module 15 — Migration & Transfer** — full coverage of AWS MGN, AWS DMS, DataSync, Snow Family, Transfer Family, and migration strategies (the 7 Rs)
>
> For SAA, recognize that **AWS MGN is the modern lift-and-shift answer**; SMS is deprecated.

---

## AWS Lightsail

AWS Lightsail is a simplified cloud platform designed for developers and small businesses who need compute, storage, and networking resources without the complexity of EC2 and VPC configuration.
<br>It bundles virtual server, SSD storage, data transfer, DNS management, and a static IP into a single predictable monthly price.

- **Use cases:** Simple websites, blogs (WordPress), dev/test environments, small databases, and basic web apps
- Virtual servers (called **instances**) are pre-configured with Linux or Windows images, or application stacks (LAMP, Node.js, etc.) ‡
- Includes **managed databases**, **load balancers**, **block storage**, **object storage**, and **CDN distributions** (backed by CloudFront)
- Lightsail VPCs are isolated from standard VPCs — **peering to a VPC** is supported via a peering connection ¤
- Can be **migrated to EC2** when the application outgrows Lightsail

> 💡 **Exam Tip:** `"Simple website, blog, or small app with predictable low cost"` → **AWS Lightsail**.
> <br>Lightsail is the answer when the scenario emphasizes simplicity and low/fixed cost over configurability.

> ⚠️ **Exam Trap:** Lightsail is **not** a replacement for EC2 in enterprise or production workloads requiring Auto Scaling, complex networking, or granular IAM control. If the scenario mentions Auto Scaling Groups, custom VPC design, or advanced IAM — use EC2, not Lightsail.

---

## AWS Outposts

AWS Outposts is a **fully managed service** that extends AWS infrastructure, services, APIs, and tools to virtually any on-premises or edge location.
<br>AWS delivers, installs, and manages physical Outposts rack hardware in the customer's data center, allowing the same AWS services and APIs used in the cloud to run on-premises.

- **Use cases:** Workloads that must remain on-premises due to data residency requirements, low-latency requirements, or local data processing needs
- Supported services on Outposts include: EC2, EBS, ECS, EKS, RDS, EMR, ElastiCache, and S3 on Outposts
- Outposts are **connected to an AWS Region** (parent Region) over a dedicated network link; they are not a standalone deployment ◊
- Local gateway (`lgw`) routes traffic between the Outpost and on-premises network
- **AWS Managed** — AWS handles hardware maintenance, software updates, and monitoring § — the customer provides physical space, power, and networking

### Outposts Form Factors

| **Form Factor** | **Description** |
|-----------------|-----------------|
| **Outposts Rack** | Full 42U rack; standard AWS hardware; for larger deployments |
| **Outposts Servers** | Individual 1U/2U servers; for limited space environments |

> 💡 **Exam Tip:** `"Run AWS services on-premises with same APIs"` → **AWS Outposts**.
> <br>`"Data must not leave the data center but workload uses EC2/RDS/ECS"` → **AWS Outposts**.

> 📚 **Learn More:**
> - **Module 5 — VPC** — Outposts in the context of AWS Global Infrastructure types (Regions, AZs, Local Zones, Wavelength Zones, Outposts, Edge Locations)

---

## Logging and Auditing
  - **CloudTrail** captures all EC2 and EBS API calls (console, CLI, SDK)
  - Without a configured trail, you can view **last 90 days †** in CloudTrail event history
  - Configure a trail to deliver events to **S3** for long-term retention

> 📚 **Learn More:** This is a quick EC2-side reference.
>
> - **Module 13 — Monitoring, Logging & Auditing** — full CloudTrail coverage including event types, multi-account trails, and integration with CloudWatch Logs

---

# Module Summary
---

## Key Topics
  - EC2 instances — virtual servers in AWS data centers, customer-managed at OS layer
  - Instance families and sizing (general, compute, memory, storage, accelerated)
  - EC2 lifecycle — pending, running, stopping, stopped, hibernating, rebooting, terminated
  - AWS Nitro System and Nitro Enclaves
  - Status checks (system vs instance) and CloudWatch-driven recovery
  - EBS volumes — persistent block storage, AZ-bound, replicated within AZ
  - EBS volume types: gp3 / gp2 / io2 / io1 / st1 / sc1
  - Instance Store — ephemeral, host-attached, lost on stop/terminate
  - ENI / ENA / EFA networking adapters
  - IP addressing — public IPv4, private IPv4, Elastic IP, IPv6
  - NAT Gateways vs NAT Instances
  - Bastion hosts vs Systems Manager Session Manager
  - Placement Groups — Cluster, Partition, Spread
  - AMIs, user data, IMDS (v1 vs v2)
  - Access keys vs IAM roles for EC2 (use roles)
  - Pricing models — On-Demand, Reserved, Savings Plans, Spot, Dedicated
  - Capacity Reservations and Capacity Blocks for ML
  - Migration via AWS MGN (deeper coverage in Module 15)
  - AWS Lightsail — simplified cloud platform; pre-configured bundles; fixed monthly cost; for simple websites and small apps
  - AWS Outposts — fully managed AWS infrastructure on-premises; same AWS APIs; connected to parent Region; data residency and low-latency use cases

---

## Critical Acronyms
  - **EC2** — Elastic Compute Cloud
  - **AMI** — Amazon Machine Image
  - **EBS** — Elastic Block Store
  - **ENI** — Elastic Network Interface
  - **ENA** — Elastic Network Adapter
  - **EFA** — Elastic Fabric Adapter
  - **EIP** — Elastic IP (address)
  - **VPC** — Virtual Private Cloud
  - **IGW** — Internet Gateway
  - **NAT** — Network Address Translation
  - **MPI** — Message Passing Interface
  - **HPC** — High Performance Computing
  - **NCCL** — NVIDIA Collective Communications Library
  - **IMDS** — Instance Metadata Service
  - **IOPS** — Input/Output Operations Per Second
  - **PPS** — Packets Per Second
  - **SSD** — Solid-State Drive
  - **HDD** — Hard Disk Drive
  - **NVMe** — Non-Volatile Memory Express
  - **RI** — Reserved Instance
  - **OD** — On-Demand
  - **AZ** — Availability Zone
  - **MGN** — Application Migration Service
  - **SMS** — Server Migration Service (deprecated Δ)
  - **DR** — Disaster Recovery
  - **SSH** — Secure Shell
  - **RDP** — Remote Desktop Protocol
  - **BYOIP** — Bring Your Own IP
  - **PII** — Personally Identifiable Information
  - **SSM** — AWS Systems Manager
  - **SR-IOV** — Single Root I/O Virtualization (used by ENA)

---

## Key Comparisons
  - EBS vs Instance Store
  - EBS Volume Types (gp3 / gp2 / io2 / io1 / st1 / sc1)
  - ENI vs ENA vs EFA
  - NAT Gateway vs NAT Instance
  - Cluster vs Partition vs Spread Placement Groups
  - IMDSv1 vs IMDSv2
  - Standard RI vs Convertible RI
  - On-Demand vs Reserved vs Spot vs Savings Plans
  - Dedicated Instances vs Dedicated Hosts
  - Compute Savings Plan vs EC2 Instance Savings Plan
  - Stop vs Terminate vs Reboot vs Hibernate (lifecycle implications)
  - Public IPv4 vs Elastic IP

---

## Top Exam Triggers
  - `EC2 needs to access an AWS service` → **IAM role + instance profile**
  - `Tightly coupled HPC, low latency between nodes` → **Cluster placement group + EFA**
  - `Distributed NoSQL DB, separate hardware racks` → **Partition placement group**
  - `Small critical fleet, eliminate correlated failures` → **Spread placement group**
  - `Stable public IP across stops/starts` → **Elastic IP**
  - `Redundant outbound internet across multiple AZs` → **NAT Gateway per AZ**
  - `Process highly sensitive data with hardware isolation` → **Nitro Enclaves**
  - `Bare-metal performance with EFA / high-perf networking` → **Nitro instance type**
  - `Steady-state, predictable workload, lowest price` → **Reserved Instances** or **Savings Plan**
  - `Cost-sensitive, fault-tolerant, interruptible workload` → **Spot Instances**
  - `Per-socket / per-core software licensing` → **Dedicated Hosts**
  - `Guarantee capacity in a specific AZ` → **Capacity Reservation** or **Zonal RI**
  - `Auto-recover instance after AWS hardware failure` → **CloudWatch alarm on `StatusCheckFailed_System` + Recover action**
  - `Modify instance type` → **Stop the instance first**
  - `Move instance to a different physical host` → **Stop and start it**
  - `Configuration script on first launch` → **EC2 user data**
  - `Lift-and-shift migration to EC2` → **AWS Application Migration Service (MGN)** Δ
  - `Replace bastion host with auditable, no-inbound-port access` → **Systems Manager Session Manager**
  - `Highest IOPS / lowest latency EBS for critical DB` → **io2** (or io2 Block Express)
  - `Cheapest EBS for archival on a boot-eligible volume` → **gp3** (sc1 is cheapest but not bootable)
  - `Big data / log streaming on EBS` → **st1**
  - `Multiple instances sharing a single EBS volume` → **io1/io2 with Multi-Attach** (Nitro instances)

---

## Quick References

<!--![Use Cases Diagram](../assets/2-EC2/placement-group-use-cases.png)-->

### [EC2 Placement Group Use Cases](https://drive.google.com/file/d/18rTDsqjTVEbv2yrtrEyWuSMFpdIIrbY8/view?usp=drive_link)

### [EC2 Pricing Use Cases](https://drive.google.com/drive/folders/1IOiSIjuvhNdJJLe3O6xb7ZrD6UcMSorH?usp=drive_link)

<!--![EC2 Pricing Use Cases 1 Diagram](../assets/2-EC2/ec2-pricing-use-cases-1.png)
[EC2 Pricing Use Cases 2 Diagram](../assets/2-EC2/ec2-pricing-use-cases-2.png)-->

### [EC2 Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28617490#overview)

<!--!
## Architecture Patterns - AWS EC2 
[EC2 Architecture Patterns1 Diagram](../assets/2-EC2/ec2-architecture-patterns-1.png)
![EC2 Architecture Patterns2 Diagram](../assets/2-EC2/ec2-architecture-patterns-2.png)
![EC2 Architecture Patterns3 Diagram](../assets/2-EC2/ec2-architecture-patterns-3.png)-->

### [EC2 Architecture Patterns Private Link](https://drive.google.com/drive/folders/1v6nN4cwX65CZD11sp6me9NRPO5TjzPMA?usp=drive_link)

### [EC2 Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346096#overview)

### [Amazon EC2 Cheatsheet](https://digitalcloud.training/amazon-ec2/)

### [Amazon VPC Cheatsheet](https://digitalcloud.training/amazon-vpc/)

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
