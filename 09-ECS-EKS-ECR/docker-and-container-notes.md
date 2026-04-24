## Server Virtualization vs Containerization

### What is Virtualization?

- **Virtualization** is the process of creating a virtual copy of something, such as an OS, a server, device, etc.
- It starts with the server layer, the hypervisor layer, and then the virtual machine layer. 
  - The hypervisor is a layer of abstraction that allows multiple processes to share the same host
    - EC2 instances are virtual machines that run on top of a hypervisor layer
- Each virtual machine runs its own OS, which can be different from the host OS with some service running on top of it.
  - e.g., Windows on Linux running a website or application
  - Every VM/Instance needs an OS, which can be resource-intensive and lead to overhead

### What is Containerization?

- **Containerization** is a lightweight alternative to virtualization that allows you to run applications in isolated environments called containers.
- Containers start with the server layer, then the OS layer, then the docker engine layer, and finally the container layer.
- A **container** includes all of the code, settings and dependencies needed to run the application.
  - Containers start very quickly and use less resources than virtual machines 
    - They share the host OS kernel, instead of requring a full OS for each instance
  - Each container is isolated from other containers and the host system
    - But they can still communicate with each other through defined channels (e.g., APIs, network ports)
  
---

## Docker Containers

- **Docker** utilizes containerization to package an application and its dependencies into a single **container image**
- **Docker Hub** is a cloud-based registry service for sharing images and automating workflows
- Containers are lightweight because they share the host OS kernel
- Docker is ideal for **microservices architecture** and building **cloud-native applications**

### Microservices Architecture
  - Applications are structured as a collection of **loosely coupled**, **independently deployable** services, each running its own process.
  - Such as a web application with separate services for user authentication, shopping cart, customer service and payment gateway.
  - **Software as a Service (SaaS)** applications are often built using microservices architecture
    - Allows for rapid development and deployment of new features and services

### Containers and Functions
  - Code runs in Docker containers and Lamda functions for isolation, elasticity and cost-efficiency
  - **Docker containers** are ideal for **long-running** applications
  - **Lambda functions** are ideal for **short-lived**, **event-driven** tasks

### Programmable, API-Based
  - Interservice communication is done through Application Programming Interfaces (APIs)
  - Allows for flexibility and scalability, as services can be developed, deployed and scaled independently
 
---

## Monolithic vs Microservices Architecture

| **Monolithic Architecture** | **Microservices Architecture** |
|-----------------------------|--------------------------------|
| Single codebase for entire application | Multiple independent services |
| Tightly coupled components | Loosely coupled services |
| Difficult to scale and maintain | Easier to scale and maintain |
| Slower development and deployment | Faster development and deployment |
| Single technology stack | Flexible use of technologies |
| Less resilient to failures | More resilient to failures |

---

## Microservices: Attrition and Benefits

| **Attribute** | **Benefit** |
|---------------|-------------|
| Use of APIs   | Easier integration between components; <br> assists with loose coupling |
| Independent deployable blocks of code | Can be scaled and maintained independently; <br> allows for faster development and deployment |
| Business oriented architecture | Deployment organized around business capabilities; <br> teams may be cross-functional and services may be reused |
| Flexible use of technologies | Each microservice can be written using different technologies; <br> allows for the use of best tools for each service |
| Speed and agility | Fast to deploy and update; <br> easy to include high availability and fault tolerance for each microservice |

---

## Amazon Elastic Container Service (ECS)

- Fully managed container orchestration service for running containerized applications
- Supports Docker containers
- Integrates with other AWS services for deployment, scaling, and networking

---

### Launch Types
- **EC2:**
  - You manage the underlying EC2 instances
  - More control over infrastructure
- **Fargate:**
  - Serverless compute for containers
  - AWS manages infrastructure

---

### Core Components

- **Clusters:**
  - Logical group of compute capacity (EC2 instances or Fargate)

- **Task Definitions:**
  - Blueprint for your application
  - Defines:
    - Container images
    - CPU/memory
    - Networking
    - IAM roles

- **Tasks:**
  - A running instance of a task definition
  - Can include one or more containers

- **Services:**
  - Manage long-running tasks
  - Maintain desired number of tasks
  - Support auto scaling and load balancing

---

### Container Images
- Stored in **Amazon Elastic Container Registry (ECR)**
- Fully managed Docker container registry
  - Makes it easy to store, manage and deploy Docker container images

---

## Amazon ECS Key Features

- **Serverless with AWS Fargate:**
  - Managed for you and fully scaleable
- **Fully managed container orchestration:**
  - Control plane is managed for you
- **Docker support:**
  - Run and manage Docker containers 
  - Integration into the **Docker Compose CLI**
- **Windows container support:**
  - ECS Supports Windows containers on EC2 launch type
- **Elastic Load Balancing:**
  - Distribute traffic across containers using ALB or NLB
    - **Application Load Balancer (ALB)** for **HTTP/HTTPS** traffic
    - **Network Load Balancer (NLB)** for **TCP/UDP** traffic
- **Amazon ECS Anywhere:**
  - Enables use of ECS control plane to manage on-premises implementations 

---

## Amazon ECS Components

| **ECS Component** | **Description** |
|---------------|-------------|
| **Cluster**       | **Logical grouping** of compute resources <br> (EC2 instances or Fargate) |
| **Container Instance** | EC2 instance **running** the ECS agent |
| **Task Definition** | **Blueprint** that describes how a **Docker container** should launch |
| **Task**          | A **running container** using settings from a **task definition** |
| **Image**         | A **Docker image** referenced in the **task definition** |
| **Service**       | Defines **long running** tasks; can control task count with auto scaling and load balancing |

---

## ECS Planes

## Control Plane vs Data Plane

| **Control Plane** | **Data Plane** |
|-------------------|----------------|
| Manages cluster state and orchestration | Runs the actual containers |
| AWS manages the control plane | **EC2:** User manages <br> **Fargate:** AWS manages |
| Handles scheduling, API requests, and cluster state | Provides compute and executes workloads |
| Sends instructions to data plane | Executes tasks and reports status |

---

## ECS Agent

- The **ECS agent** is a software component that runs on EC2 instances in an ECS cluster
- **Required for EC2 launch type** (not used with Fargate)

- **Responsibilities:**
  - Registers the instance with the ECS cluster
  - Communicates with the ECS control plane to receive task instructions
  - Manages container lifecycle (start, stop, monitor)
  - Reports task and instance status back to the control plane

- Pre-installed on ECS-optimized AMIs 
  - Can be manually installed on custom AMIs

---

## ECS Images

- Containers are created from read-only **images** that contains instructions for creating a Docker container
- Images are built from a **Dockerfile** that defines the steps to create the image
- Only Docker images can be used in ECS
- Images are stored in **Amazon ECR** or other Docker registries (e.g., Docker Hub)
- ECR supports both **public** and **private** repositories for storing container images
  - Uses resource-based permissions using IAM to control access to repositories and images
- You Can use the **Docker CLI** to push and pull images to and from ECR
  - `docker push` to upload an image to ECR
  - `docker pull` to download an image from ECR

---

## ECS Tasks and Task Definitions

- A **task definition** is required to run a task in ECS
- A task definition is a JSON file that describes one or more containers, up to a maximum of ten
- It specifies:
  - Container images
  - CPU and memory requirements
  - Networking settings
  - IAM roles
- Task definitions use Docker images to launch containers

---

## ECS Launch Types: EC2 vs Fargate

| **EC2 Launch Type** | **Fargate Launch Type** |
|---------------------|-------------------------|
| You provision and manage EC2 instances | Serverless compute (no infrastructure management) |
| Responsible for patching, scaling, and capacity planning | AWS manages compute and scaling |
| Charged per running EC2 instance | Charged per task (CPU + memory) |
| Supports EBS, EFS and FSx (via EC2) | Supports EFS only |
| Requires cluster capacity management | No capacity management required |
| More granular control over infrastructure | Limited control over infrastructure |
| Manual or Auto Scaling Groups for scaling | Automatic scaling at task level |
| Best for long-running workloads, custom configs | Best for event-driven, burst, or simplified workloads |

---

## ECS and IAM Integration

- The **container instance IAM role** provides permissions for the host EC2 instance
- The **ECS task IAM role** provides permissions to the container(s) running in the task
- **Note:** With the **Fargate launch type** the **container instance role** → **Task execution role**

---

## Auto Scaling in ECS

### Two types of scaling:

1. **Service Auto Scaling:**
  - Automatically scales the number of tasks in a service based on demand
  - Can use target tracking, step scaling, or scheduled scaling policies
  - Uses Application Auto Scaling service to manage scaling policies for ECS services

2. **Cluster Auto Scaling:**
  - Uses a **capacity provider** to scale the number of EC2 instances in a cluster
  - Uses EC2 Auto Scaling groups to add or remove instances based on resource utilization
  - EC2 launch type only (not Fargate) 

---

## Service Auto Scaling Types

1. **Target Tracking Scaling:**
  - Adjusts the number of tasks that your service runs based on a target value for a specific CloudWatch metric 
    - e.g., CPU utilization

2. **Step Scaling:**
  - Adjusts the number of tasks in a service based on CloudWatch alarms, the adjustment is based on the size of the alarm breach 
    - e.g., add 2 tasks if CPU > 80%

3. **Scheduled Scaling:**
  - Adjusts the number of tasks in a service based on a schedule 
    - e.g., add 5 tasks at 8 AM every day

4. **Cluster Auto Scaling:**
  - Automatically adjusts the number of EC2 instances in your cluster based on resource needs
  - Uses **capacity providers** and **Auto Scaling groups** to manage scaling of EC2 instances
    - Capacity provider is an **ECS resource** that is associated with an **Auto Scaling group (ASG)**

### An ASG can automatically scale using:
  - **Managed Scaling:**
    - Automatically adjusts ASG size based on task demand vs available capacity
      - Handled by scaling policies in your ASG

  - **Managed Instance Termination Protection:**
    - Prevents instances running tasks from being terminated during scale-in 
      - Called "container awarness"

---

## ALB with ECS

- A **dynamic port** is allocated on the host EC2 instance for each task, allowing multiple tasks to run on the same instance without port conflicts
- Each task is running a web servie on port 80, but the host port is dynamically assigned (e.g., 32768)
- Container awareness allows the ALB to route traffic to the correct host port for each task, even as tasks are added or removed

---

## Amazon EKS (Elastic Kubernetes Service)

- Fully managed Kubernetes service for running containerized applications
  - **Kubernetes** is an open-source system for automating deployment, scaling and management of containerized applications
- Use when you need to **standardize** container orchestration across **multiple environments** using a **managed Kubernetes service**

### Some Key Features
  - **Hybrid Deployment:**
    - Manage Kubernetes clusters and applications across hybrid environments (AWS + on-premises)

  - **Batch Processing:**
    - Run sequential or parallel batch workloads on your EKS cluster using the Kubernetes Job API
    - Plan, schedule and execute batch workloads with Kubernetes-native tools

  - **Machine Learning:**
    - Use **Kubeflow** with EKS to model your ML workflows
    - Efficiently run distributed training jobs using the latest EC2 GPU instances 
      - e.g., Inferentia and Trainium

  - **Web Applications:**
    - Build web apps that auto scale based on demand using EKS and ALB
    - Run on a highly available and secure Kubernetes control plane across multiple AZs

---

## EKS Load Balancing

  - **Load Balancing:**
    - Use ALB or NLBto distribute traffic to your EKS workloads
    - ALB for HTTP/HTTPS traffic, NLB for TCP/UDP traffic
    - Traditionally, NLB was used for instance targets and ALB for IP targets
      - Now, both ALB and NLB support both instance and IP targets for EKS workloads

  - **AWS Load Balancer Controller:**
    - Manages **AWS Elastic Load Balancers** for Kubernetes clusters
    - Install AWS Load Balancer Controller using Helm V3 or later by applying Kubernetes manifests
    - The controller provisions the following AWS resources:
      - An **AWS Application Load Balancer (ALB)** when you create a Kubernetes **Ingress resource**
      - An **AWS Network Load Balancer (NLB)** when you create a Kubernetes Service of type `LoadBalancer`
  
---

## EKS Auto Scaling

  - **Pods** are the smallest deployable units in Kubernetes
    - They are groups of one or more containers that share storage and network resources

### Workload Auto Scaling:
  - **Vertical Pod Autoscaler (VPA):**
    - Automatically adjusts CPU and memory reservations for your pods to "right-size" apps
  
  - **Horizontal Pod Autoscaler (HPA):**
    - Automatically scales the number of pods in a deployment, replication controller or replica set based on observed CPU utilization or other select metrics

  - **Cluster Autoscaling:**
    - **Kubernetes Cluster Autoscaler** automatically adjusts the number of nodes in your cluster based on the resource needs of your workloads
      - Uses **AWS Auto Scaling groups** 
    
    - **Karpenter** is an open-source cluster autoscaler built by AWS that provides more flexible and efficient scaling for EKS clusters
      - Works directly with **Amazon EC2 Fleet**

---

## Amazon EKS Distro

- Is a distribution of Kubernetes with the same dependencies as Amazon EKS
- Allows you to manually run Kubernetes clusters anywhere
- Includes binaries and container of open-source Kubernetes, etcd, networking and storage plugins, tested for compatibility
- Can be securely accessed as open-source software from GitHub or within S3 and ECR 
- Alleviates the need to track updates, determine compatibility and standardize on a common Kubernetes version across distributed teams and environments
- You can create your own EKS Distro clusters in AWS on EC2 and on your own on-prem hardware

---

## ECS and EKS Anywhere

- **Amazon ECS Anywhere** and **Amazon EKS Anywhere** allow you to run containerized applications on-premises using the same control plane as in AWS
- You can also deploy ECS/EKS Anywhere using VMware vSphere, bare metal servers or other Kubernetes distributions (for EKS Anywhere)

---

## Amazon ECR (Elastic Container Registry)

- Fully managed Docker container registry 
- Makes it easy to store, manage and deploy Docker container images
- Integrates with Amazon ECS and EKS for seamless container deployment
- Supports **Open Container Initiative (OCI)** images and **Docker Registry HTTP API V2** standards
- You can use the Docker tools and **Docker CLI** to push and pull images to and from ECR
  - Such as `push`, `pull`, `build`, `list`, and `tag` 
- Can be accessed from any Docker environment:
  - In the cloud
  - On-premises
  - Local machines
- Container images stored in S3
- You can use namespaces to organize your repositories and images
- Public and private repositories available

### Access Control

  - **IAM access control:**
    - Set policies to define access to container images in private repositories
  
  - **Resource-based policies:**
    - Access control done to the individual API actions
      - Such as `create`, `list`, `describe`, `delete` and `get`

  - Users must have IAM permissions to push an image to a **private repository**
  - Anyone can pull an image from a **public repository** without authentication

---

## ECR Components

| **ECR Component** | **Description** |
|-------------------|-----------------|
| **Registry**      | Account-level container image registry (contains repositories) |
| **Repository**    | Contains container images (Docker/OCI) |
| **Image**         | A versioned container (tagged or identified by a digest) |
| **Tag**           | A human-readable identifier for an image (e.g., `latest`, `v1.0`) |
| **Digest**        | A unique identifier for an image based on its content (e.g., `sha256:abc123`) |
| **Auth Token**    | Temporary credentials to push/pull images |
| **Repository Policy** | Controls access to a repository using resource-based policies |

---

## ECR Features

- **Lifecycle Policies:**
  - Manage the lifecycle of images in a repository by defining rules
  - Automatically expire unused or old images to save storage costs

- **Image Scanning:**
  - Identify software vulnerabilities in your container images 
  - Basic scanning included with ECR (free)
  - Advanced scanning available with Amazon Inspector for ECR (additional cost)

- **Cross-Region Replication:**
  - Replicate images across multiple AWS regions and accounts
  - Ensure high availability and disaster recovery for your container images

- **Pull Through Cache:**
  - Cache repos in remote public registries in your private registry 
  - Improves performance and reliability when pulling images from public registries

## AWS App Runner

- Fully managed service for running containerized web applications and APIs at scale
- Provides a simple way to deploy and run containerized applications without managing infrastructure
- Supports both source code and container image deployments
- Automatically scales applications based on traffic and resource needs
- Integrates with AWS services for monitoring, logging and security
- Health checks, networking, and load balancing are built in
- **PaaS (Platform as a Service)** offering for containerized applications
  - Requires only your code or container image
  - App Runner handles the rest (build, deploy, scale, manage)

---

## Quick References

### [Docker and Container Storage Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28619190#overview)

### [Docker and Container Architecture Patterns Private Link](https://drive.google.com/drive/folders/106brcs2XcuEGJzCHE9I8LE_m1ev314Go?usp=drive_link)

### [Docker and Container Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346110#overview)

### [ECS & EKS Cheat Sheet](https://digitalcloud.training/amazon-ecs-and-eks/)