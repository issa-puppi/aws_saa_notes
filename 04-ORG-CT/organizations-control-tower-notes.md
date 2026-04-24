## AWS Organizations
  - Centralized management of multiple AWS accounts
  - Allows for multiple accounts under a single organization
  - Enables Two Key Features:
    - **Consolidated billing** - 1 bill for all accounts in the organization
    - **All features** - Access to all AWS features across accounts in the organization
  - Includes:
    - **Root accounts** (formally called **management accounts**) for managing the organization
    - **Organizational units (OUs)** for grouping accounts (formally called **member accounts**)
  - Policies are applied to root or OUs

---

## Consolidated Billing Includes:
  - **Paying Account** - Independent and cannot access resources in other accounts
  - **Linked Accounts** - All linked accounts are independent and can access their own resources but not those of other accounts

---

## AWS Organization Applications

- Can create accounts programmatically using the **AWS Organizations API**
- Can group accounts into **organizational units (OUs)** for easier management
- Can apply **Service Control Policies (SCPs)** to OUs or accounts to restrict permissions
  - Can also restrict availiable API actions for accounts in the organization
- Enables **AWS Single Sign-On (SSO)** using an on-prem direcotory or **AWS SSO** directory  
- Enable **CloudTrail** in management account and apply to members (useful for auditing)
- And more...

---

## Service Control Policies (SCPs)
  - control the maximum permissions for accounts in an organization
  - applied to OUs or accounts
  - **tag policies** - control which tags can be applied to resources in an account
  - production accounts should have more restrictive policies than development accounts
    - production accounts are a child of the development OU 

### Key Takeaways
  - SCPs do not grant permissions, they only restrict them
  - SCPs are the maximum permissions for accounts (guardrails)
  - SCPs are not applied to the management account (root) by default, but can be if needed 

---

## AWS Control Tower
  - Provides a pre-configured landing zone for multi-account AWS environments
  - Creates a baseline environment with best practices for security, compliance, and governance
  - Includes: 
    - **Preventative guardrails** (SCPs, etc.)
    - **Detective guardrails** (CloudWatch alarms, Config rules, etc.)

---

## Types of Shared Accounts in Control Tower
  - **Master Account** - Centralized management account for the organization (formerly called **management account**)
  - **Log Archive Account** - Centralized location for storing logs (CloudTrail, Config, etc.)
  - **Audit Account** - Centralized location for security and compliance auditing (GuardDuty, Security Hub, etc.)

---

## Guardrails in Control Tower

  ### Preventative Guardrails
  - **Purpse:** Prevents users from performing specific actions or using specific services
  - **How it works:** Uses **SCPs** to restrict permissions for accounts in the organization
  - **Examples:**
    - Disallow Deletion of CloudTrail Logs in S3 Logging Bucket
    - Disallow Public Read Access to S3 Buckets
    - Require encryption of EBS Volumes
    - Disallow RDP/SSH Access from 0.0.0/0

  ### Detective Guardrails
  - **Purpose:** Detects and alerts to report non-compliant activities that have already occurred
  - **How it works:** Uses **CloudWatch Alarms**, **Config Rules**, and **Lambda functions** to handle detction and remediation
  - **Examples:**
    - Detecting publicly accessible S3 buckets
    - Detect if versioning is enabled on S3 buckets
    - Detect if encryption is enabled on RDS instances
    - Monitoring IAM policies that grant broad permissions 
      - e.g., `*`

---

## AWS Organization vs Control Tower

| AWS Organizations | AWS Control Tower |
|-------------------|-------------------|
| • Manage multiple AWS accounts | • Extends capabilities of Organizations |
| • Consolidated billing | • Landing zones (best-practices) |
| • Organizational Units (**OUs**) | • Federated Access (**IAM**) |
| • Service Control Policies (**SCPs**) | • Centralized logging and auditing |
| • Backup Policies | • Account Factory (automation) |
| • No pre-configured guardrails | • Guardrails (governance rules) |

---

## Policies vs Roles

- **Policies** - Define permissions for users, groups (can include OUs), and roles 
  - e.g., IAM policies, SCPs
- **Roles** - Define a set of permissions that can be assumed by users or services 
  - e.g., IAM roles, cross-account roles

---

## Quick Reference

### [AWS Organizations & Control Tower Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28617776#overview)

### [AWS Organizations & Control Tower Architecture Patterns Private Link](https://drive.google.com/drive/folders/1PMcCkDuGMBQjK6KcIvX88t9m5EOJEWDq?usp=drive_link)

### [AWS Organizations & Control Tower Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346100#overview)

### [AWS Organizations & Control Tower Cheatsheet](https://digitalcloud.training/aws-organizations/)

---