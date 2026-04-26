# Infrastructure as Code (IaC)
---

## IaC Concepts

**Infrastructure as Code (IaC)** is the practice of defining and provisioning computing infrastructure through machine-readable definition files rather than manual configuration or interactive tools.
<br>Instead of clicking through consoles or running imperative scripts, you declare the desired end-state and let the tool figure out how to get there.

**Benefits that appear on the exam:**
- Consistent, repeatable deployments — eliminates configuration drift between environments
- Version-controlled templates — changes tracked in Git, peer-reviewed, auditable
- Rollback capability — redeploy a previous template version to revert infrastructure
- No additional service cost — you pay only for the resources created, not the IaC tooling

---

## IaaS vs. PaaS

Understanding where a service sits on the cloud service model spectrum is a recurring exam concept — it determines how much you manage vs. how much AWS manages.

| **Feature** | **IaaS** | **PaaS** |
|-------------|----------|----------|
| **Full name** | Infrastructure as a Service | Platform as a Service |
| **What AWS provides** | Virtualized compute, storage, and networking | A managed runtime platform on top of the infrastructure |
| **What you manage** | OS, middleware, runtime, application, data | Application and data only |
| **Control level** | High — full access to the underlying resources | Lower — platform decisions made by the service |
| **Operational overhead** | Higher — you patch, configure, and scale | Lower — AWS handles capacity, patching, and scaling |
| **AWS examples** | Amazon EC2, Amazon EBS, Amazon VPC | AWS Elastic Beanstalk, AWS Lambda |
| **Best for** | Full control, custom configurations, lift-and-shift | Rapid application deployment, reduced ops burden |

**The practical difference:** With IaaS (EC2), you choose the OS, install the runtime, configure Auto Scaling, and manage patching. With PaaS (Elastic Beanstalk), you upload a ZIP file and AWS handles everything below your application code.

> 💡 **Exam Tip:** "Deploy an application without managing EC2, OS, or scaling configuration" → **PaaS (Elastic Beanstalk)**
<br>IaC (CloudFormation) is orthogonal to this distinction — it can *provision* either IaaS resources (EC2) or trigger PaaS deployments (Beanstalk environments) from code.

---

## AWS CloudFormation

AWS CloudFormation is the native AWS IaC service. It reads a **template** (JSON or YAML), makes the API calls to create your resources, and groups the results into a **stack** managed as a single unit.

> 💡 **Exam Tips:**
> <br>"Deploy and provision AWS resources from code" → **CloudFormation**
> <br>"Deploy a serverless application (Lambda + API Gateway + DynamoDB)" → **CloudFormation + SAM**
> <br>"Deploy infrastructure consistently across multiple accounts and regions" → **CloudFormation StackSets**

---

## CloudFormation Template Anatomy

A CloudFormation template is a JSON or YAML document describing the end state of your infrastructure. 
<br>Templates are uploaded directly to CloudFormation or via Amazon S3.

| **Section** | **Required?** | **Description** |
|-------------|--------------|-----------------|
| **Resources** | ✅ Yes | Declares the AWS resources to create; the only mandatory section |
| **Parameters** | No | Input values supplied at stack creation/update; enables template reuse — up to 60 parameters † |
| **Mappings** | No | Fixed key-value lookup tables; good for region-to-AMI mappings, environment-specific values |
| **Outputs** | No | Values exported for use by other stacks (cross-stack references) — up to 60 outputs † |
| **Conditions** | No | Logical statements that control whether resources or outputs are created |
| **Transform** | No | Specifies macros (e.g., `AWS::Serverless-2016-10-31` for SAM, or S3-referenced snippets) |
| **Metadata** | No | Additional information about the template |

**Logical IDs** are used to reference resources within a template; **Physical IDs** identify the actual created resources outside CloudFormation.

### Pseudo Parameters

Built-in parameters that CloudFormation provides automatically — you do not declare them. Common ones on the exam:

| **Pseudo Parameter** | **Returns** |
|----------------------|-------------|
| `AWS::AccountId` | Account ID of the stack owner |
| `AWS::Region` | Region where the stack is being created |
| `AWS::StackId` | Full ARN of the stack |
| `AWS::StackName` | Name of the stack |
| `AWS::NoValue` | Removes a property when used as a value |

> 🔧 **Pro Tip:** Pseudo parameters are how you make templates portable across regions and accounts without hard-coding values. 
<br> `AWS::Region` is the most common one you'll use in practice.

### Intrinsic Functions

> 🔧 **Pro Tips:**
> <br>`!Ref` — returns the value of a parameter, or the physical ID of a resource
> <br>`!GetAtt` — returns an attribute value from a resource (e.g., `!GetAtt MyLB.DNSName`)
> <br>`!FindInMap` — looks up a value from a Mappings section by key path
> <br>`!Sub` — substitutes variables into a string at runtime (useful in resource names and commands)
> <br>`!Join` — concatenates values with a delimiter
> <br>`!ImportValue` — imports an output exported from another stack (used in cross-stack references)
> <br>`!If` — conditional value selection based on a Condition

---

## CloudFormation Stacks

A **stack** is the set of AWS resources created, updated, and deleted together as a single unit based on a template.

| **Stack Behavior** | **Detail** |
|--------------------|-----------|
| **Creation failure** | By default, all resources are rolled back and deleted on any creation error § |
| **Update failure** | Stack automatically rolls back to the last known good state § |
| **Rollback disable** | Can be disabled at creation time to leave resources in place for troubleshooting |
| **Charged on failure** | You are charged for any resources that were provisioned before the failure ¤ |
| **Update methods** | Direct update (immediate) or Change Set (preview before applying) |

> ⚠️ **Exam Trap:** If CloudFormation fails to create a stack, you may still be charged for resources that were provisioned before the failure occurred.

---

## CloudFormation Change Sets

A **Change Set** is a preview of the proposed changes to a stack before you apply them. It lets you review which resources will be added, modified, or deleted before committing.

- Create a Change Set → review impact → execute or discard
- Use Change Sets for production updates to avoid unintended resource replacement or deletion

> 💡 **Exam Tip:** "Preview how a stack update will affect existing resources" → **Change Set**

---

## CloudFormation Stack Sets

**Stack Sets** extend stacks by enabling you to create, update, or delete stacks across **multiple accounts and regions** with a single operation and template.

- An **administrator account** creates and manages the StackSet
- **Target accounts** receive the provisioned stacks; a trust relationship must exist between administrator and target accounts
- Useful for standardizing infrastructure across an AWS Organization

> 💡 **Exam Tip:** "Deploy the same CloudFormation template to 50 AWS accounts across 3 regions simultaneously" → **CloudFormation StackSets**

---

## Nested Stacks

A **Nested Stack** is a CloudFormation stack created as a resource within another (parent) stack.

- Enables reuse of common template patterns (e.g., a standard VPC template, a standard ALB template)
- Breaks down large, complex templates into smaller, maintainable pieces
- The parent stack manages the lifecycle of all nested stacks
- **Cannot delete a parent stack if a nested stack's outputs are referenced by another stack**

---

## Stack Policies and Drift Detection

**Stack Policies** — JSON documents that explicitly protect sensitive stack resources from accidental update or deletion. Applied to a stack, they restrict which resources can be updated.

**Drift Detection** — identifies whether the live configuration of stack resources differs from the template. Resources modified directly (outside CloudFormation) are flagged as **drifted**.

> 💡 **Exam Tips:**
> <br>"Detect resources changed outside of CloudFormation" → **Drift Detection**
> <br>"Prevent accidental update of a production database in a stack" → **Stack Policy**

---

## CloudFormation and SAM

**AWS Serverless Application Model (SAM)** is an extension to CloudFormation for defining serverless applications. It provides simplified syntax for Lambda functions, API Gateway APIs, DynamoDB tables, and other serverless resources.

- Uses `Transform: AWS::Serverless-2016-10-31` in the template header
- SAM CLI packages deployment code, uploads to S3, and deploys via CloudFormation

> 📚 **Learn More:** SAM is covered in the context of serverless deployments in **Module 10 — Serverless Apps**.

---

## CloudFormation Helper Scripts

> 🛠️ **Implementation Notes:**
> <br>**`cfn-init`** — reads `AWS::CloudFormation::Init` metadata to install packages, write files, start/stop services; logs to `/var/log/cfn-init.log`
> <br>**`cfn-signal`** — signals CloudFormation that instance initialization is complete; used with `CreationPolicy` or `WaitOnResourceSignals` to hold stack creation until the instance is ready
> <br>**`cfn-hup`** — daemon that detects changes to resource metadata and runs user-specified hooks
> <br>User data scripts passed via `Fn::Base64`; output logged to `/var/log/cloud-init-output.log`

---

## CloudFormation vs. Elastic Beanstalk

| **Feature** | **CloudFormation** | **Elastic Beanstalk** |
|-------------|-------------------|----------------------|
| **Abstraction level** | Low — you define every resource | High — AWS manages the infrastructure |
| **Primary use** | Infrastructure provisioning (IaC) | Application deployment (PaaS) |
| **Scope** | Any AWS resource | Web apps and worker apps |
| **Template format** | JSON or YAML templates | ZIP or WAR files |
| **Cost** | Free — pay only for resources ¤ | Free — pay only for resources ¤ |
| **Analogy** | Similar to Terraform | Similar to Google App Engine / Heroku |

---

# Platform as a Service (PaaS)
---

## AWS Elastic Beanstalk

AWS Elastic Beanstalk is a **PaaS service** that deploys and manages applications without requiring you to manage the underlying infrastructure. You upload code, Beanstalk handles capacity provisioning, load balancing, auto-scaling, and health monitoring.

**Supported platforms (know the list for the exam):** Java, .NET (Windows and Linux), Node.js, PHP, Python, Ruby, Go, and Docker (single and multi-container).

**Key properties:**
- Uses core AWS services under the hood: EC2, ECS, Auto Scaling, ELB, S3
- Managed platform updates automatically apply the latest OS and platform patches
- Integrated with CloudWatch (monitoring), X-Ray (tracing), and VPC/IAM
- Application source code deployed as a **ZIP** or **WAR** file
- Logs accessible from the console without logging into individual instances
- Fault-tolerant within a single region; can span multiple AZs ◊
- No additional cost for Beanstalk itself ¤

---

## Elastic Beanstalk Application Layers

| **Layer** | **Description** |
|-----------|-----------------|
| **Application** | Top-level container; holds all environments, environment configurations, and application versions |
| **Application Version** | Specific reference to a deployable code artifact; points to an S3 bucket containing the code |
| **Environment** | An application version deployed on provisioned AWS resources — the full set of resources, not just the EC2 instance |
| **Environment Tier** | Determines the resource configuration: **Web Server** or **Worker** |
| **Environment Configuration** | Collection of parameters and settings controlling how Beanstalk provisions and configures environment resources |
| **Configuration Template** | Baseline for creating new environment configurations |

---

## Environment Tiers — Web Server vs. Worker

| **Feature** | **Web Server Tier** | **Worker Tier** |
|-------------|---------------------|-----------------|
| **Purpose** | Standard web applications | Background processing tasks |
| **Request source** | HTTP/HTTPS requests (ports 80 / 443) | Messages from an Amazon SQS queue |
| **Use cases** | Web apps, APIs, websites | Data processing, batch jobs, async tasks |
| **Scheduled tasks** | No | Yes — defined in `cron.yaml` |

> 💡 **Exam Tips:**
> <br>"Decouple long-running tasks from a web application" → **Elastic Beanstalk Worker tier + SQS**
> <br>"Application that processes HTTP requests" → **Web Server tier**

---

## Elastic Beanstalk Deployment Policies

| **Policy** | **Downtime** | **Zero Downtime** | **Rollback** | **Extra Cost** | **Capacity reduction** |
|------------|-------------|-------------------|--------------|----------------|----------------------|
| **All at once** | Yes (total outage) | ✗ | Manual redeploy | None | Total |
| **Rolling** | Partial (per batch) | ✓ | Manual redeploy | None | Per batch |
| **Rolling with additional batch** | None | ✓ | Manual redeploy | Small (batch) | None |
| **Immutable** | None | ✓ | Terminate new ASG | High (2x instances) | None |
| **Blue / Green** | None | ✓ | Swap URL back | Varies | None |

**All at once** — Deploys new version to all instances simultaneously. Fastest, but causes a complete outage. Good for development; never use in production.

**Rolling** — Deploys to a batch of instances at a time; both versions run simultaneously during the update. Reduced capacity during deployment.

**Rolling with additional batch** — Like Rolling but adds a new batch of instances first, so full capacity is maintained throughout.

**Immutable** — Launches an entirely new ASG with new instances, deploys there, then swaps traffic when healthy. Zero-downtime, quickest rollback (just terminate the new ASG), but highest cost.

**Blue / Green** — Not a built-in Beanstalk policy; you create a new (green) environment manually, test it, then use **Swap URLs** in Beanstalk to redirect traffic. Route 53 weighted policies can split traffic during testing.

> ⚠️ **Exam Trap:** Blue/Green is NOT a built-in Elastic Beanstalk deployment policy — it is a manual process using two separate environments and URL swapping.

> 💡 **Exam Tips:**
> <br>"Fastest deployment, development only, brief total outage acceptable" → **All at once**
> <br>"Zero downtime, zero capacity reduction, quickest rollback" → **Immutable**
> <br>"Zero downtime, test in isolation before switching traffic" → **Blue/Green (Swap URLs)**

---

## Elastic Beanstalk Extensions (.ebextensions)

`.ebextensions` allow you to customize your Elastic Beanstalk environment from within your source code bundle.

- Configuration files are YAML or JSON with a `.config` extension
- Must live in a `.ebextensions/` directory at the top level of the source bundle
- Can install packages, create users/groups, run shell commands, configure a load balancer, add RDS/ElastiCache/DynamoDB resources
- Resources added via `.ebextensions` are **deleted when the environment is terminated**

> 🛠️ **Implementation Notes:**
> <br>Place `.ebextensions/` in the root of your ZIP or WAR file before uploading
> <br>To configure HTTPS: load the SSL certificate onto the load balancer via `.ebextensions/securelistener-alb.config` or the console
> <br>HTTP → HTTPS redirect: configure at the application level or with an ALB listener rule

---

## Elastic Beanstalk Lifecycle Policies

- Elastic Beanstalk stores a maximum of **1,000 application versions** † per application
- To manage old versions, configure a lifecycle policy based on:
  - **Time-based** — delete versions older than N days
  - **Count-based** — retain only the N most recent versions
- Versions currently in use (deployed to an environment) are never deleted
- Optionally preserve the source bundle in S3 even when the version record is deleted

---

## Elastic Beanstalk with RDS

- You can deploy an RDS instance **inside** a Beanstalk environment — convenient but risky: terminating the environment also terminates the database
- This is appropriate for **development environments only**
- For production, create RDS **outside** Beanstalk and reference it via connection string environment variables

**To migrate from RDS-inside to RDS-outside:**
1. Snapshot the RDS instance
2. Enable deletion protection on the RDS instance
3. Create a new Beanstalk environment without RDS, pointing to the existing database
4. Blue/Green swap (Swap URLs)
5. Terminate the old environment — RDS survives due to deletion protection
6. Manually delete the stuck CloudFormation stack (it will be in `DELETE_FAILED` state)

---

# Configuration Management
---

## AWS OpsWorks

AWS OpsWorks is a **configuration management service** providing managed instances of **Chef** and **Puppet** — two industry-standard open-source automation platforms.

**Key distinction:** OpsWorks provides *configuration management* (how software is installed and configured on existing infrastructure), not *infrastructure provisioning* (like CloudFormation).

| **Component** | **Technology** | **Description** |
|---------------|---------------|-----------------|
| **OpsWorks Stacks** | Chef (recipes/cookbooks) | Organizes resources into layers; automates config, deployment, scaling, and healing on EC2 and on-premises |
| **OpsWorks for Chef Automate** | Chef | Fully managed Chef Automate server; backups to S3, SSL, auto-updates, supports hybrid (on-prem + cloud) |
| **OpsWorks for Puppet Enterprise** | Puppet (manifests/modules) | Fully managed Puppet master; backups to S3, SSL, auto-updates |

**Key features across all OpsWorks components:**
- **Auto healing** — automatically replaces failed instances to maintain uptime
- **Configuration as code** — Chef recipes or Puppet manifests define desired state
- **Hybrid support** — can manage both EC2 instances and on-premises servers
- Integrated with CloudWatch (monitoring) and CloudTrail (logging/auditing)

**Pricing:**
- OpsWorks Stacks — no additional cost; pay only for provisioned resources ¤
- OpsWorks for Chef Automate / Puppet Enterprise — charged per node per hour ¤ (7,500 node hours/month free with AWS Free Tier)

> 💡 **Exam Tip:** "Manage infrastructure configuration using Chef or Puppet" → **AWS OpsWorks**

---

# Operations and Governance
---

## AWS Systems Manager (SSM)

AWS Systems Manager provides a **unified interface** for operational visibility and control across your AWS and on-premises infrastructure. It is the go-to service for fleet management, configuration compliance, patch automation, and secure remote access — without opening firewall ports or managing SSH keys.

**Pre-requisite:** EC2 instances must have the **SSM Agent** installed and the appropriate IAM instance profile attached. SSM Agent comes pre-installed on most Amazon-provided AMIs. §

### SSM Capabilities Overview

| **Capability** | **What It Does** |
|----------------|-----------------|
| **Session Manager** | Browser- or CLI-based shell access to EC2/on-prem instances — no SSH, no bastion, no open ports |
| **Run Command** | Run scripts or commands across a fleet of managed instances simultaneously |
| **Patch Manager** | Automate patching of OS and applications; uses patch baselines and maintenance windows |
| **Parameter Store** | Secure, hierarchical key-value store for configuration data and secrets |
| **Automation** | Run pre-built or custom runbooks (SSM Documents) to automate common IT tasks |
| **State Manager** | Ensure instances remain in a defined desired state (e.g., software installed, service running) |
| **Inventory Manager** | Collect and query software inventory metadata from managed instances |
| **Maintenance Windows** | Schedule maintenance tasks during defined time windows |
| **Distributor** | Securely store and distribute software packages across your fleet |
| **OpsCenter** | Centralized view for investigating and resolving operational issues (OpsItems) |
| **Incident Manager** | Automate incident response; integrates with AWS Chatbot and runbooks |

---

## SSM Session Manager

Session Manager provides **secure, auditable shell access** to managed instances — no inbound security group rules, no bastion hosts, no SSH key pairs required.

| **Feature** | **Detail** |
|-------------|-----------|
| **Access method** | Browser-based console, AWS CLI, or Session Manager plugin |
| **Protocol** | Encrypted via TLS over HTTPS (port 443) — no port 22 or 3389 required |
| **Authentication** | IAM permissions — not SSH key pairs |
| **Logging** | All session activity logged to S3 and/or CloudWatch Logs |
| **Audit trail** | All API calls recorded in AWS CloudTrail (including `StartSession` events) |
| **OS support** | Linux (bash) and Windows (PowerShell) |

> 💡 **Exam Tip:** "Secure shell access to EC2 without opening port 22 or managing key pairs" → **SSM Session Manager**

> ⚠️ **Exam Trap:** Session Manager replaces the need for bastion hosts. If a question asks how to harden security by eliminating SSH exposure, Session Manager is the answer — not a more restrictive security group rule.

---

## SSM Run Command

Run Command lets you remotely execute commands or scripts across a fleet of managed instances without logging in to each one individually.

- Commands are defined in **SSM Documents** (JSON or YAML)
- Can target instances by tag, resource group, or manual selection
- Available via Console, CLI, SDK, or PowerShell
- All executions logged to S3 / CloudWatch Logs
- Supports rate controls and error thresholds for safe fleet-wide rollout

> 💡 **Exam Tip:** "Run a shell script or administrative command across 500 EC2 instances simultaneously" → **SSM Run Command**

---

## SSM Patch Manager

Patch Manager automates patching of OS and application software on managed instances.

- Uses **patch baselines** — rules defining which patches are auto-approved or declined
- Patch tasks are scheduled as **maintenance window** tasks
- Supports Linux and Windows; covers both OS patches and application patches
- Patch compliance data is queryable across multiple accounts and regions
- Results aggregated per instance and stored in S3 for analysis

---

## SSM Automation

SSM Automation runs **runbooks** — sequences of pre-defined or custom steps (SSM Documents) — to automate common IT operations at scale.

- Pre-built runbooks for common tasks (restart instances, create AMIs, patch and reboot)
- Can require human approval for sensitive steps
- Supports incremental rollout with automatic halt on errors
- Triggerable from Console, CLI, SDK, CloudWatch Events, or Config remediation actions

---

## SSM Parameter Store

AWS Systems Manager Parameter Store provides **secure, hierarchical key-value storage** for configuration data and secrets.

- Stores values as plain text (`String`, `StringList`) or encrypted (`SecureString` using AWS KMS)
- Supports **hierarchical organization** using path-style names: `/dev/db/password`, `/prod/db/password`
- Highly scalable, available, and durable
- **Standard parameters** — free; up to 4 KB value size † ¤
- **Advanced parameters** — charged; up to 8 KB value size; supports parameter policies (expiration, change notification) † ¤
- **No native secret rotation** — rotation can be implemented with AWS Lambda
- Accessible by applications via SDK/CLI without storing credentials in code

> 📚 **Learn More:** For automatic secret rotation and the full Parameter Store vs. Secrets Manager comparison, see the **## AWS Secrets Manager** section below.

---

## AWS Config

AWS Config is a **compliance and configuration tracking service** that continuously monitors and records your AWS resource configurations and evaluates them against desired configurations (Config Rules).

**What Config answers:** *"What did my resource look like at a specific point in time?"*
<br>**What CloudTrail answers:** *"Who made an API call to modify this resource?"*

| **Feature** | **Detail** |
|-------------|-----------|
| **Configuration Items (CIs)** | Point-in-time snapshot of a resource's configuration; recorded whenever a change is detected |
| **Configuration history** | Full timeline of how a resource's configuration has changed over time |
| **Config Rules** | Managed or custom rules that evaluate resource configurations for compliance |
| **Compliance status** | Resources are flagged as **Compliant** or **Noncompliant** |
| **Remediation** | Noncompliant resources can trigger automated remediation via SSM Automation or Lambda |
| **Notifications** | SNS or Lambda notification when resources are created, modified, or deleted |
| **Conformance Packs** | Collections of Config Rules and remediation actions deployed as a unit across accounts |
| **Multi-account/region** | Aggregate Config data across an entire AWS Organization |

### Config Rule Examples

| **Managed Rule** | **What It Checks** |
|------------------|--------------------|
| `cloudtrail-enabled` | CloudTrail is enabled in the account |
| `s3-bucket-server-side-encryption-enabled` | S3 buckets have default encryption enabled |
| `restricted-ssh` | Security groups do not allow unrestricted SSH (port 22) from 0.0.0.0/0 |
| `rds-instance-public-access-check` | RDS instances are not publicly accessible |
| `encrypted-volumes` | EBS volumes attached to EC2 instances are encrypted |

> 💡 **Exam Tips:**
> <br>"Track configuration changes to AWS resources over time" → **AWS Config**
> <br>"Audit compliance — are all S3 buckets encrypted?" → **AWS Config rule**
> <br>"Auto-remediate a noncompliant resource" → **AWS Config + SSM Automation or Lambda**
> <br>"Who changed this resource?" → **AWS CloudTrail** (not Config)

---

## AWS Secrets Manager

AWS Secrets Manager stores and manages sensitive credentials (database passwords, API keys, OAuth tokens) with **built-in automatic rotation** for supported services.

**Supported automatic rotation targets:**
- Amazon RDS (MySQL, PostgreSQL, Oracle, MariaDB, SQL Server)
- Amazon Aurora
- Amazon Redshift
- Amazon DocumentDB
- Custom rotation via AWS Lambda for any other secret

**Key properties:**
- Secrets are encrypted using AWS KMS ¤
- Secrets can be retrieved programmatically via SDK/CLI — no hard-coded credentials
- Supports cross-account access
- Charges apply per secret stored and per API call ¤

---

## Parameter Store vs. Secrets Manager

| **Feature** | **Secrets Manager** | **SSM Parameter Store** |
|-------------|---------------------|-------------------------|
| **Automatic rotation** | Yes — built-in for RDS, Aurora, Redshift, DocumentDB; Lambda for others | No native rotation; Lambda required |
| **Value types** | String or binary (always encrypted) | String, StringList, SecureString (optional KMS encryption) |
| **Hierarchical keys** | No | Yes — path-style naming |
| **Cost** | Charges per secret + per API call ¤ | Standard: free; Advanced: per parameter ¤ |
| **Max value size** | 64 KB † | Standard: 4 KB; Advanced: 8 KB † |
| **Primary use case** | Database credentials, API keys requiring rotation | Configuration data, connection strings, feature flags |

> 💡 **Exam Tips:**
> <br>"Automatic credential rotation for RDS" → **Secrets Manager**
> <br>"Store config values hierarchically (dev/prod paths), no rotation needed" → **SSM Parameter Store**
> <br>"Lowest cost option for storing non-secret config" → **SSM Parameter Store (Standard)**

---

## AWS Resource Access Manager (RAM)

AWS Resource Access Manager (RAM) enables you to **share AWS resources** across accounts or within an AWS Organization — eliminating the need to duplicate resources in every account.

**How it works:**
1. Create a Resource Share
2. Specify the resources to share
3. Specify the target accounts, OUs, or the entire Organization

**Commonly shared resource types:**
- Amazon VPC subnets (most common exam scenario)
- AWS Transit Gateways
- AWS License Manager configurations
- Amazon Route 53 Resolver rules
- AWS Resource Groups
- [Full list in the AWS documentation](https://docs.aws.amazon.com/ram/latest/userguide/shareable.html)

**Participant rules:**
- Can accept or reject resource share invitations
- Can create, modify, and delete their own resources within a shared subnet
- Cannot view or modify resources owned by other participants or the resource owner

**Cost:** No additional charge for RAM ¤

> 💡 **Exam Tips:**
> <br>`Share a VPC subnet across multiple AWS accounts in an Organization` → **AWS RAM**
> <br>`Centrally manage one Transit Gateway used by all accounts` → **AWS RAM**

---

## AWS Trusted Advisor

AWS Trusted Advisor inspects your AWS environment and provides real-time recommendations across **5 pillars**:

| **Pillar** | **Examples** |
|------------|-------------|
| **Cost Optimization** | Idle EC2 instances, underutilized EBS volumes, unassociated Elastic IPs |
| **Performance** | EC2 instances with high utilization, CloudFront header optimization |
| **Security** | MFA on root account, security group open ports, S3 bucket permissions |
| **Fault Tolerance** | RDS Multi-AZ, Auto Scaling groups, EBS snapshots |
| **Service Limits** | Warns when usage approaches service quotas |

**Access tiers:**

| **Support Plan** | **Checks Available** |
|------------------|----------------------|
| Basic / Developer | ~7 core checks (security + service limits only) |
| Business / Enterprise | All checks across all 5 pillars; programmatic access via API |

> 💡 **Exam Tips:**
> <br>`Identify idle or underutilized resources to reduce costs` → **Trusted Advisor**
> <br>`Check if service limits/quotas are being approached` → **Trusted Advisor (Service Limits pillar)**
> <br>`Verify MFA is enabled on the root account` → **Trusted Advisor (Security checks)**
> <br>`Full check access requires` → **Business or Enterprise Support plan**

---

## AWS Service Catalog

AWS Service Catalog lets organizations create and manage **catalogs of approved IT services (products)** that users can deploy — enforcing governance without blocking access to required resources.

- **Products** are CloudFormation templates packaged for self-service deployment
- Products are grouped into **Portfolios** and shared with specific IAM users, groups, or roles
- End users deploy from the approved catalog — they don't need direct CloudFormation permissions
- Supports tagging, budget alerts, and launch constraints per product
- Use case: governance, compliance, standardization in large organizations

> 💡 **Exam Tip:** "Allow developers to deploy only approved infrastructure patterns without direct CloudFormation access" → **AWS Service Catalog**

---

# Disaster Recovery
---

## RPO and RTO

Understanding RPO and RTO is foundational for choosing the right DR strategy on the exam.

**RPO (Recovery Point Objective)** — the maximum acceptable amount of **data loss** measured in time.
<br>An RPO of 1 hour means you can afford to lose up to 1 hour of data in the event of a failure.

**RTO (Recovery Time Objective)** — the maximum acceptable amount of **downtime** — the time between a failure and when the system is restored.
<br>An RTO of 4 hours means the system must be restored within 4 hours of a failure.

> ⚠️ **Exam Trap:** RPO is about **data loss** (how much can you lose?); RTO is about **recovery time** (how fast must you recover?). These are frequently confused on the exam.

---

## Achievable RPOs

| **RPO Range** | **Technique** | **AWS Examples** |
|--------------|---------------|-----------------|
| Milliseconds to seconds | Synchronous replication | Amazon RDS Multi-AZ, Aurora (within region) |
| Seconds to minutes | Asynchronous replication | RDS Read Replicas, S3 Cross-Region Replication, Aurora Global Database |
| Minutes to hours | Backup and restore | Snapshot copies, S3 versioning and lifecycle policies |
| Hours to days | Offsite / traditional backup | AWS Backup, third-party backup solutions, tape |

**RPO is determined by the replication method — not backup frequency.**

---

## Achievable RTOs

| **RTO Range** | **Technique** | **AWS Examples** |
|--------------|---------------|-----------------|
| Milliseconds to seconds | Fault tolerance and automatic failover | Multi-AZ deployments, mirrored disks |
| Seconds to minutes | High availability, load balancing, auto-scaling | EC2 Auto Scaling, Elastic Load Balancing |
| Minutes to hours | Cross-site recovery, warm standby, automated recovery | RDS Read Replicas, Elastic Beanstalk |
| Hours to days | Cold standby, manual recovery | AWS Backup, third-party backup solutions |

**RTO is determined by the recovery method — not backup frequency.**

---

## Disaster Recovery Strategies

| **DR Strategy** | **Description** | **RTO** | **RPO** | **Cost** |
|-----------------|-----------------|---------|---------|---------|
| **Backup & Restore** | Backups stored (optionally cross-region); infrastructure provisioned and data restored after failure | Hours to days | Hours to days | $ |
| **Pilot Light** | Core components (e.g., database) always running in DR region; remaining services launched on failure | Minutes to hours | Seconds to minutes | $$ |
| **Warm Standby** | Fully functional but scaled-down environment always running; scaled up on failure | Seconds to minutes | Seconds | $$$ |
| **Multi-Site Active-Active** | Fully active environments in multiple regions with live load balancing and continuous replication | Near zero | Near zero | $$$$ |

### What is running in each strategy?

| **Strategy** | **What's running** |
|-------------|-------------------|
| Backup & Restore | Nothing — restore from backup on failure |
| Pilot Light | Core only — typically just the database |
| Warm Standby | Full system at reduced scale |
| Multi-Site Active-Active | Full system at full scale, live in all regions |

---

## Warm vs. Cold Standby

| **Feature** | **Warm Standby** | **Cold Standby** |
|-------------|-----------------|-----------------|
| **Infrastructure state** | Scaled-down but fully running | Not running (or minimally provisioned) |
| **Data** | Continuously replicated | Backed up (snapshots) |
| **Recovery action** | Scale up existing environment | Provision infrastructure + restore data |
| **RTO** | Seconds to minutes | Hours to days |
| **RPO** | Low | Higher |
| **Cost** | Higher (resources always on) ¤ | Lowest (pay for storage only) ¤ |

> 💡 **Exam Tips:**
> <br>"Lowest cost DR with acceptable hours of recovery" → **Backup & Restore**
> <br>"Core database always running, rest launched on failure" → **Pilot Light**
> <br>"Full system at reduced scale, fast scale-up" → **Warm Standby**
> <br>"Near-zero RTO and RPO, highest cost" → **Multi-Site Active-Active**

---

## AWS Backup

AWS Backup is a fully managed, **centralized backup service** that automates and consolidates backup tasks across AWS services and accounts from a single console.
<br>Before AWS Backup, each service had its own backup mechanism (RDS automated backups, EBS snapshots, EFS backup, DynamoDB backups). AWS Backup provides a unified policy-based approach across all of them.

- **Backup plans** define backup frequency, retention, and lifecycle transition rules
- **Backup vaults** are encrypted storage containers for backup data; **Vault Lock** enforces WORM protection on backups ※
- **Supported services:** EC2, EBS, RDS, Aurora, DynamoDB, EFS, FSx, Storage Gateway, DocumentDB, Neptune, S3 ※, VMware on Outposts
- Works with **AWS Organizations** — apply backup policies across all accounts from the management account
- **Cross-region and cross-account** backup copies supported for DR purposes ※
- Backups are encrypted using KMS keys; you can use AWS-managed or customer-managed keys

### Key Properties

| **Concept** | **Detail** |
|------------|-----------|
| **Backup plan** | Policy defining schedule, retention (daily/weekly/monthly), and lifecycle (warm → cold storage) |
| **Recovery point** | A snapshot or backup copy — equivalent to a restore point |
| **Backup vault** | Encrypted container; region-specific; Vault Lock enforces immutability |
| **On-demand backup** | Immediate one-time backup, outside of the plan schedule |

> 💡 **Exam Tip:** `"Centralized backup policy across EC2, RDS, and DynamoDB from one place"` → **AWS Backup**.
> <br>`"Prevent backup deletion even by admin users (compliance)"` → **AWS Backup Vault Lock**.

---

# Developer Tools
---

## AWS Developer Tools — CI/CD Pipeline Services

AWS provides a suite of managed developer tools that together compose a complete **CI/CD (Continuous Integration / Continuous Delivery)** pipeline.
<br>Each service handles a different stage of the software delivery lifecycle, and they are frequently combined in exam scenarios requiring automated build, test, and deployment workflows.

> 💡 **[Pro-level detail]** At the SAA level, the exam tests awareness of what each service does and which service belongs in which pipeline stage — not deep implementation detail.

### CI/CD Pipeline Overview

| **Stage** | **AWS Service** | **What It Does** |
|----------|----------------|-----------------|
| **Source / Version Control** | **AWS CodeCommit** | Managed private Git repository; similar to GitHub/GitLab hosted on AWS |
| **Build** | **AWS CodeBuild** | Managed build service; compiles code, runs tests, produces artifacts; pay per build minute ¤ |
| **Deploy** | **AWS CodeDeploy** | Automated deployment to EC2, Lambda, ECS, or on-premises servers; supports rolling and blue/green |
| **Pipeline Orchestration** | **AWS CodePipeline** | Orchestrates the full pipeline — source → build → test → deploy; visual workflow |

### AWS CodeCommit

AWS CodeCommit is a **managed source control service** that hosts secure private Git repositories.

- Fully managed — no servers to provision; integrates with IAM for access control
- Encrypted at rest (KMS) and in transit (HTTPS/SSH)
- **Deprecated for new customers as of July 2024** Δ — AWS recommends migrating to third-party Git hosts (GitHub, GitLab, Bitbucket) integrated with CodePipeline via connections

> ⚠️ **Exam Trap:** CodeCommit is deprecated Δ for new customers but may still appear in exam scenarios. Treat it as the AWS-native Git source option in pipeline questions — the exam may not yet fully reflect the deprecation.

### AWS CodeBuild

AWS CodeBuild is a **fully managed build service** that compiles source code, runs unit tests, and produces deployable software artifacts.

- Uses **buildspec.yml** to define build commands and phases (install, pre-build, build, post-build)
- Scales automatically — no build server fleet to manage
- Outputs artifacts to **S3**; integrates with CodePipeline, CodeCommit, GitHub, Bitbucket

### AWS CodeDeploy

AWS CodeDeploy is a **deployment automation service** that deploys application updates to EC2 instances, Lambda functions, ECS services, or on-premises servers.

- Uses an **appspec.yml** (or appspec.json) file to define deployment lifecycle hooks
- **EC2/on-premises deployments:** requires **CodeDeploy Agent** installed on instances
- Supports **in-place** (replace in place, restart) and **blue/green** (new fleet, traffic shifted, old fleet drained) strategies
- **Lambda deployments:** supports traffic-shifting via aliases (linear, canary, all-at-once)

### AWS CodePipeline

AWS CodePipeline is a **fully managed CI/CD orchestration service** that models, visualizes, and automates the steps required to release software.

- A **pipeline** consists of stages; each stage contains **actions** (source, build, test, deploy, approval)
- Integrates with CodeCommit, GitHub, S3 (source), CodeBuild (build), CodeDeploy (deploy), CloudFormation (deploy), and manual approval actions
- Automatically triggers on source changes (e.g., commit to branch)
- Emit pipeline state changes as **EventBridge events** — enables automated alerting and workflow triggering

### Combined Pattern

```
CodeCommit / GitHub → CodePipeline → CodeBuild (build & test) → CodeDeploy / CloudFormation (deploy)
```

> 💡 **Exam Tip:** `"Automate code deployment when developer pushes to a branch"` → **CodePipeline (source + deploy stages)**.
> <br>`"Build and test code in a managed environment without managing build servers"` → **AWS CodeBuild**.
> <br>`"Deploy new version to EC2 fleet with minimal downtime using blue/green"` → **AWS CodeDeploy**.

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|-------------|
| Deploy repeatable multi-tier infrastructure from code | AWS CloudFormation template |
| Deploy same infrastructure template across 20 accounts in 3 regions | CloudFormation StackSets |
| Preview the impact of a stack change before applying | CloudFormation Change Set |
| Detect infrastructure changed outside of CloudFormation | CloudFormation Drift Detection |
| Deploy and manage a web application without managing EC2 | AWS Elastic Beanstalk (Web Server tier) |
| Decouple long-running async processing from a web app | Elastic Beanstalk Worker tier + SQS |
| Zero-downtime deployment with quickest rollback | Elastic Beanstalk Immutable deployment |
| Deploy to a test environment, validate, then flip production | Elastic Beanstalk Blue/Green (Swap URLs) |
| Manage configuration across EC2 fleet using Chef | AWS OpsWorks for Chef Automate |
| Secure shell access to EC2 without port 22 or bastion | SSM Session Manager |
| Run a patch command across 500 EC2 instances | SSM Run Command |
| Automate patching on a schedule with maintenance windows | SSM Patch Manager |
| Store database password with automatic rotation | AWS Secrets Manager |
| Store configuration data hierarchically (dev/prod paths) | SSM Parameter Store |
| Track which resources changed and when | AWS Config |
| Auto-remediate S3 buckets that lose encryption | AWS Config + SSM Automation or Lambda |
| Share a VPC subnet across accounts in an Organization | AWS Resource Access Manager (RAM) |
| Identify idle EC2 instances wasting money | AWS Trusted Advisor (Cost Optimization) |
| Alert before hitting a service quota limit | AWS Trusted Advisor (Service Limits) |
| Allow developers to deploy only approved infrastructure | AWS Service Catalog |
| Lowest-cost DR with hours-long recovery tolerance | Backup & Restore |
| Database always running in DR region, rest launched on failure | Pilot Light |
| Near-zero RTO/RPO across two active regions | Multi-Site Active-Active |

---

## HOL Notes — Elastic Beanstalk and Systems Manager

> 🛠️ **Implementation Notes:**
> <br>**Elastic Beanstalk:** Create an application, upload a ZIP file (or use a sample application), select a platform, and Beanstalk provisions EC2 + ELB + ASG automatically
> <br>**Elastic Beanstalk environment URLs:** Beanstalk generates a subdomain on `elasticbeanstalk.com`; for custom domains, create a Route 53 CNAME (no region in URL) or Alias record (region in URL)
> <br>**SSM Session Manager:** Requires SSM Agent on the instance + IAM instance profile with `AmazonSSMManagedInstanceCore` policy; no inbound security group rules needed
> <br>**SSM Parameter Store:** Access parameters in code with `aws ssm get-parameter --name /path/to/param --with-decryption`
> <br>**CloudFormation:** Create stacks via Console, CLI (`aws cloudformation create-stack`), or CDK; always review Change Sets before updating production stacks
> <br>**Drift Detection:** Run from the CloudFormation console: Stack → Actions → Detect Stack Drift

---

# Module Summary
---

## Key Topics
  - **Infrastructure as Code (IaC)** — concept and benefits; CloudFormation as the AWS native IaC service
  - **CloudFormation** — template anatomy (Resources, Parameters, Mappings, Outputs, Conditions, Transform), pseudo parameters, intrinsic functions, stacks, change sets, stack sets, nested stacks, drift detection, stack policies, rollback behavior
  - **CloudFormation vs. Elastic Beanstalk** — IaC provisioning vs. PaaS deployment
  - **AWS Elastic Beanstalk** — PaaS, supported platforms, application layers (application, version, environment, tier), deployment policies (all at once, rolling, rolling with additional batch, immutable, blue/green), .ebextensions, lifecycle policies, RDS inside vs. outside Beanstalk
  - **AWS OpsWorks** — Chef/Puppet configuration management, OpsWorks Stacks vs. Chef Automate vs. Puppet Enterprise, auto-healing
  - **AWS Systems Manager** — SSM Agent requirement, Session Manager (no SSH/bastion), Run Command (fleet-wide scripts), Patch Manager (patch baselines, maintenance windows), Parameter Store (hierarchical, SecureString, Standard vs. Advanced), Automation (runbooks)
  - **AWS Config** — configuration history, Config Rules, Configuration Items, compliance status, auto-remediation, conformance packs; Config vs. CloudTrail distinction
  - **AWS Secrets Manager** — automatic rotation (RDS, Aurora, Redshift, DocumentDB, Lambda for others), encryption, cost
  - **Parameter Store vs. Secrets Manager** — rotation, key types, cost, size limits
  - **AWS Resource Access Manager (RAM)** — cross-account resource sharing, VPC subnets, Transit Gateways
  - **AWS Trusted Advisor** — 5 pillars, core vs. full checks (Business/Enterprise Support required for full)
  - **AWS Service Catalog** — approved product portfolios, governance, self-service with guardrails
  - **Disaster Recovery** — RPO (data loss tolerance) vs. RTO (downtime tolerance); four DR strategies (Backup & Restore, Pilot Light, Warm Standby, Multi-Site Active-Active) with cost and recovery tradeoffs; warm vs. cold standby
  - **AWS Backup** — centralized backup across EC2, RDS, DynamoDB, EFS, and more; backup plans, vaults, Vault Lock (WORM); cross-region/cross-account copies
  - **AWS Developer Tools (CI/CD)** — CodeCommit (source, deprecated Δ), CodeBuild (build/test, buildspec.yml), CodeDeploy (deployment automation, appspec.yml, in-place vs. blue/green), CodePipeline (pipeline orchestration)

---

## Critical Acronyms
  - **IaC** — Infrastructure as Code
  - **PaaS** — Platform as a Service
  - **IaaS** — Infrastructure as a Service
  - **SAM** — Serverless Application Model
  - **SSM** — AWS Systems Manager (legacy abbreviation still widely used)
  - **KMS** — Key Management Service
  - **SQS** — Simple Queue Service
  - **ALB** — Application Load Balancer
  - **ASG** — Auto Scaling Group
  - **ELB** — Elastic Load Balancing
  - **RPO** — Recovery Point Objective
  - **RTO** — Recovery Time Objective
  - **DR** — Disaster Recovery
  - **CI** — Configuration Item (AWS Config)
  - **RAM** — Resource Access Manager
  - **OU** — Organizational Unit
  - **HSM** — Hardware Security Module
  - **ARN** — Amazon Resource Name
  - **HOL** — Hands-On Lab

---

## Key Comparisons
  - CloudFormation vs. Elastic Beanstalk (table)
  - Environment Tiers: Web Server vs. Worker (table)
  - Elastic Beanstalk Deployment Policies (table — all 5 policies)
  - SSM Session Manager vs. SSH (inline in Session Manager section)
  - SSM Parameter Store vs. Secrets Manager (table)
  - Achievable RPOs by replication method (table)
  - Achievable RTOs by recovery method (table)
  - DR Strategies — cost and recovery tradeoffs (table)
  - Warm vs. Cold Standby (table)

---

## Top Exam Triggers
  - `Deploy repeatable infrastructure from code` → **CloudFormation**
  - `Deploy same CloudFormation template across multiple accounts and regions` → **StackSets**
  - `Preview changes before applying a stack update` → **Change Set**
  - `Resources changed outside CloudFormation` → **Drift Detection**
  - `Deploy a web application without managing infrastructure` → **Elastic Beanstalk**
  - `Decouple long-running background tasks from a web app` → **Beanstalk Worker tier + SQS**
  - `Zero downtime, fastest rollback, deploy to new instances` → **Immutable deployment**
  - `Test new version in isolation, then flip traffic` → **Blue/Green (Swap URLs)**
  - `Manage EC2 configuration with Chef or Puppet` → **AWS OpsWorks**
  - `Secure shell to EC2 without port 22 or bastion host` → **SSM Session Manager**
  - `Run a command across a fleet of EC2 instances` → **SSM Run Command**
  - `Automate OS patching on a schedule` → **SSM Patch Manager**
  - `Store config data hierarchically (dev/prod paths), no rotation` → **SSM Parameter Store**
  - `Automatic credential rotation for RDS database` → **Secrets Manager**
  - `Track AWS resource configuration changes over time` → **AWS Config**
  - `Evaluate compliance: are all EBS volumes encrypted?` → **AWS Config rule**
  - `Who made the API call to change this security group?` → **AWS CloudTrail** (not Config)
  - `Auto-remediate noncompliant resources` → **AWS Config + SSM Automation or Lambda**
  - `Share a VPC subnet across AWS accounts in an Organization` → **AWS RAM**
  - `Identify underutilized resources and cost savings` → **Trusted Advisor**
  - `Check if service limits/quotas are being approached` → **Trusted Advisor (Service Limits)**
  - `Full Trusted Advisor checks` → **Business or Enterprise Support plan required**
  - `Allow self-service deployment of only approved infrastructure` → **AWS Service Catalog**
  - `Lowest-cost DR strategy` → **Backup & Restore**
  - `Core database always running in DR region` → **Pilot Light**
  - `Full system at reduced scale, fast scale-up on failure` → **Warm Standby**
  - `Near-zero RTO and RPO, highest cost` → **Multi-Site Active-Active**
  - `RPO = data loss tolerance; RTO = recovery time tolerance` → remember this distinction

---

## Quick References

### [Deployment and Management Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619424#overview)

### [Deployment and Management Architecture Patterns Private Link](https://drive.google.com/drive/folders/1YOKMWiyAdK8nkidsm4CHRpNxfjvI3oWq?usp=drive_link)

### [Deployment and Management Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346116#overview)

### [CloudFormation Cheat Sheet](https://digitalcloud.training/aws-cloudformation/)

### [AWS Elastic Beanstalk Cheat Sheet](https://digitalcloud.training/aws-elastic-beanstalk/)

### [AWS Config Cheat Sheet](https://digitalcloud.training/aws-config/)

### [AWS Resource Access Manager Cheat Sheet](https://digitalcloud.training/aws-resource-access-manager/)

### [AWS Systems Manager Cheat Sheet](https://digitalcloud.training/aws-systems-manager/)

### [AWS OpsWorks Cheat Sheet](https://digitalcloud.training/aws-opsworks/)

### [DR Architecture Strategies — AWS Official Part 1](https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-i-strategies-for-recovery-in-the-cloud/)

### [DR Architecture Strategies — AWS Official Part 2](https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-ii-backup-and-restore-with-rapid-recovery/)

### [DR Architecture Strategies — AWS Official Part 3](https://aws.amazon.com/blogs/architecture/disaster-recovery-dr-architecture-on-aws-part-iii-pilot-light-and-warm-standby/)

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


