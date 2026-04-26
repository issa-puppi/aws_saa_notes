# Identity
---

## AWS Shared Responsibility Model

The AWS Shared Responsibility Model defines the boundary between what AWS is responsible for and what the customer is responsible for when operating in the cloud.
<br>The core principle is simple: **AWS is responsible for security *of* the cloud; the customer is responsible for security *in* the cloud.**

Understanding this boundary is foundational to every security design decision — misconfigured IAM policies, unencrypted S3 buckets, and exposed security groups are all examples of **customer-side** failures, not AWS failures.

### Responsibility Boundaries

| **Layer** | **AWS Responsibility** | **Customer Responsibility** |
|-----------|----------------------|----------------------------|
| **Physical / Global Infrastructure** | Data centers, physical hardware, power, networking, AZs, Regions | Choosing Regions for data residency |
| **Compute (EC2)** | Hypervisor, host hardware | OS, patching, runtime, applications |
| **Managed Services (RDS, S3, etc.)** | Underlying infrastructure, hardware, OS patching, replication | Data classification, access controls, encryption, backups |
| **Serverless (Lambda, Fargate)** | Infrastructure, OS, runtime patching | Function code, IAM permissions, data |
| **Networking** | Global network backbone, BGP routing | VPC design, security groups, NACLs, TLS for data in transit |
| **IAM / Identity** | AWS IAM service availability | Policy design, MFA enforcement, credential rotation |
| **Data** | Physical media destruction | Data encryption, classification, retention, backup |

### Key Exam Pattern — Managed vs. Unmanaged

The customer responsibility **shrinks** as services become more managed:

- **IaaS (EC2)** → customer manages OS, runtime, data, network controls
- **PaaS (Elastic Beanstalk, RDS)** → AWS manages OS/runtime; customer manages data, access, network configs
- **SaaS / Serverless (Lambda, S3)** → AWS manages almost everything; customer manages data, permissions, and code

> 💡 **Exam Tip:** Scenario asks who is responsible for patching the OS on an RDS instance → **AWS**.
> <br>Scenario asks who is responsible for encrypting data stored in RDS → **Customer** (customer enables encryption; AWS provides the capability).

> ⚠️ **Exam Trap:** "AWS is responsible for security in the cloud" is the **wrong** statement.
> <br>AWS is responsible for security **of** the cloud. The customer is responsible for security **in** the cloud.

---

## AWS Identity and Access Management (IAM)

IAM is the AWS service used to securely control individual and group access to AWS resources. 
<br>It manages **authentication** (who you are) and **authorization** (what you can do).

### Key Properties
  - **Global service** — not regional; users, roles, and policies apply across all AWS Regions
  - **Eventually consistent** — IAM replicates data across multiple data centers globally; changes may take seconds to propagate
  - Free service ¤ — no charge for IAM itself
  - Integrates with most AWS services for fine-grained access control

> 💡 **Exam Tip:** IAM is **global** — if a question asks where to configure IAM in a multi-region architecture, the answer is "anywhere; it applies everywhere."

---

## IAM Principals & Authentication

An **IAM principal** is a person or application that can make a request for an action or operation on an AWS resource.

### Principal Types
  - **Root user** — the account owner created at signup; has unrestricted permissions
  - **IAM user** — an identity within an account, used by a person or application
  - **IAM role** — an identity that can be *assumed* by users, services, or applications for temporary access
  - **Federated user** — an external identity granted temporary AWS access via an identity provider (IdP)
  - **AWS service** — services like Amazon EC2 or AWS Lambda acting on your behalf via roles

### Authentication
  - All IAM principals must be authenticated before AWS evaluates their request (with rare exceptions like anonymous S3 reads)
  - Console authentication uses username + password (and optionally MFA)
  - Programmatic authentication uses access keys (access key ID + secret access key)

### Authorization
  - AWS evaluates attached **policies** to allow or deny each request
  - Policies can be attached to identities (users, groups, roles) or directly to resources
  - **Default behavior:** all requests are implicitly denied unless an explicit allow is granted

> ⚠️ **Exam Traps:** 
<br>New IAM users have **zero permissions by default** § 
<br>They can sign in but cannot do anything until a policy is attached.

---

## Root User vs IAM User

| **Aspect** | **Root User** | **IAM User** |
|------------|---------------|--------------|
| Sign-in | Account email address | Username + account ID/alias |
| Permissions | Full, unrestricted, cannot be limited | Defined entirely by attached policies |
| Quantity | One per account | Up to 5,000 † per account |
| Best practice | Lock away credentials, enable MFA, do not use for daily work | Use for everyday access, scoped by least privilege |
| Recoverable if compromised | Difficult — controls the entire account | Easier — admin can disable/delete |

> 💡 **Exam Tips:** 
<br>Root user is the only identity that has full access **by default**. 
<br>The fix for "root used for daily tasks" scenarios is always: 
<br>Create an IAM user with appropriate permissions, enable MFA on root, lock root credentials away.

---

## IAM Users

  - An IAM user represents a **person or service** that interacts with AWS
  - Each user has:
    - A **friendly name** (e.g., `Andrea`)
    - An **Amazon Resource Name (ARN)** uniquely identifying it (e.g., `arn:aws:iam::625148252389:user/Andrea`)
    - An optional password for console access
    - Optional access keys (up to 2 † active) for programmatic access
  - Up to **5,000 † IAM users per AWS account**
  - When an IAM user represents an application rather than a person, it is called a **service account**

> 🔧 **Pro Tips:** 
<br>AWS strongly recommends using **IAM roles instead of IAM users** for applications and workloads. 
<br>Long-lived access keys are a top source of credential leaks — a core SAP design principle.

---

## IAM User Groups

  - **Collections of users** that share a common set of permissions
  - The primary purpose is to attach permissions policies once and have them apply to all members
  - A group is **not an identity** and cannot be a principal in a policy
  - Cannot be nested (no groups within groups)
  - Users can belong to multiple groups; permissions are **cumulative (union)**
  - 300 † groups per account (default), 10 † groups per user maximum

**Example:**
  - User in `Developers` group → access to dev resources
  - Same user added to `Admins` group → also gains admin permissions
  - Final permissions = union of both groups' policies

---

## Authentication Methods

IAM users can authenticate using:

| **Method** | **Used For** | **Components** |
|------------|--------------|----------------|
| Password | AWS Management Console | Username + password (+ optional MFA) |
| Access keys | Programmatic (CLI, SDK, API) | Access key ID + secret access key |
| MFA | Additional layer for either above | Virtual app, hardware device, security key, or passkey ※ |
| Server certificates | HTTPS in unsupported regions | SSL/TLS cert (legacy — prefer ACM) |

  - **AWS Command Line Interface (CLI)** and **AWS Software Development Kits (SDKs)** both use access keys
  - **Application Programming Interface (API)** calls also use access keys
  - Secret access keys are **shown only at creation** — if lost, you must rotate (create new, delete old)
  - Access keys can be disabled without deleting them

### Multi-Factor Authentication (MFA)
  - Adds a "something you have" factor on top of "something you know" (password)
  - Supported MFA types:
    - **Virtual MFA device** — apps like Google Authenticator, Authy on a smartphone
    - **Hardware MFA device** — physical key fob (e.g., Gemalto)
    - **FIDO2 security key** — USB hardware device (e.g., YubiKey)
    - **Passkeys** ※ Δ — synced passkey support is a more recent addition
    - **Time-based One-Time Password (TOTP) tokens**
  - Multiple MFA devices per user supported ※ Δ — historically only one device per user; AWS now allows multiple registered devices

> 💡 **Exam Tips:** 
<br>**Always enable MFA on the root user.** 
<br>Best practice is also FIDO2 security keys or hardware MFA for all privileged users.

> 🛠️ **Implementation Notes:** From the CLI you can pass MFA via `aws sts get-session-token --serial-number <mfa-arn> --token-code <code>` to obtain temporary credentials.

---

## Resource Identification (ARNs)

Every AWS resource has a unique identifier called an **Amazon Resource Name (ARN)**.

### ARN Format

```text
arn:partition:service:region:account-id:resource-type/resource-id
```

  - **partition** — usually `aws` (also `aws-cn` for China, `aws-us-gov` for GovCloud) ◊
  - **service** — `iam`, `s3`, `ec2`, etc.
  - **region** — empty for global services like IAM
  - **account-id** — 12-digit AWS account number
  - **resource-type/resource-id** — e.g., `user/Andrea`, `role/EC2-Admin`

**Examples:**

```text
arn:aws:iam::625148252389:user/Andrea           # IAM user (no region)
arn:aws:s3:::my-bucket/folder/file.txt          # S3 object (no region or account)
arn:aws:ec2:us-east-1:625148252389:instance/i-0abc123
```

> 💡 **Exam Tips:** 
<br>**IAM ARNs** have an **empty region field** because IAM is global. 
<br>**S3 bucket ARNs** omit both region and account ID.

---

## IAM Roles

A **role** is an identity with permissions that can be **assumed** by trusted entities to obtain temporary credentials.

### Key Characteristics
  - **No long-term credentials** — no password or access keys attached to the role itself
  - Provides **temporary security credentials** via AWS STS when assumed
  - Used for **delegation** — granting permissions without sharing credentials
  - Can be assumed by:
    - IAM users (in the same or another account)
    - AWS services (e.g., EC2, Lambda)
    - Federated users (via SAML or web identity)

### Role Components
  - **Permissions policy** — what the role *can do* once assumed
  - **Trust policy** — *who* is allowed to assume the role (defines trusted principals)
  - Wildcards (`*`) cannot be used in the principal field of a trust policy

### Common Use Cases
  - **EC2 instance roles** — passed to instances via an *instance profile* so apps on the instance get temporary creds
  - **Cross-account access** — assume a role in account B from account A
  - **Federation** — external identity providers map users to roles
  - **Service-linked roles** — predefined roles AWS services use to act on your behalf

### Roles vs Policies
  - **Role** = an identity that can be assumed (has permissions)
  - **Policy** = a JSON document defining permissions (attached to identities or resources)

> 💡 **Exam Tip:** If a question describes "an EC2 instance needs to access an S3 bucket / DynamoDB table / etc.," the answer is **almost always an IAM role attached via an instance profile** — never embed access keys on the instance.

### Instance Profiles
  - A **container for an IAM role** that you attach to an EC2 instance to pass role credentials to applications
  - One role per instance profile, but a role can be in multiple profiles
  - Created automatically when you assign a role via the console
  - Must be created manually with the CLI/API

---

# Access
---

## IAM Policies

Policies are **JSON documents** that define permissions.

### Policy Document Structure

| **Element** | **Purpose** |
|-------------|-------------|
| Version | Policy language version (always `2012-10-17`) |
| Statement | One or more permission statements |
| Effect | `Allow` or `Deny` |
| Action | API operations the policy applies to (e.g., `s3:GetObject`) |
| Resource | The ARN(s) the policy applies to |
| Principal | (Resource-based only) who the policy applies to |
| Condition | Optional context-based constraints |

### Action Format
  - Each AWS service has its own actions in the format `service:operation`
  - Examples: `ec2:RunInstances`, `s3:GetObject`, `iam:CreateUser`, `rds:StopDBInstance`
  - Wildcards supported: `ec2:*` (all EC2 actions), `s3:Get*` (all S3 read actions)

### Example: Allow S3 Read
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
  }]
}
```

### Conditions
  - Provide **context-based access control**
  - Common condition keys:
    - `aws:SourceIp` — restrict by source IP range
    - `aws:MultiFactorAuthPresent` — require MFA
    - `aws:RequestedRegion` — restrict to specific regions
    - `s3:prefix` — limit S3 access to a folder/prefix
    - `aws:CurrentTime` — restrict to time windows

> 💡 **Exam Tip:** "Restrict access by IP / require MFA / limit users to their own folder" → `Condition` element in the policy.

---

## Types of Policies

| **Type** | **Attached To** | **Purpose** |
|----------|-----------------|-------------|
| Identity-based | Users, groups, roles | Grants permissions to the identity |
| Resource-based | Resources (e.g., S3 bucket, SQS queue) | Grants permissions to a principal accessing the resource |
| Permissions boundary | Users, roles | Sets the *maximum* permissions an identity can have |
| Service Control Policy (SCP) | AWS Organizations OUs/accounts | Sets the *maximum* permissions for accounts in an organization |
| Resource Control Policy (RCP) ※ Δ | AWS Organizations OUs/accounts | Sets the *maximum* permissions for resources across accounts (newer counterpart to SCPs) |
| Session policy | Passed at role assumption time | Further restricts permissions during a session |
| Access control list (ACL) | Cross-account resource access (legacy) | Lists principals from other accounts; not JSON |

### Identity-Based Policy Categories
  - **AWS managed policies** — created and maintained by AWS, common use cases (e.g., `AmazonS3ReadOnlyAccess`)
  - **Customer managed policies** — created by you, reusable across users/groups/roles in your account
  - **Inline policies** — embedded directly in a single user, group, or role; deleted with the entity

  - AWS managed policies aligned to **job functions** include: Administrator, Billing, Database Administrator, Data Scientist, Developer Power User, Network Administrator, Security Auditor, Support User, System Administrator, View-Only User

> 💡 **Exam Tips:** 
<br>Start with **AWS managed policies** for common cases, then move to **customer managed** for refinement. 
<br>**Inline policies** are best when you want a strict 1:1 binding (policy follows the entity, deleted together).

---

## Resource-Based vs Identity-Based Policies

| **Aspect** | **Identity-Based** | **Resource-Based** |
|------------|---------------------|---------------------|
| Attached to | User, group, or role | Resource (S3, SQS, KMS, Lambda, etc.) |
| Specifies principal? | No (the identity *is* the principal) | Yes — `Principal` element required |
| Cross-account use | Identity in account A allows assuming role in B | Resource in B grants access to principal in A directly |
| Common services | All IAM identities | S3 bucket policies, KMS key policies, SNS topic policies, Lambda resource policies |

> ⚠️ **Exam Trap:** A resource-based policy can grant cross-account access **without** a role being assumed — the principal in another account uses their own credentials, and AWS evaluates the resource's policy to allow it.

---

## Policy Evaluation Logic

When a principal makes a request, AWS evaluates **all applicable policies** in a defined order to determine if the request is allowed.

### Determination Rules
  1. By default, all requests are implicitly denied § (root user excepted)
  2. An **explicit Allow** in any identity-based or resource-based policy overrides the default deny
  3. **Permissions boundaries, SCPs, or session policies** can override an Allow with an implicit deny
  4. An **explicit Deny in any policy overrides any Allow**

### Logic Model
  - **Allow** = Union (OR across same-type policies)
  - **Deny** = Intersection (AND across boundary types — all must allow)
  - **Explicit Deny** always wins

### Request Context
AWS evaluates each request using:
  - **Action** — what the principal wants to do
  - **Resource** — the AWS object being acted on
  - **Principal** — who is making the request
  - **Environment data** — IP address, user agent, time, SSL status
  - **Resource data** — data related to the resource being requested

---

## [Permission Evaluation Flow](https://drive.google.com/file/d/1LYzD_6GxymOqRbOx-lpOu5pzNdUHtSic/view?usp=drive_link)

<!--![Permission Evaluation Flow Diagram](../assets/1-IAM/permission-evaluation-flow.png)-->

### Order of Evaluation (Detailed)
  1. **Explicit Deny (any policy)** → EXPLICIT DENY (final, no further evaluation)
  2. **SCP check** (if account is in an organization)
     - If no Allow → IMPLICIT DENY
  3. **Resource-based policy**
     - If Allow → check policy conditions; can grant access directly
     - If no Allow → move to next step
  4. **Identity-based policy**
     - If no Allow → IMPLICIT DENY
  5. **Permissions Boundary** (if attached)
     - If no Allow → IMPLICIT DENY
  6. **Session policy** (if assumed role)
     - If no Allow → IMPLICIT DENY
  7. **Final decision** — Allow if no denies and at least one matching Allow

### Simplified Order
  - Explicit Deny
  - SCP Deny
  - Resource-based Deny
  - Identity-based Deny
  - Permissions Boundary Deny
  - Session Policy Deny
  - Allow

> 💡 **Exam Tip:** When in doubt about policy outcomes, walk the chain: 
<br>**Explicit Deny? → SCP? → Resource? → Identity? → Boundary? → Session?** 
<br>First miss = denied.

---

## Permission Rules — Quick Recap

  - Default § = **implicit deny**
  - **Explicit Allow** overrides implicit deny
  - **Explicit Deny** overrides everything
  - SCPs, boundaries, and session policies can restrict but not grant
  - Allow is OR (union); cross-type Deny chain is AND (intersection); Explicit Deny is final

### Analogy
  - **Identity-based policy** → ID badge
  - **Permissions boundary** → security guard at the door
  - **Resource-based policy** → room access list
  - **SCP** → company-wide rules

---

## AWS Requests

  - Every action in AWS is an **API call**
  - Defined as `service:operation` (e.g., `s3:GetObject`, `ec2:RunInstances`)
  - Whether via Console, CLI, SDK, or direct API — IAM evaluates the same way

---

# Authorization
---

## Permissions Boundaries

A **permissions boundary** is a managed policy that defines the **maximum permissions** an IAM user or role can have.

### Key Points
  - Attached to **users or roles** (not groups, not resources)
  - Does **NOT grant permissions** — only limits what other policies can grant
  - Effective permissions = **identity policy ∩ permissions boundary** (intersection)
  - Used to **delegate user/role creation** safely (a junior admin can create roles, but they can't escape the boundary)

### Privilege Escalation Prevention
Privilege escalation occurs when a user grants themselves (or another principal they create) more permissions than they were intended to have.

**Example scenario:**
  - Lindsay has `IAMFullAccess` only
  - Without a boundary, Lindsay could create a new user `X-User`, attach `AdministratorAccess` to it, sign in as `X-User`, and gain full account access
  - **Fix:** apply a permissions boundary to Lindsay so any user/role she creates inherits the same maximum scope

> 💡 **Exam Tip:** "Delegate IAM management without granting full admin." → **Permissions boundary** on the delegate's user/role.

---

## Service Control Policies (SCPs)

SCPs are organization-level policies applied through **AWS Organizations**.

  - Define the **maximum permissions** for accounts or organizational units (OUs)
  - Do NOT grant permissions — only restrict
  - Affect all IAM users and roles in the targeted accounts, **including the root user**
  - Even an account's root user cannot exceed an SCP

### SCP vs Permissions Boundary

| **Aspect** | **SCP** | **Permissions Boundary** |
|------------|---------|--------------------------|
| Scope | Entire AWS account or OU | Single user or role |
| Applied via | AWS Organizations | IAM directly |
| Affects root user? | Yes | No (root not constrained by IAM policies) |
| Grants permissions? | No | No |

> 📚 **Learn More:** This is the IAM-perspective summary of SCPs.
>
> - **Module 4 — AWS Organizations & Control Tower** — full SCP coverage, OU inheritance, deny-list vs allow-list strategies, interaction with other Organizations features
>
> For SAA, know what SCPs are and that they restrict (not grant). <br>For SAP, you'll need to design SCP strategies in depth.

---

# Trust & Delegation
---

## Cross-Account Access

Two main mechanisms for letting principals in account A access resources in account B:

### Method 1 — Assume a Role
  1. Account B creates an IAM role with a **trust policy** allowing account A
  2. Account B attaches a **permissions policy** to that role with the desired access
  3. Account A's user/role calls **`sts:AssumeRole`** on B's role to get temporary credentials
  4. User in A operates in B with the role's permissions

### Method 2 — Resource-Based Policy
  1. Account B's resource (e.g., S3 bucket) has a resource-based policy listing account A's principal
  2. Account A's user calls the resource directly with their own credentials — no role assumption

> 💡 **Exam Tips:** 
<br>"Switch role" or "assume role" in the question → **AssumeRole + STS**. 
<br>"Bucket policy grants account X" → **resource-based policy, no role assumption needed**.

---

## AWS Security Token Service (STS)

**AWS STS** is the service that **issues temporary, limited-privilege credentials**.

### What STS Returns
  - **Access key ID**
  - **Secret access key**
  - **Session token** (the marker that distinguishes temp creds from long-term)
  - **Expiration timestamp** (minutes to hours † depending on API)

### Core APIs

| **API** | **Used By** | **Purpose** |
|---------|-------------|-------------|
| `AssumeRole` | IAM users in same or different account | Standard role assumption (also supports MFA) |
| `AssumeRoleWithSAML` | Users authenticated by a SAML 2.0 IdP | Enterprise federation (e.g., Active Directory via ADFS) |
| `AssumeRoleWithWebIdentity` | Users authenticated by a web IdP (Google, Facebook, OIDC) | Mobile/web app federation |
| `GetSessionToken` | IAM user or root | Get short-term creds, often combined with MFA enforcement |
| `GetFederationToken` | IAM user or root | Used by custom identity brokers |

### Endpoint Behavior
  - STS is available as a **global endpoint** (`sts.amazonaws.com`) and **regional endpoints**
  - Regional endpoints are recommended § Δ — newer accounts default to regional STS for resilience and lower latency
  - Credentials returned by any endpoint work globally

### Why Use Temporary Credentials?
  - No long-term keys to leak or rotate
  - Auto-expire — no explicit revocation needed
  - Supports federated and cross-account scenarios
  - Foundation for IAM roles and identity federation

> 🔧 **Pro Tip:** AWS recommends using **AWS STS regional endpoints** in production for resilience — relevant at SAP level, where regional failure-mode design matters.

---

## Identity Federation Overview

Federation lets external identities access AWS without creating IAM users for them. 
<br>The mechanism is always the same: an external IdP authenticates the user, then AWS STS issues temporary credentials tied to an IAM role.

### Federation Types
  - **SAML 2.0** — for enterprise IdPs like Active Directory Federation Services (ADFS); paired with `AssumeRoleWithSAML`
  - **Web identity** — for social IdPs (Google, Facebook, Amazon) and OpenID Connect (OIDC); paired with `AssumeRoleWithWebIdentity`
  - **Custom identity broker** — proprietary IdP integrated with `GetFederationToken`

### Implementing Services (covered in Module 14)
  - **Amazon Cognito** — web/mobile app federation with social IdPs
  - **AWS IAM Identity Center** Δ — multi-account workforce SSO (successor to AWS SSO)
  - **AWS Directory Service** — managed Active Directory in AWS

> 📚 **Learn More:** This is intentionally a conceptual overview.
>
> - **Module 14 — Security** — service-level depth on Cognito, IAM Identity Center, and Directory Service (comparison criteria, exam triggers)
>
> The IAM module covers the *mechanism* (federation → STS → role); <br>Module 14 covers the *services* that implement it.

---

# In Practice
---

## IAM Tools

### Policy Simulator
  - Test policies before applying them
  - Simulates whether a given action on a resource would be allowed or denied
  - Helps debug "why is this user denied?" scenarios

### IAM Access Analyzer
  - Identifies resources shared with external entities (other accounts, public, etc.)
  - Validates policies for syntax, security, and best-practice issues
  - Generates **least-privilege policies** based on CloudTrail activity history
  - Continuously monitors for new findings
  - Recent additions ※ Δ include unused-access analysis (find unused users, roles, permissions) and custom policy checks

### Credential Report
  - Account-level CSV report listing all IAM users and their credential status (passwords, access keys, MFA, last used)
  - Used for auditing and compliance

### Last Accessed Information
  - Shows when an IAM user, group, role, or policy last used a given service
  - Helps refine permissions toward least privilege

> 💡 **Exam Tips:** 
<br>"Find permissions that are too broad / generate least-privilege policy" → **IAM Access Analyzer**. 
<br>"Audit who has MFA / last password use" → **Credential Report**.

---

## [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

  - **Lock away root user access keys** and don't use root for daily tasks
  - **Enable MFA** on root and all privileged users
  - **Use IAM roles** for applications running on EC2 (via instance profiles) and for federation
  - **Use IAM Identity Center** for human users — federation with temporary credentials
  - **Apply least-privilege** permissions; start with managed policies, refine with customer managed
  - **Use groups** to assign permissions to multiple users
  - **Rotate access keys** regularly; remove unused credentials
  - **Use permissions boundaries** to delegate IAM management safely
  - **Use IAM Access Analyzer** to validate policies and identify external access
  - **Use policy conditions** for additional context-based restrictions (IP, MFA, time)
  - **Configure a strong password policy**
  - **Monitor activity** with CloudTrail
  - **Use customer managed policies** instead of inline policies when reuse is needed
  - **Regularly review and remove** unused users, roles, permissions, and policies

---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Select group of users only should be able to change their IAM passwords | Create a group, attach a policy granting `iam:ChangePassword` |
| EC2 instance must access a DynamoDB table | Create a role with the required permissions, attach via instance profile |
| First AWS account, assign permissions by job function | Use AWS managed policies aligned with job functions |
| Restrict access to an AWS service based on source IP | IAM policy with `Condition` element using `aws:SourceIp` |
| Developer needs programmatic access via CLI | Create access keys for the developer's IAM user |
| Group of users needs full EC2 access | Policy with wildcard `Action: "ec2:*"` |
| Delegate IAM admin without granting full admin | Permissions boundary on the delegate's role/user |
| App needs to assume different identities at runtime | Use AWS STS `AssumeRole` to get temp credentials |
| Multi-account central permissions guardrails | AWS Organizations + SCPs (see Module 4) |

---

## Login References

  - **IAM User Login**
    https://ijpc-training.signin.aws.amazon.com/console
    Username: `ijpc-training`

  - **Root Account Login**
    https://console.aws.amazon.com/
    Use the **root email option**

---

# Module Summary
---

## Key Topics
  - **AWS Shared Responsibility Model** — AWS responsible for security of the cloud; customer responsible for security in the cloud; boundary shifts with service management level
  - IAM principals (users, groups, roles, federated users)
  - Authentication methods (password, access keys, MFA)
  - Resource ARNs and global service behavior
  - IAM policies (identity-based, resource-based, boundaries, SCPs, session)
  - Policy evaluation logic
  - Permissions boundaries and privilege escalation prevention
  - Cross-account access (role assumption vs resource-based)
  - AWS STS and temporary credentials
  - Federation overview (deep coverage in Module 14)
  - IAM tools (Policy Simulator, Access Analyzer, Credential Report)

---

## Critical Acronyms
  - **IAM** — Identity and Access Management
  - **MFA** — Multi-Factor Authentication
  - **TOTP** — Time-based One-Time Password
  - **FIDO2** — Fast Identity Online 2 (security key standard)
  - **STS** — Security Token Service
  - **ARN** — Amazon Resource Name
  - **SCP** — Service Control Policy
  - **RCP** — Resource Control Policy
  - **OU** — Organizational Unit
  - **SAML** — Security Assertion Markup Language
  - **OIDC** — OpenID Connect
  - **ADFS** — Active Directory Federation Services
  - **IdP** — Identity Provider
  - **CLI** — Command Line Interface
  - **SDK** — Software Development Kit
  - **API** — Application Programming Interface
  - **ACM** — AWS Certificate Manager
  - **PCI DSS** — Payment Card Industry Data Security Standard

---

## Key Comparisons
  - Root User vs IAM User
  - Identity-Based vs Resource-Based Policies
  - AWS Managed vs Customer Managed vs Inline Policies
  - SCP vs Permissions Boundary
  - STS API options (AssumeRole / AssumeRoleWithSAML / AssumeRoleWithWebIdentity / GetSessionToken / GetFederationToken)

---

## Top Exam Triggers
  - `EC2 needs to access an AWS service` → **IAM role + instance profile**
  - `Restrict by IP / require MFA / time window` → **Policy `Condition` element**
  - `Delegate IAM admin safely` → **Permissions boundary**
  - `Multi-account central guardrails` → **AWS Organizations SCP**
  - `Cross-account access` → **AssumeRole** (or resource-based policy)
  - `Temporary credentials` → **AWS STS**
  - `Generate least-privilege policy from activity` → **IAM Access Analyzer**
  - `Audit credentials and MFA status` → **Credential Report**
  - `Federate enterprise users via Active Directory` → **SAML 2.0 + AssumeRoleWithSAML** or **IAM Identity Center**
  - `Web/mobile app users with social login` → **Amazon Cognito**
  - `Common job-function permissions` → **AWS managed policies**
  - `Block access entirely` → **Explicit Deny** (always wins)
  - `IAM is in which region?` → **None — global service**

---

## Quick References

### [IAM Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28616888#overview) 

<!--![IAM Architecture Patterns1 Assets](../assets/1-IAM/iam-architecture-patterns-1.png)
![IAM Architecture Patterns2 Assets](../assets/1-IAM/iam-architecture-patterns-2.png) -->

### [IAM Architecture Patterns Private Link](https://drive.google.com/drive/folders/1LgYNYPBjAHFn4hLGs_o8EamyIatiFYYc?usp=drive_link)

### [IAM Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346094#overview)

### [IAM Cheat Sheet](https://digitalcloud.training/aws-iam/)

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