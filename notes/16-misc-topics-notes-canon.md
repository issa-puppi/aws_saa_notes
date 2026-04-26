# Web & Mobile App Building
---

## AWS Amplify

AWS Amplify is a **complete development platform** for building and hosting full-stack web and mobile applications on AWS.
<br>It abstracts the backend infrastructure so frontend developers can build production-grade applications without deep AWS expertise.

### Key Components

| **Component** | **What It Does** |
|--------------|-----------------|
| **Amplify Studio** | Visual interface to define a data model, user authentication, and file storage — without writing backend code |
| **Amplify Libraries** | Client-side libraries for iOS, Android, Flutter, React Native, and web (JavaScript) — connect frontend apps to backend services |
| **Amplify Hosting** | Fully managed CI/CD and hosting for static and server-side rendered (SSR) apps; connects to Git repositories for auto-deploy on push |
| **Amplify CLI** | Command-line toolchain for configuring and provisioning backend AWS resources from local development |

### Integrated AWS Services

Amplify provisions and configures AWS services behind the scenes — developers interact with Amplify abstractions rather than individual services:
- **Authentication** — Amazon Cognito User Pools
- **Data / API** — AppSync (GraphQL) or API Gateway (REST) + DynamoDB
- **Storage** — Amazon S3
- **Functions** — AWS Lambda
- **Hosting** — Amazon CloudFront + S3

> 💡 **Exam Tips:**
> <br>"Build and host a full-stack web or mobile application quickly on AWS" → **AWS Amplify**
> <br>"Add authentication, a data API, and file storage to a mobile app without managing infrastructure" → **AWS Amplify**
> <br>"CI/CD pipeline + hosting for a React or Next.js application" → **Amplify Hosting**

---

## AWS AppSync

AWS AppSync is a **fully managed service for building GraphQL APIs** that allow client applications to fetch exactly the data they need — no more, no less — from multiple backend data sources in a single request.
<br>It supports real-time data via GraphQL Subscriptions and offline capabilities for mobile apps.

### Key Properties

- Uses **GraphQL** — a query language where the client defines the shape and fields of the response
- Supports **real-time updates** via GraphQL Subscriptions — clients receive data pushes when upstream data changes
- Connects to multiple data sources simultaneously: **DynamoDB, Lambda, RDS, HTTP endpoints, OpenSearch**
- **Server-side caching** reduces calls to data sources and improves performance ¤
- **Offline support** — built-in client-side caching for mobile apps that need to work without connectivity
- Auto-scales the GraphQL execution engine to match request volume

> 💡 **Exam Tips:**
> <br>"Build a GraphQL API that aggregates data from multiple AWS services" → **AWS AppSync**
> <br>"Real-time data synchronization between a mobile app and a backend" → **AppSync with GraphQL Subscriptions**
> <br>"REST API" → **API Gateway** (Module 10); "GraphQL API" → **AppSync**

> ⚠️ **Exam Trap:** AppSync and Cognito Sync are different services.
<br>**AppSync** syncs application data across users and devices (GraphQL-based, multi-user).
<br>**Cognito Sync** (legacy) syncs user profile data across a single user's devices only.

---

## AWS Device Farm ※

AWS Device Farm is an **app testing service** that lets you test web and mobile applications on real physical devices hosted in the AWS cloud — without provisioning or managing your own test infrastructure.

- Supports **automated testing** using frameworks like Appium, Espresso, XCTest, and custom scripts
- Supports **manual remote access** to real devices for exploratory testing
- Tests against a fleet of real Android and iOS devices and desktop browsers

> 💡 **Exam Tip:** "Test a mobile app on real physical devices without managing test infrastructure" → **AWS Device Farm**

---

# AI & Machine Learning Services
---

## AI/ML Services Overview

The SAA exam tests AI/ML services at an **awareness level** — know what each service does, when to use it, and how it fits into event-driven architectures.
<br>You are not expected to know the underlying ML algorithms or training processes.

| **Service** | **Category** | **What It Does** | **Key Input/Output** |
|------------|-------------|-----------------|---------------------|
| **Amazon SageMaker** | ML Platform | End-to-end ML lifecycle: build, train, tune, deploy custom models | Any data → trained ML model deployed as endpoint |
| **Amazon Rekognition** | Computer Vision | Analyze images and videos — objects, scenes, faces, text, activities | Image/video → labels, face analysis, content moderation |
| **Amazon Transcribe** | Speech → Text | Convert speech audio to text using ASR | Audio file / stream → transcript text |
| **Amazon Translate** | Language | Neural machine translation between languages | Text → translated text |
| **Amazon Comprehend** | NLP | Extract meaning from text — sentiment, entities, topics, language | Text → sentiment, key phrases, entity types |
| **Amazon Lex** | Conversational AI | Build voice and text chatbots (powers Amazon Alexa) | Voice/text → intent classification + response |
| **Amazon Polly** | Text → Speech | Convert text to lifelike speech | Text → audio stream |
| **Amazon Kendra** ※ | Enterprise Search | ML-powered intelligent search across enterprise documents | Query → relevant document passages |
| **Amazon Personalize** ※ | Recommendations | Real-time personalized recommendations (like Amazon.com) | User behavior data → recommendations |
| **Amazon Forecast** ※ | Time Series | Time series forecasting using historical data | Time series data → demand/usage forecasts |
| **Amazon DevOps Guru** ※ | ML Operations | Detect and alert on operational anomalies before they become outages | CloudWatch metrics + logs → ML-powered insights |
| **Amazon CodeGuru** ※ | ML Dev Tools | Code security vulnerability detection + performance profiling | Source code / runtime → security findings, profiling recommendations |

---

## Amazon SageMaker

Amazon SageMaker is AWS's **end-to-end machine learning platform** that covers the full lifecycle from data preparation through model training, optimization, and deployment.
<br>It provides managed infrastructure so data scientists and ML engineers can focus on the model, not the servers.

### Key Capabilities

- **SageMaker Studio** — web-based IDE for the full ML workflow
- **Built-in algorithms** — dozens of pre-built ML algorithms optimized for distributed training on AWS
- **Training jobs** — launch distributed training on managed compute clusters; scales automatically
- **Hyperparameter tuning** — automated search for optimal model parameters
- **Model deployment** — one-click deploy to a managed HTTPS endpoint; scales with traffic
- **SageMaker Pipelines** — ML CI/CD for automated model building and retraining workflows

> 💡 **Exam Tip:** "Build, train, and deploy a custom machine learning model" → **Amazon SageMaker**
<br>SageMaker is the answer when a question involves a *custom* ML model — as opposed to the pre-built AI services (Rekognition, Comprehend, etc.) which require no ML expertise.

---

## Amazon Rekognition

Amazon Rekognition adds **image and video analysis** capabilities to applications via a simple API — no ML expertise required.
<br>It processes images stored in S3 or streamed video, and publishes results to SNS topics or returns them directly.

### Key Capabilities

- Detect and label **objects, scenes, and activities** in images and videos
- **Facial analysis** — detect, compare, and search faces; estimate age range, emotions, attributes
- **Celebrity recognition** — identify well-known public figures
- **Text detection** — extract text from images (e.g., license plates, signs)
- **Content moderation** — detect inappropriate or unsafe content
- **Video analysis** — process videos stored in S3; publishes a completion notification to SNS

### Common Architecture Pattern

```
User uploads image → S3 → Lambda → Rekognition → results → DynamoDB / SNS
```

> 💡 **Exam Tip:** "Automatically tag uploaded images with content labels" or "detect faces in a photo" → **Amazon Rekognition**

---

## Speech & Language AI Services

These four services handle different aspects of human language — the exam tests which one to pick for a given scenario.

### Amazon Transcribe

Amazon Transcribe converts **spoken audio to text** using automatic speech recognition (ASR).
<br>It supports batch transcription of recorded audio files and streaming real-time transcription.

- Supports multiple languages and custom vocabularies
- Useful for: call center transcription, media subtitles, meeting transcripts

### Amazon Translate

Amazon Translate performs **neural machine translation** between languages — producing natural, accurate, context-aware translations.
<br>It localizes content such as websites, applications, and documents for international users.

### Amazon Comprehend

Amazon Comprehend is an **NLP service** that extracts meaning and insights from unstructured text.
<br>It identifies sentiment (positive/negative/neutral/mixed), key phrases, named entities (people, places, organizations), and dominant language.

- Also supports **custom entity recognition** and **custom classification** trained on your own data

### Amazon Polly

Amazon Polly converts **text to lifelike speech** using deep learning.
<br>It supports dozens of voices in many languages and includes SSML (Speech Synthesis Markup Language) for fine-grained speech control.

### Amazon Lex

Amazon Lex is the service powering **Amazon Alexa** — it provides conversational AI for building voice and text chatbots.
<br>Lex handles **intent recognition** (what does the user want?) and **slot filling** (extracting values from the utterance) with minimal training data.

- Integrates with **Lambda** for business logic
- Integrates with **Amazon Connect** for contact center automation

> 💡 **Exam Tips:**
> <br>"Convert speech audio to text for a call center transcription pipeline" → **Amazon Transcribe**
> <br>"Translate user-generated content into 50 languages" → **Amazon Translate**
> <br>"Detect customer sentiment in support tickets" → **Amazon Comprehend**
> <br>"Build an interactive voice response (IVR) chatbot" → **Amazon Lex**
> <br>"Convert article text to audio for a podcast feed" → **Amazon Polly**

---

## Document and Data Extraction

### Amazon Textract ※

Amazon Textract is a **machine learning service that automatically extracts text, handwriting, and structured data from scanned documents and forms** — going beyond simple OCR to understand document structure.

- Extracts data from **tables and forms** (key-value pairs) in addition to raw text
- Supports PDFs, JPEG, PNG input formats; returns structured JSON output
- Use cases: digitizing invoices, extracting data from tax forms, processing medical records
- Integrates with Lambda for event-driven document pipelines; output can be stored in S3 or DynamoDB

> 💡 **Exam Tip:** `"Extract structured data from scanned invoices or forms automatically"` → **Amazon Textract**.
> <br>Distinguish from Comprehend (text analysis/NLP) and Rekognition (image/video analysis) — Textract is specifically for **document extraction**.

---

## Fraud Detection

### Amazon Fraud Detector ※

Amazon Fraud Detector is a **fully managed ML service that identifies potentially fraudulent online activities** — such as online payment fraud, fake account creation, or suspicious login attempts.

- Uses **your own historical fraud data** to train a custom fraud detection model with no ML expertise required
- Provides a risk score and outcome (approve / review / reject) for each event
- Use cases: e-commerce fraud, account takeover detection, new account fraud
- Models can be updated as fraud patterns change

> 💡 **Exam Tip:** `"Detect fraudulent transactions or new account creation attempts using ML"` → **Amazon Fraud Detector**.

---

## ML-Powered Operations

### Amazon DevOps Guru ※

Amazon DevOps Guru is an **ML-powered operations service** that automatically detects operational issues — unusual latency, error spikes, resource exhaustion patterns — before they become outages.
<br>It ingests CloudWatch metrics, logs, and events, then uses ML to identify behaviors that deviate from normal operating patterns and recommends remediation actions.

### Amazon CodeGuru ※

Amazon CodeGuru is split into two capabilities:
- **CodeGuru Reviewer** — uses ML and automated reasoning to detect **code security vulnerabilities** and quality issues in pull requests; integrates with GitHub, GitLab, Bitbucket, and CodeCommit
- **CodeGuru Profiler** — identifies the most **expensive lines of code** at runtime by analyzing CPU and memory usage; recommends specific optimizations

> 💡 **Exam Tip:** "Automatically detect operational anomalies in a running application" → **Amazon DevOps Guru**
<br>"Detect security vulnerabilities in code during the CI/CD pipeline" → **Amazon CodeGuru Reviewer**

---

# Cost Management
---

## Cost Management Services Overview

AWS provides a layered set of tools for **understanding, controlling, and optimizing** cloud spend.
<br>The exam tests which tool answers a specific cost management question.

| **Tool** | **Purpose** | **Key Capability** |
|---------|------------|-------------------|
| **Cost Explorer** | Analyze historical and forecast future spend | 13-month history; 3-month forecast; filter by service/account/tag |
| **AWS Budgets** | Alert when costs, usage, or coverage exceeds thresholds | Email/SNS alerts; proactive notification before overspend |
| **Cost & Usage Report (CUR)** | Most granular billing data | Hourly/daily/monthly breakdown by resource; delivered to S3 |
| **Pricing Calculator** | Estimate costs before deploying | Build a cost model for a planned architecture |
| **Price List API** | Programmatic pricing queries | JSON (Query API) or HTML (Bulk API) |
| **Compute Optimizer** | Right-size resources using ML | EC2, EBS, Lambda, Auto Scaling recommendations |
| **Cost Allocation Tags** | Attribute costs to teams/projects | Tag resources → group costs in Cost Explorer + CUR |

---

## AWS Cost Explorer

AWS Cost Explorer is a **free tool** for visualizing, understanding, and analyzing AWS costs and usage over time. ¤
<br>It provides charts and breakdowns to help identify cost drivers and optimization opportunities.

### Key Properties

- View cost and usage data for the **past 13 months** †
- **Forecast** spending for the next **3 months** using ML-based models
- Filter and group by: service, linked account, region, AZ, tag, instance type, and more
- Identify which services, accounts, or resources are driving the most cost
- **Savings Plans** and **Reserved Instance** recommendations built in
- Free to use — no charge for accessing Cost Explorer ¤ §

> 💡 **Exam Tips:**
> <br>"Analyze AWS spending trends over the past year" → **AWS Cost Explorer**
> <br>"Forecast how much we'll spend over the next 3 months" → **Cost Explorer**
> <br>"Identify which AWS account in the Organization is driving the most cost" → **Cost Explorer with linked account filter**

---

## AWS Budgets

AWS Budgets lets you set **custom cost and usage thresholds** and receive proactive alerts when actual or forecasted spend approaches or exceeds those thresholds.
<br>Unlike Cost Explorer (which is retrospective analysis), Budgets is **forward-looking and alert-driven**.

### Budget Types

| **Budget Type** | **What It Monitors** |
|----------------|---------------------|
| **Cost budget** | Dollar amount spent |
| **Usage budget** | Units of a specific service (e.g., EC2 hours) |
| **Savings Plans budget** | Savings Plans utilization or coverage |
| **Reservation budget** | Reserved Instance utilization or coverage |

### Key Properties

- Alerts delivered via **email** or **SNS topic**
- Can trigger **automated actions** — e.g., attach an IAM policy to restrict provisioning when a threshold is hit ※
- Up to **2 free budgets per account** §; additional budgets charged per budget per day ¤

> 💡 **Exam Tips:**
> <br>"Alert the team when monthly spend exceeds $10,000" → **AWS Budgets**
> <br>"Alert when Reserved Instance coverage drops below 80%" → **AWS Budgets — reservation budget**

---

## AWS Cost & Usage Report (CUR)

The AWS Cost & Usage Report is the **most detailed and comprehensive** billing data AWS provides.
<br>It delivers raw billing records — broken down to the individual resource level — to an Amazon S3 bucket on a schedule you define.

### Key Properties

- Reports break costs down by: **hour, day, or month** — per product, resource, and tag
- Delivered to an **S3 bucket** you own; updated up to **3 times per day** §
- Can be loaded into **Amazon Athena**, **Amazon Redshift**, or **AWS QuickSight** for analysis
- The raw data source for third-party FinOps tools
- Use the **CUR API** to create, retrieve, and delete reports programmatically

> 💡 **Exam Tip:** "Granular per-resource billing data, broken down by tag and hour, for custom analysis" → **AWS Cost & Usage Report (CUR)**
<br>Cost Explorer is for visualization; CUR is for raw data + custom processing.

---

## AWS Pricing Calculator

AWS Pricing Calculator is a **free web tool** for estimating the cost of a new AWS architecture before you deploy it.
<br>You build a model of your planned resources and the calculator outputs a monthly and annual cost estimate.

- No account or login required — publicly available at `calculator.aws`
- Useful for: pre-project business cases, comparing architectures, vendor evaluations

> 💡 **Exam Tip:** "Estimate the cost of a new architecture before deploying anything" → **AWS Pricing Calculator**

---

## AWS Price List API

The AWS Price List API provides **programmatic access to AWS service pricing data** — useful for building cost tools, FinOps dashboards, or automating pricing comparisons.

- **Query API** (JSON) — query prices for specific services and configurations
- **Bulk API** (HTML) — download complete price lists
- **SNS notifications** — subscribe to receive alerts when AWS prices change

---

## AWS Cost Allocation Tags

Cost Allocation Tags allow you to **attribute AWS costs to specific dimensions** — teams, projects, environments, cost centers — by tagging resources and activating those tags for cost reporting.

### Types of Tags

| **Tag Type** | **Who Creates It** | **Use** |
|-------------|-------------------|--------|
| **AWS-generated tags** | AWS | Automatically applied (e.g., `aws:createdBy`) |
| **User-defined tags** | Customer | Custom keys/values you define (e.g., `Environment=prod`, `Team=platform`) |

### Key Properties

- Tags must be **activated** in the Billing console before they appear in Cost Explorer and CUR §
- Once activated, tagged costs are groupable in Cost Explorer and visible in CUR
- Enable **chargeback and showback** — allocate costs to the teams that own the resources

> 💡 **Exam Tip:** "Allocate AWS costs to different teams or business units for chargeback" → **Cost Allocation Tags**

---

## AWS Compute Optimizer

AWS Compute Optimizer uses **machine learning to analyze historical utilization metrics** and recommends optimal AWS resource configurations — reducing over-provisioning (wasted cost) and under-provisioning (performance risk) simultaneously.

### Supported Resources

| **Resource** | **What Compute Optimizer Analyzes** |
|-------------|-------------------------------------|
| **Amazon EC2 instances** | Instance type, size; identifies under/over-utilized instances |
| **Amazon EBS volumes** | Volume type and size; recommends gp3 over gp2 where appropriate |
| **AWS Lambda functions** | Memory configuration; identifies memory-bound vs. CPU-bound functions |
| **EC2 Auto Scaling groups** | Instance type recommendations for the ASG configuration |

- Requires at least **14 days of metric history** to generate recommendations †
- Results viewable in the console or via CLI/API
- Integrates with **AWS Organizations** — view recommendations across all accounts from a single place

> 💡 **Exam Tips:**
> <br>"Identify which EC2 instances are over-provisioned and recommend downsizing" → **AWS Compute Optimizer**
> <br>"ML-based right-sizing recommendations for EC2, EBS, and Lambda" → **Compute Optimizer**

---

# Operations & Governance
---

## AWS License Manager

AWS License Manager provides **centralized management and tracking of software licenses** across AWS and on-premises resources — preventing license violations and avoiding unexpected audit penalties.

- Manage licenses from vendors including **Microsoft, Oracle, SAP, and IBM**
- Track license usage by: vCPUs, sockets, cores, or number of machines
- Enforce license limits — prevent launching EC2 instances that would exceed your license entitlement
- Distribute, activate, and track licenses across **multiple accounts and regions** via AWS Organizations

> 💡 **Exam Tip:** "Track and enforce software license usage for Microsoft SQL Server across an Organization" → **AWS License Manager**

---

## AWS Well-Architected Framework

The AWS Well-Architected Framework provides a consistent approach for evaluating cloud architectures against **six design pillars**.
<br>It is the conceptual foundation behind every architecture design question on the SAA exam — understanding the pillars helps you reason about trade-offs even when a specific pillar isn't named.

### The Six Pillars

| **Pillar** | **Core Question** | **Key Concepts** |
|-----------|------------------|-----------------|
| **Operational Excellence** | Can we run and monitor systems effectively? | Infrastructure as code, incremental changes, runbooks, observability |
| **Security** | How do we protect data and systems? | Least privilege, encryption at rest/transit, traceability, MFA |
| **Reliability** | Does the system recover from failure? | Multi-AZ, backups, chaos engineering, Auto Scaling, retry logic |
| **Performance Efficiency** | Are we using resources efficiently? | Right instance types, serverless, caching, CDN, benchmark |
| **Cost Optimization** | Are we spending wisely? | Reserved/Spot instances, rightsizing, Cost Explorer, lifecycle policies |
| **Sustainability** ※ | How do we minimize environmental impact? | Maximize utilization, use managed services, reduce waste, efficient hardware |

### AWS Well-Architected Tool

The **AWS Well-Architected Tool** is a free service in the AWS console that guides you through a structured review of your workloads against the six pillars.
<br>It generates a report identifying high-risk issues (HRIs) and medium-risk issues (MRIs) with recommended improvement actions.

> 💡 **Exam Tips:**
> <br>"Evaluate an architecture against AWS best practices" → **AWS Well-Architected Framework / Well-Architected Tool**
> <br>"Which pillar covers HA, fault tolerance, and recovery?" → **Reliability**
> <br>"Which pillar covers IAM least privilege and encryption?" → **Security**
> <br>"Which pillar covers rightsizing and Reserved Instances?" → **Cost Optimization**
> <br>"Which pillar covers using serverless to reduce idle capacity?" → **Performance Efficiency** or **Sustainability** (context-dependent)

---

# Media Services
---

## AWS Elemental MediaConvert

AWS Elemental MediaConvert is a **file-based video transcoding service** that converts video content from one format and quality level to another for broadcast and multi-screen delivery.
<br>It is a fully managed service — no transcoding infrastructure to provision or manage.

- Converts video files (e.g., MXF, MP4, MOV) into output formats optimized for streaming, broadcast, or device delivery (HLS, DASH, MP4, etc.)
- Supports advanced features: HDR processing, DRM (Digital Rights Management), audio normalization, overlay graphics
- **Job-based:** create a transcoding job specifying input (S3), output settings (codec, resolution, bitrate), and output location (S3)
- Pricing is based on minutes of video output processed ¤
- Use cases: media companies transcoding content for streaming platforms, OTT (over-the-top) video delivery, broadcast preparation

> 💡 **Exam Tip:** `"Convert video files to different formats for streaming or device delivery"` → **AWS Elemental MediaConvert**.
> <br>This is the only Media Service in scope for SAA — it appears as an awareness-level service. The key exam signal is **video transcoding / format conversion**.

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|-------------|
| Build and host a full-stack web app with auth, data API, and storage | AWS Amplify (Cognito + AppSync/API Gateway + S3) |
| CI/CD pipeline and global hosting for a React or Next.js app | Amplify Hosting |
| GraphQL API aggregating DynamoDB and a Lambda function | AWS AppSync |
| Real-time data push to connected mobile clients | AppSync with GraphQL Subscriptions |
| Test a mobile app on real Android and iOS devices | AWS Device Farm |
| Build, train, and deploy a custom ML model | Amazon SageMaker |
| Automatically label and moderate user-uploaded images | Amazon Rekognition (S3 → Lambda → Rekognition) |
| Transcribe customer support call recordings | Amazon Transcribe |
| Translate product listings into 20 languages | Amazon Translate |
| Analyze support ticket text for customer sentiment | Amazon Comprehend |
| Build a voice/text chatbot for a contact center | Amazon Lex + Amazon Connect |
| Convert blog articles to audio for accessibility | Amazon Polly |
| Detect operational anomalies before they cause outages | Amazon DevOps Guru |
| Find security vulnerabilities in application code during CI/CD | Amazon CodeGuru Reviewer |
| Analyze AWS spending patterns over the past year | AWS Cost Explorer |
| Alert when monthly spend exceeds budget threshold | AWS Budgets |
| Export per-resource hourly billing data for custom analysis | AWS Cost & Usage Report (CUR) → S3 → Athena |
| Estimate cost of a planned architecture before deploying | AWS Pricing Calculator |
| Attribute AWS costs to individual teams for chargeback | Cost Allocation Tags → Cost Explorer / CUR |
| Identify over-provisioned EC2 instances and right-size | AWS Compute Optimizer |
| Track and enforce Microsoft SQL Server license compliance | AWS License Manager |
| Evaluate a workload against AWS best practices | AWS Well-Architected Tool |

---

## HOL Notes — Miscellaneous Services

> 🛠️ **Implementation Notes:**
> <br>**Amplify Hosting:** Connect a GitHub repo in the Amplify console → Amplify auto-detects the framework, sets build settings, and deploys on every `git push` to the configured branch
> <br>**AppSync:** In the AppSync console, define a GraphQL schema → attach resolvers to data sources (DynamoDB table, Lambda, HTTP) → test queries in the built-in GraphQL IDE
> <br>**Cost Explorer:** Navigate to Billing → Cost Explorer → enable it (one-time, takes ~24 hours to populate) → use filters and groupings to explore spending patterns
> <br>**AWS Budgets:** Billing → Budgets → Create Budget → choose type (Cost/Usage/RI/SP) → set threshold → configure SNS or email alerts → optionally add automated actions
> <br>**CUR Setup:** Billing → Cost & Usage Reports → Create report → choose S3 bucket → enable Athena integration for SQL querying
> <br>**Cost Allocation Tags:** Resource tagging with consistent keys (e.g., `Environment`, `Team`, `Project`) → Billing → Cost Allocation Tags → activate the keys → tags appear in Cost Explorer groupings within 24 hours
> <br>**Compute Optimizer:** Enable in the console (free); requires 14 days of CloudWatch metric data; view per-resource recommendations and compare current vs. recommended instance types

---

# Module Summary
---

## Key Topics
  - **AWS Amplify** — full-stack dev platform (Studio, Libraries, Hosting); provisions Cognito, AppSync/API Gateway, DynamoDB, S3, Lambda behind the scenes
  - **AWS AppSync** — managed GraphQL API; real-time via Subscriptions; multi-source resolvers; server-side caching; offline support; contrast with API Gateway (REST)
  - **AWS Device Farm** — test mobile/web apps on real physical devices
  - **AI/ML Services (awareness)** — SageMaker (custom models), Rekognition (vision), Transcribe (speech→text), Translate (language), Comprehend (NLP/sentiment), Lex (chatbot), Polly (text→speech), Kendra (enterprise search), Personalize (recommendations), Forecast (time series), **Textract (document/form extraction)**, **Fraud Detector (online fraud detection)**
  - **ML Operations** — DevOps Guru (operational anomaly detection), CodeGuru (code security + performance profiling)
  - **AWS Elemental MediaConvert** — file-based video transcoding; format conversion for streaming/broadcast; job-based; S3 in/out
  - **AWS Cost Explorer** — analyze 13 months of history; forecast 3 months; free; filter by service/account/tag
  - **AWS Budgets** — proactive alerts on cost/usage/RI/SP thresholds; email or SNS; automated actions ※
  - **Cost & Usage Report (CUR)** — most granular billing data; per-resource, hourly; delivered to S3; analyzed via Athena/Redshift/QuickSight
  - **AWS Pricing Calculator** — estimate costs before deploying; no account required
  - **AWS Price List API** — programmatic pricing; JSON (Query) or HTML (Bulk); SNS price-change alerts
  - **Cost Allocation Tags** — attribute costs to teams/projects; must activate in Billing console; powers chargeback/showback
  - **AWS Compute Optimizer** — ML right-sizing for EC2, EBS, Lambda, ASGs; 14-day minimum data; free
  - **AWS License Manager** — centralized license tracking for Microsoft, Oracle, SAP, IBM; enforce limits across accounts and regions
  - **AWS Well-Architected Framework** — 6 pillars: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, Sustainability; Well-Architected Tool for structured workload review

---

## Critical Acronyms
  - **CI/CD** — Continuous Integration / Continuous Delivery
  - **SSR** — Server-Side Rendering
  - **SSML** — Speech Synthesis Markup Language
  - **ASR** — Automatic Speech Recognition
  - **NLP** — Natural Language Processing
  - **ML** — Machine Learning
  - **IVR** — Interactive Voice Response
  - **CUR** — Cost & Usage Report
  - **RI** — Reserved Instance
  - **SP** — Savings Plans
  - **HRI** — High-Risk Issue (Well-Architected Tool)
  - **MRI** — Medium-Risk Issue (Well-Architected Tool)
  - **TCO** — Total Cost of Ownership
  - **FinOps** — Financial Operations (cloud cost management discipline)
  - **CDN** — Content Delivery Network
  - **API** — Application Programming Interface
  - **SNS** — Simple Notification Service
  - **S3** — Simple Storage Service
  - **EC2** — Elastic Compute Cloud
  - **EBS** — Elastic Block Store
  - **ASG** — Auto Scaling Group
  - **IAM** — Identity and Access Management
  - **HA** — High Availability

---

## Key Comparisons
  - AI/ML Services Overview table — all 12 services with category, purpose, input/output
  - Cost Management Services Overview table — all 7 tools with purpose and key capability
  - AWS Well-Architected Framework — six pillars with core question and key concepts (table)
  - AppSync vs. Cognito Sync — data sync across users vs. across one user's devices (inline)
  - REST (API Gateway) vs. GraphQL (AppSync) — implicit throughout module
  - Cost Explorer vs. Budgets vs. CUR — retrospective analysis vs. proactive alerting vs. raw data (inline)

---

## Top Exam Triggers
  - `Build full-stack web/mobile app on AWS quickly` → **AWS Amplify**
  - `CI/CD + hosting for a React or Next.js app` → **Amplify Hosting**
  - `GraphQL API` → **AWS AppSync**
  - `REST API` → **API Gateway** (Module 10)
  - `Real-time data push to mobile clients` → **AppSync GraphQL Subscriptions**
  - `Test mobile app on real physical devices` → **AWS Device Farm**
  - `Build and deploy a custom ML model` → **Amazon SageMaker**
  - `Detect objects, faces, or text in images` → **Amazon Rekognition**
  - `Convert speech audio to text` → **Amazon Transcribe**
  - `Translate text between languages` → **Amazon Translate**
  - `Sentiment analysis or entity extraction from text` → **Amazon Comprehend**
  - `Build a chatbot with voice and text` → **Amazon Lex**
  - `Convert text to audio/speech` → **Amazon Polly**
  - `Detect operational anomalies before outages` → **Amazon DevOps Guru**
  - `Find security bugs in code during CI/CD` → **Amazon CodeGuru Reviewer**
  - `Analyze historical AWS spending and forecast future costs` → **AWS Cost Explorer**
  - `Alert when spending exceeds a threshold` → **AWS Budgets**
  - `Most granular per-resource billing data for custom processing` → **Cost & Usage Report (CUR)**
  - `Estimate costs before deploying a new architecture` → **AWS Pricing Calculator**
  - `Attribute costs to teams for chargeback` → **Cost Allocation Tags**
  - `ML-based right-sizing for EC2, EBS, Lambda` → **AWS Compute Optimizer**
  - `Track and enforce software license compliance` → **AWS License Manager**
  - `Evaluate architecture against AWS best practices` → **AWS Well-Architected Tool**
  - `Which pillar covers HA and fault tolerance?` → **Reliability**
  - `Which pillar covers encryption and least privilege?` → **Security**
  - `Which pillar covers rightsizing and Reserved Instances?` → **Cost Optimization**

---

## Quick References

### Web & Mobile

- [AWS Amplify Docs](https://docs.aws.amazon.com/amplify/)
- [AWS AppSync Docs (GraphQL)](https://docs.aws.amazon.com/appsync/)

---

### Machine Learning & AI

- [Amazon SageMaker Overview](https://docs.aws.amazon.com/sagemaker/)
- [AWS AI Services Overview (Rekognition, Comprehend, etc.)](https://aws.amazon.com/machine-learning/ai-services/)
- [Amazon Rekognition Docs](https://docs.aws.amazon.com/rekognition/)
- [Amazon Comprehend Docs](https://docs.aws.amazon.com/comprehend/)

---

### Cost Management

- [AWS Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html)
- [AWS Cost & Usage Report (CUR)](https://docs.aws.amazon.com/cur/)
- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Price List API](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)

---

### Real-World / Industry Reference

- [Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
- [AWS ML Use Case Explorer](https://aws.amazon.com/machine-learning/use-cases/)

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
