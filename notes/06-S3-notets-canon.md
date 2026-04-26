# Object Storage
---

## Amazon Simple Storage Service (S3)

**Amazon S3** is object storage built to store and retrieve any amount of data from anywhere on the internet.
<br>It offers extremely durable, highly available, and infinitely scalable storage infrastructure at low cost.

### Key Properties
  - **Object storage** — stores files (objects) in flat-namespace buckets, not directories
  - **Regional service** — objects never leave the Region in which they are stored unless explicitly moved or replicated
  - **Unlimited storage** — no cap on total storage; unlimited objects per bucket
  - **File size range** — 0 bytes to 5 TB per object †
  - **Single PUT limit** — max 5 GB per object in a single PUT operation †
  - **Automatic scaling** — achieves at least 3,500 PUT/POST/DELETE and 5,500 GET requests per second per prefix † without provisioning
  - **Distributed architecture** — objects are redundantly stored across multiple devices and multiple AZs within the region

### Storage Type Reference

| **Type** | **Description** | **Examples** |
|----------|-----------------|--------------|
| Persistent | Data survives reboots, restarts, power cycles | S3, Glacier, EBS, EFS |
| Transient | Temporarily stored, passed to another process | SQS, SNS |
| Ephemeral | Lost when system stops | EC2 Instance Store, Memcached |

### Accessing S3 Objects
  - **HTTP REST API** using `GET`, `PUT`, `POST`, `SELECT`, `DELETE` operations
  - Two URL formats:
    - `https://bucket.s3.aws-region.amazonaws.com/key` (path-style)
    - `https://s3.aws-region.amazonaws.com/bucket/key` (virtual-hosted-style)
  - `HTTP 200` response code indicates a **successful write** to S3

---

## File Storage vs Object Storage

| **Aspect** | **File Storage (e.g., EFS)** | **Object Storage (e.g., S3)** |
|------------|------------------------------|-------------------------------|
| Structure | Directories and files | Buckets and objects |
| Namespace | Hierarchical | Flat (hierarchy mimicked with key prefixes) |
| Access | Mounted to OS; acts like local storage | Accessed via REST API; cannot be mounted |
| Connection | Network connection maintained | New connection per request |
| Use case | Shared file system, NFS workloads | Backup, media, data lakes, static hosting |

---

## S3 Buckets

A **bucket** is a container for S3 objects in a specific AWS Region.

### Bucket Properties
  - Up to **100 † buckets per account** (default soft limit)
  - Buckets are **region-specific** — data stays in the Region unless replicated
  - **Unlimited objects** can be stored in a bucket
  - **Bucket ownership is not transferable**
  - **Bucket names cannot be changed** after creation; if deleted, the name becomes available again
  - **Cannot create nested buckets**
  - S3 is a **universal namespace** — bucket names must be **globally unique** across all AWS accounts

### Bucket Naming Rules
  - 3–63 characters in length †
  - Must start and end with a **lowercase letter or number**
  - Can contain lowercase letters, numbers, and hyphens
  - Cannot be formatted as an **IP address**
  - Cannot have **periods** between labels if using Transfer Acceleration
  - Names are part of the URL used to access the bucket

### Default Bucket Behavior
  - A bucket and all its objects are **private by default** § — only the bucket owner can access
  - **S3 Block Public Access** is **enabled by default** § Δ on new buckets — prevents public access regardless of ACL or bucket policy settings

> 💡 **Exam Tip:** "Ensure an S3 bucket is never publicly accessible regardless of policies" → **S3 Block Public Access** (account-level or bucket-level setting).

---

## S3 Objects

An **object** is the fundamental entity stored in S3 — a file and its associated metadata.

### Object Components

| **Component** | **Description** |
|---------------|-----------------|
| **Key** | Unique identifier (name) for the object within the bucket |
| **Value** | The actual data (bytes) stored |
| **Version ID** | Unique identifier for a specific version (when versioning enabled) |
| **Metadata** | Key-value pairs: system metadata (content-type, size) + user-defined |
| **Subresources** | Associated configuration: ACLs, object tags, object lock settings, restore status |
| **Access Control** | Permissions governing who can access the object and what they can do |

### Object Size and Limits
  - Objects can be **0 bytes to 5 TB** †
  - Single `PUT` uploads limited to **5 GB** †
  - Use **Multipart Upload** for objects over **100 MB** (recommended) or **over 5 GB** (required)

### Consistency Model
  - **Read-after-write consistency** for `PUT` of **new objects** — immediately available after a successful write Δ (became universal in 2020)
  - **Eventual consistency** for **overwrite PUTs and DELETEs** — changes may take time to propagate to all read endpoints
  - Updates to an object are **atomic** — you will never receive partial or corrupt data

---

## S3 Storage Classes

All classes offer **11 nines durability (99.999999999%)** ‡ — if you store 10 million objects, you expect to lose **one object every 10,000 years** on average.

| **Storage Class** | **Availability** ‡ | **AZs** | **Min Object Size** | **Min Duration** | **Retrieval Fee** | **First Byte Latency** | **Best For** |
|-------------------|--------------------|---------|--------------------|-----------------|-------------------|------------------------|--------------|
| **S3 Standard** | 99.99% | ≥3 | None | None | None | Milliseconds | Frequently accessed data |
| **S3 Intelligent-Tiering** | 99.9% | ≥3 | None | None | None (IA tier has retrieval fee) | Milliseconds | Unknown or changing access patterns |
| **S3 Standard-IA** | 99.9% | ≥3 | 128 KB | 30 days | Per GB ¤ | Milliseconds | Infrequently accessed, must be retrievable instantly |
| **S3 One Zone-IA** | 99.5% | 1 | 128 KB | 30 days | Per GB ¤ | Milliseconds | Infrequently accessed, re-creatable data |
| **S3 Glacier Instant Retrieval** | 99.9% | ≥3 | 128 KB | 90 days | Per GB ¤ | Milliseconds | Archive with immediate retrieval needed |
| **S3 Glacier Flexible Retrieval** | 99.99% | ≥3 | 40 KB | 90 days | Per GB ¤ | Minutes–hours | Archive tolerating retrieval delays |
| **S3 Glacier Deep Archive** | 99.99% | ≥3 | 40 KB | 180 days | Per GB ¤ | Hours | Lowest-cost long-term retention |

### Durability vs Availability
  - **Durability** — protection against **data loss or corruption** (11 nines, all classes)
  - **Availability** — measurement of **uptime and accessibility** (varies by class)

> ⚠️ **Exam Trap:** **S3 One Zone-IA** stores data in only **one AZ** — data is lost if that AZ is destroyed. Use only for data that can be re-created or replicated elsewhere.

> 💡 **Exam Tips:** 
<br>"Frequently accessed" → **S3 Standard**. 
<br>"Unknown access patterns" → **S3 Intelligent-Tiering** (no retrieval fee for monitoring). 
<br>"Infrequent but immediate retrieval needed" → **S3 Standard-IA** or **S3 Glacier Instant Retrieval**. 
<br>"Archive, retrieval in minutes or hours" → **S3 Glacier Flexible Retrieval**. 
<br>"Lowest cost, retrieval in hours, long retention" → **S3 Glacier Deep Archive**.

---

## S3 Lifecycle Management

Lifecycle rules **automate transitions between storage classes and object expiration** to optimize costs.

### Action Types
  - **Transition actions** — define when objects move to a cheaper storage class
  - **Expiration actions** — define when objects are permanently deleted (S3 handles deletion)

### Supported Transitions (waterfall — can only go "down" in cost)

```
S3 Standard
    ↓ (any)
S3 Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant, Glacier Flexible, Glacier Deep Archive
    ↓
Standard-IA → One Zone-IA or Intelligent-Tiering
    ↓
Intelligent-Tiering → One Zone-IA
    ↓
Glacier Flexible Retrieval → Glacier Deep Archive
```

### Unsupported Transitions
  - **Any class → S3 Standard** (cannot promote back)
  - **Any class → Reduced Redundancy Storage (RRS)** — deprecated
  - **Intelligent-Tiering → Standard-IA**
  - **One Zone-IA → Standard-IA or Intelligent-Tiering**
  - **Glacier Deep Archive → any other class**

### Transition Constraints ¤
  - Objects must be stored at least **30 days** in Standard before transitioning to Standard-IA or One Zone-IA
  - Objects smaller than **128 KB** are not cost-effectively transitioned to Standard-IA, One Zone-IA, or Intelligent-Tiering — S3 will not charge the transition fee for these
  - Lifecycle rules can apply to **current versions, previous versions, or both**
  - Can filter by **prefix** or **object tag**

> 💡 **Exam Tips:** 
<br>"Move objects to cheaper storage as they age" → **S3 Lifecycle policy with Transition action**. 
<br>"Auto-delete objects after N days" → **Lifecycle policy with Expiration action**.

---

# Access & Security
---

## S3 Access Control

S3 has four mechanisms for controlling access:
  - **IAM policies** — identity-based; attached to users, groups, or roles; no Principal element
  - **Bucket policies** — resource-based; attached to the bucket; Principal element required; up to 20 KB † in size
  - **Access Control Lists (ACLs)** — legacy; predates IAM; limited grantees and permissions; only recommended use case is granting write access to the **S3 Log Delivery group**
  - **Pre-signed URLs** — time-limited access for anonymous users (see below)

### When to Use Each

| **Use IAM Policies When...** | **Use Bucket Policies When...** |
|------------------------------|----------------------------------|
| Controlling access to multiple AWS services, not just S3 | Granting simple cross-account access without IAM roles |
| Managing many S3 buckets with different access requirements | IAM policies are approaching size limits |
| Keeping access control in the IAM environment | Keeping access control in the S3 environment |

### S3 Block Public Access Δ §
  - Enabled by **default on all new buckets and accounts** — overrides any bucket policy or ACL that would grant public access
  - Four settings: block public ACLs, ignore public ACLs, block public bucket policies, restrict public bucket policies
  - Apply at **account level** to prevent any bucket in the account from becoming public
  - Apply at **bucket level** for more granular control

### Authorization Flow
The authorization decision for an S3 request works as follows:

  1. **Starts at DENY** by default
  2. Evaluates **all applicable policies** (IAM + bucket policy + ACL)
  3. **Explicit Deny?** → DENIED (final)
  4. **Explicit Allow?** → ALLOWED
  5. Default → **DENIED**

> 📚 **Learn More:** S3 authorization follows the same IAM evaluation logic covered in depth in Module 1.
>
> - **[Authorization Process Diagram](https://drive.google.com/file/d/12nX3R7CLqNS-L3YdfORgsyA8ypjd0nbn/view?usp=drive_link)**

### Cross-Account Access
  - **IAM role with trust policy** — Account B creates a role; Account A assumes it via `sts:AssumeRole` with an `external-id` condition
  - **Bucket policy** — grants access directly to principals in another account (no role required)
  - For cross-account **object ownership**: the uploading account owns the objects they upload, even though the bucket is in another account — use **S3 Object Ownership** setting Δ to enforce bucket owner ownership

---

## S3 Versioning

**Versioning** keeps multiple variants of an object in the same bucket to protect against accidental deletion or overwriting.

### Key Properties
  - Stores **all versions** of an object — including all writes and even deletes
  - Once enabled, versioning **cannot be disabled — only suspended** §
  - While suspended: new objects get a `null` version ID; uploads overwrite same-named objects
  - Objects that existed before enabling versioning have a version ID of **`null`**
  - **Old versions count toward billed storage** until permanently deleted
  - HTTP `GET` retrieves the **most recent version** by default
  - Versioning must be enabled on both source and destination buckets for **replication**

### Delete Behavior with Versioning
  - Deleting an object (without specifying version ID) places a **DELETE marker** — object appears deleted but all versions still exist
  - To fully restore: **delete the DELETE marker**
  - To permanently delete: specify the **version ID** when deleting
  - Only the **bucket owner (root user)** can permanently delete objects once versioning is enabled

### MFA Delete
  - Requires **MFA authentication** for two operations:
    - Changing the versioning state of the bucket
    - Permanently deleting an object version (specifying version ID)
  - The `x-amz-mfa` request header must be included
  - Requires versioning to be enabled first
  - **MFA Delete can only be enabled by the bucket owner (root user)**
  - Versioning can be enabled by: bucket owner, AWS account that created the bucket, or authorized IAM users

> 💡 **Exam Tips:** 
<br>"Protect against accidental deletion" → **Enable S3 Versioning**. 
<br>"Prevent even the bucket owner from deleting versions without MFA" → **MFA Delete**. 
<br>"Versioning once enabled cannot be..." → **disabled (only suspended)**.

### MFA Protected API Access
  - Enforces MFA for **any AWS API operation** (not just S3 delete)
  - Implemented via `aws:MultiFactorAuthAge` condition key in IAM or bucket policies
  - Example: `"Condition": { "Null": { "aws:MultiFactorAuthAge": true } }` — denies access if MFA was not used

---

## S3 Object Lock

**S3 Object Lock** prevents objects from being deleted or overwritten for a fixed period or indefinitely.
<br>Useful for **WORM (Write Once, Read Many)** compliance requirements.

  - Requires versioning to be enabled
  - Two modes:
    - **Governance mode** — only users with special IAM permissions can override or delete locked objects
    - **Compliance mode** — no user (including root) can override or delete; strictest protection
  - **Legal hold** — prevents deletion regardless of retention period; can be applied independently

> 💡 **Exam Tip:** "Regulatory requirement to prevent object deletion for a defined period" → **S3 Object Lock** with Compliance mode.

---

## S3 Encryption

All S3 buckets have **encryption enabled by default** § Δ — all new object uploads are automatically encrypted with **SSE-S3** at no extra cost.

### Encryption Options

| **Method** | **Who Manages Keys** | **Key Storage** | **Notes** |
|------------|---------------------|-----------------|-----------|
| **SSE-S3** | AWS (S3) | AWS | AES-256; default § |
| **SSE-KMS** | AWS KMS (customer or AWS managed key) | AWS KMS | Audit trail via CloudTrail; additional KMS charges ¤ |
| **SSE-C** | Customer | **Not stored in AWS** | Customer provides key per request; if key lost, data unrecoverable |
| **Client-side** | Customer | Not stored in AWS | Customer encrypts before upload; full control |

### Encrypting Existing Objects
  - Use **S3 Batch Operations** to apply encryption retroactively at scale
  - Use `CopyObject` API or `copy-object` CLI command for individual objects

### Enforcing Encryption via Bucket Policy
  - Deny any `PUT` request that doesn't include `x-amz-server-side-encryption: aws:kms` (for SSE-KMS)
  - Or deny requests where `aws:SecureTransport` is false (enforces HTTPS)

> 💡 **Exam Tips:** 
<br>"Company manages encryption through their own application with their own keys" → **Client-side encryption** or **SSE-C**. 
<br>"Audit key usage for encrypted S3 objects" → **SSE-KMS** (KMS events logged in CloudTrail). 
<br>"Enforce HTTPS-only access to S3" → Bucket policy with `aws:SecureTransport: false` deny condition.

---

## S3 Replication

**Replication** automatically copies objects from one S3 bucket to another — asynchronously.

### Types
  - **Cross-Region Replication (CRR)** — replicates to a bucket in a **different Region**
  - **Same-Region Replication (SRR)** — replicates to a bucket in the **same Region** (can be a different account)

### Requirements
  - **Versioning must be enabled** on both source and destination buckets
  - An **IAM role** must grant S3 permission to replicate objects
  - Bucket owner must have permission to read the object and object ACL
  - Replication is **1:1** — one source bucket to one destination bucket
  - Can replicate a **prefix** (folder) rather than the whole bucket

### Key Behaviors
  - Replication is **asynchronous** — not instantaneous
  - Replicas share the **same key names and metadata** as the originals
  - Can specify a **different storage class** for replicated objects (default: same as source)
  - Data in transit is **encrypted with SSL**
  - **Reverting to previous versions** is not replicated
  - **DELETE markers** are replicated; **deleting the delete marker** is NOT replicated
  - Can replicate **KMS-encrypted objects** by specifying a destination KMS key in the replication config

### Use Cases
  - **Disaster recovery** — secondary region copy
  - **Data locality** — replicate closer to users
  - **Compliance** — meet data residency requirements
  - **Log aggregation** — SRR to consolidate logs from multiple buckets into one
  - **Cross-account backup** — replicate to another account's bucket

> 💡 **Exam Tip:** "Backup S3 objects within a specific folder to another Region" → **CRR with a prefix filter** targeting the folder name.

---

# Performance & Features
---

## S3 Multipart Upload

**Multipart Upload** splits large objects into parts that are uploaded independently, in parallel, and in any order.

  - **Recommended** for objects ≥ **100 MB** †
  - **Required** for objects > **5 GB** †
  - Can be used for objects from **5 MB** to **5 TB** †
  - Individual parts can be **retransmitted** if they fail — no need to restart the whole upload
  - Supports **pause and resume**
  - Can begin upload **before knowing the final object size**
  - Improves throughput on high-bandwidth connections

---

## S3 Transfer Acceleration

**Transfer Acceleration** uses **CloudFront edge locations** to accelerate uploads from clients to S3 buckets over long distances.

  - Enabled at the **bucket level**
  - Uses a special endpoint: `bucketname.s3-accelerate.amazonaws.com` or `bucketname.s3-accelerate.dualstack.amazonaws.com` (dual-stack IPv4/IPv6)
  - **Cannot be disabled — only suspended** after enabling
  - AWS only charges ¤ if there is a measurable performance improvement
  - Compatible with **Multipart Upload**
  - Bucket names must be **DNS-compliant** (no periods) for Transfer Acceleration to work

> 💡 **Exam Tip:** "Long-distance uploads to S3, need performance improvement" → **S3 Transfer Acceleration**.

---

## S3 Performance Guidelines

  - S3 automatically partitions based on key prefixes — using **random prefixes** helps distribute request load across partitions
  - For **read-intensive** workloads: use **CloudFront** to offload S3 with edge caching
  - **S3 Byte-Range Fetches** — parallelize downloads by requesting specific byte ranges; useful for large file downloads and partial retrieval
  - Create buckets **closer to your clients** for lower latency and lower cost ¤ ◊

---

## S3 Select and Glacier Select

  - **S3 Select** — use SQL expressions to retrieve **individual records or partial content** from an S3 object (CSV, JSON, or Parquet) **without downloading the entire object**
  - **Glacier Select** — same capability for objects in S3 Glacier storage classes
  - Reduces data transferred, reducing cost ¤ and improving performance

> 💡 **Exam Tip:** "Query a specific field from a large CSV in S3 without retrieving the whole file" → **S3 Select**.

---

## S3 Presigned URLs

A **presigned URL** grants **temporary, time-limited access** to a specific S3 object to users **without AWS credentials**.

  - Default expiration: **1 hour** § (configurable)
  - Generated via AWS SDKs (`generate_presigned_url`) or CLI (`aws s3 presign`)
  - Works for both **downloads (GET)** and **uploads (PUT)**
  - Can be used for **SSE-KMS-encrypted objects** with additional KMS key parameters
  - By default all objects are private — presigned URL or making object public are the two ways to share

> 💡 **Exam Tip:** "Grant temporary, time-limited access to a private S3 object for users without AWS credentials" → **Presigned URL**.

---

## S3 Event Notifications

S3 can send notifications when specific events occur in a bucket — useful for triggering workflows.

### Supported Events
  - New object created (PUT, POST, COPY)
  - Object removed (DELETE)
  - Restore object (Glacier)
  - Replication events

### Supported Destinations
  - **Amazon SNS topic** — fan out notifications
  - **Amazon SQS queue** — queue-based processing
  - **AWS Lambda function** — serverless processing
  - **Amazon EventBridge** ※ Δ — newer option; supports more advanced routing and filtering

### pub/sub Basics
  - **Publisher** — S3 bucket producing the event
  - **Subscriber** — SNS/SQS/Lambda/EventBridge consuming the event
  - Notifications can be **filtered by prefix and suffix** of the object key

> 💡 **Exam Tip:** "Notify an admin when an S3 object is deleted" → **S3 Event Notification → SNS topic → email subscription**.

---

## S3 Object Lambda

**S3 Object Lambda** uses a **Lambda function to process and transform S3 GET request responses** before returning data to the caller — without modifying the underlying stored object.

### How It Works
  - Create an **S3 Object Lambda Access Point** backed by a standard S3 Access Point
  - `GetObject` requests to the Object Lambda Access Point trigger the Lambda function
  - Lambda transforms the data and returns the modified response

### Use Cases
  - **Data transformation** — convert formats, filter data on retrieval
  - **Data masking** — redact sensitive information before returning it
  - **Custom auth/authorization** — add additional access controls

### AWS Prebuilt Functions
  - **PII Access Control** — detects PII and restricts access
  - **PII Redaction** — detects PII and returns documents with PII removed
  - **Decompression** — decompresses objects (bzip2, gzip, snappy, zlib, zstandard, ZIP) before returning

---

## S3 Static Website Hosting

S3 can host **static websites** — HTML, CSS, JavaScript, images, and other static assets.

  - Specify an **Index document** (e.g., `index.html`) and optional **Error document**
  - Website endpoint: `bucketname.s3-website-<region>.amazonaws.com`
  - Use a **Route 53 Alias record** to point a custom domain name to an S3 website endpoint (bucket name must match the domain name)
  - **Does NOT support HTTPS/SSL** — use **CloudFront** in front of S3 for HTTPS
  - Only supports **GET and HEAD** requests on objects
  - Supports only **publicly readable** content
  - Supports object- and bucket-level **redirects**
  - **Automatically scales** — no provisioning needed

> ⚠️ **Exam Trap:** S3 static website hosting does **not support HTTPS**. For HTTPS, put **CloudFront** in front with an ACM certificate.

---

## Server Access Logging

Provides **detailed records of all requests** made to a bucket.

  - **Disabled by default** §
  - Details: requester, bucket name, request time, action, response status, error code
  - Configure a **separate target bucket** to store log files (cannot log to the same bucket being logged)
  - Must grant **write permissions to the S3 Log Delivery group** on the target bucket
  - Pay only for **storage used** ¤ — no per-request logging fee

---

## CORS with S3

**Cross-Origin Resource Sharing (CORS)** allows a browser to make requests to a **different origin** (domain, protocol, or port) than the one it loaded from.

  - CORS configuration is added to the **bucket being accessed** (not the origin bucket)
  - Browser sends a **preflight request** (HTTP OPTIONS) before the actual request to confirm CORS is permitted
  - CORS configuration defines: `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`
  - Configured using **JSON files** attached to the S3 bucket

> 🛠️ **Implementation Notes — CORS HOL:** 
<br>`mb` command creates a bucket in the default region (`us-east-1`). 
<br>Use `aws sts assume-role --role-arn <role-arn> --role-session-name <session-name> --external-id <external-id>` to obtain temporary credentials for cross-account bucket access.

---

## S3 Pricing Overview

  - **Storage** — per GB/month ¤ (varies by storage class)
  - **Data transfer in** — free ¤
  - **Data transfer out to internet** — charged ¤
  - **Data transfer between EC2 and S3 in the same Region** — free ¤
  - **Data transferred to other Regions** — charged ¤
  - **API requests** — PUT, GET, LIST, DELETE ¤ (rates vary by class)
  - **Retrieval fee** — applies to Standard-IA, One Zone-IA, Glacier tiers ¤
  - **Minimum storage duration charge** — applies to IA and Glacier classes ¤
  - **Requester Pays** — bucket owner pays only for storage; the requester pays for requests and data transfer; **anonymous access is not supported** (requester must be an authenticated AWS user)

> 💡 **Exam Tip:** `"Large dataset hosted on S3 — only consumers who download the data should pay transfer costs, not the bucket owner"` → **S3 Requester Pays**.
> <br>Common pattern: scientific datasets, genomics data, publicly shared large datasets where the owner wants to host but not subsidize consumer egress.

---

## S3 Access Points

S3 Access Points simplify managing access to shared datasets by providing **named access endpoints**, each with its own access policy, hostname, and optional VPC restriction.
<br>Instead of one complex bucket policy managing access for dozens of teams or applications, each gets its own dedicated access point with a focused policy.

- Each access point has a **unique hostname** (e.g., `my-ap-123.s3-accesspoint.us-east-1.amazonaws.com`) and a dedicated **access point policy**
- Access points **do not replace bucket policies** — the bucket policy must still delegate access to the access point (or grant a `*` principal with conditions)
- Access points can be **VPC-restricted** — traffic can be limited to requests originating from a specific VPC only, enforced by the access point policy with `aws:SourceVpc` or `aws:SourceVpce`
- Useful for **multi-tenant data lake** scenarios where many teams share one S3 bucket but need isolated access controls

> 💡 **Exam Tip:** `"Simplify S3 bucket policy management for a shared dataset used by many teams or applications"` → **S3 Access Points**.
> <br>`"Restrict S3 access to only requests from within a VPC"` → **S3 Access Point with VPC restriction** (or Gateway Endpoint + bucket policy `aws:SourceVpce` condition — both are valid; the exam may present either).

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Prevent accidental deletion of S3 objects | Enable **S3 Versioning** |
| Data frequently accessed for 30 days then rarely accessed, must be immediately retrievable | Lifecycle policy: S3 Standard → **S3 Standard-IA** after 30 days |
| Replicate a specific folder in a bucket to another Region | Configure **CRR** and specify the folder name as a **prefix** |
| Store previous versions of objects long-term at lowest cost | Lifecycle rule transitioning non-current versions to **S3 Glacier Deep Archive** |
| Company manages all encryption through their application with their own keys | **Client-side encryption** with client-managed keys |
| Encrypt existing unencrypted objects in a bucket | Re-upload with encryption specified, or use **S3 Batch Operations** |
| Notify an administrator when objects are deleted from a bucket | **S3 Event Notification → SNS topic** |
| Grant time-limited access to a software update for customers without AWS credentials | Generate a **presigned URL** |
| Solutions architects need cross-account programmatic and console access | **Cross-account access via IAM roles** (`sts:AssumeRole` with external ID) |
| Large CSV in S3 — need to query a specific column without downloading the whole file | **S3 Select** with a SQL expression |
| Redact PII from S3 objects before returning data to an application | **S3 Object Lambda** with the PII Redaction prebuilt function |
| Accelerate uploads from global clients over long distances | **S3 Transfer Acceleration** |
| Private S3 bucket content must be served over HTTPS with a custom domain | **CloudFront + ACM cert + S3 origin** (S3 website hosting does not support HTTPS) |
| Enforce that all objects in a bucket must be encrypted with KMS | Bucket policy denying PUT requests without `x-amz-server-side-encryption: aws:kms` |
| Ensure bucket can never become public regardless of policies | Enable **S3 Block Public Access** |
| Compliance requirement to prevent deletion for a defined period | **S3 Object Lock** — Compliance mode |
| S3 objects accessed privately from EC2 in a private subnet without internet | **VPC Gateway Endpoint for S3** (see Module 5) |

---

# Module Summary
---

## Key Topics
  - S3 as object storage — buckets, objects, keys, flat namespace, unlimited scalability
  - File storage vs object storage
  - Storage classes — Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant, Glacier Flexible, Glacier Deep Archive
  - Durability (11 nines, all classes) vs Availability (varies by class)
  - Lifecycle management — transition and expiration actions; supported/unsupported transitions
  - S3 Block Public Access — default on for new buckets
  - Access control — IAM policies, bucket policies, ACLs, presigned URLs
  - Authorization flow — default deny, explicit deny beats all, explicit allow
  - Versioning — once enabled, only suspended not disabled; DELETE markers; MFA Delete
  - S3 Object Lock — WORM compliance; Governance vs Compliance mode
  - S3 Encryption — SSE-S3 (default), SSE-KMS (audit trail), SSE-C (customer keys not stored), Client-side
  - S3 Replication — CRR (cross-region) and SRR (same-region); versioning required
  - Multipart Upload — recommended ≥100 MB, required >5 GB
  - Transfer Acceleration — CloudFront edge for long-distance uploads
  - S3 Select / Glacier Select — SQL query on object content
  - Presigned URLs — temporary access for users without credentials
  - S3 Event Notifications — SNS, SQS, Lambda, EventBridge
  - S3 Object Lambda — transform GET responses without changing stored data
  - Static website hosting — no HTTPS, use CloudFront for HTTPS + custom domain
  - Server access logging — disabled by default, separate target bucket required
  - CORS — configuration on the accessed bucket; preflight OPTIONS request
  - S3 Requester Pays — bucket owner pays only for storage; requester pays for transfer/requests; anonymous access not supported
  - S3 Access Points — named access endpoints per team/app; own policy + hostname; optional VPC restriction; simplifies complex bucket policies on shared datasets

---

## Critical Acronyms
  - **S3** — Simple Storage Service
  - **SSE** — Server-Side Encryption
  - **SSE-S3** — Server-Side Encryption with S3-managed keys
  - **SSE-KMS** — Server-Side Encryption with AWS KMS keys
  - **SSE-C** — Server-Side Encryption with Customer-provided keys
  - **KMS** — Key Management Service
  - **AES** — Advanced Encryption Standard
  - **ACL** — Access Control List
  - **CRR** — Cross-Region Replication
  - **SRR** — Same-Region Replication
  - **WORM** — Write Once, Read Many
  - **CDN** — Content Delivery Network
  - **CORS** — Cross-Origin Resource Sharing
  - **PII** — Personally Identifiable Information
  - **SLA** — Service Level Agreement
  - **IA** — Infrequent Access
  - **PUT** — HTTP method to upload/create a resource
  - **GET** — HTTP method to retrieve a resource
  - **REST** — Representational State Transfer
  - **ARN** — Amazon Resource Name

---

## Key Comparisons
  - File Storage vs Object Storage
  - S3 Storage Classes (all 7 — Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant, Glacier Flexible, Glacier Deep Archive)
  - Durability vs Availability
  - IAM Policies vs Bucket Policies vs ACLs
  - SSE-S3 vs SSE-KMS vs SSE-C vs Client-side encryption
  - CRR vs SRR
  - Static website REST API endpoint vs website endpoint
  - Versioning Enabled vs Suspended

---

## Top Exam Triggers
  - `Prevent accidental deletion` → **S3 Versioning**
  - `WORM / compliance / prevent deletion for a period` → **S3 Object Lock** (Compliance mode)
  - `Store infrequently accessed data, must be immediately retrievable` → **S3 Standard-IA** or **Glacier Instant Retrieval**
  - `Unknown or changing access patterns` → **S3 Intelligent-Tiering**
  - `Lowest cost archive, hours retrieval time` → **S3 Glacier Deep Archive**
  - `Move objects between classes automatically over time` → **S3 Lifecycle policy**
  - `Ensure bucket is never public regardless of other settings` → **S3 Block Public Access**
  - `Cross-account S3 access without IAM roles` → **S3 Bucket policy**
  - `Cross-account S3 access with programmatic + console access` → **IAM role + sts:AssumeRole**
  - `Temporary access to private S3 object for unauthenticated users` → **Presigned URL**
  - `Trigger Lambda/SNS/SQS when object uploaded or deleted` → **S3 Event Notification**
  - `Query specific data from a large file in S3 without downloading it` → **S3 Select**
  - `Transform S3 GET responses without changing the stored data` → **S3 Object Lambda**
  - `Accelerate uploads from clients in distant locations` → **S3 Transfer Acceleration**
  - `Upload large objects reliably` → **Multipart Upload** (required >5 GB, recommended ≥100 MB)
  - `S3 static website with HTTPS + custom domain` → **CloudFront + ACM** (S3 website endpoint has no HTTPS)
  - `Encrypt S3 objects with auditable key usage` → **SSE-KMS**
  - `Company manages their own encryption keys, keys not stored on AWS` → **SSE-C** or **Client-side encryption**
  - `Replicate specific folder to another Region` → **CRR with prefix filter**
  - `All S3 objects encrypted by default` → Yes § Δ — **SSE-S3 by default on all new buckets**

---

## Quick References

### [Exam Cram — S3](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28618766#overview)

### [S3 Architecture Patterns Private Link](https://drive.google.com/drive/folders/16L16izeISjBs_cqwHu1aa2X2CkrquICm?usp=drive_link)

### [S3 Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346104#overview)

### [S3 Cheat Sheet](https://digitalcloud.training/amazon-s3-and-glacier/)

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