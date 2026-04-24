# Web & Application Services
---

## Amazon CloudFront
  - Global Content Delivery Network (CDN)

### Features
  - Caches content at edge locations
  - Reduces latency
  - Supports HTTPS (SSL/TLS)

### Origins
  - S3
  - EC2
  - ALB

### Key Insight
  - Improves performance for global users

### Exam Triggers
  - `Low latency global delivery` → CloudFront
  - `Cache content at edge` → CloudFront

---

## AWS Elastic Beanstalk
  - Platform-as-a-Service (PaaS) for deploying applications

### Features
  - Handles:
    - Provisioning
    - Load balancing
    - Auto scaling
    - Monitoring

### Supported Platforms
  - Java, Python, Node.js, Docker, etc.

### Key Insight
  - You upload code → AWS manages infrastructure

### Exam Trigger
  - `Deploy app without managing infrastructure` → Elastic Beanstalk

---

## AWS App Runner
  - Fully managed service for running containerized web apps

### Features
  - Deploy directly from:
    - Source code
    - Container image

### Key Insight
  - Simpler than ECS/EKS

### Exam Trigger
  - `Run container app without managing infra` → App Runner

---

# Mobile & API Services
---

## Amazon API Gateway
  - Managed service to create and manage APIs

### Features
  - Supports:
    - REST APIs
    - HTTP APIs
    - WebSocket APIs

  - Integrates with:
    - Lambda
    - EC2
    - Other AWS services

### Key Insight
  - Enables serverless architectures

### Exam Triggers
  - `Create API` → API Gateway
  - `Serverless backend` → API Gateway + Lambda

---

## AWS Amplify
  - Full-stack development platform

### Features
  - Frontend + backend integration
  - CI/CD for web and mobile apps

### Key Insight
  - Simplifies app development

### Exam Trigger
  - `Build mobile/web apps quickly` → Amplify

---

## AWS AppSync
  - Managed GraphQL API service

### Features
  - Real-time data sync
  - Offline capabilities

### Key Insight
  - Alternative to REST APIs

### Exam Trigger
  - `GraphQL API` → AppSync

---

# Machine Learning Services
---

## Amazon SageMaker
  - End-to-end ML platform

### Features
  - Build, train, and deploy ML models
  - Managed infrastructure

### Key Insight
  - Full ML lifecycle service

### Exam Trigger
  - `Build/train ML models` → SageMaker

---

## Amazon Rekognition
  - Image and video analysis

### Features
  - Face detection
  - Object recognition

### Exam Trigger
  - `Analyze images/video` → Rekognition

---

## Amazon Comprehend
  - Natural Language Processing (NLP)

### Features
  - Sentiment analysis
  - Entity recognition

### Exam Trigger
  - `Analyze text` → Comprehend

---

## Amazon Polly
  - Text-to-speech service

### Exam Trigger
  - `Convert text to speech` → Polly

---

## Amazon Transcribe
  - Speech-to-text service

### Exam Trigger
  - `Convert speech to text` → Transcribe

---

## Amazon Translate
  - Language translation service

### Exam Trigger
  - `Translate text` → Translate

---

## Amazon Lex
  - Conversational AI (chatbots)

### Features
  - Voice + text interfaces

### Exam Trigger
  - `Build chatbot` → Lex

---

# Cost Optimization
---

## Cost Management Services

### AWS Cost Explorer
  - Analyze AWS spending over time

### AWS Budgets
  - Set cost and usage alerts

### AWS Pricing Calculator
  - Estimate costs before deployment

### AWS Trusted Advisor
  - Provides cost optimization recommendations

---

### Key Insight
  - Cost optimization is continuous:
    - Monitor → Analyze → Optimize

---

### Exam Triggers
  - `Analyze cost trends` → Cost Explorer
  - `Set budget alerts` → Budgets
  - `Estimate costs` → Pricing Calculator
  - `Optimize resources` → Trusted Advisor

---

# Module Summary
---

## Key Comparisons

| **Concept** | **Service** |
|--------|--------|
| CDN / caching | CloudFront |
| PaaS app deployment | Elastic Beanstalk |
| Container app (simple) | App Runner |
| REST API | API Gateway |
| GraphQL API | AppSync |
| Full-stack dev | Amplify |
| ML platform | SageMaker |
| Image analysis | Rekognition |
| NLP | Comprehend |
| Text-to-speech | Polly |
| Speech-to-text | Transcribe |
| Translation | Translate |
| Chatbot | Lex |
| Cost analysis | Cost Explorer |
| Budget alerts | AWS Budgets |
| Cost estimation | Pricing Calculator |
| Cost optimization | Trusted Advisor |

---

## High-Yield Exam Scenarios

- `Global content delivery` → CloudFront
- `Deploy app quickly (PaaS)` → Elastic Beanstalk
- `Run containers simply` → App Runner
- `Create API` → API Gateway
- `GraphQL API` → AppSync
- `Build ML models` → SageMaker
- `Analyze images` → Rekognition
- `Analyze text sentiment` → Comprehend
- `Text to speech` → Polly
- `Speech to text` → Transcribe
- `Translate languages` → Translate
- `Build chatbot` → Lex
- `Analyze costs` → Cost Explorer
- `Set budget alerts` → AWS Budgets

---

## Quick References

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

---