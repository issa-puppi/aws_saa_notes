# Migration and Transfer
---

## Migration Strategies (7 Rs)
  - **Rehost (Lift and Shift)**
    - Move applications without modification

  - **Replatform**
    - Minor optimizations (e.g., move DB to RDS)

  - **Repurchase**
    - Move to SaaS solution

  - **Refactor (Re-architect)**
    - Redesign for cloud-native

  - **Retire**
    - Decommission unused apps

  - **Retain**
    - Keep on-prem

  - **Relocate**
    - Move entire environment (VMware Cloud on AWS)

### Exam Triggers
  - `Quick migration` → Rehost
  - `Optimize DB` → Replatform
  - `Cloud-native` → Refactor

---

## AWS Migration Services

### AWS Application Migration Service (MGN)
  - Lift-and-shift server migration
  - Continuous replication
  - Minimal downtime cutover

### AWS Database Migration Service (DMS)
  - Migrates databases
  - Supports:
    - Homogeneous
    - Heterogeneous

  - **CDC (Change Data Capture)**
    - Keeps source and target in sync

### AWS Schema Conversion Tool (SCT)
  - Converts DB schema
  - Required for heterogeneous migrations

---

## Data Transfer Services

### AWS DataSync
  - Fast, automated data transfer
  - On-prem → AWS (S3, EFS, FSx)

### AWS Transfer Family
  - Managed SFTP / FTP / FTPS
  - Uses S3 or EFS

### AWS Snow Family
  - **Snowball** → PB-scale transfer
  - **Snowball Edge** → compute + storage
  - **Snowmobile** → EB-scale transfer

---

## Hybrid & Discovery

### AWS Storage Gateway
  - Hybrid storage service

  - Types:
    - File Gateway (NFS/SMB → S3)
    - Volume Gateway (iSCSI)
    - Tape Gateway (backup)

### AWS Application Discovery Service
  - Collects:
    - Server usage
    - Dependencies
    - Network configs

### AWS Migration Hub
  - Central migration tracking dashboard

---

## Networking for Migration

### AWS Direct Connect
  - Dedicated private connection
  - Low latency, consistent performance

### AWS VPN
  - Secure connection over internet

---

## Performance Optimization

### Amazon S3 Transfer Acceleration
  - Uses CloudFront edge locations
  - Speeds up global uploads

---

# Module Summary
---

## Key Comparisons

| Concept | Service |
|--------|--------|
| Server migration | MGN |
| Database migration | DMS |
| Schema conversion | SCT |
| Large data transfer (online) | DataSync |
| Large data transfer (offline) | Snowball |
| SFTP transfer | Transfer Family |
| Hybrid storage | Storage Gateway |
| Discover environment | Application Discovery Service |
| Track migration | Migration Hub |
| Private connection | Direct Connect |
| Secure internet connection | VPN |

---

## Common Exam Scenarios

- `Migrate servers` → MGN
- `Migrate DB with minimal downtime` → DMS
- `Convert DB schema` → SCT
- `Discover environment` → Application Discovery Service
- `Track migration` → Migration Hub
- `Transfer large data (network)` → DataSync
- `Transfer PB data offline` → Snowball
- `SFTP service` → Transfer Family
- `Hybrid storage` → Storage Gateway
- `Private connection` → Direct Connect
- `Quick secure connection` → VPN
- `Speed up uploads` → Transfer Acceleration

---

## Quick References

### [Migration and Transfer Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619608#overview)

### [Migration and Transfer Architecture Patterns Private Link](https://drive.google.com/drive/folders/1vlwd2zXFFVC62_9Id4esho2q0D24pk8Z?usp=drive_link)

### [Migration and Transfer Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346122#overview)

### [AWS Migration Services Cheat Sheet](https://digitalcloud.training/aws-migration-services/)

---