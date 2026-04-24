## Amazon S3 (Simple Storage Service)

- **Bucket**: A container for storing objects in S3
- **Object**: The fundamental entity stored in S3, consisting of data and metadata
- **Key**: The unique identifier for an object within a bucket

**HTTP protocol** is used with **REST API:**
  - **GET**: Retrieve an object from S3
  - **PUT**: Upload an object to S3
  - **POST**: Create a new object or update an existing object in S3
  - **SELECT**: Query data from S3 using SQL-like syntax
  - **DELETE**: Remove an object from S3

---

## S3 Objects 

#### An S3 object consists of:
- **Key**: The unique identifier for the object within the bucket
- **Version ID**: A unique identifier for each version of an object
- **Value**: The actual data stored in the object
- **Metadata**: Additional information about the object
  - Such as content type, content length, and custom metadata defined by the user
- **Subresources**: Additional features and functionalities associated with the object
  - Such as access control lists (ACLs), object tags, and object lock settings
- **Access Control**: Permissions and policies that govern who can access the object and what actions they can perform on it

---

## Consistency Model

- **Read-after-write consistency** for `PUTS` of new objects
  - After a successful write of a new object, it is immediately available for read operations
  - Became available in 2020 for all AWS regions

- **Eventual consistency** for overwrite `PUTS` and `DELETES`
  - After a successful overwrite or delete operation, it may take some time for the changes to be reflected in subsequent read operations
  - During this time, read operations may return the old version of the object or indicate that the object does not exist

---

## S3 Gateway Endpoints

Since S3 is a public service, EC2 instances connect to the Public Internet via IGW to access S3 (sits outside of the VPC)

- **S3 Gateway Endpoint**: A gateway that allows EC2 instances to privately connect to S3 without using the public Internet

### Key Benefits:
  - Improved security by keeping traffic within the AWS network
  - Reduced latency and improved performance for S3 access
  - No need for an Internet gateway, NAT device, or VPN connection to access S3

---

## File Storage vs Object Storage

| File Share | Object Storage |
|------------|----------------|
| Data stored in directories and files | Data stored in buckets and objects |
| Hierarchical structure | Flat namespace structure<br>Can be mimicked using<br>prefixes and delimiters |
| Files systems are mounted to OS<br> Functions like local storage | Accessed via APIs (HTTP/REST) |
| Network connection is maintained | Network connection is completed<br> after each data access request |
| Example is Amazon EFS | Example is Amazon S3 |

---

## Durability vs Availability

| **Durability** | **Availability** |
|------------|--------------|
| **Durability is protection against:** | **Availability is a measurement of:** |
| • Data loss | • Uptime and accessibility of the service |
| • Data corruption | • Expressed as a % of time per year |
| • S3 offers 11 9s durability<br>(99.999999999%) | • S3 offers 99.99% availability |

### If you store 10 million objects in S3, you can expect to lose one object every 10,000 years on average!

---

## S3 Storage Classes

| **Feature** | **S3 Standard** | **S3 Intelligent-Tiering** | **S3 Standard-IA** | **S3 One Zone-IA** | **S3 Glacier Instant Retrieval** | **S3 Glacier Flexible Retrieval** | **S3 Glacier Deep Archive** |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Durability** | 99.999999999% | 99.999999999% | 99.999999999% | 99.999999999% | 99.999999999% | 99.999999999% | 99.999999999% |
| **Availability** | 99.99% | 99.9% | 99.9% | **99.5%** | 99.9% | 99.9% | 99.9% |
| **Availability Zones** | $\geq$ 3 | $\geq$ 3 | $\geq$ 3 | **1** | $\geq$ 3 | $\geq$ 3 | $\geq$ 3 |
| **Minimum Storage Capacity** | N/A | N/A | 128 KB | 128 KB | 128 KB | 40 KB | 40 KB |
| **Minimum Storage Duration** | N/A | N/A | 30 days | 30 days | 90 days | 90 days | 180 days |
| **Retrieval Fee** | N/A | Depends<br>IA = Yes<br>FA = No | Yes | Yes | Yes | Yes | Yes | 
| **First Byte Latency** | Milliseconds | Milliseconds | Milliseconds | Milliseconds | Milliseconds | Minutes to hours | Hours |
| **Storage Type** | Object Storage | Object Storage | Object Storage | Object Storage | Object Storage | Object Storage | Object Storage |
| **Lifecyle Transitions** | Supported | Supported | Supported | Supported | Supported | Supported | Supported |
| **Use Cases** | Frequently accessed data | Data with unknown or changing access patterns | Infrequently accessed data | Infrequently accessed data that can be recreated | Data that requires immediate retrieval | Data that can tolerate retrieval times of minutes to hours | Data that can tolerate retrieval times of hours |
| **Cost** | Higher | Higher than Standard-IA but lower than Standard | Lower than Standard | Lower than Standard-IA | Lower than Standard-IA | Lower than Glacier Instant Retrieval | Lowest |

---

## S3 Policies

- **IAM Policies**: identity-based policies
  - Attached to the **Principal** e.g., IAM users, groups, or roles
  - Define permissions for actions on S3 resources
  - Written in JSON format using the AWS policy language
  - The **Principal** element is not required in the policy 

- **Bucket Policies**: resource-based policies
  - Attached directly to S3 buckets
  - Use the same AWS policy language as IAM policies
  - Define permissions for actions on the bucket and its objects
  - The **Principal** element is required in the policy to specify access permissions

---

## Some Example Use Cases

### Use IAM policies if:
  - You need to control access to multiple AWS services, not just S3
  - You have numerous S3 buckets each with different access requirements
  - You want to manage permissions for a large number of users or roles

### Use bucket policies if:
  - You want a simple way to grant cross-account access to your S3 bucket (without IAM roles)
  - Your IAM policies are reaching the size limit
  - You prefer to manage permissions directly in S3 Environment rather than in IAM

---

## [Authorization Process for S3](https://drive.google.com/file/d/12nX3R7CLqNS-L3YdfORgsyA8ypjd0nbn/view?usp=drive_link)

1. Starts at **DENY** by default
2. Evaluates all applicable policies (IAM and bucket policies)
3. Explicit deny? If yes, **DENIED**
4. Explicit allow? If yes, **ALLOWED**
5. Final decision is **DENIED** (default)

---

## S3 Versioning

- **Versioning** is a feature that allows you to keep multiple versions of an object in the same bucket
- Use versioning to preserve, retrieve, and restore every version of every object stored in your S3 bucket
- Versioning-enabled buckets enable you to recover objects from **accidental deletion** or **overwriting**

---

## S3 Replication

- **Replication** is the process of copying objects from one S3 bucket to another
  - **Cross-Region Replication (CRR)**: Replicates objects across different AWS regions
  - **Same-Region Replication (SRR)**: Replicates objects within the same AWS region
    - Can transfer buckets from one account to another account within the same region
- Use replication for:
  - **Disaster recovery**: Replicate data to another region for backup and recovery purposes
  - **Data locality**: Replicate data to a region closer to your users for improved performance
  - **Compliance**: Replicate data to meet regulatory requirements for data storage and residency

**All buckets involved in replication must have versioning enabled**

---

## S3 Lifecycle Management

### There are two types of lifecycle actions:

- **Transition actions**: Define when objects transition to a different storage class 
  - e.g., from S3 Standard to S3 Glacier
- **Expiration actions**: Define when objects expire and are permanently deleted from S3

### Supported Transitions:
- S3 Standard to any other storage class
- Any storage class to S3 Glacier storage class family
- S3 Standard-IA to S3 One Zone-IA or S3 Intelligent-Tiering
- S3 Intelligent-Tiering to S3 One Zone-IA
- S3 Glacier storage class to S3 Glacier Deep Archive

### Unsupported Transitions:
- Any storage class to S3 Standard
- Any storage class to Reduced Redundancy Storage (RRS) (deprecated)
- S3 Intelligent-Tiering to S3 Standard-IA
- S3 One Zone-IA to S3 Standard-IA or S3 Intelligent-Tiering

---

## MFA with S3

### S3 Multi-Factor Authentication Delete (MFA Delete):
  - Adds MFA requirement for bucket owners to the following operations:
    - Changing the versioning state of the bucket
    - Permanently deleting an object version
  - The `x-amz-mfa` request header must be included for the above requests
  - the second factor is a token generated by a hardware device or program

### **Versioning** can be enabled by:
  - Bucket owner (root user) 
  - AWS Account that created the bucket
  - Authorized IAM users 

### **MFA Delete** can be enabled by:
  - Only the bucket owner (root user)

---

## MFA Protected API Access

- Used to enforce another authentication factor (MFA code) when accessing AWS services (not just S3)
- Enforced using the `aws:MultiFactorAuthAge` key in a bucket policy or IAM policy condition
  - `"Condition": { "Null": { "aws:MultiFactorAuthAge": true } }` <br>
  Denies access if MFA is not used

---

## S3 Encryption

| Server Side Encryption<br>(SSE-S3) | Server Side Encryption with AWS KMS<br>(SSE-KMS) | Server Side Encryption with Customer-Provided Keys<br>(SSE-C) | Client-Side Encryption |
|:---:|:---:|:---:|:---:|
| S3 managed keys | KMS managed keys | Customer managed keys | Client managed keys |
| Unique object keys | Can be AWS or client managed | Not stored in AWS | Can use KMS or not stored in AWS |

---

## S3 Default Encryption

- All S3 buckets have encryption configured by default
- All new object uploads to S3 are automatically encrypted
- There is no additional cost and no performance impact
- Objects are automatically encrypted by using server-side encryption with S3 managed keys (SSE-S3)
- To encrypt existing objects, you can use S3 Batch Operations 
  - Can apply retroactive encryption to existing objects in the bucket
  - Can also apply other actions like:
    - Copying objects to another bucket
    - Changing object ownership
    - Applying object tags
- You can also encrypt existing objects using `CopyObject` API operation or the `copy-object` command in the AWS CLI
- Can also encforce encryption by using bucket policies with the conditions:<br>`aws:SecureTransport` or `"s3:x-amz-server-side-encryption": "aws:kms"`

---

## S3 Event Notifications

- Sends notifications when certain events occur in an S3 bucket
- Destinations include:
  - **Amazon Simple Notification Service (SNS)**: A fully managed pub/sub messaging service
  - **Amazon Simple Queue Service (SQS)**: A fully managed message queuing service
  - **AWS Lambda**: A serverless compute service that runs code in response to events

---

## What does "pub/sub" mean? 

  - **Publisher**: The entity that produces messages 
    - e.g., S3 bucket
  - **Subscriber**: The entity that consumes messages 
    - e.g., SNS topic, SQS queue, Lambda function
  - **SNS Topic**: A logical access point for publishing messages 
    - e.g., `MyEmail` (a channel for messages you can subscribe to)
  - **Subscription**: A relationship between a topic and a subscriber
    - e.g., SQS queue subscribed to an SNS topic

---

## S3 Presigned URLs

- A presigned URL is a URL that you can provide to users to grant temporary access to a specific S3 object (default expiration is 1 hour)
- Presigned URLs are generated using the `generate_presigned_url` method in the AWS SDKs or the `aws s3 presign` command in the AWS CLI
- Can also generate presigned URLs for S3 objects that are encrypted with server-side encryption using AWS KMS (SSE-KMS)
  - Requires additional parameters to specify the KMS key used for encryption
  - The presigned URL will include the necessary information for the recipient to access the encrypted object

---

## S3 Multipart Upload

- Allows uploading large objects in parts independently, in parallel, and in any order
- Performed by using S3 Multipart Upload API operations or the `aws s3api` command in the AWS CLI
- It is recommended for objects larger than 100 MB to improve upload performance and reliability
- Can be used for objects from 5 MB to 5 TB in size
- Must be used for objects larger than 5 GB in size

---

## S3 Transfer Acceleration

- Uses CloudFront edge locations to improve performance of transfers from clients to S3 buckets
- Is enabled at a bucket level and requires the use of a specific endpoint for uploads 
  - e.g., `bucketname.s3-accelerate.amazonaws.com`
- AWS only charges if there is a performance improvement 

**Keep an eye out for exam questions about long distance transfers to S3 and performance improvements!**

---

## S3 Select and Glacier Select

- **S3 Select**: Allows SQL expression to rerieve individual data from an S3 object (like a ZIP archive) without having to retrieve the entire object
- **Glacier Select**: Similar to S3 Select but for objects stored in S3 Glacier storage classes

---

## Server Access Logging

- Provides detailed records for the requests made to an S3 bucket
- Details include:
  - Requester
  - Bucket name
  - Request time
  - Action type
  - Error code (if any)
- Disabled by default and must be enabled on a per-bucket basis
- Only pay for the storage space used
- Must configure a target bucket to store the log files 
  - Cannot be the same bucket being logged
- Must grant write permissions to the S3 Log Delivery group for the target bucket

---

## CORS with S3

- **Cross-Origin Resource Sharing (CORS):**
  - Allows request from an origin (domain) to another origin
  - Origin is defined by DNS name, protocol, and port
  - CORS is implemented on the bucket you want to access, not the bucket you are accessing from

- **Preflight request**: A preliminary request made by the browser to determine if the actual request is safe to send
  - Uses the HTTP OPTIONS method
  - Checks for permissions and allowed methods before sending the actual request

---

## HOL Notes - CORS with S3

- `mb` command creates a bucket in the default region (`us-east-1`)
- `external-id` is the password you set to access the bucket 
- ` aws sts assume-role --role-arn <role-arn> --role-session-name <session-name> --external-id <external-id>` grants temporary credentials to access the bucket

---

## S3 Object Lambda

- Uses functions to process output of S3 GET requests before returning the data to the requester
- Allows you to modify and process data as it is retrieved from S3 without changing the underlying data in the bucket
- You can use your own functions or AWS pre-built functions

### Use cases include:
  - Data transformation 
    - e.g., converting data formats, filtering data
  - Data masking 
    - e.g., redacting sensitive information
  - Custom authentication and authorization 
    - e.g., adding additional access controls

---

## S3 Object Lambda - Prebuilt Functions

- **PII Detection**: Automatically detects and redacts **personally identifiable information (PII)** from S3 objects
- **PII Access Control**: Restricts access to S3 objects that contain PII based on user permissions
- **PII Redaction**: Redacts PII from S3 objects before returning the data to the requester
- **Decompression**: Automatically decompresses compressed S3 objects (e.g., gzip) before returning the data to the requester

---

## Quick References

### [Exam Cram - S3](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28618766#overview)

### [S3 Architecture Patterns Private Link](https://drive.google.com/drive/folders/16L16izeISjBs_cqwHu1aa2X2CkrquICm?usp=drive_link)

### [S3 Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346104#overview)
### [S3 Cheat Sheet](https://digitalcloud.training/amazon-s3-and-glacier/)

---
