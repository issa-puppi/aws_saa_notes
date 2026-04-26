# Containerization Fundamentals
---

## Virtualization vs. Containerization

Understanding the distinction between VMs and containers is foundational — the exam uses this to frame why container services exist and when to choose them.

| **Aspect** | **Server Virtualization (VMs)** | **Containerization** |
|------------|----------------------------------|----------------------|
| **Abstraction layer** | Hypervisor virtualizes hardware | Container engine (Docker) shares the host OS kernel |
| **OS per unit** | Each VM runs its own full OS | Containers share the host OS kernel — no guest OS |
| **Resource overhead** | High — full OS per VM | Low — minimal overhead per container |
| **Startup time** | Minutes | Seconds (or sub-second) |
| **Isolation** | Strong — separate kernel per VM | Process-level isolation (namespaces, cgroups) |
| **Portability** | Tied to hypervisor/AMI type | Runs anywhere Docker or a container runtime is available |
| **AWS examples** | EC2 instances (Xen / Nitro hypervisor) | ECS, EKS, Fargate |
| **Best for** | Long-lived OS-level isolation, legacy lift-and-shift | Microservices, cloud-native apps, CI/CD pipelines |

---

## Docker and Container Images

**Docker** packages an application and all its dependencies into a portable **container image**.

  - A **container image** is a read-only template built from a **Dockerfile** — a text file defining the steps to create the image
  - A **container** is a running instance of an image — isolated from other containers and the host, but sharing the host OS kernel
  - **Docker Hub** is the default public registry for sharing images
  - **Amazon ECR** is AWS's managed container registry (see below)

### Containers vs. Lambda Functions

| **Aspect** | **Docker Containers** | **Lambda Functions** |
|------------|----------------------|----------------------|
| **Workload type** | Long-running, persistent services | Short-lived, event-driven tasks |
| **Startup** | Fast (seconds) | Very fast (milliseconds, with Provisioned Concurrency) |
| **Infrastructure** | Managed (Fargate) or self-managed (EC2) | Fully serverless — zero infrastructure |
| **Max runtime** | Unlimited | 15 minutes per invocation |
| **Use case** | Web servers, APIs, microservices, batch jobs | Event handlers, triggers, quick transformations |

---

## Microservices Architecture

**Microservices** structures an application as a collection of **loosely coupled, independently deployable services**, each running its own process and communicating via APIs.

| **Attribute** | **Monolithic Architecture** | **Microservices Architecture** |
|---------------|-----------------------------|---------------------------------|
| **Codebase** | Single codebase for entire application | Multiple independent services |
| **Coupling** | Tightly coupled components | Loosely coupled — each service is independent |
| **Scaling** | Scale entire application | Scale individual services independently |
| **Technology** | Single technology stack | Each service can use the best tool for the job |
| **Deployment** | Deploy entire app per release | Deploy individual services independently |
| **Resilience** | One failure can bring down entire app | Failures are isolated to individual services |
| **Development speed** | Slower as codebase grows | Faster — smaller teams own smaller codebases |

  - Services communicate via **APIs** — typically HTTP/REST or messaging (SQS/SNS)
  - Containers are the natural runtime unit for microservices — one container per service
  - **SaaS** applications are commonly built using microservices architectures

---

# Container Orchestration
---

## Container Orchestration — Service Overview

| **Service** | **Orchestrator** | **Managed?** | **Best For** |
|-------------|-----------------|--------------|--------------|
| **Amazon ECS** | AWS-native | ✓ Fully managed | AWS-native simplicity, tight AWS integration |
| **Amazon EKS** | Kubernetes | ✓ Managed control plane | Kubernetes workloads, hybrid/multi-cloud, portability |
| **AWS Fargate** | Works with ECS or EKS | ✓ Serverless | No infrastructure management; pay per task |
| **AWS App Runner** | Fully abstracted | ✓ PaaS | Simplest path for containerized web apps/APIs |
| **ECS Anywhere / EKS Anywhere** | ECS or Kubernetes | ✓ Control plane only | On-premises containers with cloud control plane |

---

## Amazon Elastic Container Service (ECS)

Amazon Elastic Container Service (ECS) is a **fully managed container orchestration service** that runs Docker containers on AWS.
<br>ECS eliminates the need to install, operate, or scale your own cluster management infrastructure.

### Key Properties
  - **AWS-native** — integrates directly with IAM, ALB/NLB, CloudWatch, VPC, EBS, EFS, Secrets Manager
  - Supports **Docker** containers (Linux and Windows)
  - Clusters are **region-specific**
  - No additional charge for ECS itself ¤ — you pay for the underlying compute (EC2 or Fargate)
  - Monthly uptime SLA: **99.99%**
  - Integrates with **Elastic Beanstalk** — Beanstalk can provision an ECS cluster, load balancing, and auto scaling

---

## ECS Core Components

| **Component** | **Description** |
|---------------|-----------------|
| **Cluster** | Logical grouping of compute resources (EC2 instances or Fargate capacity) |
| **Container Instance** | EC2 instance running the ECS agent (EC2 launch type only) |
| **Task Definition** | JSON blueprint describing one or more containers (up to 10); <br>defines images, CPU/memory, networking, IAM role, environment variables, volumes |
| **Task** | A running instance of a task definition — one or more containers executing together |
| **Service** | Manages long-running tasks; maintains desired count; integrates with auto scaling and load balancing |
| **Image** | Docker container image referenced in the task definition; stored in ECR or Docker Hub |
| **Capacity Provider** | ECS resource linking a cluster to an EC2 Auto Scaling Group for cluster auto scaling |

---

## ECS Launch Types

ECS tasks and services can run on two launch types:

| **Feature** | **EC2 Launch Type** | **Fargate Launch Type** |
|-------------|---------------------|-------------------------|
| **Infrastructure management** | You provision, patch, and manage EC2 instances | AWS manages all compute — serverless |
| **Control** | Full control over instance type, OS, placement | Limited infrastructure control |
| **Cost model** ¤ | Pay for running EC2 instances + EBS | Pay per task by vCPU + memory consumed |
| **Supported storage** | EBS, EFS, FSx (via EC2), instance store | **EFS only** |
| **Private registries** | Supported | ECR and Docker Hub only |
| **Scaling** | Manual or ASG-based cluster scaling | Automatic task-level scaling |
| **ECS agent required** | ✓ Yes — runs on each EC2 instance | ✗ No — managed by AWS |
| **Best for** | Long-running workloads, custom configs, GPU, Windows | Event-driven, bursty, or simplified workloads |

> 💡 **Exam Tips:**
> <br>"Serverless containers — no EC2 management" → **ECS with Fargate**
> <br>"Need EBS or instance store with containers" → **ECS EC2 launch type** (Fargate supports EFS only)
> <br>"Windows containers" → **ECS EC2 launch type** (Fargate supports Windows containers as well ※)

---

## ECS Control Plane vs. Data Plane

| **Plane** | **Responsibility** | **Who Manages It** |
|-----------|--------------------|--------------------|
| **Control Plane** | Cluster state, scheduling, API requests, placement decisions | AWS (always managed) |
| **Data Plane** | Actual container execution, compute resources | **EC2 launch type**: you manage; **Fargate**: AWS manages |

---

## ECS Agent

The **ECS container agent** runs on each EC2 instance in a cluster (EC2 launch type only — not used with Fargate).

  - Pre-installed on **ECS-optimized AMIs**; can be manually installed on custom AMIs
  - Can also be installed on **non-AWS Linux instances** for ECS Anywhere
  - **Responsibilities:** register instance with cluster → receive task instructions from control plane → manage container lifecycle (start, stop, monitor) → report status back

---

## ECS IAM Roles

| **Role** | **Applies To** | **Purpose** |
|----------|---------------|-------------|
| **Container Instance IAM Role** | EC2 instance (EC2 launch type) | Permissions for the host EC2 — allows agent to call ECS APIs |
| **Task IAM Role** | Running containers (both launch types) | Fine-grained permissions for the application running in the container |
| **Task Execution Role** | Fargate (replaces container instance role) | Allows Fargate to pull images from ECR, send logs to CloudWatch, retrieve secrets |

  - IAM roles are applied to container instances **before launch** (EC2 launch type)
  - Security groups attach at the instance level (EC2) or container/task level (Fargate)

> 💡 **Exam Tip:** "Container needs to access S3 / DynamoDB" → **ECS Task IAM Role**
<br>This is the container-level equivalent of an EC2 instance profile.

---

## ECS Networking and Load Balancing

  - **ALB (Application Load Balancer)** — for HTTP/HTTPS traffic; supports **dynamic port mapping** on EC2 launch type
    - Dynamic port mapping: each task is assigned a random host port on the EC2 instance, allowing multiple tasks to run on the same host without port conflicts; the ALB's container awareness routes traffic to the correct host port per task
  - **NLB (Network Load Balancer)** — for TCP/UDP traffic; high throughput, static ports
  - **Service** registers tasks as ALB/NLB targets automatically as tasks start and stop

---

## ECS Auto Scaling

### Service Auto Scaling (scales the number of tasks)

| **Type** | **How It Works** |
|----------|-----------------|
| **Target Tracking** | Maintain a target value for a CloudWatch metric (e.g., CPU utilization = 50%) |
| **Step Scaling** | Add/remove tasks in steps when a CloudWatch alarm breaches (e.g., +2 tasks if CPU > 80%) |
| **Scheduled Scaling** | Scale at a defined time (e.g., add 5 tasks at 8 AM daily) |

### Cluster Auto Scaling (scales EC2 instances in the cluster — EC2 launch type only)

  - Uses a **Capacity Provider** linked to an EC2 **Auto Scaling Group (ASG)**
  - **Managed Scaling** — ECS automatically adjusts ASG size using the **Capacity Provider Reservation** metric
  - **Managed Instance Termination Protection** — prevents scale-in from terminating instances that are still running tasks ("container awareness")

---

## Amazon Elastic Kubernetes Service (EKS)

Amazon Elastic Kubernetes Service (EKS) is a **fully managed Kubernetes service** for running containerized applications on AWS.
<br>Kubernetes is an open-source system for automating the deployment, scaling, and management of containerized applications.

### Key Properties
  - **Managed control plane** — runs across **3 AZs** for high availability; AWS automatically detects and replaces unhealthy control plane nodes
  - Manages **Kubernetes API servers** and the **etcd** persistence layer
  - Can run on **EC2** (you manage worker nodes) or **Fargate** (serverless pods)
  - Integrates with ALB, NLB, IAM (RBAC), VPC, CloudWatch
  - **Primary use case**: organizations needing a consistent Kubernetes control plane across **hybrid** or **multi-cloud** environments

### ECS vs. EKS

| **Aspect** | **Amazon ECS** | **Amazon EKS** |
|------------|----------------|----------------|
| **Orchestrator** | AWS-native (proprietary) | Kubernetes (open-source standard) |
| **Complexity** | Simpler, easier to use | More feature-rich, steeper learning curve |
| **Portability** | AWS-specific | Compatible with any Kubernetes deployment — easy lift-and-shift |
| **Task unit** | **Tasks** — isolated container groups | **Pods** — co-located containers sharing storage/network |
| **Extensibility** | Limited (AWS integrations) | Extensive — wide ecosystem of third-party add-ons |
| **AWS integrations** | Route 53, ALB, CloudWatch, ECS-native | ALB/NLB via AWS Load Balancer Controller, IAM RBAC |
| **Best for** | AWS-native simplicity | Kubernetes workloads, hybrid/multi-cloud consistency |

---

## EKS Core Concepts

  - **Pod** — the smallest deployable unit in Kubernetes; one or more containers that share storage and network resources, scheduled together on the same node
  - **Node** — a worker machine (EC2 instance or Fargate) that runs pods
  - **Control plane** — API server, scheduler, etcd (managed by AWS in EKS)
  - **etcd** — distributed key-value store that holds all cluster state

### EKS Load Balancing
  - **AWS Load Balancer Controller** — manages ALBs and NLBs for Kubernetes clusters via Kubernetes-native resources:
    - Kubernetes **Ingress resource** → provisions an **ALB** (HTTP/HTTPS routing)
    - Kubernetes **Service of type `LoadBalancer`** → provisions an **NLB** (TCP/UDP)
  - Both ALB and NLB support **instance** and **IP** targets for EKS workloads

---

## EKS Auto Scaling

### Workload Auto Scaling (scales pods)

| **Scaler** | **What It Does** |
|------------|-----------------|
| **Horizontal Pod Autoscaler (HPA)** | Scales the **number of pods** based on CPU utilization or custom metrics |
| **Vertical Pod Autoscaler (VPA)** | Adjusts **CPU and memory reservations** per pod to right-size resource requests |

### Cluster Auto Scaling (scales nodes)

| **Tool** | **Mechanism** | **Notes** |
|----------|--------------|-----------|
| **Kubernetes Cluster Autoscaler** | Adjusts number of nodes in the cluster based on pod resource needs | Uses **AWS Auto Scaling Groups** |
| **Karpenter** ※ | AWS-built open-source autoscaler; provisions nodes directly via **EC2 Fleet** | Faster, more flexible than Cluster Autoscaler; preferred for new EKS deployments Δ |

---

## EKS Distro and Anywhere

  - **Amazon EKS Distro** — the same Kubernetes distribution used by EKS; available as open source (GitHub, S3, ECR); run Kubernetes anywhere — EC2, on-premises hardware — with the same tested dependencies as managed EKS
  - **Amazon EKS Anywhere** — deploy EKS-compatible clusters on-premises on VMware vSphere, bare metal, or other supported infrastructure; uses AWS for updates and support but runs locally

---

# Container Registry
---

## Amazon Elastic Container Registry (ECR)

Amazon Elastic Container Registry (ECR) is a **fully managed Docker container registry** for storing, managing, and deploying container images.

### Key Properties
  - Container images are stored in **Amazon S3** (internally) — highly available and durable §
  - Supports **Docker Registry HTTP API V2** and **OCI (Open Container Initiative)** image standards
  - Integrates natively with ECS and EKS for seamless image pulls
  - Images can be pushed/pulled from any Docker environment: cloud, on-premises, local machines
  - **Namespaces** can be used to organize repositories
  - Authentication required: use `aws ecr get-login-password` to obtain a temporary auth token before push/pull

### Public vs. Private Repositories

| **Type** | **Access** | **Use Case** |
|----------|------------|--------------|
| **Private repository** | Authenticated access via IAM | Internal/production images |
| **Public repository** | Anyone can pull without authentication | Sharing public images (e.g., open-source) |

### ECR Components

| **Component** | **Description** |
|---------------|-----------------|
| **Registry** | Account-level container; holds repositories |
| **Repository** | Named container for images (like a folder per application) |
| **Image** | A versioned container artifact |
| **Tag** | Human-readable identifier (e.g., `latest`, `v1.0`) |
| **Digest** | Immutable content-based identifier (e.g., `sha256:abc123`) |
| **Auth Token** | Temporary credential for push/pull operations |
| **Repository Policy** | Resource-based IAM policy controlling repository access |

### ECR Features

| **Feature** | **Description** |
|-------------|-----------------|
| **Lifecycle Policies** | Automatically expire old/unused images based on rules; reduces storage costs ¤ |
| **Image Scanning** | Identify vulnerabilities in images; basic scanning included free ¤; advanced scanning via Amazon Inspector ¤ |
| **Cross-Region Replication** | Replicate images across AWS regions and accounts for HA and DR |
| **Pull Through Cache** | Cache images from public registries (e.g., Docker Hub) in your private ECR registry — improves reliability and reduces egress |
| **Immutable Tags** | Prevent image tags from being overwritten ※ |
| **Encryption** | Images encrypted at rest using KMS |

### ECR Access Control
  - **Private repositories**: users must have IAM permissions to push/pull; resource-based policies control API-level access (`create`, `list`, `describe`, `delete`, `get`)
  - **Public repositories**: anyone can pull without authentication
  - IAM roles on ECS tasks and EKS pods control image pull permissions from private ECR

> 💡 **Exam Tips:** "Store container images securely within AWS, integrate with ECS/EKS" → **Amazon ECR**
<br> For cross-account image sharing, configure ECR repository policies with cross-account IAM permissions.

---

# Fully Managed Container Platforms
---

## AWS Fargate

AWS Fargate is a **serverless compute engine for containers** that works with both ECS and EKS.
<br>With Fargate you define your task's CPU and memory requirements — AWS provisions, scales, and manages all underlying infrastructure.

  - **No EC2 instances to manage** — eliminates patching, capacity planning, and cluster optimization
  - **Per-task billing** ¤ — charged by vCPU and memory consumed by running tasks
  - **Storage**: EFS is the only persistent shared storage option (no EBS with Fargate)
  - Fargate tasks run with **task-level network isolation** (each task gets its own ENI in awsvpc network mode)
  - Supports both **Linux** and **Windows** containers ※

> ⚠️ **Exam Trap:** Fargate only supports **EFS** for persistent shared storage — not EBS, FSx, or instance store. <br>If a scenario requires EBS, you must use the **EC2 launch type**.

---

## AWS App Runner

**AWS App Runner** is a fully managed **PaaS (Platform as a Service)** for deploying containerized web applications and APIs with no infrastructure management.

  - Accepts either a **container image** (from ECR) or **source code** (App Runner builds it)
  - Automatically handles: build, deploy, scaling, load balancing, health checks, TLS
  - **Auto-scales** based on traffic — scales to zero when idle ¤
  - Integrates with CloudWatch for monitoring and logging
  - Simpler than ECS or EKS — intended for developers who want to deploy without managing orchestration

| **Aspect** | **App Runner** | **ECS (Fargate)** |
|------------|---------------|-------------------|
| **Abstraction level** | Highest — full PaaS | Managed compute, but requires ECS configuration |
| **Configuration required** | Minimal | Moderate (task definitions, services, clusters) |
| **Use case** | Simple web apps, APIs, microservices | Broader container workloads, more control |
| **Source input** | Container image or source code | Container image only |

---

## ECS Anywhere and EKS Anywhere

| **Service** | **What It Does** | **Supported Environments** |
|-------------|-----------------|---------------------------|
| **ECS Anywhere** | Run ECS tasks on-premises using the AWS ECS control plane | On-premises servers, VMs, any Linux host |
| **EKS Anywhere** | Run EKS-compatible Kubernetes clusters on-premises | VMware vSphere, bare metal, Nutanix, Snow Family |

  - Both use the AWS-managed **control plane** while the **data plane** runs locally
  - ECS Anywhere requires the ECS agent + SSM agent to be installed on-premises
  - Enables hybrid container management — same tools and APIs as cloud ECS/EKS

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Run Docker containers without managing EC2 instances | **ECS + Fargate** |
| Run containers on EC2 with full control over instance type / storage | **ECS + EC2 launch type** |
| Containers need EBS volumes attached | **ECS EC2 launch type** (Fargate does not support EBS) |
| Kubernetes workloads, hybrid/multi-cloud consistency | **Amazon EKS** |
| Simplest container deployment — just provide code or image | **AWS App Runner** |
| Scale number of ECS tasks based on CPU/memory metrics | **ECS Service Auto Scaling (Target Tracking)** |
| Scale EC2 nodes in ECS cluster automatically | **ECS Capacity Provider + ASG with Managed Scaling** |
| Scale Kubernetes pods horizontally on CPU | **EKS Horizontal Pod Autoscaler (HPA)** |
| Faster, flexible node provisioning for EKS | **Karpenter** |
| Store and manage container images within AWS | **Amazon ECR** |
| Automatically remove old container images to save cost | **ECR Lifecycle Policies** |
| Scan container images for CVEs | **ECR Image Scanning** (basic: free; advanced: Amazon Inspector) |
| Container application needs to call DynamoDB | **ECS Task IAM Role** |
| Fargate task needs to pull from ECR and write CloudWatch Logs | **Task Execution Role** |
| Multiple ECS tasks on same EC2 instance, different ports | **ALB dynamic port mapping** |
| Run ECS on-premises with same control plane as AWS | **ECS Anywhere** |
| Run Kubernetes on-premises with AWS-supported control plane | **EKS Anywhere** |
| Cache public Docker Hub images locally in AWS | **ECR Pull Through Cache** |

---

## HOL Notes — ECR Image Push

> 🛠️ **Implementation Notes:**
> <br>Authenticate: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com`
> <br>Tag image: `docker tag <image_id> <account_id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:<tag>`
> <br>Push: `docker push <account_id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:<tag>`
> <br>Pull: `docker pull <account_id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:<tag_or_digest>`
> <br>X-Ray runs as a **daemon container** (EC2 launch type) or **sidecar** (Fargate — sidecar only) on port 2000 UDP

---


# Module Summary
---

## Key Topics
  - Virtualization vs. containerization: kernel sharing, overhead, startup time, isolation
  - Docker: images, Dockerfile, container registries, containers vs. Lambda
  - Microservices vs. monolithic architecture
  - ECS: clusters, task definitions, tasks, services, capacity providers
  - ECS launch types: EC2 (self-managed compute) vs. Fargate (serverless)
  - ECS IAM: container instance role vs. task role vs. task execution role
  - ECS networking: dynamic port mapping with ALB
  - ECS auto scaling: Service Auto Scaling (target tracking, step, scheduled) and Cluster Auto Scaling (capacity providers)
  - EKS: managed Kubernetes control plane, pods, AWS Load Balancer Controller
  - EKS auto scaling: HPA (pods), VPA (pod sizing), Cluster Autoscaler, Karpenter (nodes)
  - EKS Distro and EKS Anywhere
  - Amazon ECR: registries, repositories, image scanning, lifecycle policies, pull through cache
  - AWS Fargate: serverless compute for ECS and EKS; EFS-only storage
  - AWS App Runner: PaaS for containerized web apps and APIs
  - ECS Anywhere / EKS Anywhere: hybrid container management

---

## Critical Acronyms
  - **ECS** — Elastic Container Service
  - **EKS** — Elastic Kubernetes Service
  - **ECR** — Elastic Container Registry
  - **OCI** — Open Container Initiative
  - **HPA** — Horizontal Pod Autoscaler
  - **VPA** — Vertical Pod Autoscaler
  - **ASG** — Auto Scaling Group
  - **ENI** — Elastic Network Interface
  - **RBAC** — Role-Based Access Control
  - **etcd** — distributed key-value store used by Kubernetes for cluster state
  - **PaaS** — Platform as a Service
  - **SaaS** — Software as a Service
  - **API** — Application Programming Interface
  - **ALB** — Application Load Balancer
  - **NLB** — Network Load Balancer
  - **IAM** — Identity and Access Management
  - **SSM** — AWS Systems Manager
  - **CVE** — Common Vulnerabilities and Exposures
  - **DFS** — Distributed File System
  - **VPC** — Virtual Private Cloud
  - **AMI** — Amazon Machine Image
  - **GPU** — Graphics Processing Unit

---

## Key Comparisons
  - Virtualization vs. Containerization
  - Docker Containers vs. Lambda Functions
  - Monolithic vs. Microservices Architecture
  - ECS vs. EKS
  - ECS EC2 Launch Type vs. Fargate Launch Type
  - Control Plane vs. Data Plane
  - ECS Container Instance Role vs. Task Role vs. Task Execution Role
  - ECS Service Auto Scaling types (Target Tracking, Step, Scheduled)
  - HPA vs. VPA vs. Cluster Autoscaler vs. Karpenter
  - ECR Public vs. Private Repositories
  - AWS App Runner vs. ECS Fargate
  - ECS Anywhere vs. EKS Anywhere

---

## Top Exam Triggers
  - `Serverless containers, no EC2 management` → **ECS + Fargate**
  - `Containers need EBS storage` → **ECS EC2 launch type** (Fargate = EFS only)
  - `Container application needs AWS service access` → **ECS Task IAM Role**
  - `Fargate pull from ECR + write to CloudWatch` → **Task Execution Role**
  - `Multiple containers on same EC2, different logical ports` → **ALB dynamic port mapping**
  - `Scale tasks based on CPU/custom metric` → **ECS Service Auto Scaling (Target Tracking)**
  - `Scale EC2 nodes in ECS cluster automatically` → **ECS Capacity Provider + Managed Scaling**
  - `Kubernetes on AWS` → **Amazon EKS**
  - `Kubernetes — consistent control plane for hybrid/multi-cloud` → **Amazon EKS**
  - `Scale pods horizontally` → **HPA**
  - `Right-size pod CPU/memory` → **VPA**
  - `Fast/flexible Kubernetes node provisioning` → **Karpenter**
  - `Store container images in AWS` → **Amazon ECR**
  - `Auto-expire old/unused container images` → **ECR Lifecycle Policies**
  - `Scan images for vulnerabilities` → **ECR Image Scanning** (or Amazon Inspector for advanced)
  - `Cache Docker Hub images in private registry` → **ECR Pull Through Cache**
  - `Simplest container web app deployment, no infra` → **AWS App Runner**
  - `Run ECS/EKS on-premises with AWS control plane` → **ECS Anywhere / EKS Anywhere**
  - `ECS is simpler; EKS is portable` → **ECS = AWS-native; EKS = Kubernetes standard**

---

## Quick References

### [Docker and Container Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619190#overview)

### [Docker and Container Architecture Patterns Private Link](https://drive.google.com/drive/folders/106brcs2XcuEGJzCHE9I8LE_m1ev314Go?usp=drive_link)

### [Docker and Container Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346110#overview)

### [ECS & EKS Cheat Sheet](https://digitalcloud.training/amazon-ecs-and-eks/)

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
