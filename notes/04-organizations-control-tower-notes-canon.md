# Organization Management
---

## AWS Organizations

**AWS Organizations** lets you consolidate multiple AWS accounts into a centrally managed organization.
<br>AWS accounts are natural boundaries for permissions, security, costs, and workloads.
<br>Using a **multi-account environment** is the recommended best practice when scaling cloud environments.

### Feature Sets
AWS Organizations operates in one of two modes:

| **Feature Set** | **What's Included** |
|-----------------|----------------------|
| **Consolidated Billing** | Single payment method, cost visibility, volume discounts |
| **All Features** | Consolidated Billing + SCPs, Tag Policies, Backup Policies, AI services opt-out policies, and full governance controls |

  - **All Features mode** must be enabled to use SCPs and policy-based governance
  - Organizations is **free** ¤ — no additional charge to use it

### Key Concepts

| **Term** | **Definition** |
|----------|----------------|
| **Organization** | The collection of AWS accounts you manage centrally |
| **Management Account** | The account used to create and manage the organization (formerly called the payer account) |
| **Member Account** | Any account in the organization other than the management account |
| **Administrative Root** | The top of the OU hierarchy — the starting point for organizing accounts |
| **Organizational Unit (OU)** | A group of accounts within the organization; OUs can contain other OUs (nested hierarchy) |
| **Policy** | A document defining controls applied to a group of accounts (e.g., SCPs, Tag Policies) |

> 💡 **Exam Tip:** The **management account** is not affected by SCPs — it has unrestricted access to all accounts in the organization regardless of SCP configuration.

---

## Consolidated Billing

  - Provides a **single bill** for all accounts in the organization
  - The **Paying Account** receives and pays the consolidated bill — independent and cannot access resources in other accounts
  - **Linked Accounts** are independent — can access their own resources but not those of other accounts
  - Limit of **20 † linked accounts** for consolidated billing (default soft limit — can be increased)
  - **Volume discounts** ¤ from aggregated usage (e.g., S3 storage, EC2 Reserved Instances) — accounts contribute toward shared discount tiers
  - **Unused Reserved Instances** are applied across the group ¤ — an RI purchased in one account can provide discounts to matching usage in another account
  - **Billing history and reports** remain with the management account if a member account leaves the organization

> 💡 **Exam Tip:** Consolidated billing benefits: **one bill, volume discounts, RI sharing across accounts**. 
<br>These are the three big wins from Organizations even without SCPs.

---

## Organization Structure & Applications

  - Create accounts **programmatically** using the **AWS Organizations API** or CLI
  - Group accounts into **OUs** — example: `Production`, `Development`, `Test` OUs under the management account
  - Apply **Service Control Policies (SCPs)** to OUs or accounts to restrict available permissions
  - Apply **Tag Policies** to enforce consistent tagging standards across accounts
  - Enable **AWS CloudTrail** in the management account and propagate to all member accounts — member accounts **cannot turn off or modify** this trail ※
  - Delegate responsibility for specific AWS services to member accounts (**delegated administrator** pattern) ※
  - Share AWS resources across the organization using **AWS Resource Access Manager (RAM)**
  - Enable **AWS IAM Identity Center** Δ (formerly AWS SSO) for centralized access using an on-premises directory or managed directory
  - Use **AWS Cost Explorer** and **AWS Compute Optimizer** for cross-account cost and resource visibility

### OrganizationAccountAccessRole
  - When you create a new account through the Organizations console, an **`OrganizationAccountAccessRole`** is automatically created in the new account
  - This IAM role has full administrative permissions in the new account
  - Can be assumed by any user with `sts:AssumeRole` permissions in the management account
  - Use this role to **switch roles** into the new account immediately after creation

> 🛠️ **Implementation Notes:** New accounts created via Organizations console → use `Switch Role` in the console (or assume `OrganizationAccountAccessRole` via CLI) to access the new account. The role exists by default; no manual setup needed.

---

## Migrating Accounts Between Organizations

  - Accounts can be migrated between organizations
  - Requires **root or IAM access** to both the member and management accounts
  - **Console**: suitable for migrating a small number of accounts
  - **API or CLI**: preferred for bulk migrations
  - **Billing history stays with the management account** — download billing reports before migrating if you need to retain them
  - When a member account leaves an organization, all charges are billed directly to that standalone account
  - Even a brief move (minutes) may incur direct charges to the member account

---

# Governance & Control
---

## Service Control Policies (SCPs)

**SCPs** define the **maximum available permissions** for all accounts in an organization.
<br>They act as guardrails — restricting what IAM users, roles, and even the root user of member accounts can do.

### Key Rules
  - SCPs **do NOT grant permissions** — they only restrict what IAM policies can grant
  - SCPs affect **IAM users and roles** in member accounts, including the **root user** of those accounts
  - SCPs do **NOT affect the management account** — users and roles there are unrestricted
  - SCPs do **NOT affect service-linked roles** — these operate outside SCP restrictions
  - SCPs are available **only in All Features mode** — not with consolidated billing only
  - Effective permissions = **intersection of SCP allows AND IAM policy allows**

### SCP Inheritance
  - An account has only the permissions permitted by **every parent above it in the hierarchy**
  - Permissions blocked at **any level** (implicitly or explicitly) cannot be granted to IAM users/roles in the account — even if `AdministratorAccess` is attached to the user
  - Example: if the Root SCP blocks `ec2:RunInstances` for a `t3.large`, no IAM policy in any child account can override that

### Inheritance Example (from slides)
  - **Root SCP**: restricts to `t2.micro` only
  - **Dev OU** (inherits from Root): Dev users can only launch `t2.micro`
  - **Prod OU** (inherits from Root): Prod users also cannot launch anything other than `t2.micro`
  - **Management Account**: users are **not restricted** — SCP does not apply

### SCP Strategies
  - **Allow list (whitelist)**: default deny, explicitly allow specific actions
  - **Deny list (blacklist)**: start with full access, explicitly deny specific actions
  - Production accounts should have **more restrictive** SCPs than development accounts
  - Keep Production and Development as **separate peer OUs** — do not nest one under the other

> ⚠️ **Exam Traps:**
<br>SCPs **do not grant permissions** — a user still needs IAM policies. An SCP allow alone doesn't let anyone do anything.
<br>SCPs **do not affect the management account** — guardrails there must be implemented separately.
<br>SCPs **do not affect service-linked roles** — these are always exempt.

> 🔧 **Pro Tips:** SCP deny-list vs allow-list design is a core SAP scenario. 
<br>The recommended pattern is to **start with allow-list** (principle of least privilege) and add permissions explicitly, rather than a deny-list which can have gaps. AWS Control Tower uses preventive guardrails (deny-list SCPs) on top of a permissive baseline.

---

## Tag Policies

  - A type of Organizations policy that enforces **consistent tagging standards** across accounts
  - Define which tags are required, which keys are valid, and which values are acceptable
  - Help with **cost allocation, security automation, and resource organization**
  - Non-compliant resources are flagged (but not blocked — tag policies are detective in nature by default)

---

## Backup Policies

  - Define and enforce **AWS Backup plans** across accounts in the organization ※
  - Ensure consistent backup schedules, retention, and vaults across the entire org
  - Applied via Organizations — member accounts cannot override them

---

## Resource Groups & Tag Editor

  - **Resource Groups** — logical groupings of AWS resources that match tag-based or CloudFormation stack-based queries
  - **Two query types**:
    - **Tag-based** — list resources matching specific tag keys/values
    - **AWS CloudFormation stack-based** — group resources within a specific stack in the current region
  - Resource groups can be **nested** (a group can contain existing groups)
  - **Tag Editor** — assists with finding resources across accounts and adding/modifying tags at scale
  - Accessible via: AWS Management Console, AWS Systems Manager console, or Resource Groups API/CLI/SDK

---

# Control Tower
---

## AWS Control Tower

**AWS Control Tower** extends AWS Organizations with a **pre-configured, well-architected landing zone** for multi-account environments.
<br>It automates account setup, applies governance guardrails, and integrates federated access — reducing the manual effort of building a secure multi-account baseline from scratch.

### What Control Tower Provides

| **Capability** | **Detail** |
|----------------|------------|
| **Landing Zone** | Pre-configured, well-architected multi-account baseline |
| **Federated Access** | Via **IAM Identity Center** Δ (SAML 2.0 IdP or Microsoft AD also supported) |
| **Centralized Logging** | CloudTrail and Config logs aggregated in the Log Archive account |
| **Account Factory** | Automated account provisioning with pre-applied guardrails |
| **Guardrails** | Preventive (SCPs) and Detective (Config Rules + Lambda) governance rules |

### Landing Zone Structure
  - **Security OU** — contains the Log Archive and Audit accounts
  - **Sandbox OU** — for experimental/dev accounts
  - **Production OU** — for production workloads
  - Additional OUs can be created as the organization grows

---

## Control Tower Shared Accounts

| **Account** | **Purpose** |
|-------------|-------------|
| **Management Account** | Created and used to launch Control Tower; root user and IAM admin have full access to all landing zone resources |
| **Log Archive Account** | Central S3 bucket storing copies of all CloudTrail and Config log files from all accounts in the landing zone |
| **Audit Account** | Aggregates and stores logs from all other accounts; restricted access; used for security and compliance review |

> 💡 **Exam Tip:** "Where are centralized CloudTrail logs stored in a Control Tower environment?" → **Log Archive Account**.

---

## Control Tower Guardrails

Guardrails are governance rules applied automatically to all accounts in the landing zone. Two types:

### Preventive Guardrails
  - **Purpose:** Proactively prevent policy violations before they occur
  - **Mechanism:** Implemented as **SCPs** — restricts what actions users/roles can perform
  - **Examples:**
    - Disallow deletion of CloudTrail logs or S3 logging buckets
    - Disallow public read access to S3 buckets
    - Require encryption on EBS volumes
    - Disallow RDP/SSH access from `0.0.0.0/0`

### Detective Guardrails
  - **Purpose:** Monitor and report on non-compliant activities that have already occurred
  - **Mechanism:** Implemented using **AWS Config Rules** and **Lambda functions** — continuously evaluates resource configuration and generates alerts/reports
  - **Examples:**
    - Detect publicly accessible S3 buckets
    - Detect whether versioning is enabled on S3 buckets
    - Detect whether encryption is enabled on RDS instances
    - Detect IAM policies that grant overly broad permissions (e.g., `*`)

### Preventive vs Detective Guardrails

| **Aspect** | **Preventive** | **Detective** |
|------------|----------------|---------------|
| When it acts | Before the violation | After the violation |
| Mechanism | SCPs | AWS Config Rules + Lambda |
| Effect | Blocks the action | Alerts / reports non-compliance |
| Analogy | Locked door | Security camera |

> 💡 **Exam Tips:**
<br>"Block an action from happening at all" → **Preventive guardrail (SCP)**
<br>"Find out when something non-compliant already happened" → **Detective guardrail (Config Rule)**

---

## AWS Organizations vs AWS Control Tower

| **AWS Organizations** | **AWS Control Tower** |
|-----------------------|------------------------|
| Manage multiple AWS accounts | Extends capabilities of Organizations |
| Consolidated billing | Landing Zones (well-architected baseline) |
| Organizational Units (OUs) | Federated Access via IAM Identity Center Δ |
| Service Control Policies (SCPs) | Centralized logging (Log Archive + Audit accounts) |
| Tag Policies | Account Factory (automated provisioning) |
| Backup Policies | Guardrails (preventive + detective governance rules) |
| Manual setup required | Pre-configured best-practice environment |

> 💡 **Exam Tip:** **Organizations** gives you the building blocks; **Control Tower** gives you a pre-built, best-practice house using those building blocks. 
<br>Use Organizations directly when you want full control. 
<br>Use Control Tower when you want a governed baseline with less setup.

---

## Policies vs Roles (Quick Distinction)

  - **Policies** — define permissions; attached to identities (users, groups, roles) or resources; also the mechanism for OUs (SCPs, tag policies)
  - **Roles** — define a set of permissions that can be **assumed** by users or services; used for cross-account access (e.g., `OrganizationAccountAccessRole`)

---

# In Practice
---

## Management Account Best Practices

  - Use the management account **only for organizational tasks** — not for running workloads
  - Use a **group email address** for the management account's root user (not a personal email)
  - Use a **complex password** and **enable MFA** for the root user
  - Add a **phone number** to account contact information
  - Regularly **review who has access** to the management account
  - **Document processes** for using root user credentials
  - Apply **monitoring controls** to detect access to root credentials

---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Create multiple AWS accounts quickly and programmatically | Use the **Organizations API** (or CLI) to create accounts programmatically |
| Restrict member account users from making IAM changes | Apply an **SCP** to the OU or account that denies IAM actions |
| Move an account between organizations | Use the **AWS Organizations console** (or API/CLI for bulk) to migrate the account |
| Log in to a newly created member account | **Switch roles** using the auto-created `OrganizationAccountAccessRole` |
| Apply the same permission restrictions to multiple member accounts | Create an **OU**, add the member accounts, then **attach the SCP to the OU** |
| Central governance for developer accounts owned by individuals | Create an **AWS Organization** and invite each developer account to join |
| Prevent deletion of CloudTrail logs across all accounts | Apply a **Preventive Control Tower guardrail** (SCP) |
| Detect publicly accessible S3 buckets across all accounts | Apply a **Detective Control Tower guardrail** (Config Rule) |
| Consistent backup policies across all accounts | Use **Organizations Backup Policies** |
| Share resources (e.g., VPCs, subnets) across accounts | Use **AWS Resource Access Manager (RAM)** |

---

# Module Summary
---

## Key Topics
  - AWS Organizations — multi-account management, consolidated billing, OU hierarchy
  - Two feature sets: Consolidated Billing vs All Features
  - Management account — not affected by SCPs, used for org management only
  - Consolidated billing benefits — single bill, volume discounts, RI sharing
  - SCPs — restrict (not grant) permissions; apply to OUs and accounts; affect root user; exempt management account and service-linked roles
  - SCP inheritance — cumulative from root down through OU hierarchy
  - Tag Policies, Backup Policies — organization-level governance
  - OrganizationAccountAccessRole — auto-created cross-account admin role
  - Migrating accounts between organizations
  - AWS Control Tower — landing zones, Account Factory, federated access via IAM Identity Center
  - Control Tower shared accounts — Management, Log Archive, Audit
  - Preventive guardrails (SCPs) vs Detective guardrails (Config Rules + Lambda)
  - Resource Groups — tag-based and CloudFormation stack-based groupings

---

## Critical Acronyms
  - **OU** — Organizational Unit
  - **SCP** — Service Control Policy
  - **RAM** — Resource Access Manager
  - **RI** — Reserved Instance
  - **MFA** — Multi-Factor Authentication
  - **IAM** — Identity and Access Management
  - **SAML** — Security Assertion Markup Language
  - **AD** — Active Directory (Microsoft)
  - **CLI** — Command Line Interface
  - **API** — Application Programming Interface
  - **Config** — AWS Config (configuration compliance service)
  - **CloudTrail** — AWS audit logging service

---

## Key Comparisons
  - Consolidated Billing feature set vs All Features mode
  - AWS Organizations vs AWS Control Tower
  - SCPs vs IAM Policies (restrict vs grant)
  - SCPs vs Permissions Boundaries (org-level vs identity-level)
  - Preventive Guardrails vs Detective Guardrails
  - Management Account vs Member Account (SCP behavior)

---

## Top Exam Triggers
  - `Centrally manage multiple AWS accounts` → **AWS Organizations**
  - `Single bill across all accounts` → **Consolidated Billing**
  - `Volume discounts across accounts` → **Consolidated Billing** in Organizations
  - `Unused RIs applying to other accounts` → **Consolidated Billing / RI sharing**
  - `Restrict member accounts from specific AWS services or actions` → **Service Control Policy (SCP)**
  - `SCP doesn't restrict the management account` → **Management account is always exempt from SCPs**
  - `Block IAM changes in member accounts` → **SCP denying IAM actions**
  - `Multi-account governed baseline with logging and guardrails` → **AWS Control Tower**
  - `Automated account provisioning with pre-applied governance` → **Account Factory (Control Tower)**
  - `Where are centralized CloudTrail logs in Control Tower?` → **Log Archive Account**
  - `Security and compliance review account in Control Tower` → **Audit Account**
  - `Prevent a policy violation from happening` → **Preventive guardrail (SCP)**
  - `Detect a policy violation after it occurs` → **Detective guardrail (Config Rule + Lambda)**
  - `Enforce consistent tagging standards across accounts` → **Tag Policies**
  - `Create accounts programmatically` → **Organizations API**
  - `Log into a new account created through Organizations` → **Switch roles using OrganizationAccountAccessRole**
  - `Apply same restrictions to multiple accounts` → **Create an OU, add accounts, attach SCP to OU**
  - `Share resources (VPCs, subnets) across accounts` → **AWS Resource Access Manager (RAM)**
  - `Federated access across accounts in Control Tower` → **AWS IAM Identity Center** Δ

---

## Quick References

### [AWS Organizations & Control Tower Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28617776#overview)

### [AWS Organizations & Control Tower Architecture Patterns Private Link](https://drive.google.com/drive/folders/1PMcCkDuGMBQjK6KcIvX88t9m5EOJEWDq?usp=drive_link)

### [AWS Organizations & Control Tower Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346100#overview)

### [AWS Organizations & Control Tower Cheatsheet](https://digitalcloud.training/aws-organizations/)

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