## Stateless vs Stateful

- **Stateless** — no stored session state; each request is independent  
  - No reliance on previous requests  
  - Examples: web servers, REST APIs, microservices  

- **Stateful** — maintains session or application state across requests  
  - Requests may depend on previous interactions  
  - Examples: databases, file systems, applications with session data (e.g., shopping carts)  
  - State is commonly managed using cookies, sessions, or tokens  

---

## Scaling Up vs Scaling Out

- **Scaling Up (Vertical Scaling)** — increasing resources of a single instance (CPU, RAM, storage)  
  - Limited by hardware capacity  
  - Can improve performance but reduces flexibility  

- **Scaling Out (Horizontal Scaling)** — adding more instances to distribute load  
  - Improves fault tolerance and availability  
  - More flexible and typically more cost-effective  
  - Enables use of Auto Scaling Groups (ASGs)  

**Rule of Thumb:**  
Stateless applications are easier to scale horizontally, while stateful applications traditionally rely more on vertical scaling. Modern architectures, however, often enable horizontal scaling for both depending on design.

---

## Key Takeaways

- Scaling out → high availability and fault tolerance  
- Scaling up → increased performance per instance  

---

## EC2 Auto Scaling Groups (ASGs)

ASGs automatically adjust the number of EC2 instances based on demand.

### Key Features

- Automatically launches and terminates instances  
  - Enables horizontal scaling (scale out/in)  

- Maintains desired capacity and availability  
  - Provides elasticity and resilience  

- Scales dynamically based on metrics  
  - e.g., CPU utilization, network traffic (via CloudWatch)  

- Integrates with multiple AWS services  
  - EC2, ECS, EKS  

---

## Common AWS Integrations

- **CloudWatch** → monitoring and scaling triggers  
- **Elastic Load Balancer (ELB)** → traffic distribution  
- **EC2 Spot Instances** → cost optimization  
- **VPC** → multi-AZ deployments  

---

## Launch Options

- **Launch Templates** — recommended modern approach  
  - Define AMI, instance type, networking, security groups, etc.  

- **Launch Configurations** — legacy  
  - Limited functionality and cannot be updated  
  - Replaced by Launch Templates  

---

## Health Checks

- **EC2 Health Checks** — instance-level status checks  
- **ELB Health Checks** — application-level health (more comprehensive)  

- **Health Check Grace Period**  
  - Time allowed for a new instance to initialize before health checks begin  
  - Prevents premature replacement of instances  

---

## Types of Auto Scaling

- **Manual Scaling** — manually adjust capacity
- **Dynamic Scaling** — automatically adjust based on demand
- **Predictive Scaling** — uses ML to predict future demand
- **Scheduled Scaling** — scale based on a schedule 

---

## HOL Lab Notes - User Data Web Server

- `yum` is used for Amazon Linux 2 but doesn't work for Amazon Linux 2023
- `dnf` is the package manager for Amazon Linux 2023
    - Scripts using both package managers are provided for compatibility with both versions of Amazon Linux.

- Ensure browser is HTTP enabled, HTTPS support requires additional configuration
    1. Apache listening on 443
    2. A TLS certificate + private key
    3. Security group rule allowing 443 

**Note:** most browsers automatically redirect HTTP to HTTPS meaning these scripts will fail to load on HTTPS if not manually adjusted. This is a common issue when using self-signed certificates or when the server is not configured for HTTPS.

Pictured below is what the `Activity History` of an ASG looks like when scaling out and in based on CloudWatch metrics. In this example, manual termination led to a scale out event as the ASG replaced the terminated instance.

![Auto Scaling](../assets/HOL-labs/web-server-auto-scaling.png)

---

## High Availability vs Fault Tolerance

| High Availability | Fault Tolerance |
|:---:|:---:|
| Minimizes downtime | Near-zero downtime |
| Redundant components (failover-based) | Fully redundant components (active-active) |
| Usually asynchronous replication | Synchronous replication required |
| Recovery required (seconds to minutes) | No recovery needed |
| Possible small data loss (RPO > 0) | No data loss (RPO = 0) |
| Lower cost | Higher cost |
| Active-passive (failover) | Active-active |
| Example: Multi-AZ (RDS, ELB) | Example: Multi-region active-active |

---

## Note on Availability Zones (AZs)

Think of an AZ as a single data center.

If that data center goes down, all resources in that AZ are unavailable. 

By deploying across multiple AZs, you can achieve high availability and fault tolerance, ensuring your application remains accessible even if one AZ experiences issues.

---

## Durability vs Availability

| Durability | Availability |
|---|---|
| Protection against: | Measurement of: |
| • Data loss | • Uptime |
| • Data corruption | • % of time / year |
| • S3 offers 11 9's durability | • RDS Multi-AZ has 99.99% uptime |

- If you store 10 million objects in S3, you can expect to lose one object every 10,000 years on average 

---

## Elastic Load Balancing (ELB)

**ELB** automatically distributes incoming application traffic across multiple targets.

**Targets include:**
    - EC2 instances
    - ECS containers
    - IP addresses
    - Lambda functions
    - Other Load Balancers