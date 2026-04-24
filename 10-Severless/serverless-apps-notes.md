## Event-Driven Architecture

A software architecture pattern where components communicate by producing and reacting to events

---

## Components of Event-Driven Architecture:

- **Event** – A change in state or occurrence 
  - e.g., file upload, user action, scheduled trigger
- **Event Producers** – Components that generate events 
  - e.g., applications, services, devices
- **Event Consumers** – Components that listen for and react to events 
  - e.g., Lambda functions, applications
- **Event Channels** – Communication pathways through which events are transmitted from producers to consumers
  - **Examples:**
    - Message queues (Amazon SQS)
    - Event buses (Amazon EventBridge)
    - Streaming platforms
- **Event Processing** – Logic applied to events (filtering, transformation, routing)
  - Often implemented by consumers (e.g., Lambda)

---

## Serverless Services

- With serverless architecture, there are no instances to manage
- No need to provision hardware, install software, or manage infrastructure
- Capacity provisioning and scaling are handled automatically 
- Can be more cost-effective as you only pay for what you use

---

## AWS Lambda

- A serverless compute service that runs code in response to events and automatically manages the underlying compute resources
  - Source can be CLI, API, SDK, or AWS services
- Pay only for the compute time you consume 
  - No charge when code is not running
- Hard limit of 15 minutes per execution

---

### Key Benefits of AWS Lambda:
  - No server management
  - Automatic and continuous scaling
  - Milisecond billing
  - Integrated with many AWS services

---

### Primary Use Cases of AWS Lambda:
  - Data processing (e.g., real-time file processing, stream processing)
  - Real-time file processing (e.g., image resizing, log analysis)
  - Real-time stream processing (e.g., processing data from Kinesis or DynamoDB Streams)
  - Backend services (e.g., APIs, microservices)
  - Automation (e.g., scheduled tasks, infrastructure automation)
  - Event-driven applications (e.g., responding to events from other AWS services)

---

## Lambda Function Invocation Types

### Synchronous Invocation:
  - CLI, SDK, API Gateway
  - Wait for the function to process the event and return a response
  - Error handling happens client side 
    - Retries, exponential backoff, etc.

---

### Asynchronous Invocation:
  - AWS services (e.g., S3, SNS, CloudWatch Events, etc.)
  - Event is queued for processing and a response is returned immediately
  - Lambda retries up to 3 times
  - Processing must be idempotent (due to retries)
    - **Idempotent:** An operation that can be performed multiple times without changing the result beyond the initial application

---

### Event Source Mapping:
  - SQS, Kinesis Data Streams, DynamoDB Streams
  - Lamda does the polling (polls the source for new events)
  - Records get processed in order (except for SQS Standard)

---

## Lambda Function Concurrency

- There is a **burst** or **account limit** that varies by region (e.g., 1000 concurrent executions)
  - Innital burst limit ranges from 500 to 3000 depending on the region
  - After the burst limit is reached, the concurrency scales +1000 every 10 seconds (per function)
- If the limit is reached, throttling occurs with error code 429 `TooManyRequestsException`

---

## Application Integration Services Overview

| **Service** | **What It Does** | **Use Cases** |
|-------------|------------------|---------------|
| **Amazon Simple Queue Service (SQS)** | Messaging queue; <br> store and forward patterns | Building distributed / decoupled applications |
| **Amazon Simple Notification Service (SNS)** | Set up, operate, and send notifications from the cloud | Send email notifications when CloudWatch is triggered |
| **Step Functions** | Out-of-box coordingation of AWS services with visual workflows | Order processing workflow |
| **Simple Workflow Service (SWF)** | Need to support external processes or specialized execution logic | Human enabled workflows like an order fulfillment system or for procedural requests like a loan application process <br> **Note:** AWS reccomends that for new apps, customders consider Step Functions instead of SWF|
| **Amazon MQ** | Messages broker service for Apache ActiveMQ and RabbitMQ | Need a message queue that supports industry-standard APIs and protocols (like JMS, NMS, AMQP, STOMP, MQTT, and WebSocket); migrate queues to AWS |
| **Amazon Kinesis** | Collect, process, and analyze real-time streaming data | Collect data from IoT devices for later processing; real-time log processing |
| **Amazon EventBridge** | Serverless event bus that makes it easy to connect applications using data from your own applications, integrated SaaS applications, and AWS services | Build event-driven applications; integrate with SaaS applications |

---

## Kinesis vs SQS vs SNS

| **Amazon Kinesis** | **Amazon SQS** | **Amazon SNS** |
|--------------------|----------------|----------------|
| Consumers pull data | Consumers pull data | Producers push data to many subscribers |
| Many consumers (limited by shard capacity) | Data is deleted after being consumed | Publisher-subscriber model |
| Routes related records to same record processor | Can have as many workers (consumers) as needed | Integrates with SQS for fan-out pattern |
| Multiple applications can access the same stream concurrently | **Standard:** no ordering guarantees <br>**FIFO:** ordering and exactly once delivery | Up to 10 million subscribers per topic |
| Ordering at the shard level | Provides messaging semantics <br>**Standard:** at least once<br>**FIFO:** exactly once | Up to 100,000 topics per account |
| Can consume records in correct order at later time | Individual message delay | Data is not persisted (messages are delivered immediately, data is lost after retries) |
| Must provision throughput (shards based) | Dynamic scaling | No need to provision throughput |

---

## Amazon SQS (Simple Queue Service)

- Is a fully managed message queuing service 
- **Pull based** delivery to a **single consumer**
- Enables you to decouple and scale:
  - Microservices
  - Distributed systems
  - Serverless applications

---

### Example Use Case for SQS:

You could use SQS as an intermediary between the web tier and the app tier such that if a desync were to occur, such as to an influx of traffic, the web tier can continue to accept requests and place them in the queue while the app tier processes them at its own pace. This allows for better handling of traffic spikes and prevents the web tier from being overwhelmed.

---

## SQS Queue Types

### Standard Queue
  - Best effort ordering 
    - Tries to preserve the order of messages, but does not guarantee it
    - Messages might not be delivered in the order they were sent
  - At least once delivery 
    - Guarantees that a message will be delivered
    - However, messages might be delivered more than once (duplicates)
  - Unlimited throughput 
    - Can process a nearly unlimited number of transactions per second (TPS)

---

### FIFO Queue
  - First-In-First-Out delivery 
    - Messages are delivered in the order they were sent
  - Exactly once processing 
    - Each message is delivered once 
    - Message remains available until a consumer processes and deletes it
  - Limited throughput 
    - Up to 300 transactions per second without batching
    - Up to 3,000 transactions per second with batching
  - Requires the **MessageGroupId** and **MessageDeduplicationId** parameters 
    - **MessageGroupId:** Tag that specifies that a message belongs to a specific message group 
    - **MessageDeduplicationId:** Token used for deduplication of messages within deduplication interval (5 minutes)

---

## Standard vs FIFO SQS

| **Standard Queue**     | **FIFO Queue**              |
|------------------------|-----------------------------|
| Unlimited throughput   | Limited throughput          |
| Best effort ordering   | First-In-First-Out delivery |
| At least once delivery | Exactly once processing     |

---

## Queue Configurations

### Dead-Letter Queues (DLQ)
  - A queue that receives messages that could not be processed successfully after a specified number of attempts
  - Helps to isolate and analyze failed messages without affecting the main queue
  - Can be used with both Standard and FIFO queues
  - Not a queue type, but rather a configuration option for handling message failures

---

### Delay Queues
  - A queue that postpones the delivery of messages for a specified amount of time (up to 15 minutes)
  - Can be used to implement a delay in processing messages, such as for retry logic or scheduled tasks
  - Can be used with both Standard and FIFO queues

---

## Polling Methods

### Short Polling
  - A polling method where the consumer checks a subset of servers for messages
  - Returns immediately even if no messages are found
  - May not return all available messages
  - Can result in empty responses and increased API requests
    - Can lead to higher costs

---

### Long Polling
  - A polling method where the consumer waits for a specified amount of time `WaitTimeSeconds` 
     - `WaitTimeSeconds` can be set up to 20 seconds
     - `WaitTimeSeconds` = 0 means short polling

  - Enabled at:
    - The API level (e.g., `ReceiveMessage` action) 
    - Or at the queue level (e.g., `ReceiveMessageWaitTimeSeconds` attribute)

  - Eliminates empty responses and reduces the number of API requests
    - Allows Long Polling to be more cost-effective than Short Polling

---

## Amazon SNS (Simple Notification Service)

- Fully managed pub/sub messaging service
- Highly available, durable, and secure
- Fan-out message delivery to multiple subscribers
- Multiple recipients can be grouped under a single topic
  - Messages are delivered to all subscribers of the topic
- **Push based** delivery to **multiple subscribers**
- **Publishers** send messages to a topic
- **Subscribers** receive messages from the topic (fan-out)

---

### Delivery Methods ( Transport Protocols):
  - HTTP / HTTPS
  - Email / Email-JSON
  - SMS
  - **SQS** *
    - Techincally not a transport protocol, but a supported delivery method

---

### Subscriber Targets:
  - SQS queues
  - Lambda functions
  - HTTP/S endpoints
  - Email addresses
  - SMS endpoints
 
---

## Amazon SNS + Amazon SQS Fan-Out Pattern

- You can subsribe multiple SQS queues to a single SNS topic
- SQS manages the subscriptions and any necessary permissions
- When you publish a message to the SNS topic, SNS delivers a copy to every subscribed SQS queue

---

## AWS Step Functions

- Used to build distributed applications as a series of steps in a visual workflow
- Each step is a state that can perform work, make decisions, or pass data to the next step
- You can quickly build and run state machines to execute the steps of your application
- Very similar to logic flow diagrams used in software design

---

### How it works:

1. Define the steps of your workflow in the **JSON-based Amazon States Language** (ASL). <br> The visual console automatically graphs each step in the order of execution

2. Start an execution to visualize and verify the steps of your workflow are working as expected. <br> AWS Step Functions **operates and scales** the steps of your app and **underlying compute resources** to ensure your app executes reliably under increasing demand

---

## Amazon EventBridge

- A serverless event bus that makes it easy to connect applications using data from your own applications, integrated SaaS applications, and AWS services
- Used to be called CloudWatch Events, but was rebranded to reflect its expanded capabilities

---

### Order of operations is as follows:
  1. An event is generated by an event source 
    - e.g., AWS service, custom application, integrated SaaS application
  2. The event is sent to an event bus 
    - e.g., default, custom or partner event bus
  3. The event is matched against rules that determine which targets should receive the event
    - e.g., event pattern matching, schedule-based rules, etc.
  4. The event is delivered to the appropriate targets 
    - e.g., Lambda functions, SQS queues, SNS topics, HTTP/S endpoints

---

### Event Sources:
  - AWS services 
    - e.g., S3, EC2, Lambda, etc.
  - Custom applications 
    - e.g., applications running on-premises or in the cloud
  - Integrated SaaS applications 
    - e.g., Zendesk, Datadog, etc.

---

### API Event Targets:
  - AWS services 
    - e.g., Lambda, SQS, SNS, Step Functions, etc.
  - HTTP/S endpoints 
    - e.g., webhooks, APIs, etc.

---

## Amazon API Gateway

- A fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale
- Supports RESTful APIs and WebSocket APIs
- Can be used to create APIs that access AWS services, Lambda functions, or any web application
- Acts as a:
  - **Front door** for applications to access data, business logic, or functionality from backend services
  - **Event source** for Lambda functions, allowing you to trigger Lambda functions in response to API calls
  - **Request router** that routes requests to the appropriate backend targets based on the API configuration

---

### Provides features such as:
  - Request and response transformation
  - Caching
  - Throttling
  - Authentication and authorization
  - Monitoring and logging

---

### API Gateway Integration Types:
  - For a **Lambda function** you can have:
    - **Proxy integration**
    - **Custom integration**
  - For an **HTTP endpoint** you can have:
    - **HTTP proxy integration**
    - **HTTP custom integration**
  - For an **AWS service** you can only have:
    - **AWS service integration**

---

### API Gateway Endpoint Types:
- **Regional:** for clients within the same region
  - Can use CloudFront if added manually
- **Edge-Optimized:** uses CloudFront for global access
- **Private:** accessible only within a VPC

---

### API Gateway — CORS (Cross-Origin Resource Sharing)
- Allows web applications from one domain to access resources from another domain
- API Gateway handles **CORS preflight (OPTIONS) requests**
- Adds required headers (e.g., `Access-Control-Allow-Origin`) to responses

---

### API Gateway — Roles and Layers:

- **API Front Door:**
  - Entry point for clients to access backend services

- **Request Router:**
  - Routes requests to backend targets (Lambda, HTTP, AWS services)

- **Lambda Trigger:**
  - Acts as an event source for Lambda functions

- **Service Integration Layer:**
  - Directly integrates with AWS services

- **Security Enforcement Layer:**
  - Handles authentication and authorization (IAM, Cognito, Lambda authorizers)

- **Traffic Control Layer:**
  - Throttling, rate limiting, and usage plans

- **Transformation Layer:**
  - Transforms request/response payloads

- **Caching Layer:**
  - Caches responses to reduce latency and backend load

- **Protocol Translation Layer:**
  - Converts HTTP requests into backend-compatible formats

---

### API Gateway Flow:

**Client** → **CloudFront** (if edge-optimized) → **API Gateway** → **Backend** (Lambda, HTTP endpoint, AWS service)

---

### API Gateway Caching:
  - You can add caching to your API calls by provisioning an API Gateway cache
    - Must specify the cache size (from 0.5 GB to 237 GB)
  - Caching allows you to cache the endpoint's response 
    - Reduces the number of calls made to your endpoint and improves latency

---

### API Gateway Authorization:
- IAM roles
- Cognito User Pools
- Lambda authorizers

---

### API Gateway Throttling
  - API Gateway sets a limit on steady-state rate and burst of requests on all APIs in an account
    - **Steady-state rate:** 10,000 requests per second (RPS) per account
    - **Maximum concurrent requests:** 5,000 per account
    - **Burst:** 5,000 RPS per account
      - Limits can change based on region
      - Can be increased by requesting a limit increase through AWS Support
  - If the limit is exceeded, API Gateway returns a `429 TooManyRequestsException` error
  - Upon catching such exceptions, the client should implement retries with exponential backoff 

---

### API Gateway — Usage Plans and API Keys
  - Usage plans specify who can access one or more deployed API stages and methods
    - Also how much and how fast they can access them
  - API keys are used to identify and track API usage by individual clients
    - API keys are **NOT** used for authentication or authorization
    - They **ARE** used to identify and track API usage by clients

---

## Quick References

[Serverless Services Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619266#overview)

[Serverless Services Architecture Patterns Private Link](https://drive.google.com/drive/folders/1jiizmhK-9yIGh0RBnKT6ZwZzPyksM0x7?usp=drive_link)

[Serverless Services Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346112#overview)

[AWS Lambda Cheat Sheet](https://digitalcloud.training/aws-lambda/)

[AWS API Gateway Cheat Sheet](https://digitalcloud.training/amazon-api-gateway/)

[AWS Application Integration Services Cheat Sheet](https://digitalcloud.training/aws-application-integration)

[AWS CloudWatch Cheat Sheet](https://digitalcloud.training/amazon-cloudwatch/)

---