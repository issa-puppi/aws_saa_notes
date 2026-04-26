# DNS & Name Resolution
---

## Domain Name System (DNS)

The **Domain Name System (DNS)** is a hierarchical and decentralized naming system that translates human-readable domain names into IP addresses computers can use. (e.g., `www.example.com` → `192.0.2.1`)

### DNS Hierarchy

Every fully qualified domain name (**FQDN**) is read right-to-left through the hierarchy:

```
www.example.com.
│   │       │  └── root domain (.) — implied at the end; not usually shown
│   │       └───── top-level domain (TLD) — e.g., com, org, net, gov
│   └───────────── second-level domain (SLD) — e.g., example, amazon, google
└───────────────── hostname — e.g., www, api, mail
```

  - **Root (`.`)** — the top of the hierarchy; managed by IANA's root servers
  - **TLD** — managed by registries (e.g., Verisign for `.com`)
  - **SLD** — the domain you register (e.g., `example.com`)
  - **Subdomain** — any label to the left of the SLD (e.g., `support.example.com`, `mail.example.com`)
  - **Hostname** — the specific host within a domain (e.g., `www`)

### DNS Record Types

| **Record** | **Purpose** | **Example** |
|------------|-------------|-------------|
| A | Maps a domain to an **IPv4 address** | `example.com → 52.23.21.43` |
| AAAA | Maps a domain to an **IPv6 address** | `example.com → 2001:db8::1` |
| CNAME | Canonical name — maps one domain name to another (alias) | `www.example.com → example.com` |
| MX | Specifies **mail servers** for a domain | `example.com → mail.example.com` |
| NS | Specifies **authoritative name servers** for a zone | `example.com → ns1.example.com` |
| TXT | Stores **text** (e.g., SPF, DKIM, domain verification) | `v=spf1 include:_spf.google.com ~all` |
| SRV | Specifies **services** available for a domain | `_sip._tcp.example.com → sipserver.example.com:5060` |
| SOA | **Start of Authority** — administrative info about the zone | primary name server, admin email, serial |
| PTR | **Reverse DNS** — maps an IP to a domain name | `52.23.21.43 → example.com` |
| CAA | **Certification Authority Authorization** — restricts which CAs can issue certs for the domain | `example.com 0 issue "letsencrypt.org"` |
| ALIAS | AWS-specific virtual record — maps a domain to an AWS resource | `example.com → d1234.cloudfront.net` |

> ⚠️ **Exam Traps:**
> <br>**CNAME cannot be used at the zone apex** (root domain, e.g., `example.com`) — use an **Alias** record instead.
> <br>**Alias** records are Route 53-specific; they do not incur query charges when pointing to AWS resources.

---

# DNS Services
---

## Amazon Route 53

Amazon Route 53 is a highly available and scalable **Domain Name System (DNS)** web service.
<br>It provides three core functions: **domain registration**, **DNS routing**, and **health checking**.

### Key Properties
  - **Global service** ◊ — not regional; hosted zones are replicated across Route 53's worldwide distributed infrastructure
  - **100% uptime SLA** — the only AWS service with a 100% availability SLA
  - Located alongside all **edge locations**; uses UDP port 53 (TCP as fallback)
  - Supports domain registration for supported Top-Level Domains (TLDs) †
  - IAM can be used to control management access to hosted zones
  - Default limit of **50 domain names** † per account (can be increased via support)

---

## Hosted Zones

A **hosted zone** is a container for DNS records for a specific domain — analogous to a traditional DNS zone file.
<br>Route 53 automatically creates **NS** and **SOA** records for every hosted zone.
<br>Each hosted zone receives a set of **4 unique name servers** (a delegation set).

| **Zone Type** | **Purpose** | **Key Properties** |
|---------------|-------------|--------------------|
| **Public hosted zone** | Routes traffic over the internet | Used for publicly accessible domains |
| **Private hosted zone** | Routes traffic within one or more VPCs | Resources not accessible outside the VPC; requires `enableDnsHostnames` and `enableDnsSupport` set to `true` in VPC settings |

  - You can create **multiple hosted zones with the same name** (different records)
  - A private hosted zone in Account A can be associated with a VPC in Account B via CLI (CLI-only; requires authorization then association then deletion of the authorization)
  - You **cannot automatically register EC2 instances** with private hosted zones — must be scripted
  - **You cannot extend Route 53 to on-premises instances** — only the reverse (on-premises → VPC) is possible via Resolver

> 💡 **Exam Tip:** For a private hosted zone to resolve inside a VPC, the VPC must have **both** `enableDnsHostnames` and `enableDnsSupport` set to `true`.

---

## CNAME vs Alias Records

| **CNAME Records** | **Alias Records** |
|-------------------|-------------------|
| Route 53 charges for CNAME queries ¤ | No charge for alias queries to AWS resources ¤ |
| Cannot be created at the zone apex | Can be created at the zone apex |
| Can point to any DNS record anywhere | Can only point to: CloudFront, ELB, Elastic Beanstalk, S3 static website, API Gateway, VPC interface endpoint, or another record in the same hosted zone |
| Visible in DNS query responses | Only visible in Route 53 console/API |
| Followed by recursive resolvers | Followed only inside Route 53 |
| TTL is configurable | TTL is managed by the target service (cannot be set manually) |

> 💡 **Exam Tip:** Whenever a question involves mapping a **root domain** (e.g., `example.com`) to an AWS resource like an ELB or CloudFront distribution, the answer is always **Alias record**, not CNAME.

---

## Route 53 Routing Policies

Routing policies determine how Route 53 responds to DNS queries.

| **Policy** | **What It Does** | **Health Checks?** | **Key Use Case** |
|------------|------------------|--------------------|-----------------|
| **Simple** | Returns one or more IP addresses; uses round-robin | ✗ No | Single resource, basic routing |
| **Failover** | Routes to secondary if primary health check fails | ✓ Required | Active-passive high availability / DR |
| **Geolocation** | Routes based on the **user's** geographic location | Optional | Localized content, regulatory compliance |
| **Geoproximity** | Routes based on geographic location of **resources and users**, with adjustable bias | Optional | Shift traffic between regions; requires Traffic Flow |
| **Latency** | Routes to the AWS region with the **lowest latency** for the user | Optional | Performance optimization across regions |
| **Multivalue Answer** | Returns up to **8 healthy records** at random | Optional | Lightweight load distribution (not a replacement for ELB) |
| **Weighted** | Routes proportionally based on **relative weights** (0–255) | Optional | Blue/green deployments, canary testing, gradual migrations |
| **IP-based** | Routes based on the **client's IP address / CIDR block** | Optional | ISP-based routing, on-premises IP routing |

### Routing Policy Details

**Simple**
  - Associated with one or more IP addresses; uses round-robin when multiple values exist
  - **Does not support health checks** — the only policy that cannot use them §

**Failover**
  - Active-passive pattern: primary → secondary when primary health check fails
  - When used with Alias records, set **Evaluate Target Health** to `Yes` (do not add a separate health check)

**Geolocation**
  - Routes based on **where the user is** — not necessarily the closest resource
  - If multiple records cover overlapping regions, Route 53 routes to the **smallest geographic region**
  - Create a **default record** for users whose IP does not map to any geographic region (otherwise they get no answer)
  - Use cases: localized content, language-specific sites, content rights management

**Geoproximity**
  - Routes based on location of **both resource and user**, with optional **bias** to shift more/less traffic to a resource
  - **Requires Traffic Flow** — cannot be configured without it
  - Bias values: positive (expand the region, attract more traffic), negative (shrink the region, send less traffic)

**Latency**
  - AWS maintains a latency database; routes to the region with the **lowest measured latency**
  - You create latency records for each region where your resources exist

**Multivalue Answer**
  - Returns up to **8 healthy records** selected at random
  - If health checks are enabled, only healthy endpoints are returned
  - Provides basic client-side load distribution — not a substitute for Elastic Load Balancing

**Weighted**
  - Assign weights 0–255 to records with the same name and type
  - Traffic % ≈ (record weight / total weight of all records)
  - Weight = 0 → stop sending traffic to that resource (useful for draining)

**IP-based**
  - Define CIDR blocks → endpoint mappings; Route 53 routes based on the originating IP
  - Use case: route traffic from known corporate CIDRs or ISP address ranges to specific endpoints

> 💡 **Exam Tips:**
> <br>"Active-passive failover" → **Failover routing policy**
> <br>"Route based on user's country or continent" → **Geolocation**
> <br>"Shift traffic proportionally / blue-green / canary" → **Weighted**
> <br>"Lowest latency AWS region" → **Latency**
> <br>"Basic multi-IP with health checks, no ELB" → **Multivalue Answer**

---

## Route 53 Health Checks

Health checks verify that internet-connected resources are reachable, available, and functional.
<br>Health checks can be pointed at: **endpoints** (IP or domain), **other health checks** (calculated), or **CloudWatch alarms**.

### Health Check Types
  - **HTTP / HTTPS** — establishes TCP connection, submits request, checks for HTTP 2xx/3xx response
  - **HTTP_STR_MATCH / HTTPS_STR_MATCH** — additionally searches first 5,120 bytes of response body for a string
  - **TCP** — verifies TCP connection can be established
  - **CALCULATED** — aggregates results of multiple child health checks using a threshold (HealthThreshold)
  - **CLOUDWATCH_METRIC** — ties health to the state of a CloudWatch alarm (OK = healthy, ALARM = unhealthy)

> 💡 **Exam Tip:** Health checks are **required** for Failover routing and **recommended** for Multivalue Answer. Simple routing **does not support** health checks.

---

## Route 53 Traffic Flow

**Traffic Flow** is Route 53's visual policy editor for building complex, multi-condition routing configurations.

  - Provides **Global Traffic Management (GTM)** capabilities
  - Build routing policies combining: geolocation, geoproximity, latency, failover, weighted
  - **Geoproximity routing requires Traffic Flow** — it cannot be configured without it
  - Supports **versioning** — maintain history of policy changes, roll back to previous versions via console or API
  - Use cases: sophisticated multi-region routing, backup S3 page failover, traffic shaping across endpoints

---

## Route 53 Resolver

**Route 53 Resolver** provides **recursive DNS resolution** for VPCs and enables **bi-directional DNS querying** between AWS and on-premises networks over private connections (Direct Connect or VPN).

### Endpoint Types

| **Endpoint** | **Direction** | **Use Case** |
|--------------|---------------|--------------|
| **Inbound endpoint** | On-premises → VPC | Allows on-premises DNS servers to resolve AWS-hosted domain names |
| **Outbound endpoint** | VPC → On-premises | Allows VPC resources to resolve on-premises domain names via conditional forwarding rules |

  - **Conditional forwarding rules** trigger when a query matches a configured domain and forward the query to on-premises DNS servers
  - Endpoints are configured via IP address assignment in each subnet
  - Requires private connectivity (Direct Connect or VPN) for hybrid DNS resolution
  - Enables DNS resolution for hybrid cloud architectures

> 💡 **Exam Tips:**
> <br>"On-premises servers need to resolve AWS private DNS names" → **Route 53 Resolver inbound endpoint**
> <br>"EC2 instances need to resolve on-premises domain names" → **Route 53 Resolver outbound endpoint + conditional forwarding rules**

> 🔧 **Pro Tip:** For Active Directory integration, two patterns work: (1) Route 53 Resolver outbound with a conditional forwarding rule for the AD domain, or (2) configure the VPC DHCP options set with AD Domain Controller IPs and configure AD DNS to forward non-authoritative queries to the VPC Resolver.

---

# Content Delivery
---

## Amazon CloudFront

Amazon CloudFront is a **Content Delivery Network (CDN)** that distributes content globally with low latency and high transfer speeds by caching content at **edge locations** close to end users.

### Key Properties
  - **Global service** — not regional; operates across 400+ edge locations worldwide ‡ ◊
  - Supports dynamic, static, streaming, and interactive content
  - Keeps **persistent connections** open with origin servers to reduce latency
  - Integrated with **AWS Shield Standard** by default for DDoS protection
  - **PCI DSS** and **HIPAA** compliant ※
  - Supports **wildcard CNAME** and **wildcard SSL certificates**
  - Supports **Perfect Forward Secrecy** — creates a new private key for each SSL session
  - Free data transfer between AWS regions and CloudFront ¤

### Edge Locations and Regional Edge Caches

  - **Edge locations** — 400+ ‡ worldwide; where content is cached and served to users; not tied to Availability Zones or regions; requests are automatically routed to the nearest edge location
  - **Regional Edge Caches** — 13–15 ‡ mid-tier caches between the origin and edge locations; larger cache than any individual edge location; objects remain cached longer here
    - Dynamic content and proxy methods (PUT/POST/PATCH/OPTIONS/DELETE) bypass Regional Edge Caches and go directly to the origin from edge locations
    - Write operations (PUT/POST) go directly to the origin

> 💡 **Exam Tip:** There are **two tiers** of caching: regional edge caches (mid-tier) and edge locations (closest to users). Knowing this helps answer questions about cache hit optimization.

---

## CloudFront Origins

An **origin** is the source of content that CloudFront distributes.

| **Origin Type** | **Examples** | **Notes** |
|-----------------|--------------|-----------|
| S3 bucket | Static assets, images, media | Use OAC (preferred) or OAI to restrict direct S3 access |
| S3 static website | Website hosting endpoint | Treated as a **custom HTTP origin**, not an S3 bucket origin |
| EC2 instance | Custom application | Must be publicly accessible (or via ELB) |
| Elastic Load Balancer | ALB, NLB | Common pattern for dynamic content |
| API Gateway | REST or HTTP APIs | Edge-optimized or regional |
| On-premises / non-AWS HTTP server | Any web server | Must specify DNS name, ports, and protocols |

  - **Origin certificates must be public certificates** — CloudFront cannot validate private/self-signed certs on custom origins
  - **Origin failover**: configure an origin group with a primary and secondary origin; CloudFront automatically fails over on specified HTTP error codes (e.g., 5xx)
  - Origin failover also works with Lambda@Edge functions

---

## CloudFront Distributions

A **distribution** is the configuration unit for CloudFront — it defines how content is delivered.

Distribution configuration includes: origins, access (public or restricted), security (HTTP/HTTPS), cookie/query-string forwarding, geo-restrictions, and access logs.

> ⚠️ **Exam Trap:** RTMP distributions (for Adobe Flash streaming) were **discontinued** Δ — CloudFront no longer supports RTMP. Use **web distributions** for all streaming via HTTP/HTTPS (HLS, DASH, etc.) instead.

  - To delete a distribution it must first be **disabled** (can take up to 15 minutes) then deleted
  - CloudFront creates a domain name such as `a232323.cloudfront.net` §
  - **Alternate domain names (CNAMEs)** can be configured to use a custom domain — requires an SSL certificate in ACM (must be in `us-east-1`) ◊
  - For zone apex with a custom domain, use a Route 53 **Alias** record pointing to the CloudFront distribution
  - CloudFront supports moving **subdomains** between distributions yourself; root domain moves require AWS Support

---

## CloudFront Cache Behaviors

A **cache behavior** defines how CloudFront handles requests matching a specific URL path pattern.

Per-behavior settings:
  - **Path pattern** — e.g., `/images/*`, `/api/*`; must define a default (`*`) behavior
  - **Origin** — which origin receives requests for this path
  - **Viewer protocol policy** — HTTP and HTTPS / Redirect HTTP to HTTPS / HTTPS only
  - **Allowed HTTP methods** — GET+HEAD / GET+HEAD+OPTIONS / all methods
  - **Cache policy** — TTL settings, cache key configuration
  - **Query string / cookie / header forwarding** — what CloudFront passes to the origin and uses as part of the cache key
  - **Signed URL / signed cookie requirement**
  - **Field-level encryption** — encrypts specific POST fields at the edge for end-to-end protection

> 💡 **Exam Tip:** Multiple behaviors allow a single distribution to route `/api/*` requests to an ALB (no cache) and `/images/*` to an S3 bucket (cached). This is a common architecture question pattern.

---

## CloudFront Caching and TTL

  - Objects are cached at edge locations for the **Time to Live (TTL)** duration
  - **Default TTL: 24 hours** § (86,400 seconds); default maximum: 1 year
  - TTL can be overridden by `Cache-Control` headers from the origin:
    - `Cache-Control: max-age=<seconds>` — sets TTL
    - `Cache-Control: no-cache` — forces revalidation with origin
    - `Cache-Control: no-store` — prevents caching entirely
  - **Only GET requests are cached** — PUT/POST/PATCH/DELETE are proxied directly to the origin
  - **Object invalidation** — remove an object from the cache before TTL expires; **chargeable** ¤; cannot be cancelled after submission
  - **Cache hit ratio** — the percentage of requests served from cache (higher = better)

### Improving Cache Hit Ratio
  - Use `Cache-Control max-age` to increase TTL
  - Enable **Origin Shield** — adds an additional caching layer between Regional Edge Caches and the origin
  - Forward only query strings, cookies, and headers that your origin uses to generate unique responses
  - Avoid forwarding all headers/cookies when not needed

---

## CloudFront Geo-Restrictions

CloudFront supports **geo-restrictions (geo-blocking)** to restrict access by country.

| **Method** | **Granularity** | **Scope** |
|------------|-----------------|-----------|
| CloudFront geo-restriction feature | Country level | All files in a distribution |
| Third-party geo-location service | Sub-country / finer granularity | Subset of files; returns 403 with custom logic |

  - Only one list can be active at a time: **allowlist** (whitelist) or **blocklist** (blacklist)

---

## CloudFront Origin Access (OAI and OAC)

These mechanisms restrict users from accessing S3 content directly via S3 URLs — they must go through CloudFront.

| **Feature** | **OAI (Origin Access Identity)** | **OAC (Origin Access Control)** |
|-------------|-----------------------------------|---------------------------------|
| Status | Legacy Δ | **Current recommended approach** Δ |
| Principal in S3 bucket policy | `arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity <ID>` | `cloudfront.amazonaws.com` (AWS service principal) |
| Signed requests support | Limited | ✓ Full support (SigV4 signing) |
| SSE-KMS (S3 server-side encryption with KMS) | ✗ Not supported | ✓ Supported |
| Applies to | S3 bucket origins only | S3 bucket origins, MediaStore, MediaPackage |

  - In both cases: create the identity/control in CloudFront → update S3 bucket policy → associate with distribution
  - Does not affect EC2, ALB, or custom origins — only S3 bucket origins

> 💡 **Exam Tips:**
> <br>"Restrict S3 access to only CloudFront, prevent direct S3 URL access" → **OAC** (current) or **OAI** (legacy)
> <br>OAC is the **preferred** approach for new deployments Δ.

---

## CloudFront SSL/TLS and SNI

  - **Default SSL cert** — CloudFront provides a default certificate for `*.cloudfront.net` at no cost
  - **Custom SSL** — use AWS Certificate Manager (ACM) or import a third-party certificate; ACM cert **must be in `us-east-1`** for CloudFront ◊
  - **Server Name Indication (SNI)** — TLS extension allowing multiple SSL certs on the same IP address; supported by all modern browsers (2010+ for major browsers); **free** ¤
  - **Dedicated IP SSL** — a unique IP per distribution; supports legacy clients that do not support SNI; **additional cost** ¤
  - **Origin certificates** must be **public certificates** — CloudFront validates the cert on the origin during HTTPS connections
  - S3 has its own SSL certificates and they cannot be changed

> 💡 **Exam Tip:** SNI is almost always the correct choice — it's free and supported by all modern clients. Dedicated IP SSL is only needed for legacy client compatibility and costs extra.

---

## Lambda@Edge

**Lambda@Edge** runs Node.js or Python Lambda functions **at CloudFront edge locations** to customize content delivery without routing requests back to a central region.

### Execution Points

```
Viewer ──[viewer request]──▶ CloudFront ──[origin request]──▶ Origin
Viewer ◀──[viewer response]── CloudFront ◀──[origin response]── Origin
```

| **Trigger** | **When It Fires** | **Common Use Cases** |
|-------------|-------------------|----------------------|
| **Viewer request** | After CloudFront receives a request from the viewer (before cache check) | A/B testing, authentication, URL rewriting |
| **Origin request** | Before CloudFront forwards the request to the origin (only on cache miss) | Modify request headers, route to different origins |
| **Origin response** | After CloudFront receives the response from the origin | Modify response headers, error handling |
| **Viewer response** | Before CloudFront forwards the response to the viewer | Add security headers, modify cookies |

  - Executes in AWS locations **closer to the user** — reduces latency vs. calling a central Lambda function
  - Can inspect cookies, rewrite URLs, implement access control via headers, generate HTTP responses, modify headers to direct users to different cached objects
  - Lambda@Edge functions must be deployed in **`us-east-1`** and are then replicated to edge locations ◊

> 💡 **Exam Tips:**
> <br>"Run code at the edge to customize CloudFront" → **Lambda@Edge**
> <br>"Load different content based on User-Agent header" → **Lambda@Edge (origin request trigger)**
> <br>"A/B testing with CloudFront" → **Lambda@Edge (viewer request trigger)**

> 🔧 **Pro Tip:** **CloudFront Functions** (not Lambda@Edge) is the lighter-weight alternative for sub-millisecond, high-volume customizations at the viewer request/response triggers only (e.g., header manipulation, URL normalization). Lambda@Edge is needed for origin request/response triggers and for heavier compute tasks.

---

## CloudFront Functions ※

**CloudFront Functions** is a lightweight serverless runtime built directly into CloudFront for **high-volume, sub-millisecond edge customizations** at the viewer request and viewer response triggers.
<br>It is faster and cheaper than Lambda@Edge for simple header/URL manipulations — it does not need to round-trip to a Lambda region.

### CloudFront Functions vs Lambda@Edge

| **Dimension** | **CloudFront Functions** | **Lambda@Edge** |
|--------------|--------------------------|-----------------|
| **Runtime** | JavaScript (ES5.1) | Node.js or Python |
| **Execution location** | 200+ CloudFront edge PoPs globally | ~13 regional edge caches |
| **Latency** | Sub-millisecond ‡ | Milliseconds ‡ |
| **Max execution time** | 1 ms † | 5 seconds (viewer) / 30 seconds (origin) † |
| **Memory** | 2 MB † | 128 MB – 10 GB † |
| **Triggers** | Viewer request, Viewer response only | All 4: Viewer request, Origin request, Origin response, Viewer response |
| **Access to request body** | ❌ No | ✅ Yes (origin triggers) |
| **Network calls** | ❌ Not allowed | ✅ Allowed |
| **Pricing** | Lower — charged per 1M invocations ¤ | Higher — charged per request + duration ¤ |
| **Use cases** | URL normalization, HTTP header manipulation, simple redirects, cache key manipulation | Complex logic, external API calls, origin routing, request body inspection |

> 💡 **Exam Tips:**
> <br>`"Add security headers to every CloudFront response at minimal cost"` → **CloudFront Functions (viewer response trigger)**
> <br>`"Rewrite URLs or normalize cache keys at the edge"` → **CloudFront Functions**
> <br>`"Inspect or modify request body before forwarding to origin"` → **Lambda@Edge (origin request trigger)** — CloudFront Functions cannot access the request body
> <br>`"Custom logic requires calling an external API or has complex processing"` → **Lambda@Edge**

---

## CloudFront Signed URLs and Signed Cookies

Both mechanisms require a **CloudFront key pair** to sign requests and restrict access to private content.

| **Feature** | **Signed URLs** | **Signed Cookies** |
|-------------|-----------------|-------------------|
| **Scope** | Individual file / object | Multiple files (e.g., all files in a subscriber area) |
| **URL change** | Yes — signed URL differs from base URL | No — existing URLs are unchanged |
| **Best for** | Single file download, custom HTTP clients that don't support cookies | Streaming (HLS), subscriber area with many files |
| **How it works** | Expiration, IP restrictions, HTTPS requirement embedded in the URL | Three `Set-Cookie` headers sent to viewer; viewer includes them in requests |

  - Both can embed: **expiration time**, **start time**, **IP address restriction**
  - Application must authenticate the user and generate the signed URL/cookie — CloudFront itself does not authenticate users

> 💡 **Exam Tip:** "Restrict access to a single file with an expiration" → **Signed URL**. "Restrict access to multiple files in a subscriber area without changing URLs" → **Signed Cookies**.

---

## CloudFront Security and Compliance

  - Protected by **AWS Shield Standard** by default — always-on DDoS mitigation at the edge
  - **AWS WAF** can be associated with a CloudFront distribution — filter HTTP/HTTPS requests by IP, query string values, headers; returns HTTP 403 for blocked requests
  - **PCI DSS** compliant — do not cache credit card information at edge locations ¤
  - **HIPAA** eligible ※
  - **Field-level encryption** — encrypts specific sensitive POST fields at the edge; data remains encrypted through application processing

---

## CloudFront Monitoring and Logging

  - **CloudFront access logs** — stored in an S3 bucket; log all viewer requests; analyze with **Amazon Athena**
  - **CloudTrail** integration — captures API-level requests (console, API, SDK, CLI); must update existing trails to include global services to see CloudFront requests
  - **Default CloudWatch metrics** (no additional cost): requests, bytes downloaded, bytes uploaded, 4xx error rate, 5xx error rate, total error rate
  - **Additional CloudWatch metrics** (additional cost ¤): cache hit rate, origin latency (first-byte latency), error rate by status code (401, 403, 404, 502, 503, 504)

---

# Global Networking
---

## AWS Global Accelerator

**AWS Global Accelerator** improves the availability and performance of applications by routing traffic over the **AWS global network** instead of the public internet, using **static anycast IP addresses** as a fixed entry point.

### Key Properties
  - Provides **2 static anycast IPv4 addresses** (redundant, in different network zones A and B) † — globally advertised from multiple edge locations simultaneously
  - Static IPs are assigned to your accelerator **permanently** — they do not change even if you disable the accelerator or replace endpoints
  - Routes TCP and UDP traffic to the optimal, healthy endpoint based on health, geography, and routing policies you define
  - Targets: **EC2 instances**, **ALB**, **NLB** — not CloudFront distributions
  - Endpoints are associated to regional AWS resources
  - Protected by **AWS Shield Standard** by default; can enable **Shield Advanced** ※

### Traffic Routing and Performance
  - Ingests traffic at the nearest **AWS edge location**, then routes it over the **AWS global backbone network** (private, congestion-free) — bypasses public internet
  - Routes to the **closest AWS region** to the user based on geography
  - **Instant failover** to the next best endpoint if an endpoint becomes unhealthy (detects unhealthy endpoint and redirects in < 1 minute)
  - **Traffic dials** — dial up/down traffic per endpoint group (0–100%) per region; default is 100% across all endpoint groups; useful for blue/green and performance testing
  - **Endpoint weights** — within a region, control distribution across individual endpoints
  - **Client affinity** — optionally route all requests from the same user to the same endpoint (for stateful applications)

### Health Checks
  - Continuously monitors endpoint health via **TCP, HTTP, and HTTPS** health checks
  - Note: the cheat sheet states health checks for Global Accelerator are **TCP only for detecting health** at the accelerator level — endpoint-level health checks use TCP, HTTP, HTTPS depending on configuration
  - Redirects traffic away from unhealthy endpoints automatically

### Fault Tolerance
  - Two static IPs from **independent network zones** (separate physical infrastructure, unique IP subnets) — like two independent Availability Zones for the IP layer
  - If one IP/network zone becomes unavailable, clients retry with the healthy IP from the other zone

---

## CloudFront vs. Global Accelerator

| **Aspect** | **Amazon CloudFront** | **AWS Global Accelerator** |
|------------|----------------------|---------------------------|
| **Primary purpose** | Content caching and delivery (CDN) | Application performance and availability (network acceleration) |
| **Protocol** | HTTP/HTTPS only | TCP and UDP |
| **Caching** | ✓ Yes — caches content at edge locations | ✗ No — proxies traffic, no caching |
| **Entry point** | CloudFront domain (e.g., `a123.cloudfront.net`) or custom CNAME | 2 static anycast IPv4 addresses |
| **IP addresses** | Dynamic (DNS-based) | Static (fixed IPs — never change) |
| **Use case** | Static assets, video streaming, websites, APIs (HTTP) | Gaming, IoT, VoIP, applications requiring static IPs or UDP |
| **DDoS protection** | Shield Standard built-in | Shield Standard built-in |
| **Health routing** | CloudFront origin failover (origin group) | Continuous health checks; instant failover |
| **Exam trigger** | "CDN", "cache at edge", "low latency for static/dynamic content" | "Static IPs for global app", "UDP", "non-HTTP", "gaming", "fixed entry point" |

> 💡 **Exam Tips:**
> <br>"Static IPs required for a global application" → **Global Accelerator**
> <br>"Cache content at edge locations, reduce origin load" → **CloudFront**
> <br>"Gaming or VoIP requiring UDP" → **Global Accelerator** (CloudFront is HTTP/HTTPS only)
> <br>"Blue/green with traffic dial" → **Global Accelerator** (traffic dials per endpoint group)

> ⚠️ **Exam Trap:** CloudFront and Global Accelerator both use AWS edge locations, but they serve fundamentally different purposes. CloudFront **caches content**; Global Accelerator **accelerates network traffic** without caching.

---

# In Practice
---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| Custom domain at zone apex (e.g., `example.com`) pointing to an ELB | Route 53 **Alias** record → ELB |
| Custom domain at zone apex pointing to CloudFront | Route 53 **Alias** record → CloudFront distribution |
| Active-passive failover between primary and DR site | Route 53 **Failover** routing policy with health checks |
| Route users in Europe to EU region, users in US to US region | Route 53 **Geolocation** routing policy |
| Gradually shift traffic from old to new deployment (canary) | Route 53 **Weighted** routing policy (e.g., 90/10 weights) |
| Resolve on-premises DNS names from within a VPC | Route 53 Resolver **outbound endpoint** + conditional forwarding rules |
| Resolve AWS private DNS names from on-premises | Route 53 Resolver **inbound endpoint** (requires DX or VPN) |
| Serve static website globally with low latency | CloudFront distribution with S3 origin + OAC |
| Restrict S3 content to CloudFront only (prevent direct S3 access) | OAC (preferred) or OAI on CloudFront distribution; restrict S3 bucket policy |
| Restrict content access to authenticated subscribers (multiple files) | CloudFront **signed cookies** |
| Restrict access to a single downloadable file | CloudFront **signed URL** |
| Block users from specific countries | CloudFront **geo-restriction** (allowlist or blocklist) |
| Customize content based on User-Agent at the edge | **Lambda@Edge** (origin request trigger) |
| Add security headers to all responses at the edge | **Lambda@Edge** (viewer response trigger) or **CloudFront Functions** |
| Applications requiring static IPs, UDP support, or non-HTTP protocols globally | **AWS Global Accelerator** |
| Blue/green deployment with traffic dial across regions | **AWS Global Accelerator** traffic dials |
| SSL certificate for CloudFront custom domain | ACM certificate in **`us-east-1`** associated with distribution |
| Multiple SSL certs on same IP (cost-effective) | **SNI Custom SSL** on CloudFront |

---

# Module Summary
---

## Key Topics
  - DNS fundamentals: hierarchy (root, TLD, SLD, hostname), FQDNs, record types (A, AAAA, CNAME, Alias, MX, NS, TXT, SOA, PTR, CAA)
  - Route 53: public vs. private hosted zones, Alias vs. CNAME records
  - Route 53 routing policies: Simple, Failover, Geolocation, Geoproximity, Latency, Multivalue Answer, Weighted, IP-based
  - Route 53 health checks: endpoint, calculated, CloudWatch alarm
  - Route 53 Traffic Flow and Geoproximity dependency
  - Route 53 Resolver: inbound and outbound endpoints, conditional forwarding, hybrid DNS
  - CloudFront: edge locations, regional edge caches, origins, distributions, cache behaviors
  - CloudFront: TTL, cache invalidation, cache hit ratio, Origin Shield
  - CloudFront: OAI (legacy) vs. OAC (current) for S3 origin access restriction
  - CloudFront: signed URLs vs. signed cookies
  - CloudFront: Lambda@Edge (four execution triggers)
  - CloudFront: CloudFront Functions ※ — sub-millisecond JS at all PoPs; viewer triggers only; vs Lambda@Edge comparison (complexity, triggers, body access, network calls)
  - CloudFront: geo-restrictions, SSL/TLS, SNI vs. dedicated IP, WAF integration
  - AWS Global Accelerator: static anycast IPs, AWS global network, traffic dials, endpoint weights, client affinity
  - CloudFront vs. Global Accelerator comparison

---

## Critical Acronyms
  - **DNS** — Domain Name System
  - **FQDN** — Fully Qualified Domain Name
  - **TLD** — Top-Level Domain
  - **SLD** — Second-Level Domain
  - **TXT** — Text record (DNS)
  - **MX** — Mail Exchanger (DNS record)
  - **NS** — Name Server (DNS record)
  - **SOA** — Start of Authority (DNS record)
  - **PTR** — Pointer record (reverse DNS)
  - **CAA** — Certification Authority Authorization (DNS record)
  - **TTL** — Time to Live
  - **CDN** — Content Delivery Network
  - **OAI** — Origin Access Identity (CloudFront, legacy)
  - **OAC** — Origin Access Control (CloudFront, current)
  - **SNI** — Server Name Indication
  - **GTM** — Global Traffic Management
  - **ACM** — AWS Certificate Manager
  - **WAF** — Web Application Firewall
  - **SLA** — Service Level Agreement
  - **DDoS** — Distributed Denial of Service
  - **HLS** — HTTP Live Streaming
  - **VPN** — Virtual Private Network
  - **DX** — Direct Connect
  - **ALB** — Application Load Balancer
  - **NLB** — Network Load Balancer
  - **ELB** — Elastic Load Balancer
  - **UDP** — User Datagram Protocol
  - **TCP** — Transmission Control Protocol
  - **RTMP** — Real-Time Messaging Protocol (discontinued in CloudFront) Δ
  - **IANA** — Internet Assigned Numbers Authority
  - **CIDR** — Classless Inter-Domain Routing

---

## Key Comparisons
  - CNAME Records vs. Alias Records
  - Route 53 Routing Policies (all 8 — table format)
  - OAI vs. OAC (S3 origin access restriction)
  - Signed URLs vs. Signed Cookies
  - SNI Custom SSL vs. Dedicated IP SSL
  - CloudFront vs. AWS Global Accelerator

---

## Top Exam Triggers
  - `Route traffic based on user's country` → **Geolocation routing policy**
  - `Shift traffic gradually / blue-green / canary` → **Weighted routing policy**
  - `Route to lowest-latency AWS region` → **Latency routing policy**
  - `Active-passive failover to DR site` → **Failover routing policy**
  - `Return multiple IPs, no ELB` → **Multivalue Answer routing policy**
  - `Complex routing with bias / geographic proximity` → **Geoproximity + Traffic Flow**
  - `Root domain (zone apex) mapped to AWS resource` → **Route 53 Alias record** (not CNAME)
  - `Alias record pointing to what?` → CloudFront, ELB, Elastic Beanstalk, S3 static website, API Gateway, VPC interface endpoint, or same-zone record
  - `Resolve on-premises DNS from VPC` → **Route 53 Resolver outbound endpoint + conditional forwarding**
  - `Resolve AWS private DNS from on-premises` → **Route 53 Resolver inbound endpoint**
  - `Cache content globally at edge` → **Amazon CloudFront**
  - `Restrict S3 access to CloudFront only` → **OAC** (preferred) or **OAI** (legacy)
  - `Single file expiring download link` → **CloudFront signed URL**
  - `Multiple files, subscriber area, no URL change` → **CloudFront signed cookies**
  - `Customize content based on User-Agent or A/B test at edge` → **Lambda@Edge**
  - `Block access by country on CloudFront` → **CloudFront geo-restriction**
  - `Static IPs for global application / UDP / non-HTTP` → **AWS Global Accelerator**
  - `Blue/green across regions with traffic dial` → **AWS Global Accelerator**
  - `SSL cert for CloudFront custom domain` → **ACM cert in us-east-1**
  - `Multiple SSL certs on same IP, cost-effective` → **SNI Custom SSL**

---

## Quick References

### [Route 53 & DNS Exam Cram](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28618842#overview)

### [Route 53 & DNS Architecture Patterns Private Link](https://drive.google.com/drive/folders/1L62jhN4o_I92Ti3KwZy49hBbvXWxvKqP?usp=drive_link)

### [Route 53 & DNS Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346106#overview)

### [Route 53 Cheat Sheet](https://digitalcloud.training/amazon-route-53/)

### [CloudFront Cheat Sheet](https://digitalcloud.training/amazon-cloudfront/)

### [Global Accelerator Cheat Sheet](https://digitalcloud.training/aws-global-accelerator/)

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
