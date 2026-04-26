# AWS Certified Solutions Architect – Associate (SAA-C03) Study Repository

Personal study repository for the **AWS Certified Solutions Architect – Associate** certification (SAA-C03, current as of 2026 exam objectives). Contains structured notes, code examples, and review materials organized for both active study and long-term reference.

---

## Purpose

This repository is intended to:

- Reinforce understanding of AWS services through structured written notes and applied examples
- Serve as a personal, reusable reference for the SAA-C03 exam and future projects
- Track progress and provide a documented study record
- Provide a foundation for continued study toward the **AWS Solutions Architect – Professional** certification

---

## Repository Structure

```
.
├── assets/               # Diagrams, visual aids, and reference images
├── modules/              # Core study content organized by topic
│   ├── 01-IAM/
│   │   ├── code/         # Shell scripts, CLI examples, user-data scripts (where applicable)
│   │   └── *.notes.md    # Structured topic notes
│   ├── 02-EC2/
│   ├── 03-ASG-ELB/
│   ├── 04-ORG-CT/
│   ├── 05-VPC/
│   ├── 06-S3/
│   ├── 07-DNS-PO/
│   ├── 08-EBS-EFS/
│   ├── 09-ECS-EKS-E.../
│   ├── 10-Serverless/
│   ├── 11-DBs-Analy.../
│   ├── 12-Deploy-M.../
│   ├── 13-Monitor-L.../
│   ├── 14-Security/
│   ├── 15-Migrate-Tr.../
│   └── 16-Web-Mob.../
├── notes/                # Standalone notes for quick access and cross-topic review
├── review/               # Exam review notes and quick-reference glossary
└── README.md
```

---

## Directory Descriptions

### `modules/`

The primary study content. Each subdirectory corresponds to a core AWS domain and contains:

- **`*.notes.md`** — Structured topic notes covering key concepts, service comparisons, exam-relevant details, and links to official AWS documentation. Where noted, content may also include implementation depth relevant to the **AWS Certified Solutions Architect – Professional (SAP-C02)** exam.
- **`code/`** — Scripts, CLI command examples, CloudFormation snippets, and lab-based configurations used to reinforce practical understanding.

| Module | Topics |
|--------|--------|
| 01-IAM | Identity & Access Management, policies, roles, federation |
| 02-EC2 | Compute, instance types, pricing models, storage-backed instances |
| 03-ASG-ELB | Auto Scaling Groups, Elastic Load Balancing, target tracking |
| 04-ORG-CT | AWS Organizations, Control Tower, SCPs, Landing Zone |
| 05-VPC | Networking, subnets, routing, security groups, NACLs, peering |
| 06-S3 | Object storage, storage classes, lifecycle, replication, security |
| 07-DNS-PO | Route 53, DNS routing policies, health checks |
| 08-EBS-EFS | Block and file storage, performance tiers, mount targets |
| 09-ECS-EKS | Containers, Fargate, Kubernetes on AWS, ECR |
| 10-Serverless | Lambda, API Gateway, Step Functions, EventBridge |
| 11-DBs-Analytics | RDS, Aurora, DynamoDB, Redshift, Athena, Glue, Kinesis |
| 12-Deploy-Mgmt | CloudFormation, Elastic Beanstalk, CodeDeploy, Systems Manager |
| 13-Monitor-Log | CloudWatch, CloudTrail, Config, X-Ray |
| 14-Security | KMS, Secrets Manager, WAF, Shield, GuardDuty, Inspector |
| 15-Migrate-Transfer | DMS, Snow Family, DataSync, Migration Hub |
| 16-Web-Mobile | CloudFront, Global Accelerator, AppSync |

---

### `notes/`

Flat collection of notes files mirroring the module content for convenient browsing and cross-topic review without navigating individual module directories.

---

### `review/`

Materials created during final exam review, including:

- Condensed review notes organized by domain
  - - Condensed review notes focused on weak points and high-priority topics identified during exam preparation
- A **quick-reference glossary** consolidating key terms, service comparisons, and links for each topic

---

### `assets/`

Diagrams, architecture visuals, and reference images used throughout the notes.

> **Note:** Screenshots sourced from third-party training materials have been removed from this repository for copyright compliance. Original materials are stored privately, deleted, and/or are not publicly distributed.

---

## Disclaimers & Legal Notices

### Educational Use
All content in this repository is created for **personal educational purposes only**. Nothing here constitutes official AWS documentation, professional advice, or production-ready configurations.

### Code & Scripts
Code snippets and scripts are provided **as-is for educational and reference purposes**. They may require modification before use in any real environment. Some examples are environment-specific (e.g., EC2 user data, IAM policy stubs) and should be reviewed carefully before any production or account-level use. The author assumes no liability for misuse.

### Third-Party Training Materials
Portions of these notes were developed while studying content from providers including **Neal Davis / Digital Cloud Training** and official **AWS training resources**. These notes represent personal learning summaries and interpretations — they are not reproductions of proprietary course content. Please support original creators by accessing their materials through official channels.

### AWS Documentation
AWS services, features, and pricing change frequently. Always refer to the [official AWS documentation](https://docs.aws.amazon.com/) as the authoritative source of truth. External links included in notes may become outdated.

### No Affiliation
This repository has no affiliation with Amazon Web Services, Inc., or any third-party training provider. All trademarks and service names are the property of their respective owners.

### Exam Integrity
This repository contains no braindump content, leaked exam questions, or materials that violate the [AWS Certification Program Agreement](https://aws.amazon.com/certification/policies/). All content is derived from publicly available documentation, personal study, and authorized training resources.

---

*Last updated: 2026 — aligned with SAA-C03 current exam objectives.*
