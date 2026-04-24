## Amazon Global Infrastructure

- **Regions:** a physical geographical area in the world 
  - consists of multiple **Availability Zones (AZs)**

- **Availability Zones (AZs):** a data center or a group of data centers

- **Outposts:** a fully managed service that extends AWS infrastructure, services, APIs, and tools to customer premises
  - allows customers to run AWS services on-premises for a hybrid experience

- **Local Zones:** an extension of an AWS Region that is geographically close to your users
  - higher costs, but lower latency for apps thatrequire single-digit millisecond latency

- **Wavelength Zones:** infrastructure deployments that extend AWS infrastructure to the edge of the 5G network
  - designed for applications that require ultra-low latency
    - such as AR, VR and ML at the edge

- **Edge Locations:** sites that CloudFront uses to cache copies of your content for faster delivery to users at any location
  - also used by **AWS Global Accelerator** and **AWS Lambda@Edge**

---

## CloudFront

- **CloudFront** is a content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency and high transfer speeds.
  - uses a global network of edge locations to cache content closer to users
  - integrates with other AWS services like **S3, EC2, and Lambda** for dynamic content delivery

---

## Structure of an IPv4 address

Written in dotted decimal notation, consisting of four octets separated by periods 
  - Each binary octet can range from 0 to 255, representing 8 bits of the address
    - Left hand → most significant bits (MSB)
    - Right hand → least significant bits (LSB)
    - **Example:** `192 . 168 . 0 . 1`
      - **192** → `11000000` (128 + 64)
      - **168** → `10101000` (128 + 32 + 8)
      - **0** → `00000000` (0)
      - **1** → `00000001` (1)

- **Network ID portion:** identifies the specific network to which the IP address belongs
  - Same for all devices within the same network 
  - e.g., `192.168.0`

- **Host ID portion:** identifies the specific device (host) within that network
  - Unique for each device within the same network
  - e.g., `.1`

- **Subnet Mask:** is used to determine which part of the IP address is the network ID and which part is the host ID 
  - Written in dotted decimal notation, similar to an IP address
  - e.g., `255.255.255.0` (24 bits for network ID, 8 bits for host ID)

- **CIDR (Classless Inter-Domain Routing) notation:** represents IP addresses and their associated network masks in a compact format
  - e.g., `192.168.0.0/24`
    - `/24` → first 24 bits are the network ID
    - Remainder (8 bits) are for host IDs 

---

## Private IP Address Ranges

These addresses are reserved for **private use** according to IETF RFC-1918

- **IPv4 Private Address Ranges:**
  - `10.0.0.0` → `10.255.255.255`
  - `172.16.0.0` → `172.31.255.255`
  - `192.168.0.0` → `192.168.255.255`

These addresses are not routable on the public internet and are used for internal communication within a private network 
  - e.g., within a VPC in AWS, or within a corporate network

---

## Amazon VPC (Virtual Private Cloud)

- A **VPC** is a logically isolated section of the AWS Cloud within a region
  - Cotain subnets, route tables, internet gateways, and other resources
  - You can launch AWS resources, such as EC2 instances, into your VPC

Default limit of 5 VPCs per region, but can be increased by requesting a limit increase from AWS Support

---

## Internet Connectivity in VPCs

- **VPC Router:** a virtual router that controls the routing of traffic of the VPC
  - Routes traffic between subnets, to the internet, and to other VPCs
  - You interact with it indirectly through route tables

- **Internet Gateway (IGW):** attaches to a VPC to enable internet connectivity for resources in the VPC
  - Used by public subnets to enable communication with the internet
  - Only one IGW can be attached to a VPC at a time
  - **Ingress and egress traffic** - allows both inbound and outbound traffic  

- **NAT Gateway:** enables instances in a private subnet to connect to the internet or other AWS services
  - Prevents the internet from initiating connections with those instances
  - **Egress-only service** - outbound traffic is allowed, but inbound traffic is blocked

---

## Amazon VPC Components (High-Level Overview)

| **Component** | **What it is** | 
| :---: | --- |
| **VPC** | A virtual network dedicated to your AWS account |
| **Subnet** | A segment of a VPC's IP address range where you can place **groups of isolated resources** |
| **Internet Gateway (IGW)** | Enables communication between instances in your VPC and the internet (IPv4 & IPv6) |
| **Router** | Controls the routing of traffic **within the VPC** |
| **Peering Connection** | A direct connection between **two VPCs** |
| **VPC Endpoint** | A private connection between your VPC and supported AWS services **without using the internet** |
| **NAT Instances** | Enables instances in a private subnet to connect to the internet (**user managed**) |
| **NAT Gateway** | Enables instances in a private subnet to connect to the internet (**AWS managed**) |
| **Virtual Private Gateway** | Enables the VPC side of a **Virtual Private Network (VPN)** connection |
| **AWS Direct Connect** | A high-speed, high-bandwidth, connection from your premises to AWS |
| **Security Groups** | Instance-level virtual firewall (**stateful**, automatically allows return traffic) |
| **Network ACLs** | Subnet-level virtual firewall (**stateless**, evaluate both inbound and outbound rules separately) |

---

## VPC Core Concepts

- A VPC is a **logical isolation** of the AWS Cloud dedicated to your AWS account
  - You have complete control over your virtual networking environment, including selection of IP address range, creation of subnets, and configuration of route tables and network gateways
  - Analogous to having your own data center in the cloud, but without the need to manage physical hardware

- A VPC spans all the Availability Zones in the region, but each subnet must reside entirely within one AZ

- **Default VPC:** AWS automatically creates a default VPC in each region for your account, which includes a default subnet in each AZ, an internet gateway, and default route tables and security groups
  - You can use the default VPC or create your own custom VPCs to meet specific requirements

---

## Defining CIDR Blocks for a VPC

- CIDR blocks size can be between `/16` and `/28`
  - `/16` → $2^{16}$ host bits = 65,536 IP addresses (**largest size**)
  - `/28` → $2^{4}$ host bits = 16 IP addresses (**smallest size**)
  - 32 bits total, so the number of `host bits = 32 - prefix length`

- CIDR blocks must not overlap with any other CIDR blocks associated with the VPC
- Cannot increase or decrease the size of an existing CIDR block 
- The first four IP addresses and the last IP address in each subnet are reserved by AWS
- AWS recommends using a CIDR block from RFC 1918 ranges

---

## Private IP Address Ranges

| **RFC 1918 Range** | **Example CIDR Block** | 
| :---| :--- |
| `10.0.0.0` → `10.255.255.255` (`10/8` prefix) | Must be `/16` or smaller, i.e., `10.0.0.0/16` |
| `172.16.0.0` → `172.31.255.255` (`172.16/12` prefix)| Must be `/16` or smaller, i.e., `172.16.0.0/16` |
| `192.168.0.0` → `192.168.255.255` (`192.168/16` prefix) | Can be smaller, i.e., `192.168.0.0/20` |

---

## Subnet Masking and Subnetting

- `/24` is a common CIDR block size for subnets within a VPC 
  - Borrows 8 bits from the host portion for subnetting (`/16` to `/24`)
    - Allows a longer subnet mask, which means more subnets and fewer hosts per subnet
  - Allows for 256 subnets ($2^8$) (including reserved addresses)

### Additional Considerations for Subnetting

  - Ensure you have enough networks and hosts
  - **Bigger CIDR blocks** (e.g., `/16`) are typically better (more flexibility)
    - Can lead to wasted IP addresses if not used efficiently
  - **Smaller CIDR blocks** (e.g., `/24`) can lead to more efficient use of IP addresses
    - May require more careful planning to ensure enough subnets and hosts
  
  - Consider deploying application tiers per subnet for better security and management
    - e.g., web, application, database 
  
  - Split your HA resources across multiple subnets in different AZs
    - Allows for high availability and fault tolerance 
  
  - VPC Peering requires non-overlapping CIDR blocks
    - This is across all VPCs in all Regions / Accounts that you want to peer with

### **AVOID OVERLAPPING CIDR BLOCKS WHENEVER POSSIBLE (as shown in the table below)**

| Subnet Name | IPv4 CIDR Block | Availability Zone | Route Table | Auto-assign Public IPv4 |
| :---: | :---: | :---: | :---: | :---: |
| `private-1a` | `10.0.0.0/24` | `us-east-1a` | `Private-RT` | No |
| `private-1b` | `10.0.1.0/24` | `us-east-1b` | `Private-RT` | No |
| `private-1c` | `10.0.2.0/24` | `us-east-1c` | `Private-RT` | No |
| `public-1a` | `10.0.3.0/24` | `us-east-1a` | `MAIN` | Yes |
| `public-1b` | `10.0.4.0/24` | `us-east-1b` | `MAIN` | Yes |
| `public-1c` | `10.0.5.0/24` | `us-east-1c` | `MAIN` | Yes |

Use a [VPC CIDR calculator](https://www.ipaddressguide.com/cidr) or [subnet calculator](https://www.subnet-calculator.com/) to help with subnetting and CIDR block planning

---

## HOL - Creating a Custom VPC Manually

- When making a VPC manually, be sure to:
  - Map the `Private-RT` to the **private subnets**
  - Map the `Main-RT` to the **public subnets**
    - Or leave it as is since it's the default RT

---

## Security Groups vs Network ACLs

- **Security Groups (SGs)**
  - **Instance level** virtual firewall 
  - **Stateful**: Has state awareness (memory of previous traffic)
  - Automatically allows return traffic 
    - e.g., if you allow outbound traffic on port 80 <br>
    → automatically allow the return traffic for that connection

- **Network Access Control Lists (NACLs)**
  - **Subnet level** virtual firewall
  - **Stateless**: Does not have state awareness (no memory of previous traffic)
  - Seperate evaluation of inbound and outbound rules
    - Only applies to traffic that is entering or leaving the subnet

---

| **Security Groups** | **Network ACLs** |
| :---: | :---: |
| Instance level | Subnet level |
| Allow rules **ONLY** | Allow **AND** deny rules |
| Stateful | Stateless |
| Evaluates all rules | Evaluates rules in order |
| Applies to **AN** instance <br>if associated w/ group | Applies to **ALL** instances <br>in the subnet |
| Automatically allows return traffic | Must explicitly allow return traffic |

---

## HOL - Security Groups and Network ACLs

* `sudo su` to switch to root user and avoid permission issues with `iptables` commands

Can create a script for a simple web server as follows:

1. `nano user-data.sh` to create a user data script that will run on instance launch
2. Add the following content to the script:

```bash
#!/bin/bash

# Update the package index and install Apache HTTP Server
yum update -y
yum install -y httpd

# Start the Apache HTTP Server and enable it to start on boot
systemctl start httpd
systemctl enable httpd

```
3. Save and exit the script
4. `chmod +x user-data.sh` to make the script executable
5. `./user-data.sh` to run the script and set up the web server

**Notes:**
- For security groups, you must set rules for inbound and outbound traffic separately
- Security group chaining allows you to reference another security group in the rules
  - Such as allowing inbound traffic from instances associated with a specific security group
  - This is useful for allowing traffic between instances in different security groups without needing to specify IP addresses
- For network ACLs, you must specify both allow and deny rules explicitly
- Network ACLs evaluate rules in order, starting with the lowest numbered rule
  - The first rule that matches the traffic is applied, and no further rules are evaluated
    - If rule 99 **allows** traffic and rule 100 **denies** traffic, then the traffic will be **allowed** because rule 99 is evaluated first
    - If rule 99 **denies** traffic and rule 100 **allows** traffic, then the traffic will be **denied** because rule 99 is evaluated first
  - If no rules match, the default action is to deny the traffic

---

## HOL - VPC Peering

* You can use CloudFormation to create a VPC peering connection between two VPCs (any region, any account)
  - Create a CloudFormation stack in each VPC to create the peering connection
  - Use the `AWS → EC2 → VPC → Peering Connections` resource to create the peering connection
  - Use the `AWS → EC2 → Route Tables` resource to add routes to the route tables in each VPC to allow traffic to flow between the peered VPCs

* Can find an example template in the `code` folder of this repository named `vpc-peering.yaml` 
  - Make sure to update the `ImageId` parameters before launching the stack

* You can delete the peering connection by deleting the CloudFormation stacks in both VPCs
  - Deleting the stack will automatically delete the peering connection and any associated resources 
    - e.g., route table entries

---

## VPC Endpoints

- A **VPC Endpoint** is a private connection between your VPC and supported AWS services without using the internet
  - Traffic between your VPC and the other service does not leave the Amazon network
  - Can connect to an **AWS PrivateLink** powered service
    - A service that is hosted by another AWS account and made available to you through PrivateLink

- An **ENI (Elastic Network Interface)** is created in your VPC (subnet) for the endpoint, and traffic to the service is routed through this ENI
  - The ENI has a private IP address from your VPC's CIDR block
  - It serves as an entry point for traffic destined to the service

---

## VPC Endpoint Policies

- **Bucket Policy** (resource-based)
  - Can restrict access using aws:SourceVpce
  - Controls who/what can access the bucket

- **IAM Policy** (identity-based)
  - Controls what actions a user/role can perform

- **VPC Endpoint Policy** (endpoint-based)
  - Controls what traffic is allowed through the endpoint
  - Can restrict actions and resources

| | **Interface Endpoint** | **Gateway Endpoint** |
| :---: | :---: | :---: |
| **What** | ENI w/ private IP | A gateway that is a target<br> for a specific route |
| **How** | Uses DNS entries<br> to redirect traffic | Uses prefix lists in<br> RTs to redirect traffic |
| **Supported<br>Services** | API Gateway, CloudFormation,<br>CloudWatch, etc. | Amazon S3, DynamoDB |
| **Security** | Security groups | VPC Endpoint Policies |

---

## Service Provider Model

To access a service through a VPC Endpoint, the Consumer provisions the endpoint in their VPC and then connects to the NLB of the Service Provider's service.

---

## HOL - Create a Custom VPC

1. Create a VPC choosing the `VPC and more` option
2. Provide a name for the VPC, e.g. `lab1-custom-vpc`
3. No NAT Gateway
4. Use defaults for other selections
5. Modify the public subnets to auto assign IPv4 addresses

### Test the S3 Gateway Endpoint

1. Launch an instance in a public subnet of the VPC with S3 read only permissions
2. Connect to the instance using EC2 Instance Connect 
3. Run `aws s3 ls` - you should receive a list of buckets
4. Edit the policy on the S3 gateway endpoint to change `Allow` to `Deny`
5. Run `aws s3 ls` again - it should not have changed (should work)
6. Edit the S3 gateway endpoint to add the public route table
7. Run `aws s3 ls` again - this time access should be denied
8. Revert the policy and it should start working again (via the S3 gateway endpoint)

**Notes:**
  - Might need to add a Public IP address to the instance
    - Enable auto-assign public IPv4 addresses on the subnet or assign a public IP address to the instance during launch
  - Can use `aws s3 ls` to see the list of buckets in the account
    - Won't be able to access the buckets if the endpoint policy is set to `Deny` or if the route table is not associated with the endpoint
  
---

## Amazon Remote Connection Types

- **Amazon Client VPN** is a managed client-based VPN service
  - You can utilize any OpenVPN-based client to connect to the Client VPN endpoint
  - Provides secure access to your AWS resources and on-premises network from any location

- **AWS Site-to-Site VPN** is a managed VPN service that connects your on-premises network to your AWS VPCs
  - Uses **IPsec (Internet Protocol Security)** to establish secure tunnels between your network and AWS
  - **VGW (Virtual Private Gateway)** is deployed on the **AWS side** 
    - Route table connects to the VGW to route traffic
  - **CGW (Customer Gateway)** is deployed on the **on-premises side**
  - Provides a secure and reliable connection for hybrid cloud architectures 
  - Supports both static and dynamic routing, **BGP (Border Gateway Protocol) peering/routing**
    - BGP allows for dynamic routing and automatic failover between multiple VPN tunnels

---

## AWS VPN CloudHub

- **AWS VPN CloudHub** enables you to securely connect multiple on-premises networks to a single AWS VPC using Site-to-Site VPN connections
  - Uses a hub-and-spoke model where the AWS VPC serves as the hub and the on-premises networks serve as the spokes 
  - Each office must have its own unique **BGP ASN (Autonomous System Number)** to establish BGP peering with the VGW in the AWS VPC
  - Uses IPsec VPN tunnels for secure connections

---

## AWS Direct Connect

- **AWS Direct Connect** is a cloud service solution that establishes a dedicated network connection from your premises to AWS
  - Provides a more consistent network experience than internet-based connections
  - DX Port (1000-Base-X or 10G-Base-LR) must be allocated to a Direct Connect location
  - A cross connect is then established between DX Router and the customer/partner DX Router
  - DX is a physical fiber connection to AWS at 1 Gbps or 10 Gbps speeds (or 100 Gbps in some locations)
  - The customer router is connected to the DX router at the Direct Connect location

- **VIF (Virtual Interface)** uses DX (802.1Q VLAN) and a BGP session is established over the VIF for routing
  - **Private VIF** is used to connects a single VPC in the same region using a VGW
    - Multiple Private VIFs can be used to connect to multiple VPCs in the same region using a TGW
    - Hosted VIF is shared by multiple accounts and can connect to a single VPC or multiple VPCs in the same region using a TGW

  - **Public VIF** is used to connect to AWS public services (e.g., S3, DynamoDB)

  - **Transit VIF** is used to connect to a TGW for access to multiple VPCs across regions
    - Allows you to connect to multiple VPCs across different regions using a single Direct Connect connection

---

## Direct Connect Gateway (DXGW)

- A **Direct Connect Gateway (DXGW)** is a globally available resource that allows you to connect your Direct Connect connection to one or more VPCs across different AWS Regions
  - Acts as a central hub for your Direct Connect connections, enabling you to manage connectivity to multiple VPCs from a single location

## Transit Gateway (TGW)

- A **Transit Gateway (TGW)** is a network transit hub that you can use to interconnect your VPCs and on-premises networks
  - Acts as a central hub for routing traffic between your VPCs and on-premises networks, simplifying your network architecture and reducing the number of connections required

---

| **Direct Connect<br> Gateway (DXGW)** | **Transit Gateway (TGW)** |
| :---: | :---: |
| Connects Direct Connect<br> to VPCs across regions | Connects VPCs and<br> on-premises networks |
| Global resource | Regional resource |
| Used for Direct<br>Connect connections | Used for VPC peering<br> and VPN connections |

---

## IPv6 in VPCs


### IPv4 vs IPv6
- An IPv4 address is 32 bits long, while an IPv6 address is 128 bits long
  - 4.3 billion IPv4 addresses vs 340 undecillion IPv6 addresses
  - one undecillion = $10^{36}$ = 1 billion trillion trillion
    - 100 IPv6 addresses for every atom on Earth

### IPv6
- IPv6 addresses are written in hexadecimal and separated by colons
  - e.g., `2001:0db8:85a3:0000:0000:8a2e:0370:7334`
- AWS provides a default IPv6 CIDR block of `/56` for your VPC
- You can also request a custom IPv6 CIDR block if needed
- A hexadecimal pair is assigned to each subnet (values from `00` to `ff`)
- Allowing for 256 subnets within the `/64` subnets
  - `/64` allows for 18 quintillion (18 million trillion) IPv6 addresses per subnet
- All IPv6 addresses are publicly routable (no NAT needed)

**Egress-only Internet Gateway** allows outbound IPv6 traffic to the internet but blocks inbound traffic initiated from the internet

---

## Quick References

### [Exam Cram - VPC](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/lecture/28617860#overview)

### [VPC Architecture Patterns Private Link](https://drive.google.com/drive/folders/1ddnjjXC23tnUzA3TuWBkGVV8SWofWHm7?usp=drive_link)

### [VPC Quiz](https://www.udemy.com/course/aws-certified-solutions-architect-associate-hands-on/learn/quiz/5346102#overview)

### [VPC Cheat Sheet](https://digitalcloud.training/amazon-vpc/)
### [Direct Connect Cheat Sheet](https://digitalcloud.training/aws-direct-connect/)

---