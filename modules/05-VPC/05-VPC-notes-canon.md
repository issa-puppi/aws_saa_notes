# Global Infrastructure
---

## AWS Global Infrastructure

AWS operates a global network of infrastructure organized into distinct layers, each with a different purpose and latency profile.

| **Component** | **What It Is** | **Purpose** |
|---------------|----------------|-------------|
| **Region** | Separate physical geographic location in the world | Deploy resources close to users; meet data residency requirements |
| **Availability Zone (AZ)** | One or more discrete data centers with independent power, cooling, and networking | HA and fault tolerance within a region |
| **AWS Outposts** | Fully managed AWS infrastructure installed on-premises | Run AWS services in your own data center (hybrid) |
| **Local Zone** | Extension of a Region placed geographically close to users ¤ | Single-digit millisecond latency for latency-sensitive apps |
| **Wavelength Zone** | AWS infrastructure at the edge of 5G networks ※ | Ultra-low latency for mobile/edge apps (AR, VR, ML at edge) |
| **Edge Location** | Sites used by CloudFront, Global Accelerator, and Lambda@Edge | Cache and serve content closer to global end-users |

### Key Regional Properties
  - A **Region** spans multiple AZs — typically 3 or more
  - AZs within a Region are connected with **low-latency, high-throughput, highly redundant networking**
  - AZ names (e.g., `ap-southeast-2a`) are **mapped differently per account** — your `us-east-1a` may not be the same physical zone as another account's `us-east-1a`
  - A **VPC spans all AZs in a Region**; subnets reside in a single AZ

> 💡 **Exam Tips:** 
<br>"Reduce latency for users in a specific metro area" → **Local Zone**. 
<br>"Ultra-low latency for 5G mobile apps" → **Wavelength Zone**. 
<br>"Cache content globally" → **CloudFront edge locations**.

---

## Amazon CloudFront

**CloudFront** is a global **Content Delivery Network (CDN)** that delivers data, video, applications, and APIs worldwide with low latency.
<br>It uses a network of **edge locations** and **regional edge caches** to serve content from the location closest to the user.

  - Origins can be: **S3, EC2, ALB, or any HTTP endpoint**
  - Reduces load on the origin by caching at the edge
  - Supports **HTTPS, HTTP/2, WebSocket** ※
  - Integrates with **AWS WAF** for edge security
  - **Lambda@Edge** allows running code at edge locations without provisioning servers

> 📚 **Learn More:** CloudFront is covered in depth in the context of DNS and performance optimization.
>
> - **Module 7 — DNS & Performance Optimization** — full CloudFront coverage including behaviors, cache policies, signed URLs, and Lambda@Edge

---

# Networking Fundamentals
---

## IP Addressing — IPv4

### IPv4 Structure
  - **32-bit** address written in **dotted decimal notation** — four octets separated by periods
  - Each octet is 8 binary bits representing a decimal value from 0–255
  - Example: `192.168.0.1`
    - `192` → `11000000` (128 + 64)
    - `168` → `10101000` (128 + 32 + 8)
    - `0` → `00000000`
    - `1` → `00000001`

### Network ID vs Host ID
  - **Network ID** — identifies the network; same for all devices on the network (e.g., `192.168.0`)
  - **Host ID** — identifies the specific device within the network (e.g., `.1`)
  - **Subnet mask** — defines where the network ID ends and the host ID begins (e.g., `255.255.255.0`)

### CIDR Notation
  - **Classless Inter-Domain Routing (CIDR)** — compact format for IP address + network mask
  - Example: `192.168.0.0/24`
    - `/24` → first 24 bits = Network ID
    - Remaining 8 bits = Host IDs (256 possible addresses, 254 usable)
  - Formula: `host bits = 32 - prefix length`

### Private IP Address Ranges (RFC 1918)
These ranges are reserved for private use and **not routable on the public internet**:

| **RFC 1918 Range** | **Example VPC CIDR** |
|--------------------|----------------------|
| `10.0.0.0` – `10.255.255.255` (`10/8` prefix) | `10.0.0.0/16` |
| `172.16.0.0` – `172.31.255.255` (`172.16/12` prefix) | `172.16.0.0/16` |
| `192.168.0.0` – `192.168.255.255` (`192.168/16` prefix) | `192.168.0.0/20` |

---

## IP Addressing — IPv6

  - **128-bit** address written in **hexadecimal**, separated by colons
  - Example: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
  - Provides **340 undecillion** addresses (340,282,366,920,938,463,463,374,607,431,768,211,456)
    - Enough for 100+ IPv6 addresses per atom on Earth
  - **All IPv6 addresses are publicly routable** — no NAT needed
  - AWS assigns a `/56` IPv6 CIDR block to your VPC §
  - Subnets receive a `/64` range — 18 quintillion addresses per subnet

### IPv4 vs IPv6

| **Aspect** | **IPv4** | **IPv6** |
|------------|----------|----------|
| Length | 32 bits | 128 bits |
| Notation | Dotted decimal (`192.168.0.1`) | Hexadecimal with colons (`2001:db8::1`) |
| Address space | ~4.3 billion | ~340 undecillion |
| NAT required? | Yes (private ranges) | No (all addresses public) |
| AWS VPC allocation | Customer-defined (RFC 1918 recommended) | AWS-assigned `/56` per VPC |
| Outbound-only gateway | NAT Gateway | Egress-only Internet Gateway |

---

# VPC Core
---

## Amazon Virtual Private Cloud (VPC)

A **VPC** is a logically isolated section of the AWS Cloud within a Region — analogous to having your own data center inside AWS.
<br>You have complete control over the virtual networking environment: IP address ranges, subnets, route tables, and gateways.

### Key Properties
  - **Regional resource** — a VPC spans all AZs in the Region
  - **Logically isolated** from other VPCs on AWS
  - Up to **5 † VPCs per Region** (default soft limit)
  - Can define **dedicated tenancy** for a VPC — all instances launch on dedicated hardware
  - AWS automatically creates a **default VPC** in each Region with:
    - A `/16` IPv4 CIDR block
    - A `/20` default subnet in each AZ (all public)
    - An attached Internet Gateway
    - A default route table, security group, and DHCP options set
  - Instances in the default VPC always have **both a public and private IP address** §

### CIDR Block Rules
  - Block size must be between `/16` (65,536 IPs) and `/28` (16 IPs) †
  - **Cannot increase or decrease** an existing CIDR block once created
  - **Cannot overlap** with existing CIDR blocks in the VPC
  - **Cannot create additional CIDR blocks** in a different RFC 1918 range than the primary block
  - AWS recommends using RFC 1918 ranges — though publicly routable CIDR blocks are technically allowed
  - **VPC peering requires non-overlapping CIDR blocks** across all peered VPCs in all Regions and accounts

### Reserved IP Addresses Per Subnet
For each subnet CIDR block, the first 4 and last 1 address are reserved:

| **Address** | **Reserved For** |
|-------------|-----------------|
| `10.0.0.0` | Network address |
| `10.0.0.1` | VPC router |
| `10.0.0.2` | AWS DNS |
| `10.0.0.3` | Future use |
| `10.0.0.255` | Broadcast (not supported, reserved) |

> ⚠️ **Exam Trap:** A `/28` subnet gives 16 total IPs — **5 are reserved**, leaving only **11 usable** host addresses.

---

## Subnets

A **subnet** is a segment of the VPC's IP address range used to place groups of isolated resources.

  - Subnets **map 1:1 to an AZ** — one subnet resides in exactly one AZ; cannot span AZs
  - A subnet is **public** if its route table has a route to an Internet Gateway (IGW)
  - A subnet is **private** if it has no route to an IGW
  - A subnet is **VPN-only** if it has no IGW route but has traffic routed to a Virtual Private Gateway (VGW)
  - New subnets are associated with the **main route table** by default §
  - Each subnet can only be associated with **one route table at a time**
  - One route table can be assigned to **multiple subnets**
  - Public subnets have **auto-assign public IPv4** set to "Yes" §
  - **Cannot delete** the main route table

### Route Tables
  - Up to **200 † route tables per VPC**
  - Up to **50 † route entries per route table**
  - There is a **default local route** (e.g., `10.0.0.0/16 → Local`) that allows all VPC subnets to communicate — **cannot be deleted or modified**
  - Routing problems between subnets are more likely caused by **security groups or NACLs**, not the router

### Example Subnet Layout

| **Subnet** | **IPv4 CIDR** | **AZ** | **Route Table** | **Auto-assign Public IPv4** |
|------------|---------------|--------|-----------------|------------------------------|
| `private-1a` | `10.0.0.0/24` | `us-east-1a` | `Private-RT` | No |
| `private-1b` | `10.0.1.0/24` | `us-east-1b` | `Private-RT` | No |
| `private-1c` | `10.0.2.0/24` | `us-east-1c` | `Private-RT` | No |
| `public-1a` | `10.0.3.0/24` | `us-east-1a` | `Main` | Yes |
| `public-1b` | `10.0.4.0/24` | `us-east-1b` | `Main` | Yes |
| `public-1c` | `10.0.5.0/24` | `us-east-1c` | `Main` | Yes |

Use a [CIDR calculator](https://www.ipaddressguide.com/cidr) or [subnet calculator](https://www.subnet-calculator.com/) for subnetting and CIDR block planning.

> 💡 **Exam Tips:** 
<br>"How many usable IPs in a `/24` subnet?" → **256 total − 5 reserved = 251 usable**. 
<br>"Application tiers should be in separate subnets" → Yes — web, app, and database tiers each in their own subnet for security and routing control.

---

## VPC Components Overview

| **Component** | **What It Is** |
|---------------|----------------|
| **VPC** | Logically isolated virtual network dedicated to your account |
| **Subnet** | Segment of a VPC's IP range — resources placed here; maps 1:1 to an AZ |
| **Internet Gateway (IGW)** | Enables bidirectional IPv4/IPv6 communication between VPC and the internet; horizontally scaled, HA, redundant |
| **Egress-only IGW** | IPv6-only outbound gateway — allows outbound IPv6, blocks inbound from internet; stateful |
| **Router** | Interconnects subnets and routes traffic to IGW, VGW, NAT GW, and other subnets |
| **NAT Gateway** | AWS-managed; enables private subnet instances to initiate outbound IPv4 internet traffic; no inbound |
| **NAT Instance** | User-managed EC2 instance configured for NAT; legacy |
| **Virtual Private Gateway (VGW)** | AWS-side endpoint for Site-to-Site VPN connections |
| **Customer Gateway (CGW)** | Customer-side representation of the VPN connection (device or software) |
| **Peering Connection** | Direct private IPv4/IPv6 routing connection between two VPCs; non-transitive |
| **VPC Endpoint** | Private connection to AWS services without traversing the internet (Interface or Gateway types) |
| **AWS Direct Connect** | Dedicated private physical fiber connection from on-premises to AWS |
| **Security Group** | Instance/ENI-level virtual firewall; stateful; allow rules only |
| **Network ACL (NACL)** | Subnet-level virtual firewall; stateless; allow and deny rules; processes rules in order |
| **VPC Flow Logs** | Captures IP traffic metadata for network interfaces, subnets, or VPCs; stored in CloudWatch Logs or S3 |
| **Transit Gateway (TGW)** | Regional network transit hub connecting VPCs and on-premises networks at scale |

---

# Security
---

## Security Groups (SGs)

Security groups act as a **virtual firewall at the instance/ENI level**.

### Key Properties
  - **Stateful** — return traffic is automatically allowed regardless of outbound rules
  - **Allow rules only** — cannot create deny rules; implicit deny at the end
  - All rules are **evaluated together** — no ordering
  - Up to **5 § security groups per ENI** †
  - No limit on number of EC2 instances per security group
  - **Cannot block specific IP ranges** — use NACLs for that
  - Changes take effect **immediately** §
  - Security group membership can be **changed on running instances**
  - You can use **another security group as a source** (security group chaining) — allows all instances in that group without specifying IPs
  - **Default security group**: has inbound allow rules for traffic from instances in the same group; cannot be deleted
  - **Custom security group**: no inbound allow rules by default §; all outbound traffic allowed by default §

---

## Network Access Control Lists (NACLs)

NACLs act as a **virtual firewall at the subnet level**.

### Key Properties
  - **Stateless** — return traffic must be explicitly allowed in both directions
  - **Allow and deny rules**
  - Rules are **processed in order** from lowest to highest number — first match wins
  - Apply to **all instances** in the associated subnet automatically
  - A VPC has a **default NACL** that allows all inbound/outbound traffic §
  - **Custom NACLs** deny all traffic by default until rules are added §
  - Each subnet must be associated with exactly **one NACL**; one NACL can apply to multiple subnets
  - NACLs only filter traffic **entering or leaving the subnet** — not traffic within the same subnet
  - Recommended to **leave spacing** between rule numbers (e.g., 10, 20, 30) for easy insertion
  - **Best tool for blocking specific IPs or IP ranges**

### Security Groups vs NACLs

| **Aspect** | **Security Group** | **Network ACL** |
|------------|---------------------|-----------------|
| Level | Instance / ENI | Subnet |
| Rules | Allow only | Allow and deny |
| Statefulness | Stateful (return traffic auto-allowed) | Stateless (must allow return traffic explicitly) |
| Rule evaluation | All rules evaluated | Rules processed in numbered order; first match wins |
| Scope | Only instances explicitly associated | All instances in associated subnets |
| Block specific IPs? | No | **Yes** |
| Default VPC behavior | Default SG allows inbound from group members § | Default NACL allows all traffic § |

> 💡 **Exam Tips:** 
<br>"Block traffic from a specific malicious IP" → **NACL deny rule** (Security Groups cannot deny). 
<br>"Stateful firewall at instance level" → **Security Group**. 
<br>"Need separate inbound and outbound rules evaluated independently" → **NACL** (stateless).

> ⚠️ **Exam Trap:** NACL rules are processed in **order** — a lower-numbered allow beats a higher-numbered deny for the same traffic. If rule 99 denies and rule 100 allows the same traffic, the traffic is **denied**.

> 🛠️ **Implementation Notes:** 
<br>`sudo su` before running `iptables` commands to avoid permission issues. 
<br>Security group chaining — reference another SG as the source to allow traffic between instance groups without specifying IPs.

---

## VPC Flow Logs

**VPC Flow Logs** capture metadata about IP traffic going to and from network interfaces.

### Key Properties
  - Can be created at three levels: **VPC, Subnet, or Network Interface**
  - Data stored in **Amazon CloudWatch Logs** or **Amazon S3**
  - **Cannot be modified** after creation — delete and re-create to change configuration
  - **Cannot be tagged**
  - Cannot enable flow logs for peered VPCs **unless the peer VPC is in your account**

### Traffic Excluded from Flow Logs
  - Traffic to/from Route 53
  - Windows license activation traffic
  - Traffic to/from `169.254.169.254` (instance metadata)
  - Traffic to/from `169.254.169.123` (Amazon Time Sync Service)
  - DHCP traffic
  - Traffic to the reserved IP of the default VPC router

> 💡 **Exam Tip:** "Investigate network traffic or diagnose connectivity issues" → **VPC Flow Logs**. 
<br>They capture metadata (IPs, ports, protocol, bytes, accept/reject) — not packet contents.

---

# Connectivity
---

## Internet Gateway (IGW)

An **IGW** enables bidirectional communication between resources in a VPC and the internet.

  - **Horizontally scaled, redundant, and highly available** — no HA configuration needed
  - **One IGW per VPC** — cannot attach multiple IGWs
  - Must be **attached to the VPC** and referenced in a **route table** (`0.0.0.0/0 → igw-id`) for a subnet to be public
  - Performs **NAT** between private and public IPv4 addresses for instances with a public IP
  - Supports **both IPv4 and IPv6**
  - Must **detach** the IGW before deleting it

### Egress-only Internet Gateway
  - For **IPv6 traffic only** — allows outbound IPv6 but blocks inbound connections from the internet
  - **Stateful** — automatically allows return traffic for outbound connections
  - Route table entry: `::/0 → eo-igw-id`
  - Use instead of NAT Gateway for IPv6

> 💡 **Exam Tip:** "IPv6 instances need outbound internet access without being reachable from the internet" → **Egress-only Internet Gateway**.

---

## VPC Peering

A **VPC peering connection** enables routing between two VPCs using private IPv4 or IPv6 addresses — as if they were in the same network.

### Key Properties
  - Can peer VPCs **across accounts and across Regions** ※
  - **Non-transitive** — if A↔B and B↔C, A cannot reach C through B; requires A↔C directly
  - **Full mesh required** for all-to-all connectivity (6 peering connections for 4 VPCs)
  - CIDR blocks of peered VPCs **cannot overlap**
  - Data between VPCs in **different regions** is **encrypted in transit** ※ (data transfer charges apply ¤)
  - **Route tables in both VPCs** must be updated with the peering connection as target
  - **Security groups in both VPCs** must allow the relevant traffic
  - **Only one peering connection** can exist between any two VPCs at a time
  - For cross-account peering: enter the account ID and VPC ID of the peer; peer must accept the request
  - Peering connections appear in route tables as targets starting with `pcx-`

### Inter-Region Peering Limitations ◊
  - Cannot reference a peer security group in rules
  - Cannot enable DNS resolution
  - Maximum MTU is 1500 bytes (no jumbo frames)

> ⚠️ **Exam Trap:** VPC peering is **non-transitive**. To connect N VPCs in a full mesh, you need N(N-1)/2 peering connections. For large numbers of VPCs, **Transit Gateway** is the better solution.

> 🛠️ **Implementation Notes — VPC Peering via CloudFormation:** 
<br>Use `AWS::EC2::VPCPeeringConnection` resource to create the peering connection. 
<br>Use `AWS::EC2::Route` to add routes to both VPCs' route tables. 
<br>See `code/vpc-peering.yaml` in this repo (update `ImageId` parameters before launching).

---

## VPC Endpoints

A **VPC Endpoint** provides **private connectivity** to supported AWS services from within your VPC **without using the internet, VPN, NAT, or Direct Connect**.
<br>Traffic between your VPC and the service stays on the **Amazon private network**.

### Interface Endpoints
  - Creates an **ENI with a private IP** in your subnet
  - Uses **DNS entries** to redirect traffic to the service
  - Secured with **Security Groups**
  - Supports a **large number of AWS services** (API Gateway, CloudFormation, CloudWatch, SSM, STS, etc.)
  - Powered by **AWS PrivateLink**

### Gateway Endpoints
  - A **gateway added to your route table** — uses **prefix lists** to redirect traffic
  - Secured with **VPC Endpoint Policies**
  - Supports **only two services: Amazon S3 and Amazon DynamoDB**
  - **Free** ¤ — no additional charge beyond data transfer
  - No security group association — controlled via endpoint policies, IAM policies, and bucket/table policies

### Interface vs Gateway Endpoints

| **Aspect** | **Interface Endpoint** | **Gateway Endpoint** |
|------------|------------------------|----------------------|
| Mechanism | ENI with private IP in your subnet | Route table entry with prefix list |
| Routing | DNS-based redirect | Route table-based redirect |
| Services | Most AWS services | S3 and DynamoDB only |
| Security | Security Groups | VPC Endpoint Policies |
| Cost ¤ | Hourly + per-GB charges | Free |
| Multi-AZ | Deploy in each AZ's subnet | Single gateway per VPC |

### VPC Endpoint Policies
Three layers of access control for endpoints:
  - **Bucket/resource policy** — restricts access using `aws:SourceVpce` condition to limit to specific endpoint
  - **IAM policy** — controls what actions a user/role can perform
  - **VPC Endpoint policy** — controls what traffic is allowed through the endpoint (actions, resources)

> 💡 **Exam Tips:** 
<br>"S3 or DynamoDB access from private subnet without internet" → **Gateway Endpoint** (free, route-table-based). 
<br>"Private access to other AWS services (CloudWatch, SSM, STS, etc.) without internet" → **Interface Endpoint** (PrivateLink). 
<br>"S3 bucket must only allow access from a specific VPC" → **Gateway endpoint + bucket policy with `aws:SourceVpce` condition**.

> ⚠️ **Exam Trap:** Gateway endpoints support **only S3 and DynamoDB** — this is a frequent exam distinction. <br>Everything else uses Interface Endpoints.

### Service Provider Model (AWS PrivateLink)
  - A **service provider** exposes their service via a **Network Load Balancer (NLB)**
  - A **service consumer** creates an **Interface Endpoint** in their VPC to access it
  - Traffic flows: Consumer VPC → Endpoint ENI → NLB → Service Provider VPC
  - Keeps traffic off the public internet and within the AWS network

### AWS PrivateLink
  - Provides **private connectivity** between VPCs, AWS services, and on-premises applications
  - Eliminates exposure to the public internet
  - Works across different accounts and VPCs
  - Accessible over **Inter-Region VPC Peering** — traffic stays on AWS backbone ※

> ⚠️ **Exam Trap:** Know the difference between **AWS PrivateLink** (Interface Endpoints, private service connectivity) and **ClassicLink** (legacy, links EC2-Classic to a VPC — not available to accounts created after December 2013; may appear as a wrong answer choice).

---

## AWS Client VPN

**AWS Client VPN** is a managed, **client-based VPN service** for secure remote access.

  - Uses **OpenVPN-based clients** to connect to a VPN endpoint
  - Connects over **SSL/TLS (port 443)**
  - Provides secure access to **AWS resources and on-premises networks** from any location
  - Client VPN network interfaces are created in the associated subnets
  - A **SNAT** is performed from the VPN client CIDR to the VPC CIDR

> 💡 **Exam Tip:** "Remote users need secure access to VPC resources from anywhere" → **AWS Client VPN**.

---

## AWS Site-to-Site VPN

**Site-to-Site VPN** connects your **on-premises network to an AWS VPC** using encrypted IPsec tunnels over the internet.

### Components
  - **Virtual Private Gateway (VGW)** — deployed on the **AWS side**; attached to the VPC
  - **Customer Gateway (CGW)** — deployed on the **customer/on-premises side** (physical device or software)
  - **Two tunnels per connection** — required for redundancy §
  - Route table in the VPC must point the on-premises CIDR to the VGW

### Key Properties
  - Uses **IPsec** for encrypted tunnels
  - Supports **static routing** or **dynamic routing via BGP (Border Gateway Protocol)**
  - BGP allows dynamic routing and automatic failover between tunnels
  - Quick, easy to deploy, **cost-effective** ¤
  - **Internet-dependent** — performance can vary
  - Cannot access **Elastic IPs** via VPN (EIPs are internet-only)
  - Cannot use a NAT Gateway for VPN clients coming inbound

---

## AWS VPN CloudHub

**VPN CloudHub** enables **multiple on-premises networks** to connect to a single VPC and to **each other** using a hub-and-spoke topology.

  - AWS VPC (with VGW) acts as the **hub**; on-premises offices are the **spokes**
  - Each office connects via its own **Site-to-Site VPN** tunnel
  - Each office must have a **unique BGP ASN (Autonomous System Number)**
  - Offices can communicate **with each other** through the VGW (traffic routed over IPsec VPN)
  - Uses **eBGP** for routing
  - Up to **10 † IPsec tunnels** on a VGW by default
  - Billed at **hourly rate + data egress charges** ¤

> 💡 **Exam Tip:** "Multiple branch offices need to connect to AWS and to each other over VPN" → **AWS VPN CloudHub**.

---

## AWS Direct Connect (DX)

**AWS Direct Connect** establishes a **dedicated private physical fiber connection** from your premises to AWS — bypassing the public internet entirely.

### Physical Architecture
  - A **DX port** (1000-Base-LX or 10GBASE-LR) must be allocated at a **DX location** ‡
  - A **cross-connect** is established between the AWS DX router and the customer/partner DX router
  - The customer router connects to the DX router at the DX location
  - Dedicated speeds: **1 Gbps or 10 Gbps** (100 Gbps in select locations ※) ‡
  - Hosted connections via APN partners: **50 Mbps – 500 Mbps** ‡

### Benefits
  - **Consistent network experience** — predictable latency, bandwidth, and throughput
  - **Lower costs** ¤ for organizations transferring large volumes of data
  - **Private connectivity** — traffic never traverses the public internet

### Critical: Direct Connect is NOT Encrypted §
  - DX connections are **not encrypted by default**
  - To add encryption: **run an IPsec Site-to-Site VPN connection over a Public VIF** on top of DX

### Virtual Interfaces (VIFs)
A **VIF** is a virtual interface (802.1Q VLAN) with a BGP session used for routing over DX:

| **VIF Type** | **Purpose** |
|--------------|-------------|
| **Private VIF** | Connects to a single VPC in the same region via a VGW |
| **Public VIF** | Connects to AWS public services (S3, DynamoDB, etc.) in any Region — not the internet |
| **Transit VIF** | Connects to a Transit Gateway for access to multiple VPCs across regions |
| **Hosted VIF** | Shared VIF; can connect to a single VPC or multiple VPCs via TGW across accounts |

> ⚠️ **Exam Trap:** Direct Connect is **not encrypted** by default. If a question asks for consistent performance **plus** encryption → **DX + Site-to-Site VPN over a Public VIF**.

> 🔧 **Pro Tip:** Direct Connect is **not HA by default** — a single DX connection is a single point of failure. <br>For resilience, establish a **second DX connection** (ideally via a different provider) or use a **Site-to-Site VPN as backup**. 
<br>Full Active-Active or Active-Passive HA DX design is a core SAP topic.

---

## Direct Connect Gateway (DXGW)

A **Direct Connect Gateway** is a **globally available** resource that allows a single DX connection to reach VPCs in **multiple AWS Regions**.

  - Associates with a VGW (Private VIF) or a TGW (Transit VIF)
  - BGP advertises routes to all connected VPCs via the DXGW
  - **Does NOT allow VGWs to route traffic to each other** — on-premises to any VPC only; not VPC-to-VPC through DXGW

---

## Transit Gateway (TGW)

A **Transit Gateway** is a **regional network transit hub** that connects VPCs and on-premises networks at scale.

  - Replaces complex full-mesh VPC peering or per-VPC VPN connections
  - **Supports transitive routing** — unlike VPC peering, traffic can flow through the TGW hub
  - One subnet per AZ must be specified to enable routing within each AZ
  - Can attach: **VPCs, VPNs, Direct Connect Gateways, 3rd-party appliances, other TGWs** (inter-region ※, cross-account ※)

### Problem It Solves
Without TGW — 4 VPCs + 1 on-premises = 6 peering connections + 4 VPN connections (8 for full redundancy).
<br>With TGW — 4 VPC attachments + 1 VPN/DX attachment = everything routes through the central hub.

### DXGW vs TGW

| **Aspect** | **Direct Connect Gateway (DXGW)** | **Transit Gateway (TGW)** |
|------------|-----------------------------------|-----------------------------|
| Purpose | Connect DX to VPCs across Regions | Connect VPCs and on-premises at scale |
| Scope | Global | Regional |
| Transitive routing | No (on-prem → VPCs only) | Yes |
| Connects to | VGWs, TGWs | VPCs, VPNs, DXGWs, TGWs |
| Use case | Single DX to multi-region VPCs | Hub-and-spoke network at scale |

### TGW + DXGW Pattern
  - Use a **Transit VIF** to attach DX → DXGW → TGW
  - Enables **full transitive routing** between on-premises and all VPCs attached to the TGW

> 💡 **Exam Tips:** 
<br>"Many VPCs need to communicate and connect to on-premises — simplify architecture" → **Transit Gateway**. 
<br>"Single DX connection, need access to VPCs in multiple regions" → **Direct Connect Gateway**. 
<br>"DX + multi-region VPC access + VPC-to-VPC routing through TGW" → **DX → DXGW → TGW via Transit VIF**.

---

# In Practice
---

## HOL — Creating a Custom VPC

### Steps
1. Create a VPC — use the `VPC and more` option
2. Provide a name (e.g., `lab1-custom-vpc`), set CIDR block
3. No NAT Gateway for basic setup
4. Modify public subnets to **auto-assign public IPv4 addresses**
5. When creating manually: map `Private-RT` to private subnets; `Main-RT` to public subnets

### Testing the S3 Gateway Endpoint
1. Launch an instance in a public subnet with S3 read-only permissions
2. Connect via EC2 Instance Connect; run `aws s3 ls` — should list buckets
3. Edit the S3 Gateway Endpoint policy: change `Allow` to `Deny`
4. Run `aws s3 ls` again — **no change yet** (traffic still goes through public internet, not endpoint)
5. Edit the endpoint to **add the public route table** to the endpoint association
6. Run `aws s3 ls` again — **access now denied** (traffic routes through endpoint, policy blocks it)
7. Revert policy to `Allow` — access restored

**Notes:**
  - Instance may need a public IP — enable auto-assign on the subnet or assign manually at launch
  - The route table must be associated with the endpoint for the endpoint policy to take effect

---

## High Availability for Networking

  - Create **subnets across multiple AZs** for Multi-AZ presence
  - **NAT Gateways**: deploy one **per AZ**, with private subnets in each AZ routing to the local NAT GW
  - **Site-to-Site VPN**: configure at least **two tunnels** into the VGW for redundancy §
  - **Direct Connect**: not HA by default — add a second DX or use a VPN as backup
  - **Route 53 health checks**: redirect DNS for endpoint-level failover
  - **Elastic IPs**: allow changing backend instances without affecting name resolution

---

## Architecture Patterns

| **Requirement** | **Solution** |
|-----------------|--------------|
| S3 bucket must only allow access from EC2 instances in a private subnet using private IPs | **VPC Gateway Endpoint** + S3 bucket policy using `aws:SourceVpce` condition |
| Malicious traffic reaching EC2 instances from specific public IPs | **NACL deny rule** targeting those source IPs |
| On-premises DC needs to connect to AWS with consistent performance and encryption | **Direct Connect** + **Site-to-Site VPN over a Public VIF** for encryption |
| Private connectivity between VPCs in different Regions with full redundancy | **VPC Peering** between the VPCs (inter-region peering) |
| Multiple remote offices must connect to a VPC and to each other over the internet | **AWS VPN CloudHub** — hub-and-spoke VPN topology via VGW |
| Microservices app needs instance-level firewall with different rules per component | **Separate Security Groups** per component with appropriate rules |
| IPv6 instances need outbound internet access without being reachable from internet | **Egress-only Internet Gateway** |
| New public subnet must allow internet connectivity with auto IP assignment | **Attach IGW to VPC**, update route table with `0.0.0.0/0 → igw-id`, enable auto-assign public IPv4 on subnet |
| Multiple VPCs and on-premises need full mesh connectivity — simplify architecture | **Transit Gateway** — attach all VPCs and the VPN/DX connection |
| Single DX connection must reach VPCs in multiple regions | **Direct Connect Gateway (DXGW)** associated with VGWs in each region |
| DX + multi-region VPCs + transitive VPC-to-VPC routing | **DX → DXGW → TGW via Transit VIF** |
| Private access to CloudWatch, SSM, STS without internet from private subnet | **Interface Endpoint (PrivateLink)** for each service |
| Remote employees need secure access to VPC resources from anywhere | **AWS Client VPN** |

---

# Module Summary
---

## Key Topics
  - AWS Global Infrastructure — Regions, AZs, Outposts, Local Zones, Wavelength Zones, Edge Locations
  - IPv4 addressing — CIDR notation, subnet masks, RFC 1918 private ranges, reserved IPs per subnet
  - IPv6 addressing — 128-bit, hex notation, all addresses public, `/56` VPC allocation
  - VPC fundamentals — regional, spans AZs, 5 VPCs per region limit, default VPC
  - CIDR block rules — `/16` to `/28`, no overlap, cannot modify after creation
  - Subnets — 1:1 AZ mapping, public/private/VPN-only types, route tables
  - Reserved IPs — 5 per subnet (network, router, DNS, future, broadcast)
  - IGW — required for public subnets, one per VPC, handles NAT for public IPs
  - Egress-only IGW — outbound IPv6 only, stateful
  - Security Groups — instance/ENI level, stateful, allow only, security group chaining
  - NACLs — subnet level, stateless, allow and deny, numbered order, use to block IPs
  - VPC Flow Logs — metadata capture at VPC/subnet/ENI level, stored in CW Logs or S3
  - VPC Peering — non-transitive, cross-account/cross-region, non-overlapping CIDRs required
  - VPC Endpoints — Gateway (S3, DynamoDB, free) vs Interface (PrivateLink, most services, charged)
  - AWS PrivateLink — private connectivity via Interface Endpoints and NLB service provider model
  - Site-to-Site VPN — IPsec over internet, VGW + CGW, BGP supported
  - AWS Client VPN — OpenVPN-based, remote user access
  - VPN CloudHub — hub-and-spoke multi-office VPN via VGW
  - Direct Connect — private fiber, not encrypted, 1/10 Gbps, use VPN over DX for encryption
  - VIF types — Private (VPC), Public (AWS services), Transit (TGW)
  - Direct Connect Gateway — global, single DX to multi-region VPCs
  - Transit Gateway — regional hub, transitive routing, replaces complex mesh topologies

---

## Critical Acronyms
  - **VPC** — Virtual Private Cloud
  - **AZ** — Availability Zone
  - **IGW** — Internet Gateway
  - **NACL** — Network Access Control List
  - **SG** — Security Group
  - **CIDR** — Classless Inter-Domain Routing
  - **NAT** — Network Address Translation
  - **VGW** — Virtual Private Gateway
  - **CGW** — Customer Gateway
  - **DX** — Direct Connect
  - **DXGW** — Direct Connect Gateway
  - **TGW** — Transit Gateway
  - **VIF** — Virtual Interface
  - **BGP** — Border Gateway Protocol
  - **ASN** — Autonomous System Number
  - **RFC** — Request for Comments (IETF standards body)
  - **ENI** — Elastic Network Interface
  - **CDN** — Content Delivery Network
  - **MTU** — Maximum Transmission Unit
  - **SNAT** — Source Network Address Translation
  - **AR / VR** — Augmented / Virtual Reality

---

## Key Comparisons
  - IPv4 vs IPv6
  - Public Subnet vs Private Subnet vs VPN-only Subnet
  - Security Groups vs NACLs
  - Interface Endpoint vs Gateway Endpoint
  - VPC Peering vs Transit Gateway (non-transitive vs transitive)
  - Direct Connect vs Site-to-Site VPN (dedicated/consistent vs internet-based/encrypted)
  - Direct Connect + VPN (dedicated + encrypted)
  - Direct Connect Gateway vs Transit Gateway (global vs regional; DX-focused vs multi-attach hub)
  - Egress-only IGW vs NAT Gateway (IPv6 vs IPv4)
  - Client VPN vs Site-to-Site VPN (user-initiated vs network-to-network)
  - VPN CloudHub vs Transit Gateway (internet-based multi-office vs private multi-VPC hub)

---

## Top Exam Triggers
  - `Private subnet instances need outbound internet access` → **NAT Gateway** (in public subnet, EIP required)
  - `Block traffic from a specific IP address` → **NACL deny rule** (SGs cannot deny)
  - `Instance-level firewall` → **Security Group** (stateful, allow only)
  - `Subnet-level firewall` → **Network ACL** (stateless, allow and deny)
  - `Private access to S3 or DynamoDB from VPC` → **VPC Gateway Endpoint** (free, route table-based)
  - `Private access to most other AWS services from VPC` → **VPC Interface Endpoint** (PrivateLink)
  - `S3 bucket restricted to specific VPC endpoint` → **Bucket policy with `aws:SourceVpce` condition**
  - `VPCs cannot communicate transitively through peering` → True — add direct peering or use **Transit Gateway**
  - `Many VPCs + on-premises — simplify` → **Transit Gateway**
  - `DX to multiple regions from one connection` → **Direct Connect Gateway**
  - `DX + encryption` → **Site-to-Site VPN over a Public VIF** on DX
  - `Multiple offices connected to AWS and to each other via VPN` → **VPN CloudHub**
  - `Remote users secure access to VPC` → **AWS Client VPN**
  - `Network traffic analysis / connectivity troubleshooting` → **VPC Flow Logs**
  - `IPv6 outbound only — block inbound` → **Egress-only Internet Gateway**
  - `VPC peering across regions` → Supported ※; CIDR cannot overlap
  - `Consistent performance + private connection on-premises to AWS` → **Direct Connect**
  - `On-premises to AWS — lowest cost, fastest to deploy` → **Site-to-Site VPN**
  - `Local Zones vs Wavelength Zones` → Local Zones = low-latency metro apps; Wavelength = 5G edge apps

---

## Quick References

### [VPC Architecture Patterns Private Link](https://drive.google.com/drive/folders/1ddnjjXC23tnUzA3TuWBkGVV8SWofWHm7?usp=drive_link)

### [Exam Cram — VPC](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28617860#overview)

### [VPC Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346102#overview)

### [VPC Cheat Sheet](https://digitalcloud.training/amazon-vpc/)

### [Direct Connect Cheat Sheet](https://digitalcloud.training/aws-direct-connect/)

### [CIDR Calculator](https://www.ipaddressguide.com/cidr)

### [Subnet Calculator](https://www.subnet-calculator.com/)

---

> ### Symbol Key:
> - `†` quota or limit 
> - `‡` hardware/performance spec 
> - `§` AWS default behavior
> - `※` feature availability 
> - `¤` pricing-related 
> - `◊` regional variance
> - `Δ` recently changed (older sources may describe prior behavior)
> - All flagged values are subject to change — verify against current AWS documentation before relying on them for design decisions.