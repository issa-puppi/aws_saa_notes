## Infrastructure as Code (IaC) with CloudFormation
  - Infrastructure patterns are defined in a **template** file using **code** (JSON or YAML)
  - CloudFormation **builds** your infrastructure based on the template
  - Creates a **stack** which is a collection of AWS resources that you can manage as a single unit

---

### Infrastructure as Code (IaC)
  - IaC is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than manual hardware configuration or interactive configuration tools.

---

## AWS CloudFormation
  - A service that allows you to model and set up your AWS resources using templates
  - Templates are JSON or YAML files that define the resources and their configurations
  - Enables repeatable and consistent infrastructure deployment
  - Supports a wide range of AWS services and resources
  - Can be used to deploy Elastic Beanstalk environments, EC2 instances, VPCs, and more

---

### Benefits of CloudFormation
  - **Automation**: Automates provisioning and management of AWS resources, reducing manual effort and human error
  - **Consistency**: Ensures infrastructure is deployed identically across environments (e.g., dev, staging, prod)
  - **Version Control**: Templates can be stored in version control systems (e.g., Git) to track changes and enable collaboration
  - **Reusability**: Templates can be reused across projects and environments, improving efficiency
  - **Integration**: Integrates with AWS services (e.g., CodePipeline) for CI/CD workflows
  - **Cost Efficiency**: No additional cost for CloudFormation (pay only for created resources)
  - **Drift Detection**: Detects configuration changes made outside of CloudFormation

---

## AWS CloudFormation Components

| **Component** | **Description** |
|---------------|-----------------|
| **Template** | A JSON or YAML text file that contains the instructions for building the AWS environment |
| **Stack** | The entire environment created by CloudFormation based on the template <br> Is the sum of all the resources defined in the template <br> Created, updated, or deleted as a single unit |
| **Stack Set** | Extends the functionality of stacks by allowing you to manage multiple stacks across multiple accounts and regions with a single template or operation |
| **Change Set** | A summary of proposed changes to a stack that allows you to review and see how the changes will affect your resources before implementing them |

---

## Nested Stacks
  - A stack that is created as part of another stack
  - Allows you to reuse common template patterns and manage related resources together
  - Helps to break down complex templates into smaller, more manageable pieces

---

## IaaS vs PaaS
  - **IaaS (Infrastructure as a Service)**: Provides virtualized computing resources over the internet. You manage the operating system, applications, and data.
    - Examples include **Amazon EC2** and **Amazon S3**
  - **PaaS (Platform as a Service)**: Provides a platform allowing customers to develop, run, and manage applications without dealing with the underlying infrastructure.
    - Examples include **AWS Elastic Beanstalk** and **AWS Lambda**

---

## AWS Elastic Beanstalk
  - A **PaaS service** that allows you to **deploy and manage applications** without worrying about the underlying infrastructure
    - Everything within the environment is **launched and managed** by Elastic Beanstalk
    - Automatically handles capacity provisioning, load balancing, scaling, and health monitoring
  - Supports multiple programming languages and platforms including:
    - Java, .NET, PHP, Node.js, Python, Ruby, Go, and Docker
  - Uses Core AWS services such as EC2, ECS, Auto Scaling, and Elastic Load Balancing
  - Provides a simple UI to manage and monitor your applications
  - Managed platform updates and patches deploy the latest versions
  - Source files are formatted as a ZIP file or War file

 ---

## Application Versions
  - A specific reference to a section of deployable code for an application
  - The app version with point typically to an S3 bucket where the code is stored
  - Versions can be applied to any environment 

---

## Environments
  - An app version that has been deployed on AWS Resources
  - The resources are configured and provisioned by AWS Elastic Beanstalk
  - The environment is comprised of all the AWS resources created by Elastic Beanstalk
    - More than the EC2 instance created with your application code
    - Also includes the load balancer, auto-scaling group, security groups, and more

---

### Web Server Environments
  - **Standard apps** that **listen for and then process HTTP** requests 
    - **Port 80** for HTTP and **Port 443** for HTTPS
  - Examples include web applications, APIs, and websites

---

### Workers Environments
  - Are **specialized apps** that have a background processing task 
    - **Listens for and then processes** messages from an **Amazon SQS queue**
  - Can also be used for **long-running tasks** that are not suitable for web servers
    - Such as data processing, batch jobs, and other asynchronous tasks

---

## AWS Systems Manager Parameter Store (SSM Parameter Store)
  - Provides **secure, hierarchical storage** for configuration data management and secrets management
  - Allows you to store values as **key-value pairs** and reference them in your applications
  - Highly scalable, available, and durable 
  - Supports **encryption** using AWS KMS for sensitive data
    - Stored as plain text (unencrypted) or ciphertext (encrypted)
  - Can be used to manage configuration data across multiple environments and applications
  - No native rotation of keys, but can be integrated with AWS Lambda for custom rotation logic
    - Different from AWS Secrets Manager which has built-in rotation capabilities

---

## AWS Config
  - A service that enables you to **assess, audit, and evaluate** the configurations of your AWS resources
  - Allows you to **track changes** to your AWS resources
    - Maintains a history of resource configurations
  - Provides **compliance auditing** and **security analysis** 
    - By comparing current to ideal configurations
  - Can be used to **automate remediation** of non-compliant resources 
    - Via AWS Systems Manager Automation or AWS Lambda
  - Can receive notifications whenever a resource is created, modified, or deleted
    - Via Amazon SNS or AWS Lambda
  - Supports **custom rules** that you can create 
    - Help to evaluate specific configurations or compliance requirements

---

### Example Rules

| **Example Rule** | **Description** |
|------------------|-----------------|
| `s3-bucket-server-side-encryption-enabled` | Checks if S3 buckets have S3 default encryption enabled or that the S3 bucket policy explicitly denies put-object requests without server-side encryption |
| `restricted-ssh` | Checks if security groups allow unrestricted incoming SSH traffic (port 22) from the internet |
| `rds-instance-public-access-check` | Checks if RDS instances are publicly accessible |
| `cloudtrail-enabled` | Checks if AWS CloudTrail is enabled in your account |

---

## AWS Secrets Manager
  - A service that helps you protect access to your applications, services, and IT resources
    - Without the upfront cost and complexity of self-managing a **hardware security module (HSM)** infrastructure
  - Stores and manages secrets such as:
    - Database credentials
    - API keys
    - Other sensitive information
  - Supports built-in **automatic rotation** for supported AWS services:
    - Amazon RDS / Amazon Aurora 
    - Amazon Redshift
    - Amazon DocumentDB
    - MySQL / PostgreSQL
    - Oracle, MariaDB, and SQL Server databases
  - Can also rotate secrets for other applications using AWS Lambda
    -  Same as SSM Parameter Store but with built-in rotation capabilities

---
  
## AWS SSM Parameter Store vs AWS Secrets Manager

| **Feature** | **Secrets Manager** | **SSM Parameter Store** |
|-------------|---------------------|-------------------------|
| **Automatic Key Rotation** | Yes, built-in for supported services, <br> can use AWS Lambda for others | No native key-rotation; <br>can be done with AWS Lambda |
| **Key/Value Type** | String or Binary (encrypted) | String, StringList,<br> or SecureString (encrypted) |
| **Hierarchical Keys** | No | Yes |
| **Cost** | Charges applied per secret | Free for standard parameters, <br>charges for advanced parameters |

---

## AWS Resource Access Manager (RAM)
  - A service that enables you to **share your AWS resources** within or across AWS accounts
  - The list of [supported resources](https://docs.aws.amazon.com/ram/latest/userguide/shareable.html) is extensive and includes:
    - Amazon VPC subnets
    - AWS Transit Gateways
    - AWS License Manager configurations
    - AWS Resource Groups
    - And many more
  - **Participants** in a resource share can be AWS accounts, organizational units (OUs), or entire AWS Organizations
    - Participants **can** accept or reject resource share invitations
    - Participants **can** create, modify, and delete their own resources 
    - Participants **cannot** view or modify resources of other participants or the VPC owner

---

## RPO (Recovery Point Objective)
  - The maximum acceptable amount of data loss measured in time
  - For example: 
    - an RPO of 1 hour = in the event of a failure, you can afford to lose up to 1 hour of data

---

## RTO (Recovery Time Objective)
  - The maximum acceptable amount of time to restore a system after a failure
  - For example: 
    - an RTO of 4 hours = in the event of a failure, you need to have the system back up and running within 4 hours
  
---

## Achievable RPOs

| **Recovery Point Objective (RPO)** | **Technique** | **Examples** |
|------------------------------------|---------------|--------------|
| Milliseconds to seconds | Synchronous replication | Amazon RDS Multi-AZ, Amazon Aurora (within region) |
| Seconds to minutes | Asynchronous replication | Amazon RDS Read Replicas, Amazon S3 Cross-Region Replication, Aurora Global Database |
| Minutes to hours | Backup and restore | Snapshot copies, Amazon S3 versioning and lifecycle policies |
| Hours to days | Offsite / traditional / tape backups | AWS Backup, third-party backup solutions |

**RPO** is determined by **replication method** not **backup frequency**

---

## Achievable RTOs

| **Recovery Time Objective (RTO)** | **Technique** | **Examples** |
|-----------------------------------|---------------|--------------|
| Milliseconds to seconds | Fault tolerance and failover | Mirrored disk, Multi-AZ deployments |
| Seconds to minutes | High availiability, load balancing, auto-scaling | Amazon EC2 Auto Scaling, Elastic Load Balancing |
| Minutes to hours | Cross-site recovery, warm standby, automated recovery | Amazon RDS Read Replicas, AWS Elastic Beanstalk |
| Hours to days | Cross-site recovery (traditional, cold standby), manual recovery | AWS Backup, third-party backup solutions |

**RTO** is determined by **recovery method** not **backup frequency**

---

## Disaster Recovery (DR) Strategies

| **DR Strategy** | **Description** | **Use Case** | **RTO** | **RPO** | **Cost** |
|-----------------|-----------------|--------------|---------|---------|----------|
| **Backup & Restore** | Backups stored (optionally cross-region), infrastructure provisioned and data restored after failure | Low priority, non-critical workloads | Hours to days | Hours to days | $ |
| **Pilot Light** | Core components (e.g., database) always running, other services started on failure | Moderate priority workloads | Minutes to hours | Seconds to minutes | $$ |
| **Warm Standby** | Fully functional but scaled-down environment always running, scaled up on failure | Business-critical workloads | Seconds to minutes | Seconds (low) | $$$ |
| **Multi-Site Active-Active** | Fully active environments in multiple regions with load balancing and continuous replication | Mission-critical workloads | Near zero | Near zero | $$$$ |

### What is running?
  - **Backup** → nothing running 
  - **Pilot Light** → core only (DB)
  - **Warm Standby** → full system (small)
  - **Active-Active** → full system (full size, live)

---

## Warm vs Cold Standby

### Warm Standby
  - A **scaled-down but fully running environment** in another region/AZ
  - Continuously receives data (typically via replication)
  - Can be **quickly scaled up** during a failure
  - **Lower RTO, moderate RPO**
  - Higher cost (resources are always running)

---

### Cold Standby
  - Infrastructure is **not running (or minimally provisioned)**
  - Data is backed up (snapshots, backups) but environment must be **provisioned on failure**
  - Requires:
    - Restoring data
    - Launching infrastructure
  - **Higher RTO, higher RPO**
  - Lowest cost (pay only for storage/backups)

---

## AWS OpsWorks

### Overview
  - Configuration management service using:
    - **Chef** (cookbooks, recipes)
    - **Puppet** (manifests, modules)

  - Used to **automate infrastructure configuration, deployment, and management**
    - e.g., install packages, configure servers, manage scaling

---

### Key components
  - **OpsWorks Stacks**
    - Automates infrastructure using Chef recipes
    - Organizes resources into **layers** (e.g., load balancer, app, DB)
    - Supports:
      - Auto healing (replaces failed instances)
      - EC2 + EBS provisioning
      - Event-based configuration (e.g., on boot, deploy)
    - Supports Linux and Windows

  - **OpsWorks for Chef Automate**
    - Managed Chef server
    - Handles:
      - Backups (stored in S3)
      - Patching and updates
      - Scaling nodes (via Auto Scaling + user data)
    - Supports hybrid environments (on-prem + AWS)
    - Uses SSL for secure communication

  - **OpsWorks for Puppet Enterprise**
    - Managed Puppet master server
    - Similar to Chef Automate:
      - Automated backups (S3)
      - SSL-secured communication
      - Easy node onboarding
      - Automatic updates

---

### Integrations
  - CloudWatch → monitoring
  - CloudTrail → logging and auditing

---

### Key features
  - **Auto healing** (replace failed instances)
  - **Configuration as code** (Chef/Puppet)
  - **Hybrid support** (on-prem + cloud)

---

### Pricing
  - OpsWorks Stacks → no additional cost (pay for resources only)
  - Chef / Puppet → charged per node + instance usage

---

### Key characteristic
  - Provides **configuration management**, not infrastructure provisioning (like CloudFormation)

---
  
## Quick References

### [DR Architecture Strategies - AWS Official - Part 1](https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-i-strategies-for-recovery-in-the-cloud/)

### [DR Architecture Strategies - AWS Official - Part 2](https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-ii-backup-and-restore-with-rapid-recovery/)

### [DR Architecture Strategies - AWS Official - Part 3](https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-iii-pilot-light-and-warm-standby/)

### [Deployment and Management Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619424#overview)

### [Deployment and Management Architecture Patterns Private Link](https://drive.google.com/drive/folders/1YOKMWiyAdK8nkidsm4CHRpNxfjvI3oWq?usp=drive_link)

### [Deployment and Management Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346116#overview)

### [Cloud Formation Cheat Sheet](https://digitalcloud.training/aws-cloudformation/)

### [AWS Elastic Beanstalk](https://digitalcloud.training/aws-elastic-beanstalk/)

### [AWS Config](https://digitalcloud.training/aws-config/)

### [AWS Resource Access Manager](https://digitalcloud.training/aws-resource-access-manager/)

### [AWS Systems Manager](https://digitalcloud.training/aws-systems-manager/)

### [AWS OpsWorks](https://digitalcloud.training/aws-opsworks/)

---