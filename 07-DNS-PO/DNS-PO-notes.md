## DNS (Domain Name System)

**Domain Name System (DNS):**
  - Is a hierarchical and decentralized naming system for computers, services and resources
  - Translates human-readable domain names (like `www.google.com.`) into IP addresses 
    - `.` represents the **root domain** of the DNS hierarchy
      - The root domain is not usually visible in DNS name
      - Implied to be at the end of the domain name
    - `com` is a top-level domain (**TLD**)
    - `google` is a subdomain (**SLD**)
      - `support` and `mail` are also subdomains of `google`
    - `www` is a **hostname** within `google` subdomain

---

## DNS Zones and Records

| Record Type | Description | Example |
|-------------|-------------|---------|
| A           | Maps a domain name to an **IPv4 address** | e.g., `www.example.com` to `52.23.21.43` |
| AAAA        | Maps a domain name to an **IPv6 address** | e.g., `www.example.com` to `2001:0db8:85a3:0000:0000:8a2e:0370:7334` |
| CNAME       | Maps a domain name to another domain name (alias) | e.g., `www.example.com` to `example.com` |
| MX          | Specifies **mail servers** for a domain | e.g., `example.com` to `mail.example.com` |
| NS            | Specifies **authoritative name servers** for a domain | e.g., `example.com` to `ns1.example.com` |
| TXT           | Stores **text information** for a domain (e.g., SPF records) | e.g., `example.com` to `v=spf1 include:_spf.google.com ~all` |
| SRV           | Specifies **services** available for a domain | e.g., `_sip._tcp.example.com` to `sipserver.example.com:5060` |
| SOA           | **Start of Authority** record, contains administrative information about the zone | e.g., `example.com` to `ns1.example.com` (primary name server) |
| ALIAS         | Maps a domain name to an AWS resource (e.g., CloudFront, ELB) | e.g., `www.example.com` to `d1234567890.cloudfront.net` |
| PTR           | Maps an IP address to a domain name (reverse DNS) | e.g., `52.23.21.43` to `www.example.com` |

**And many more...**

Full list of DNS record types can be found in the [IANA DNS Parameters](https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-4).

---

## AWS Route 53

**Amazon Route 53:**
  - Is a scalable and highly available **Domain Name System (DNS)** web service
  - Provides domain registration, DNS and traffic routing, and health checking of resources
  - Allows you to manage your domain names and route traffic to your resources in or out of AWS
  - Supports various routing policies (covered below in the next section)

---

## Route 53 Routing Policies

| Routing Policy | What it does | Use Case |
|----------------|--------------|----------|
| Simple | Routes traffic to a resource associated with the name | Basic routing for a single endpoint |
| Failover | If primary is down (health check fails), route to secondary | High availability and disaster recovery |
| Geolocation | Routes traffic based on the geographic location of the user | Deliver localized content or comply with regulations |
| Geoproximity | Routes traffic based on the geographic location of resources and users, with optional bias | Optimize latency by routing to the closest resource |
| Latency | Routes traffic to the resource with the lowest latency for the user | Improve performance by routing to the fastest endpoint |
| Multivalue Answer | Returns several IP addresses and functions like a basic load balancer | Load balancing and high availability |
| Weighted | Routes traffic based on assigned weights to resources | Distribute traffic across multiple resources based on weight |
| IP-based | Routes traffic based on the IP address of the user | Restrict access or route based on user IP |

---

## DNS Routing Policies in Detail

### Simple Routing Policy
- Routes traffic to a single resource associated with the name
- Example: `www.example.com` routes to a single IP address or endpoint

### Weighted Routing Policy
- Routes traffic to multiple resources based on assigned weights
  - Weights are relative and range from 0 to 255
  - Higher weight means more traffic will be routed to that resource
  - Health checks are optional 
- Example: `www.example.com` routes 70% of traffic to `resource1` and 30% to `resource2`

### Latency Routing Policy
- Routes traffic to the resource with the lowest latency for the user
- Example: users in US → `us-east-1` and users in Europe → `eu-west-1`

### Failover Routing Policy
- If primary resource is unhealthy (health check fails), route to secondary resource
- Example: `www.example.com` routes to `primary-resource` and if it fails, routes to `secondary-resource`

### Geolocation Routing Policy
- Routes traffic based on the geographic location of the user
- Example: users in North America → `na.example.com` and users in Asia → `asia.example.com`

### Geoproximity Routing Policy
- Routes traffic based on the geographic location of resources and users, with optional bias
- Uses traffic flow to route traffic to the closest resource, requires a policy
- Example: users in US → `us-east-1` and users in Europe → `eu-west-1`, with bias to route more traffic to `us-east-1`

### Multivalue Answer Routing Policy
- Returns several IP addresses and functions like a basic load balancer
- Health checks are optional, but if enabled, only healthy endpoints will be returned
- Example: `www.example.com` returns multiple IP addresses for load balancing and high availability

### IP-based Routing Policy
- Routes traffic based on the IP address and CIDR blocks of the user
- Create routing rules that allow or block traffic from specific IP addresses or ranges
- Example: `www.example.com.us` allows traffic from `US-CIDR` and blocks traffic from `EU-CIDR`

---

## Route 53 Resolver

**Route 53 Resolver:**
  - Is a DNS service that provides recursive DNS resolution for VPCs
  - Allows you to forward DNS queries between your VPC and your network 
    - On-premises or another VPC
  - Supports both inbound and outbound DNS queries
  - Provides features like conditional forwarding, rules, and logging

- **Outbound Endpoints:**
  - Allow you to forward DNS queries from your VPC to your network
  - Example: Forward queries for `example.com` to an on-premises DNS server

- **Inbound Endpoints:**
  - Allow you to forward DNS queries from your network to your VPC  
  - Example: Forward queries for `internal.example.com` to a DNS server in your VPC

---

## Cloudfront and Edge Locations

**Amazon CloudFront:**
  - Is a content delivery network (CDN) service
  - Distributes content globally with low latency and high transfer speeds
  - Uses a network of edge locations around the world to cache and deliver content

**Edge Locations:**
  - Are data centers located in major cities around the world
  - Serve cached content to users based on their geographic location
  - Help reduce latency and improve performance for end-users
  - Is a Point of Presence (PoP) that serves content to users from the nearest location

---

## Origin and Distribution in CloudFront

**Origin:**
  - Is the source of the content that CloudFront delivers
  - Can be an S3 bucket, an HTTP server, an Elastic Load Balancer, or an AWS MediaStore container
  - Example: An S3 bucket containing images or a web server hosting a website

**Distribution:**
  - Is a collection of edge locations that deliver content from the origin
  - Can be either a web distribution (for websites) or an RTMP distribution (for streaming media, discontinued)
    - `.html`, `.css` `.php` and graphics files are examples of web distributions
    - Distribute media via HTTP or HTTPS
    - Add, update or delete objects and submit data from web forms
    - Use live streaming for media content in real time
  - Example: A web distribution that delivers a website to users around the world

---

## CloudFront Caching and TTL

**Caching:**
  - CloudFront caches content at edge locations to reduce latency and improve performance
  - Object is cached for TTL (Time to Live) duration, which is configurable (default is 24 hours)
    - If TTL expires, the file is removed from the cache and must be fetched from the origin again
  - Decreasing TTL can improve performance but may increase load on the origin server
    - Best for dynamic content that changes frequently
    - Removing content can be done but it does incur additional costs
  - TTL is defined at behavior level and can be overridden by cache-control headers from the origin
    - `Cache-Control: max-age=seconds` sets the TTL for the object in seconds
    - `Cache-Control: no-cache` forces CloudFront to revalidate the object with the origin
    - `Cache-Control: no-store` prevents CloudFront from caching the object at all
  - If the content is not in the cache, the request gets a cache miss and CloudFront retrieves the content from the origin, caches it, and serves it to the user

---

## Global Network of CloudFront

- There are 13-15 dedicated **Regional Edge Caches** that sit between the origin and the edge locations to further improve performance by caching content closer to the users
  - 400+ edge locations globally to serve content to users with low latency

---

## Path Patterns and Behaviors in CloudFront

**Path Patterns:**
  - Define how CloudFront routes requests to different origins based on the URL path
  - Must define a default path pattern (`*`) that matches all requests and routes to a default origin
  - Example: 
    - `www.example.com/images/*` routes to an S3 bucket for images
    - `www.example.com/api/*` routes to an API Gateway or Elastic Load Balancer for API requests

**Behaviors:**
  - Define how CloudFront processes requests for specific path patterns
  - Can specify settings such as allowed HTTP methods, caching behavior, and viewer protocol policy
  - Example:
    - For `www.example.com/images/*`, allow only GET and HEAD methods, cache for 24 hours, and redirect HTTP to HTTPS
    - For `www.example.com/api/*`, allow all HTTP methods, do not cache, and require HTTPS

---

## Signed URLs

- **Signed URLs:**
  - Provide more control over access to content
  - Can specify a beginning and expiration time for the URL, restrict IP addresses, and require HTTPS

- **Signed Cookies:**
  - Allow you to control access to multiple files (e.g., all files in a directory) with a single cookie
  - Useful for streaming media or when you want to restrict access to multiple resources without generating individual signed URLs for each resource

- Both signed URLs and signed cookies require a CloudFront key pair to sign the requests
- **Examples:**
  - A signed URL for `www.example.com/protected/content.mp4` that expires in 1 hour and is only accessible from a specific IP address
  - A signed cookie that allows access to all content under `www.example.com/protected/*` for users with the cookie set

---

## CloudFront Origin Access Identity (OAI)

- **Origin Access Identity (OAI):**
  - Is a special CloudFront user that you can associate with your distribution to restrict access to your S3 bucket
  - Allows CloudFront to access the S3 bucket on behalf of the users, while preventing direct access to the bucket from the internet
  - **Principal is the OAI user** `arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity <OAI-ID>` in the S3 bucket policy
  - To use OAI, you need to:
    1. Create an OAI in CloudFront
    2. Update the S3 bucket policy to allow access to the OAI and deny access to everyone else
    3. Associate the OAI with your CloudFront distribution
  - Does not affect EC2 instances or other origins, only S3 buckets

- Has been replaced by **CloudFront Origin Access Control (OAC)**, which provides more granular control over access to S3 buckets and supports additional features like signed URLs and signed cookies for S3 origins

---

## CloudFront Origin Access Control (OAC)

- **Origin Access Control (OAC):**
  - Is a more secure and flexible way to restrict access to your S3 bucket from CloudFront
  - Provides more granular control over access to S3 buckets, allowing you to specify which CloudFront distributions can access the bucket and under what conditions
  - Supports additional features like signed URLs and signed cookies for S3 origins, which were not supported with OAI
  - **Principal is AWS Service `cloudfront.amazonaws.com`** in the S3 bucket policy
  - To use OAC, you need to:
    1. Create an OAC in CloudFront
    2. Update the S3 bucket policy to allow access to the OAC and deny access to everyone else
    3. Associate the OAC with your CloudFront distribution

---

## CloudFront and SSL/TLS

- Issued by AWS Certificate Manager (ACM) or imported from an external certificate authority
- Default CF domain name can be changed using CNAME (alternate domain name)
- S3 has it's own SSL certificates and can't be changed
- Custom Origin can be ACM (ALB) or third party (EC2)
- **Origin certificates** must be **public certificates**

---

## CloudFront and Server Name Indication (SNI)

- **Server Name Indication (SNI):**
  - Is an extension to the TLS protocol that allows a client to indicate which hostname it is trying to connect to at the start of the handshake process
  - CloudFront supports both SNI and dedicated IP SSL for custom SSL certificates
  - SNI is more cost-effective as it allows multiple SSL certificates to be served from the same IP address, while dedicated IP SSL requires a unique IP address for each certificate
  - SNI is supported by most modern browsers and clients, but some older clients may not support it, in which case you may need to use dedicated IP SSL
    - 2010 and later versions of major browsers support SNI, while older versions may not

---

## Lamda@Edge

- Run Node.js or Python Lambda functions to customize the content that CloudFront delivers
- Executes functions closer to the user, improving performance and reducing latency
- Can be run at the following points:
  - **After** CloudFront **receives a request** from a **viewer** (**viewer request**)
  - **Before** CloudFront **forwards the request** to the **origin** (**origin request**)
  - **After** CloudFront **receives the response** from the **origin** (**origin response**)
  - **Before** CloudFront **forwards the response** to the **viewer** (**viewer response**)

---

## AWS Global Accelerator

- Is a service that improves the availability and performance of your applications with global users
- Uses the AWS global network to route traffic to the optimal endpoint based on health, geography, and policies that you define
- Provides static IP addresses that act as a fixed entry point to your application, improving availability and performance
- Supports both TCP and UDP traffic, making it suitable for a wide range of applications, including web applications, gaming, IoT, and more
- Can be used in conjunction with CloudFront for content delivery and AWS Global Accelerator for application acceleration

---

## Quick Reference

### [Route 53 & DNS Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28618842#overview)

### [Route 53 & DNS Architecture Patterns Private Link](https://drive.google.com/drive/folders/1L62jhN4o_I92Ti3KwZy49hBbvXWxvKqP?usp=drive_link)

### [Route 53 & DNS Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346106#overview)

### [Route 53 Cheat Sheet](https://digitalcloud.training/amazon-route-53/)
### [CloudFront Cheat Sheet](https://digitalcloud.training/amazon-cloudfront/)
### [Global Accelerator Cheat Sheet](https://digitalcloud.training/aws-global-accelerator/)

---