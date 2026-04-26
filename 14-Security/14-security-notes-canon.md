# Identity & Access
---

## Identity Federation Overview

**Identity Federation** allows external identities — users who exist in an outside directory or identity provider — to access AWS resources using **temporary credentials** from AWS STS (Security Token Service), without requiring IAM user accounts for each individual.

> 📚 **Learn More:** IAM fundamentals (users, groups, roles, policies, SCPs) are fully covered in Module 1.
>
> - **Module 1 — IAM** — IAM users, groups, roles, policy types, permissions boundaries, Organizations SCPs
>
> This module covers the advanced identity topics: federation patterns, STS, Cognito, Directory Services, and IAM Identity Center.

| **Federation Type** | **Identity Source** | **AWS Mechanism** | **Typical Use Case** |
|--------------------|--------------------|--------------------|---------------------|
| **SAML 2.0** | Enterprise IdP (AD FS, Okta, etc.) | STS `AssumeRoleWithSAML` | Corporate employees → AWS Console or API |
| **Web Identity / OIDC** | Social providers (Google, Facebook, Amazon) | STS `AssumeRoleWithWebIdentity` | Consumer mobile/web apps (use Cognito instead) |
| **Amazon Cognito** | User Pools + Identity Pools | STS via Cognito | Mobile and web application users → AWS resources |
| **IAM Identity Center** | Identity Center directory, AD, or SAML IdP | SSO portal + STS | Multi-account AWS access with a single login |
| **Cross-Account Role** | Another AWS account | STS `AssumeRole` | Dev account assuming a role in prod account |

---

## AWS Security Token Service (STS)

AWS STS is the underlying service that issues **temporary security credentials** — every federation flow ultimately calls STS. Credentials consist of an Access Key ID, a Secret Access Key, and a Session Token, and have a configurable lifetime (minutes to hours).

| **STS API** | **Who Can Call It** | **Use Case** |
|-------------|--------------------|--------------| 
| `AssumeRole` | IAM users, IAM roles | Cross-account access; role chaining; MFA-protected operations |
| `AssumeRoleWithSAML` | Any user with valid SAML assertion | Enterprise federation via SAML 2.0 IdP |
| `AssumeRoleWithWebIdentity` | Any user with OIDC/OAuth token | Web/mobile identity federation (Cognito wraps this) |
| `GetSessionToken` | IAM user or root user | MFA-enforced access; temporary credentials from existing credentials |
| `GetFederationToken` | IAM user or root user | Broker-based custom federation |

> 💡 **Exam Tip:** "Temporary credentials" or "temporary access" in any context → **AWS STS**.
<br>STS itself is not a directory or identity store — it only issues credentials after a trust assertion has been verified.

---

## SAML 2.0 Federation

SAML 2.0 (Security Assertion Markup Language) federation is the standard pattern for enterprise employees to access AWS using their existing corporate credentials.

**Authentication flow:**
1. User authenticates with the corporate Identity Provider (IdP) — e.g., Active Directory Federation Services (ADFS), Okta, Ping
2. IdP generates a **SAML assertion** (a signed XML document) confirming the user's identity and group memberships
3. The SAML assertion is submitted to AWS STS via `AssumeRoleWithSAML`
4. STS validates the assertion against the configured IdP trust and returns temporary credentials
5. User accesses AWS Console or API using those credentials

> 💡 **Exam Tips:**
> <br>"Corporate employees log in to the AWS Console using their Active Directory credentials" → **SAML 2.0 federation** with `AssumeRoleWithSAML`
> <br>"Single Sign-On for enterprise users across multiple AWS accounts" → **IAM Identity Center** (which supports SAML 2.0 as an identity source)

---

## AWS IAM Identity Center

AWS IAM Identity Center (formerly AWS Single Sign-On / SSO) provides **centralized multi-account access management** with a single sign-on experience across all AWS accounts in an organization and supported SaaS applications. Δ

### Key Properties

- Manages **permission sets** that define what a user can do in each account
- Users authenticate once → receive a portal with one-click access to any assigned account/role
- Works natively with **AWS Organizations** — one permission set can be deployed across hundreds of accounts
- Identity sources (choose one):
  - **Identity Center built-in directory** — manage users directly in Identity Center
  - **AWS Managed Microsoft AD** (via Directory Service) — use corporate AD identities
  - **External SAML 2.0 IdP** — Okta, Azure AD, Ping, etc.

> 💡 **Exam Tips:**
> <br>"Centralized SSO across all AWS accounts in an Organization" → **IAM Identity Center**
> <br>"Use existing Okta identity provider for AWS multi-account access" → **IAM Identity Center with external SAML 2.0 IdP**
> <br>"IAM Identity Center" and "AWS SSO" refer to the same service in exam questions Δ

---

## Amazon Cognito

Amazon Cognito is the AWS managed service for adding **authentication, authorization, and user management** to web and mobile applications. It handles identity broker functions so your application code doesn't have to.

> 💡 **Exam Tip:** "Web or mobile application needs user sign-up, sign-in, and access to AWS resources" → **Amazon Cognito** (User Pool for auth + Identity Pool for AWS access)

---

## Cognito User Pools

A **User Pool** is a managed **user directory** for your application. It handles:

- User sign-up and sign-in (email/phone/username + password)
- Social identity federation (Google, Facebook, Apple, Amazon)
- SAML and OIDC identity provider federation
- Built-in MFA, compromised credential checks, account takeover protection
- Customizable web UI hosted by Cognito
- Lambda triggers for custom authentication workflows

**What it returns:** After successful authentication, Cognito User Pools issue **JSON Web Tokens (JWT)**.
<br>Specifically these are an **ID token, access token, and refresh token**. 
<br>The application uses the JWT to authorize access to the app's own APIs or backend.

---

## Cognito Identity Pools

A **Cognito Identity Pool** (also called a **Federated Identity**) exchanges an authenticated identity token for **temporary AWS credentials** via STS. The credentials allow the user to directly call AWS services.

- Supports identities authenticated via **User Pools, social providers, SAML IdPs, and OIDC providers**
- Maps authenticated (and optionally unauthenticated) identities to IAM roles
- Allows guest (unauthenticated) access with a restricted IAM role

**What it returns:** Temporary AWS credentials (**Access Key ID, Secret Access Key, Session Token**).

---

## User Pools vs. Identity Pools

This distinction is one of the most-tested Cognito concepts:

| **Feature** | **Cognito User Pool** | **Cognito Identity Pool** |
|-------------|----------------------|--------------------------|
| **Purpose** | Authenticate users | Authorize AWS resource access |
| **Question it answers** | "Who are you?" | "What AWS resources can you access?" |
| **Output** | JWT tokens (ID / access / refresh) | Temporary AWS credentials via STS |
| **Analogy** | Like IAM Users or an Active Directory | Like an IAM Role |
| **Standalone use** | Yes — secure your own APIs with JWT | Yes — grant guest access to AWS services |
| **Combined use** | User Pool authenticates → Identity Pool exchanges JWT for AWS creds | ← same scenario |

> ⚠️ **Exam Trap:** User Pools authenticate users and return **JWT tokens** — they do **not** grant direct access to AWS services. 
<br>To access AWS services (S3, DynamoDB, etc.), you need an **Identity Pool** to exchange the JWT for AWS credentials.

> 💡 **Exam Tips:**
> <br>"Mobile app users need to sign in and read from S3" → **User Pool (authentication) + Identity Pool (AWS access)**
> <br>"App needs to call DynamoDB on behalf of a signed-in user" → **Cognito Identity Pool** (provides scoped IAM role credentials)
> <br>"Secure your REST API with Cognito-issued tokens" → **Cognito User Pool as an authorizer** for API Gateway

---

## AWS Directory Service

AWS Directory Service provides **managed Microsoft Active Directory** options — eliminating the need to run and maintain your own AD domain controllers in the cloud.

### Directory Service Options

| **Option** | **Description** | **Best When** | **Limitations** |
|-----------|----------------|--------------|-----------------|
| **AWS Managed Microsoft AD** | Full Microsoft AD (Windows Server) managed by AWS | > 5,000 users; need trust relationships; schema extensions; standalone AD in AWS | Requires VPN or Direct Connect for on-prem integration |
| **AD Connector** | Proxy that redirects all directory requests to your existing on-premises AD | You want AWS services to use on-prem AD identities without replicating them | Requires VPN or Direct Connect; on-prem AD must remain available |
| **Simple AD** | Lightweight Samba 4-based AD-compatible directory | < 5,000 users; basic LDAP needs; low cost; no advanced features needed | No trust relationships; no schema extensions; no MFA; not RDS SQL Server compatible |

### AWS Managed Microsoft AD — Key Details

- Two editions: **Standard** (up to 30,000 objects, ~5,000 users) and **Enterprise** (up to 500,000 objects)
- Deployed across **two AZs** in the same region for high availability
- Supports **trust relationships** with on-premises AD — on-prem users can SSO into AWS resources
- Supports **schema extensions**, MFA via RADIUS, fine-grained password policies
- Compatible with: WorkSpaces, WorkDocs, RDS for SQL Server, QuickSight, and more
- Does **not** support replication mode (no sync to on-prem AD) — use trust relationships instead

### AD Connector — Key Details

- **No user objects stored** in AWS — all authentication requests proxied to on-prem AD DCs
- Sizes: Small (up to 500 users), Large (up to 5,000 users)
- Supports MFA via RADIUS-based MFA infrastructure
- Not compatible with RDS SQL Server

### Simple AD — Key Details

- Sizes: Small (up to 500 users / ~2,000 objects), Large (up to 5,000 users / ~20,000 objects)
- Supports: user accounts, groups, group policies, domain join, Kerberos SSO
- Does **not** support: trust relationships, schema extensions, MFA, LDAPS, FSMO roles
- Not compatible with RDS SQL Server

> 💡 **Exam Tips:**
> <br>"Managed Microsoft AD in AWS, more than 5,000 users" → **AWS Managed Microsoft AD**
> <br>"Use existing on-premises AD identities with AWS services without migrating" → **AD Connector**
> <br>"Simple low-cost directory, basic LDAP, fewer than 5,000 users" → **Simple AD**
> <br>"Join EC2 instances to an on-premises domain" → **AD Connector** or **AWS Managed Microsoft AD** (with trust)

> ⚠️ **Exam Trap:** AD Connector does **not** cache credentials — if the connection to on-premises AD goes down, authentication fails. 
<br>Simple AD is standalone and doesn't depend on on-premises connectivity.

---

# Encryption & Key Management
---

## Encryption Fundamentals

| **Concept** | **Definition** | **AWS Mechanism** |
|-------------|---------------|-------------------|
| **Encryption at rest** | Data is encrypted while stored on disk or object storage | KMS keys with integrated AWS services (S3, EBS, RDS, DynamoDB…) |
| **Encryption in transit** | Data is encrypted while moving over a network | SSL/TLS (HTTPS, TLS 1.2+) |
| **Symmetric encryption** | Same key encrypts and decrypts | KMS symmetric keys (AES-256) — bulk data |
| **Asymmetric encryption** | Public key encrypts; private key decrypts | KMS asymmetric keys (RSA, ECC) — digital signatures, key exchange |
| **Envelope encryption** | Data key encrypts data; KMS key encrypts the data key | Standard pattern for all AWS service encryption |

**KMS is encryption at rest only** — it does not protect data in transit. Use SSL/TLS for in-transit protection.

---

## AWS Key Management Service (KMS)

AWS KMS is the managed service for **creating, storing, and controlling cryptographic keys** used to encrypt data across AWS services and custom applications. KMS keys never leave the service unencrypted and are protected by FIPS 140-2 Level 2 validated HSMs. ‡

### Key Properties

- KMS keys can directly encrypt data up to **4 KB** in size † — for larger data, use envelope encryption
- KMS is tightly integrated with most AWS services: S3, EBS, RDS, DynamoDB, Lambda, SQS, SNS, etc.
- All KMS API calls are logged in **AWS CloudTrail** — full audit trail of key usage
- Keys are **regional** — a KMS key in us-east-1 cannot be used by a service in eu-west-1 ◊
- **Multi-Region Keys** ※ — replicate a key to other regions with the same key ID; for cross-region encryption use cases
- Up to **1,000 KMS keys** per account per region † (AWS Managed Keys do not count toward this limit)

---

## KMS Key Types

| **Key Type** | **Viewable?** | **Manageable?** | **Cost** ¤ | **Rotation** | **Key Policy** | **Notes** |
|-------------|--------------|----------------|-----------|-------------|---------------|-----------|
| **AWS Owned Key** | ❌ No | ❌ No | Free — not in your account | AWS manages (varies) | N/A | Shared across AWS accounts; used automatically by services |
| **AWS Managed Key** | ✅ Yes | ❌ No | Free monthly; usage fees may apply | Automatic — every year § | Cannot modify | Named `aws/servicename` (e.g., `aws/s3`, `aws/ebs`) |
| **Customer Managed Key (CMK)** | ✅ Yes | ✅ Yes | Monthly fee + usage fees ¤ | Optional automatic (annual); manual supported | Customer-defined | Full control: enable/disable, delete, cross-account grants |

> 💡 **Exam Tips:**
> <br>"Customer needs control over key policies and rotation" → **Customer Managed Key (CMK)**
> <br>"Simple AWS-native encryption with no key management overhead" → **AWS Managed Key** (or AWS Owned Key — customer doesn't choose)
> <br>"Cross-account access to an encrypted EBS snapshot" → requires **CMK** with explicit `kms:Decrypt` and `kms:CreateGrant` permissions for the target account

---

## KMS Key Policies

Key policies are the **primary access control mechanism** for KMS keys — unlike IAM, a KMS key cannot be used without a key policy. 
<br>Key policies work in conjunction with IAM policies and grants.

- **Key policy** — resource-based policy attached directly to the KMS key; defines who can administer and use the key
- **IAM policy** — allows IAM users/roles to interact with KMS, but only if the key policy also permits it
- **Grants** — delegate specific operations to AWS principals programmatically; used by AWS services to use keys on your behalf without modifying the key policy

**`kms:ViaService` condition key** — restricts a key to be used only by a specific AWS service (e.g., only by `ec2.amazonaws.com`). Useful for preventing direct API use of a key while still allowing EBS to use it.

> ⚠️ **Exam Trap:** Sharing an encrypted snapshot with another account requires that the **CMK's key policy** explicitly grants the target account `kms:Decrypt` and `kms:CreateGrant`. IAM permissions alone in the target account are not sufficient — the key policy must also allow it.

---

## Envelope Encryption

Envelope encryption is the pattern all AWS services use to encrypt data larger than 4 KB:

```
1. Call KMS GenerateDataKey → returns:
   a. Plaintext data key (in memory only — never persisted)
   b. Encrypted data key (encrypted under the KMS key)
2. Use the plaintext data key to encrypt your data (AES-256)
3. Discard the plaintext data key from memory
4. Store the encrypted data key alongside the ciphertext
```

**To decrypt:**
1. Send the encrypted data key to KMS → KMS returns the plaintext data key
2. Use the plaintext data key to decrypt the ciphertext
3. Discard the plaintext data key

**Why this pattern?** KMS only handles keys — your data never passes through KMS. The data key does the actual bulk encryption locally. KMS is only invoked to wrap/unwrap the data key.

> 💡 **Exam Tip:** "How does KMS encrypt an S3 object larger than 4 KB?" → **Envelope encryption** — `GenerateDataKey` → encrypt locally → store encrypted key with object.

---

## KMS Key Rotation

| **Scenario** | **Rotation Behavior** |
|-------------|----------------------|
| AWS Managed Keys | Automatic — every year § |
| Customer Managed Keys | **Optional** automatic rotation — every year (or configurable period) ※ |
| Imported key material | Manual only — automatic rotation **not supported** |
| Asymmetric KMS keys | Automatic rotation **not supported** |
| HMAC KMS keys | Automatic rotation **not supported** |
| Keys in custom key stores (CloudHSM) | Automatic rotation **not supported** |

**With automatic rotation enabled:** AWS KMS creates new key material every year. The key ID, ARN, policies, and aliases remain unchanged. Existing ciphertext can still be decrypted — KMS keeps all previous key versions for decryption purposes. Applications do not need to be updated.

**Cryptographic erasure** — the ability to immediately and irrevocably make encrypted data unreadable. Achieved by deleting imported key material (`DeleteImportedKeyMaterial` API). This is the only key type where you can achieve immediate cryptographic erasure on demand.

---

## KMS Key Deletion

- Schedule deletion with a configurable waiting period: **7 to 30 days** † (§ default: 30 days)
- During the waiting period, the key cannot be used — it enters `Pending Deletion` state
- **Cancellable** during the waiting period
- Once deleted, all data encrypted with that key becomes permanently unrecoverable

> ⚠️ **Exam Trap:** Deleting a KMS key is irreversible after the waiting period. Any data encrypted **only** with that key (without backup) becomes permanently inaccessible.

---

## AWS CloudHSM

AWS CloudHSM provides **dedicated, single-tenant hardware security modules** in the AWS cloud. Unlike KMS (where AWS manages the HSM fleet), CloudHSM gives you direct, exclusive control of the cryptographic hardware.

### Key Properties

| **Feature** | **CloudHSM** |
|------------|-------------|
| **Tenancy** | Single-tenant — dedicated HSMs in your VPC |
| **Compliance** | FIPS 140-2 **Level 3** ‡ (KMS is Level 2) |
| **Key visibility** | Only the customer — AWS has **zero visibility** into your keys |
| **Key export** | Keys can be exported (unlike KMS where keys never leave unencrypted) |
| **API support** | PKCS#11, JCE (Java), Microsoft CNG |
| **Deployment** | Deployed into your VPC; you manage availability via HSM clusters |
| **Key material** | Can be used as a custom key store for KMS |

### CloudHSM Use Cases
- Offload **SSL/TLS processing** from web servers
- Protect **private keys for Certificate Authorities (CAs)**
- Store Oracle **Transparent Data Encryption (TDE)** master keys
- Meet regulatory requirements mandating **FIPS 140-2 Level 3** hardware
- Use as a **custom key store for KMS** — key operations stay in your HSMs while AWS services use KMS APIs

---

## KMS vs. CloudHSM

| **Feature** | **AWS KMS** | **AWS CloudHSM** |
|------------|------------|-----------------|
| **Tenancy** | Multi-tenant (shared HSM fleet) | Single-tenant (dedicated hardware) |
| **FIPS compliance** | Level 2 | **Level 3** |
| **AWS visibility into keys** | AWS has access under strict controls | **Zero** — customer-only |
| **Key export** | Keys never leave KMS unencrypted | Keys can be exported |
| **AWS service integration** | Deep — S3, EBS, RDS, Lambda, etc. | Via KMS custom key store |
| **Management overhead** | Low — fully managed | Higher — you manage HSM clusters |
| **Use when** | Standard AWS service encryption, broad integration | Strict compliance, L3 FIPS, customer-controlled root of trust |

> 💡 **Exam Tips:**
> <br>"AWS must not have access to encryption keys" → **CloudHSM**
> <br>"FIPS 140-2 Level 3 compliance required" → **CloudHSM**
> <br>"Encrypt EBS, S3, RDS with minimal management overhead" → **KMS**
> <br>"Use your own HSM hardware but still use KMS APIs" → **KMS custom key store backed by CloudHSM**

---

## AWS Certificate Manager (ACM)

AWS Certificate Manager provisions, manages, and **automatically renews** SSL/TLS certificates for use with AWS services.

### Key Properties

- **Public certificates** — issued by Amazon's CA, **free of charge** ¤ for integrated services
- **Private certificates** — requires **ACM Private CA** (AWS Private Certificate Authority) — separate paid service ¤
- **Imported certificates** — bring your own certificate from a third-party CA
- **Auto-renewal** — ACM automatically renews certificates it issues, before expiration §
- Certificates managed by ACM **cannot be exported** (private key stays in ACM) — by design, for security

### Integrations

ACM certificates can be deployed to:
- Elastic Load Balancing (ALB, NLB, CLB)
- Amazon CloudFront distributions
- Amazon API Gateway
- AWS Elastic Beanstalk
- AWS CloudFormation

> ⚠️ **Exam Trap:** ACM certificates **cannot** be installed directly on EC2 instances — the private key is not exportable. 
<br>For EC2-hosted web servers, you must import a certificate from a third-party CA (or use a self-signed cert). <br>ACM is for **managed integrations only** (ELB, CloudFront, API Gateway).

> 💡 **Exam Tips:**
> <br>"Provision and auto-renew an SSL/TLS certificate for an ALB or CloudFront" → **ACM**
> <br>"Issue private certificates for internal services" → **ACM Private CA**
> <br>"Use an existing certificate from an external CA" → **Import into ACM**

---

# Network & Application Protection
---

## AWS WAF (Web Application Firewall)

AWS WAF is a **Layer 7** (HTTP/HTTPS) web application firewall that filters web requests before they reach your application. It protects against common web exploits and allows fine-grained traffic control.

### Key Properties

- Operates at **Layer 7** — inspects HTTP/HTTPS content (not just IP/port like a standard firewall)
- Deployed via a **Web ACL** (Access Control List) that contains ordered rules
- Rules evaluate incoming requests and take one of four actions: `Allow`, `Block`, `Count`, `CAPTCHA`
- New rules can be deployed in **minutes** without downtime
- Charged per Web ACL, per rule, and per million requests ¤

### WAF Rule Types

| **Rule Type** | **Description** |
|--------------|----------------|
| **IP Set match** | Allow or block a list of specific IP addresses or CIDR ranges |
| **Geographic match** | Block or allow requests based on country of origin |
| **String match** | Match specific strings in URI, header, query string, or body |
| **Regex pattern set** | Complex string matching using regular expressions |
| **SQL injection detection** | Detect and block SQL injection patterns |
| **XSS detection** | Detect and block cross-site scripting patterns |
| **Size constraint** | Block requests whose body, header, or URI exceeds a size threshold |
| **Rate-based rule** | Block IPs that send requests above a configured rate (per 5 minutes) |

### Managed Rule Groups ※

AWS WAF Managed Rules are **pre-built rule groups** maintained by AWS or AWS Marketplace vendors. Customers subscribe to them without needing to write individual rules:

- **AWS Managed Rules** (free) — common threats: `AWSManagedRulesCommonRuleSet`, `AWSManagedRulesSQLiRuleSet`, `AWSManagedRulesKnownBadInputsRuleSet`
- **Marketplace Managed Rules** (paid) — from security vendors (Fortinet, F5, Imperva, etc.)

### WAF Integrations

WAF Web ACLs can be attached to:
- **Amazon CloudFront** — rules execute at edge locations globally
- **Application Load Balancer (ALB)** — rules execute in the region
- **Amazon API Gateway** — REST APIs
- **AWS AppSync** — GraphQL APIs
- **Amazon Cognito User Pools** ※ — protect your authentication endpoint

> 💡 **Exam Tips:**
> <br>"Block SQL injection and XSS attacks against a web application" → **AWS WAF**
> <br>"Block traffic from specific countries" → **WAF geographic match rule**
> <br>"Rate-limit a specific API to prevent abuse" → **WAF rate-based rule**
> <br>"Protect at the edge before traffic reaches the origin" → **WAF on CloudFront**

---

## AWS Shield

AWS Shield is the **managed DDoS (Distributed Denial of Service) protection** service. It protects AWS resources from network-layer and application-layer volumetric attacks.

### Shield Standard vs. Shield Advanced

| **Feature** | **Shield Standard** | **Shield Advanced** |
|------------|--------------------|--------------------|
| **Cost** | Free — included for all AWS customers § ¤ | Paid — monthly subscription per organization ¤ |
| **Protection layers** | Layer 3 and Layer 4 only | Layer 3, 4, and Layer 7 (with WAF) |
| **Detection** | Automatic, always-on | Enhanced — more sophisticated detection |
| **Mitigation** | Automatic inline | Automatic + SRT (Shield Response Team) assistance |
| **DDoS Response Team (DRT)** | ❌ | ✅ 24×7 access |
| **DDoS cost protection** | ❌ | ✅ Protects against billing spikes from DDoS-driven scaling ¤ |
| **Visibility** | No attack visibility | Real-time dashboards and attack diagnostics |
| **Protected resources** | CloudFront, Route 53 | EC2, ELB, CloudFront, Global Accelerator, Route 53 |

### Shield Advanced Key Details

- Protects against large and sophisticated DDoS attacks targeting **EC2, ELB, CloudFront, Global Accelerator, and Route 53**
- **DDoS cost protection** — if a DDoS attack causes your resources to scale up (EC2, ELB, CloudFront, Global Accelerator, Route 53), you can request service credits ¤
- Integrates with **AWS WAF** for Layer 7 protection
- Available globally on all CloudFront, Global Accelerator, and Route 53 edge locations ◊

> 💡 **Exam Tips:**
> <br>"Protect against DDoS at no additional cost" → **Shield Standard** (always on, free)
> <br>"Advanced DDoS protection with 24×7 DRT access and attack visibility" → **Shield Advanced**
> <br>"Protection against billing spikes caused by a DDoS attack" → **Shield Advanced** (DDoS cost protection)

---

## AWS Firewall Manager

AWS Firewall Manager is a **security management service** that lets you centrally configure and manage firewall rules across all accounts and resources in your AWS Organization — from a single **administrator account**.

### What Firewall Manager Manages

| **Policy Type** | **What It Enforces** |
|----------------|---------------------|
| **AWS WAF** | WAF Web ACLs across ALBs, CloudFront, API Gateway |
| **AWS Shield Advanced** | Enrollment and protection across accounts |
| **Security Groups** | Enforce or audit security group rules across EC2 and ENIs |
| **Network Firewall** | Deploy AWS Network Firewall policies across VPCs |
| **Route 53 Resolver DNS Firewall** | Enforce DNS firewall rules |

### Key Properties

- Requires **AWS Organizations** with all features enabled
- Designated **Firewall Manager administrator account** manages policies
- Policies are applied **automatically to new accounts** added to the organization
- Non-compliance is flagged and can trigger remediation

> 💡 **Exam Tips:**
> <br>"Centrally enforce WAF rules across all accounts in an Organization" → **AWS Firewall Manager**
> <br>"New AWS accounts must automatically have WAF protection applied" → **Firewall Manager**
> <br>"Manage Shield Advanced enrollment across all accounts" → **Firewall Manager**

---

## WAF vs. Shield vs. Firewall Manager

| **Service** | **What It Protects Against** | **Layer** | **Scope** |
|------------|------------------------------|-----------|-----------|
| **AWS WAF** | Web exploits (SQLi, XSS, bad bots, rate abuse) | L7 (HTTP/HTTPS) | Per resource (CloudFront, ALB, API GW) |
| **AWS Shield Standard** | Network/transport DDoS | L3/L4 | All AWS customers, automatic |
| **AWS Shield Advanced** | Sophisticated DDoS + billing protection + DRT | L3/L4/L7 | Specific protected resources |
| **AWS Firewall Manager** | Policy enforcement across accounts | Any | Organization-wide governance |

---

# Threat Detection & Security Visibility
---

## Threat Detection Services Overview

| **Service** | **What It Does** | **Primary Data Sources** | **Output** |
|------------|-----------------|--------------------------|-----------|
| **Amazon GuardDuty** | Continuous ML-based threat detection | CloudTrail, VPC Flow Logs, DNS logs | Threat findings |
| **Amazon Inspector** | Automated vulnerability scanning | EC2 SSM agent, ECR image layers | CVE findings |
| **Amazon Macie** | Sensitive data discovery in S3 | S3 object content + metadata | Data findings |
| **AWS Security Hub** | Centralized findings aggregation + CSPM | GuardDuty, Inspector, Macie, Config, etc. | Normalized findings dashboard |
| **Amazon Detective** | Security investigation + root cause analysis | CloudTrail, VPC Flow Logs, GuardDuty findings | Graph-based investigation |

---

## Amazon GuardDuty

Amazon GuardDuty is a **continuous, ML-powered threat detection service** that analyzes AWS account activity to identify malicious behavior, unauthorized access, and compromised resources — without requiring agents or infrastructure changes.

### Data Sources

GuardDuty automatically analyzes:
- **AWS CloudTrail management events** — suspicious API calls, account-level activity
- **AWS CloudTrail S3 data events** — unusual S3 access patterns ※
- **VPC Flow Logs** — unusual network traffic, port scanning, data exfiltration
- **DNS logs** — queries to known malicious domains, C2 communication
- **EKS audit logs, EKS runtime activity** — container threat detection ※
- **Lambda network activity** ※

### Finding Categories

| **Category** | **Example** |
|-------------|------------|
| Reconnaissance | `Recon:IAMUser/MaliciousIPCaller` — API enumeration from known malicious IP |
| Backdoor/Trojan | `Backdoor:EC2/C&CActivity.B` — EC2 communicating with known botnet |
| Cryptomining | `CryptoCurrency:EC2/BitcoinTool.B!DNS` — mining traffic detected |
| Data exfiltration | `Exfiltration:S3/ObjectRead.Unusual` — unusual S3 read pattern |
| Credential compromise | `UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration` — credentials used outside AWS |
| Privilege escalation | `PrivilegeEscalation:IAMUser/AdministrativePermissions` |

### Multi-Account Support

- **Administrator account** — designated GuardDuty management account for an Organization
- **Member accounts** — all accounts in the Organization can have findings consolidated in the administrator account
- Findings in member accounts are visible in the administrator account's GuardDuty console
- Aggregating findings with **AWS Security Hub** provides cross-account visibility

### Key Properties

- **No agent required** — GuardDuty operates at the control plane and network flow level
- Does **not** directly block traffic — findings drive response via EventBridge → Lambda automation or Security Hub
- Findings are delivered to GuardDuty console, CloudWatch Events / EventBridge, and optionally Security Hub
- 30-day **free trial** on first enablement per account; paid based on data volume analyzed ¤

> 💡 **Exam Tips:**
> <br>"Detect if EC2 instance is communicating with a known command-and-control server" → **GuardDuty**
> <br>"Continuous threat monitoring across AWS accounts without installing agents" → **GuardDuty**
> <br>"GuardDuty found a threat — automatically remediate" → **GuardDuty finding → EventBridge rule → Lambda**

> ⚠️ **Exam Trap:** GuardDuty does **not** block traffic or take action on its own. It detects and alerts. <br>Automated response requires an EventBridge rule that triggers a Lambda function or SSM automation.

---

## Amazon Inspector

Amazon Inspector is an **automated vulnerability management service** that continuously scans AWS workloads for software vulnerabilities and unintended network exposure.

### What Inspector Scans

| **Target** | **What It Checks** | **Agent Required?** |
|-----------|-------------------|---------------------|
| **Amazon EC2 instances** | OS packages with known CVEs; network reachability | ✅ Yes — SSM Agent must be installed and running |
| **Amazon ECR container images** | Package vulnerabilities in container image layers; on push or on schedule | ❌ No agent — integrated with ECR |
| **AWS Lambda functions** | Vulnerabilities in Lambda function code and dependencies ※ | ❌ No agent |

### Key Properties

- **Continuously scans** — not just point-in-time; findings are updated as new CVEs are published Δ
- **Risk scoring** — each finding gets a score based on CVE severity + exploitability + network exposure context
- Automatically discovers resources via **SSM** (EC2) and ECR/Lambda integration
- Findings published to Inspector console, Security Hub, and EventBridge

> 💡 **Exam Tips:**
> <br>"Scan EC2 instances for OS-level vulnerabilities and CVEs" → **Amazon Inspector**
> <br>"Scan container images for vulnerabilities before deployment" → **Inspector + ECR integration**
> <br>"Network reachability assessment — is port 22 exposed to the internet?" → **Inspector** (network assessment, no agent needed for network checks)

> ⚠️ **Exam Trap:** EC2 vulnerability scanning in Inspector requires the **SSM Agent** to be installed. 
<br>The old Inspector Classic required a separate Inspector agent — the current Inspector uses SSM. Δ

---

## Amazon Macie

Amazon Macie is a **data security service** that uses machine learning to automatically **discover, classify, and protect sensitive data** stored in Amazon S3.

### What Macie Detects

| **Category** | **Examples** |
|-------------|-------------|
| **PII** (Personally Identifiable Information) | Names, addresses, email addresses, phone numbers, SSNs |
| **Financial data** | Credit card numbers, bank account numbers |
| **Health data (PHI)** | Medical record numbers, health insurance IDs |
| **Credentials** | API keys, secret keys, passwords in files |
| **Custom patterns** | User-defined regex for organization-specific sensitive data |

### Key Properties

- **Automated bucket discovery** — Macie scans and catalogs all S3 buckets in the account, assessing for public accessibility, encryption status, and replication settings
- Findings are published to the Macie console, **Security Hub**, and **EventBridge**
- Supports multi-account via AWS Organizations — one administrator account sees all member findings
- Charged per GB of S3 data evaluated ¤

> 💡 **Exam Tips:**
> <br>"Discover PII or sensitive data accidentally stored in S3 buckets" → **Amazon Macie**
> <br>"Continuously monitor S3 for sensitive data compliance" → **Amazon Macie**
> <br>"Identify which S3 buckets are publicly accessible" → Macie also reports on bucket-level security posture (though S3 Block Public Access and Config can also do this)

---

## AWS Security Hub

AWS Security Hub provides a **comprehensive, centralized view of security alerts and compliance status** across all AWS accounts. 
<br>It aggregates, normalizes, and prioritizes findings from multiple AWS security services and third-party tools.

### Finding Sources

Security Hub ingests findings from:
- Amazon GuardDuty
- Amazon Inspector
- Amazon Macie
- AWS Config (compliance rules)
- AWS IAM Access Analyzer
- AWS Firewall Manager
- Third-party partner integrations (CrowdStrike, Palo Alto Networks, etc.)

### Compliance Standards (CSPM)

Security Hub continuously evaluates resources against industry-standard compliance frameworks:
- **CIS AWS Foundations Benchmark**
- **AWS Foundational Security Best Practices (FSBP)**
- **PCI DSS**
- **NIST 800-53** ※

### Key Properties

- Findings use a **standardized format** (ASFF — AWS Security Finding Format) for cross-service correlation
- **Cross-account aggregation** — designate an administrator account to see all member account findings
- Findings can trigger **EventBridge rules** → automated remediation workflows
- Requires enabling GuardDuty, Inspector, Macie, etc. separately — Security Hub aggregates, it does not replace them

> 💡 **Exam Tips:**
> <br>"Single pane of glass for security findings across multiple AWS security services" → **AWS Security Hub**
> <br>"Continuously check if AWS resources comply with CIS or PCI DSS standards" → **Security Hub compliance standards**
> <br>"Automated workflow triggered by a security finding" → **Security Hub → EventBridge → Lambda**

---

## Amazon Detective

Amazon Detective makes it easy to **investigate security findings and determine their root cause** by automatically collecting and correlating log data into an interactive graph model.

### Key Properties

- **Investigation tool** — not a detection tool; Detective is used *after* GuardDuty or Security Hub surfaces a finding
- Automatically ingests and correlates: **CloudTrail**, **VPC Flow Logs**, **GuardDuty findings**, and **EKS audit logs** ※
- Builds a **behavior graph** — a persistent model of normal account activity over up to 1 year
- Allows analysts to query: "Who else did this IAM role call? What other resources communicated with this IP?"
- No infrastructure to set up — fully managed; Detective analyzes data automatically

### Detective vs. GuardDuty

| **Service** | **Purpose** | **Timing** |
|-------------|------------|-----------|
| **GuardDuty** | Detect threats and anomalies | Proactive / real-time |
| **Amazon Detective** | Investigate and analyze threats | Reactive / post-detection |

> 💡 **Exam Tip:** "A GuardDuty finding was triggered — now investigate the root cause and scope of the incident" → **Amazon Detective**.
<br>Detective answers "what happened?" — GuardDuty answers "something suspicious happened."

---

# Secrets & Credentials
---

## Secrets Manager and Parameter Store (Cross-Reference)

> 📚 **Learn More:** AWS Secrets Manager and SSM Parameter Store are fully covered in Module 12 — Deployment & Management, including automatic rotation, the SecureString type, and the full Secrets Manager vs. Parameter Store comparison table.
>
> - **Module 12 — Deployment & Management** — Secrets Manager, Parameter Store, rotation, cost comparison

**Quick exam-recall distinction for this module's security context:**

| **Need** | **Service** |
|----------|------------|
| Store and automatically rotate RDS/Aurora/Redshift database passwords | **Secrets Manager** |
| Store configuration values (API endpoints, feature flags) with optional encryption | **SSM Parameter Store** |
| Cryptographic key management | **KMS** (not Secrets Manager) |
| Application credentials without managing rotation code | **Secrets Manager** |

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|-------------|
| Enterprise users log in to AWS Console using their Active Directory credentials | SAML 2.0 federation with STS `AssumeRoleWithSAML` — or — IAM Identity Center with AD as identity source |
| Centralized SSO for all accounts in an AWS Organization | IAM Identity Center with permission sets |
| Mobile app user sign-up and sign-in | Amazon Cognito User Pool |
| Mobile app users need to read/write to DynamoDB directly | Cognito User Pool (authentication) + Identity Pool (AWS credentials) |
| Secure REST API so only authenticated Cognito users can call it | API Gateway authorizer backed by Cognito User Pool |
| Managed AD in AWS for more than 5,000 users with on-prem trust | AWS Managed Microsoft AD with trust relationship |
| Use on-premises AD identities with AWS services (no migration) | AD Connector (requires VPN/Direct Connect) |
| Encrypt EBS volumes and S3 objects with customer-controlled keys | KMS Customer Managed Key |
| FIPS 140-2 Level 3 compliance for key storage | AWS CloudHSM |
| KMS API integration with customer-controlled HSMs | KMS custom key store backed by CloudHSM |
| Encrypt 500 MB S3 object | Envelope encryption: `GenerateDataKey` → encrypt locally → store encrypted DEK with object |
| Cross-account encrypted EBS snapshot sharing | CMK key policy grants target account `kms:Decrypt` + `kms:CreateGrant` |
| TLS certificate for an ALB — auto-renewed | ACM public certificate |
| Issue private certificates for internal microservices | ACM Private CA |
| Protect a web application from SQL injection and XSS | AWS WAF on ALB or CloudFront |
| Block traffic from specific countries at the edge | WAF geographic match rule on CloudFront |
| Rate-limit an API to prevent abuse | WAF rate-based rule |
| DDoS protection at no cost | Shield Standard (automatic) |
| DDoS protection with DRT access + billing protection | Shield Advanced |
| Enforce WAF policies across all accounts in an Organization | AWS Firewall Manager |
| Continuously detect compromised EC2 instances or leaked credentials | Amazon GuardDuty |
| Auto-isolate a compromised EC2 instance when GuardDuty fires | GuardDuty finding → EventBridge rule → Lambda (modify SG) |
| Scan EC2 instances for known OS vulnerabilities | Amazon Inspector (EC2 + SSM Agent) |
| Scan ECR container images for vulnerabilities on push | Amazon Inspector + ECR integration |
| Discover PII stored in S3 buckets | Amazon Macie |
| Single pane of glass for findings from GuardDuty + Inspector + Macie | AWS Security Hub |
| Investigate the root cause of a GuardDuty finding | Amazon Detective |

> 🛠️ **Implementation Notes:**
> <br>**Enabling GuardDuty:** Enable per region; in Organizations, use the delegated administrator account and enable auto-enrollment for member accounts
> <br>**KMS Key Policy minimum:** A key policy must include at least a statement granting the **root user of the account** full access — otherwise the key becomes unmanageable
> <br>**ACM certificate validation:** DNS validation is preferred over email validation — DNS validation auto-renews even if no one responds to an email
> <br>**Cognito + API Gateway:** In the API Gateway console, set the Authorizer type to "Cognito" and provide the User Pool ARN; the JWT is validated automatically
> <br>**Security Hub + Organizations:** Designate a delegated administrator account for Security Hub; enable auto-enrollment; all findings aggregate to the admin account's Security Hub console
> <br>**CloudHSM cluster deployment:** Deploy at least two HSMs in different AZs for high availability; CloudHSM does not provide HA automatically — you must provision multiple HSMs

---

# Module Summary
---

## Key Topics
  - **Identity Federation** — SAML 2.0 (`AssumeRoleWithSAML`), Web Identity / OIDC (`AssumeRoleWithWebIdentity`), AWS STS temporary credentials
  - **AWS STS** — temporary credentials; key APIs: `AssumeRole`, `AssumeRoleWithSAML`, `AssumeRoleWithWebIdentity`, `GetSessionToken`
  - **IAM Identity Center** — centralized multi-account SSO (formerly AWS SSO); permission sets; identity sources (built-in, AD, SAML IdP)
  - **Amazon Cognito** — User Pools (authentication → JWT) vs. Identity Pools (authorization → temporary AWS credentials); combined pattern for mobile apps
  - **AWS Directory Service** — Managed Microsoft AD (> 5,000 users, trust relationships) vs. AD Connector (proxy to on-prem AD, no migration) vs. Simple AD (< 5,000 users, lightweight)
  - **Encryption fundamentals** — at rest vs. in transit; symmetric vs. asymmetric; envelope encryption pattern
  - **AWS KMS** — key types (AWS Owned / AWS Managed / Customer Managed); 4 KB direct limit; envelope encryption (`GenerateDataKey`); key policies + IAM + grants; rotation rules; key deletion waiting period (7–30 days); regional scope; keys never exported
  - **CloudHSM** — dedicated single-tenant HSM; FIPS 140-2 Level 3; customer-only key access; custom key store for KMS
  - **KMS vs. CloudHSM** — tenancy, FIPS level, AWS visibility, export capability, integration breadth
  - **ACM** — free public TLS certs; auto-renewal; no private key export; integrates with ALB/CloudFront/API GW; ACM Private CA for internal certs
  - **AWS WAF** — Layer 7; Web ACLs; rule types (IP, geo, string, SQLi, XSS, rate-based); managed rule groups; integrates with CloudFront/ALB/API GW
  - **AWS Shield** — Standard (free, L3/L4, automatic) vs. Advanced (paid, L3/L4/L7, DRT, cost protection)
  - **AWS Firewall Manager** — centralized WAF + Shield + SG management across Organizations
  - **Amazon GuardDuty** — ML-based threat detection; CloudTrail + VPC Flow Logs + DNS logs; no agents; findings → EventBridge → remediation
  - **Amazon Inspector** — vulnerability scanning; EC2 (SSM Agent required) + ECR + Lambda; CVE-based; continuous
  - **Amazon Macie** — PII/sensitive data discovery in S3; ML-based; S3 bucket security posture
  - **AWS Security Hub** — centralized findings aggregation; CSPM; CIS/PCI DSS/FSBP compliance checks; ASFF normalized findings
  - **Amazon Detective** — post-incident investigation; behavior graph; correlates CloudTrail + VPC Flow Logs + GuardDuty findings

---

## Critical Acronyms
  - **IAM** — Identity and Access Management
  - **STS** — Security Token Service
  - **SAML** — Security Assertion Markup Language
  - **OIDC** — OpenID Connect
  - **JWT** — JSON Web Token
  - **SSO** — Single Sign-On
  - **IdP** — Identity Provider
  - **ADFS** — Active Directory Federation Services
  - **AD** — Active Directory
  - **LDAP** — Lightweight Directory Access Protocol
  - **MFA** — Multi-Factor Authentication
  - **RADIUS** — Remote Authentication Dial-In User Service
  - **KMS** — Key Management Service
  - **CMK** — Customer Managed Key (also used as shorthand for any KMS key; formal term is now "KMS key") Δ
  - **DEK** — Data Encryption Key
  - **HSM** — Hardware Security Module
  - **FIPS** — Federal Information Processing Standard
  - **ACM** — AWS Certificate Manager
  - **CA** — Certificate Authority
  - **TDE** — Transparent Data Encryption
  - **TLS** — Transport Layer Security
  - **SSL** — Secure Sockets Layer (legacy term; TLS is the current protocol)
  - **WAF** — Web Application Firewall
  - **DDoS** — Distributed Denial of Service
  - **DRT** — DDoS Response Team (Shield Advanced)
  - **CSPM** — Cloud Security Posture Management
  - **ASFF** — AWS Security Finding Format
  - **CVE** — Common Vulnerabilities and Exposures
  - **PII** — Personally Identifiable Information
  - **PHI** — Protected Health Information
  - **XSS** — Cross-Site Scripting
  - **SQLi** — SQL Injection
  - **VPC** — Virtual Private Cloud
  - **EC2** — Elastic Compute Cloud
  - **ECR** — Elastic Container Registry
  - **EKS** — Elastic Kubernetes Service
  - **ALB** — Application Load Balancer
  - **API GW** — API Gateway (informal)
  - **SNS** — Simple Notification Service
  - **SQS** — Simple Queue Service
  - **EBS** — Elastic Block Store
  - **RDS** — Relational Database Service
  - **SSM** — AWS Systems Manager

---

## Key Comparisons
  - Cognito User Pools vs. Identity Pools (table)
  - Directory Service options: Managed Microsoft AD vs. AD Connector vs. Simple AD (table)
  - KMS Key Types: AWS Owned vs. AWS Managed vs. Customer Managed (table)
  - KMS vs. CloudHSM (table)
  - Shield Standard vs. Shield Advanced (table)
  - WAF vs. Shield vs. Firewall Manager (table)
  - Threat Detection Services Overview: GuardDuty vs. Inspector vs. Macie vs. Security Hub vs. Detective (table)
  - GuardDuty vs. Detective — detect vs. investigate (table)
  - Identity Federation types — SAML / Web Identity / Cognito / Identity Center (table)

---

## Top Exam Triggers
  - `Corporate users authenticate to AWS Console with AD credentials` → **SAML 2.0 federation + STS AssumeRoleWithSAML**
  - `Centralized SSO across all AWS accounts in an Organization` → **IAM Identity Center**
  - `Mobile/web app user sign-up and sign-in` → **Cognito User Pool**
  - `App users need temporary AWS credentials to call AWS services directly` → **Cognito Identity Pool**
  - `User Pool returns JWTs; Identity Pool returns AWS credentials` → core distinction
  - `More than 5,000 users, AD trust relationships needed in AWS` → **AWS Managed Microsoft AD**
  - `Use existing on-prem AD with AWS services — no user migration` → **AD Connector**
  - `Low-cost, fewer than 5,000 users, basic LDAP` → **Simple AD**
  - `Encrypt data at rest with AWS services` → **KMS**
  - `Customer needs full control over key policies and rotation` → **Customer Managed Key (CMK)**
  - `KMS key can only encrypt data up to` → **4 KB directly**
  - `Encrypt large data with KMS` → **Envelope encryption — GenerateDataKey**
  - `Cross-account encrypted snapshot sharing` → **CMK key policy grants target account kms:Decrypt + kms:CreateGrant**
  - `FIPS 140-2 Level 3 or AWS must not see keys` → **AWS CloudHSM**
  - `KMS APIs but keys stay in customer HSMs` → **KMS custom key store backed by CloudHSM**
  - `Cryptographic erasure` → **Delete imported key material (DeleteImportedKeyMaterial)**
  - `KMS key deletion waiting period` → **7–30 days (default 30)**
  - `Auto-renewing TLS certificate for ALB or CloudFront` → **ACM**
  - `Private certificates for internal microservices` → **ACM Private CA**
  - `Block SQL injection / XSS at Layer 7` → **AWS WAF**
  - `Block traffic from a country` → **WAF geographic match rule**
  - `Rate-limit an API endpoint` → **WAF rate-based rule**
  - `Enforce WAF/Shield policies across all Organization accounts` → **AWS Firewall Manager**
  - `Free automatic DDoS protection` → **Shield Standard**
  - `Advanced DDoS + 24×7 DRT + billing protection` → **Shield Advanced**
  - `Continuous threat detection without installing agents` → **Amazon GuardDuty**
  - `EC2 communicating with a known C2 server` → **GuardDuty finding**
  - `Automatically remediate a GuardDuty finding` → **EventBridge rule → Lambda**
  - `Scan EC2 for CVE vulnerabilities` → **Amazon Inspector** (requires SSM Agent)
  - `Scan ECR images for vulnerabilities` → **Inspector + ECR**
  - `Find PII or sensitive data in S3` → **Amazon Macie**
  - `Aggregated security findings dashboard across GuardDuty + Inspector + Macie` → **AWS Security Hub**
  - `Investigate root cause of a GuardDuty finding` → **Amazon Detective**

---

## Quick References

### [Security Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619570#overview)

### [Security Architecture Patterns Private Link](https://drive.google.com/drive/folders/15_WRzEWn19gjCcpPT9leoxQ3h3nciT7P?usp=drive_link)

### [Security Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346120#overview)

### [AWS IAM Cheat Sheet](https://digitalcloud.training/aws-iam/)

### [Amazon Cognito Cheat Sheet](https://digitalcloud.training/amazon-cognito/)

### [AWS Directory Services Cheat Sheet](https://digitalcloud.training/aws-directory-services/)

### [AWS KMS Cheat Sheet](https://digitalcloud.training/aws-kms/)

### [AWS CloudHSM Cheat Sheet](https://digitalcloud.training/aws-cloudhsm/)

### [AWS WAF & Shield Cheat Sheet](https://digitalcloud.training/aws-waf-shield/)

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
