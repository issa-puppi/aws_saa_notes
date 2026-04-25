# Security in the Cloud
---

## AWS Directory Service
  - Managed directory services for integrating Microsoft Active Directory with 
  - Active Directory is an LDAP **Identity Store** for user authentication and authorization

### Directory Service Options
  - **AWS Managed Microsoft AD**
    - Fully managed Microsoft Active Directory running on Windows Server
    - Best choice when:
      - More than 5,000 users
      - Need trust relationships
      - Need schema extensions
      - Need standalone AD in AWS
    - Can perform schema extensions
    - Supports trust relationships with on-premises AD

  - **AD Connector**
    - Redirects directory requests to an existing on-premises AD
    - Best choice when:
      - You want to use existing AD identities with AWS services
      - You do not need AWS to host the directory
    - Two sizes:
      - **Small**: Up to 5,000 users
      - **Large**: Up to 500,000 users
    - Requires:
      - VPN or Direct Connect

  - **Simple AD**
    - Low-cost, standalone AD-compatible directory
    - Best choice when:
      - Fewer than 5,000 users
      - No advanced AD features needed

### Use Cases
  - Join EC2 instances to a domain
  - Use AD credentials with AWS applications
  - Enable SSO to AWS applications
  - Apply group policies
  - Enable MFA with RADIUS

### Exam Triggers
  - `Need managed Microsoft AD in AWS` → AWS Managed Microsoft AD
  - `Use existing on-prem AD without migrating it` → AD Connector
  - `Low-cost simple directory` → Simple AD

---

## Identity Providers and Federation
  - Federation allows external identities to access AWS using temporary credentials

### SAML 2.0 Federation
  - Used for enterprise federation with **identity providers (IdPs)**
  - Common with:
    - **Active Directory Federation Services (ADFS)**
    - SAML-compatible identity providers
      - **SAML** = Security Assertion Markup Language

  - Flow:
    - User authenticates with IdP
    - IdP sends SAML assertion
    - AWS STS returns temporary credentials

### Web Identity Federation
  - Used with social or OIDC-compatible (**OpenID Connect**) identity providers
  - AWS recommends using **Amazon Cognito** for most web identity federation use cases

### IAM Identity Center
  - Successor to **AWS Single Sign-On (SSO)**
  - Provides centralized access management across AWS accounts and applications
  - Identity sources can include:
    - Identity Center directory
    - Active Directory
    - SAML 2.0 providers

### Exam Triggers
  - `Enterprise SSO with SAML` → SAML federation / IAM Identity Center
  - `Temporary credentials from external IdP` → AWS STS
  - `Centralized multi-account SSO` → IAM Identity Center

---

## Amazon Cognito
  - Authentication and authorization service for web and mobile applications

### Cognito User Pools
  - User directory for application sign-up and sign-in
  - Returns JWT tokens after authentication
  - Supports:
    - Native users
    - Social identity providers
    - SAML / OIDC identity providers

### Cognito Identity Pools
  - Provides temporary AWS credentials for users
  - Uses AWS STS to assume IAM roles
  - Allows authenticated users to access AWS services

### User Pools vs Identity Pools
  - **User Pool**
    - Who are you?
    - Authentication
    - Returns JWT tokens

  - **Identity Pool**
    - What AWS resources can you access?
    - Authorization
    - Returns temporary AWS credentials

### Exam Triggers
  - `User sign-up/sign-in for app` → Cognito User Pool
  - `App users need access to AWS services` → Cognito Identity Pool
  - `Mobile app with social login and AWS access` → User Pool + Identity Pool

---

## Encryption Concepts
  - Encryption protects data either in transit or at rest

### Encryption In Transit
  - Protects data while moving across a network
  - Uses SSL/TLS
  - Examples:
    - HTTPS
    - TLS connections to load balancers or APIs

### Encryption At Rest
  - Protects stored data
  - Examples:
    - S3 object encryption
    - EBS encryption
    - RDS encryption

### Symmetric Encryption
  - Same key is used for encryption and decryption
  - Common for bulk data encryption

### Asymmetric Encryption
  - Uses public/private key pair
  - Common for:
    - SSL/TLS
    - SSH

---

## AWS Key Management Service (KMS)
  - Managed service for creating and managing encryption keys
  - Supports symmetric and asymmetric KMS keys
  - KMS keys are protected by hardware security modules

### Key Types
  - **AWS Owned Keys**
    - Managed entirely by AWS
    - Not visible in customer account

  - **AWS Managed Keys**
    - Managed by AWS for specific services
    - Visible in customer account
    - Usually named like `aws/ebs`, `aws/s3`, etc.

  - **Customer Managed Keys**
    - Created and controlled by the customer
    - More control over:
      - Key policies
      - Rotation
      - Deletion
      - Access

### Key Rotation
  - AWS managed keys rotate automatically
  - Customer managed keys can support automatic rotation
  - Imported key material requires manual management

### Exam Notes
  - KMS is usually the default answer for AWS-native encryption key management
  - Cryptographic erasure can be achieved by deleting imported key material
  - `InvalidKeyId` with encrypted data can indicate the KMS key is disabled or unavailable

### Exam Triggers
  - `Encrypt AWS service data at rest` → KMS
  - `Need customer control over key policies` → Customer managed KMS key
  - `Delete ability to decrypt imported key material` → Delete imported key material

---

## AWS Keys Comparison

| **Key Type** | **Can View** | **Can Manage** | **Used Only for AWS Account** | **Rotation** |
|--------------|--------------|----------------|-------------------------------|--------------|
| **Customer Managed Key** | Yes | Yes | Yes | Optional. Every year recommended | 
| **AWS Managed Key** | Yes | No | Yes | Required. Every 3 years |
| **AWS Owned Key** | No | No | No | Varies by service |

---

## AWS CloudHSM
  - Cloud-based hardware security module
  - Used to generate and manage encryption keys in dedicated HSMs

### Features
  - Runs in your VPC
  - Uses FIPS 140-2 Level 3 validated HSMs
  - Single-tenant HSM
  - Customer controls access to keys
  - AWS has no visibility into encryption keys

### Use Cases
  - Offload SSL/TLS processing
  - Protect private keys for certificate authorities
  - Store Oracle TDE master keys
  - Use as a custom key store for KMS

### CloudHSM vs KMS
  - **CloudHSM**
    - Single-tenant
    - Customer-managed root of trust
    - More control
    - More operational responsibility

  - **KMS**
    - Multi-tenant managed AWS service
    - AWS-managed root of trust
    - Broad AWS service integration
    - Easier to operate

### Exam Triggers
  - `Dedicated hardware key storage` → CloudHSM
  - `AWS should not have access to keys` → CloudHSM
  - `Easy AWS service encryption integration` → KMS

---

## AWS Certificate Manager (ACM)
  - Service for creating, storing, importing, and renewing SSL/TLS certificates

### Features
  - Supports:
    - Single-domain certificates
    - Multiple-domain certificates
    - Wildcard certificates

  - Can provide:
    - Public certificates
    - Private certificates using ACM Private CA
    - Imported third-party certificates

### Integrations
  - Elastic Load Balancing
  - Amazon CloudFront
  - Elastic Beanstalk
  - Nitro Enclaves
  - CloudFormation

### Exam Triggers
  - `Need SSL/TLS certificate for ALB or CloudFront` → ACM
  - `Private internal certificates` → ACM Private CA
  - `Use existing third-party certificate` → Import into ACM

---

## AWS WAF
  - Web application firewall for filtering HTTP/HTTPS traffic

### Features
  - Create rules based on:
    - IP addresses
    - HTTP headers
    - Request body
    - Custom URIs
    - Regex patterns
    - Geographic origin

  - Blocks common web exploits:
    - SQL injection
    - Cross-site scripting (XSS)

### Rule Actions
  - **Count**: Count matching requests without allowing or blocking

  - **Allow**: Forward request to protected resource

  - **Block**: Block request and return HTTP 403

### Match Statements
  - Geographic match
  - IP set match
  - Regex pattern set
  - Size constraint
  - SQL injection
  - String match
  - XSS scripting attack

### Integrations
  - CloudFront
  - Application Load Balancer
  - API Gateway
  - AppSync

### Exam Triggers
  - `Block SQL injection / XSS` → WAF
  - `Filter web traffic by IP/header/URI` → WAF
  - `Protect CloudFront or ALB at Layer 7` → WAF

---

## AWS Shield
  - Managed Distributed Denial of Service (DDoS) protection service

### Tiers
  - **Shield Standard**
    - No additional cost
    - Always-on protection
    - Included automatically with CloudFront and Route 53 style edge protections

  - **Shield Advanced**
    - Paid service
    - Higher level of DDoS protection
    - Used for mission-critical applications

### Exam Triggers
  - `DDoS protection` → Shield
  - `Basic DDoS protection` → Shield Standard
  - `Advanced DDoS protection for critical workloads` → Shield Advanced

---

## Amazon Macie
  - Data security and privacy service for Amazon S3
  - Uses machine learning and pattern matching to discover sensitive data

### Detects
  - PII
  - PHI
  - Regulatory documents
  - API keys
  - Secret keys

### Features
  - Automatically discovers S3 buckets
  - Analyzes S3 data for sensitive information
  - Monitors S3 security posture
  - Generates findings

### Integrations
  - Security Hub
  - EventBridge

### Exam Triggers
  - `Find PII in S3` → Macie
  - `Discover sensitive data in S3 buckets` → Macie

---

## Amazon Inspector
  - Security assessment service for finding vulnerabilities and exposures

### Features
  - Runs security assessments
  - Can be scheduled
  - Checks EC2 instances for vulnerabilities and exposures

### Assessment Types
  - **Host assessments**
    - Require agent installed on EC2

  - **Network assessments**
    - Do not require an agent

### Exam Triggers
  - `Find vulnerabilities on EC2` → Inspector
  - `Scheduled security assessment` → Inspector
  - `Network assessment without agent` → Inspector

---

# Module Summary
---

## Key Comparisons

| **Need** | **Service** |
|---------|-------------|
| Managed Microsoft AD in AWS | AWS Managed Microsoft AD |
| Use existing on-prem AD | AD Connector |
| Simple low-cost directory | Simple AD |
| App user sign-up/sign-in | Cognito User Pool |
| Temporary AWS credentials for app users | Cognito Identity Pool |
| Enterprise SSO across AWS accounts | IAM Identity Center |
| AWS-native encryption key management | KMS |
| Dedicated HSM / customer-controlled keys | CloudHSM |
| SSL/TLS certificates | ACM |
| Web exploit protection | WAF |
| DDoS protection | Shield |
| Sensitive data discovery in S3 | Macie |
| Vulnerability assessment | Inspector |

---

## Common Exam Scenarios

- `More than 5,000 users or trust relationships` → AWS Managed Microsoft AD
- `Use existing on-prem AD with AWS` → AD Connector
- `Low-cost standalone directory` → Simple AD
- `Mobile app user authentication` → Cognito User Pool
- `Mobile app users need AWS credentials` → Cognito Identity Pool
- `Centralized SSO across AWS accounts` → IAM Identity Center
- `Encrypt AWS resources at rest` → KMS
- `Dedicated hardware security module` → CloudHSM
- `TLS certificate for ALB / CloudFront` → ACM
- `Block SQL injection or XSS` → WAF
- `Protect from DDoS` → Shield
- `Find sensitive data in S3` → Macie
- `Assess EC2 vulnerabilities` → Inspector

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