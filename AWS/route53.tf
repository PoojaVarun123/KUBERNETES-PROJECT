1. What is Amazon Route 53?
Answer:
Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service designed to give developers and businesses an extremely reliable and cost-effective way to route end users to Internet applications. The “53” refers to the DNS port number.

It performs three main functions:

Domain registration

DNS routing

Health checking and failover

2. What types of routing policies does Route 53 support?
Answer:
Amazon Route 53 supports the following routing policies:

Routing Policy	Description
Simple Routing	Basic DNS record mapping without conditions.
Weighted Routing	Distributes traffic based on assigned weights (e.g., 70%-30%).
Latency-based	Routes users to the lowest latency endpoint.
Failover Routing	Routes traffic to a backup when the primary fails.
Geolocation	Routes based on the geographic location of the requester.
Geoproximity	Routes based on the proximity of the user to AWS resources.
Multi-value Answer	Returns multiple healthy records to support load balancing.

3. What is a hosted zone in Route 53?
Answer:
A hosted zone is a container for records belonging to a single domain. It’s similar to a traditional DNS zone file. There are two types:

Public Hosted Zone: Resolves domain names on the internet.

Private Hosted Zone: Used within an Amazon VPC for internal DNS resolution.

4. What is the TTL (Time to Live) in DNS records?
Answer:
TTL is a setting in DNS records that tells resolvers how long to cache the response. A lower TTL leads to quicker propagation of DNS changes but increases DNS query traffic. Higher TTL improves performance and reduces DNS cost.

5. What are alias records in Route 53? How are they different from CNAME?
Answer:
Alias records are Route 53-specific records that allow you to map a domain name to AWS resources, such as:

ELB

CloudFront

S3 static website

API Gateway

Differences from CNAME:

Alias can be used at the root domain (e.g., example.com) — CNAME cannot.

Alias doesn’t incur additional DNS query charges.

Alias is resolved by Route 53 itself.

6. How does Route 53 ensure high availability and fault tolerance?
Answer:
Route 53 achieves this by:

Using a global network of DNS servers (edge locations).

Supporting failover routing with health checks.

Allowing multi-region, latency-based routing.

Built-in DNSSEC for domain name integrity.

7. Can Route 53 be used for private DNS resolution?
Answer:
Yes, by creating Private Hosted Zones, Route 53 can resolve domain names within a VPC, useful for internal services like microservices or databases not exposed to the internet.

8. What is DNS failover in Route 53?
Answer:
It refers to Route 53’s ability to automatically switch DNS resolution to a healthy resource if a health check fails for the primary endpoint. This ensures high availability and disaster recovery.

9. How do health checks work in Route 53?
Answer:
Health checks monitor:

HTTP/HTTPS/TCP endpoints

Status of other Route 53 health checks

CloudWatch alarms

If an endpoint fails the health check, Route 53 can:

Remove it from DNS responses

Trigger failover

Alert via CloudWatch

10. What is DNSSEC? Does Route 53 support it?
Answer:
DNSSEC (Domain Name System Security Extensions) adds authentication to DNS, preventing attacks like DNS spoofing.

Yes, Route 53 supports:

DNSSEC signing for hosted zones

DNSSEC validation via the domain registrar and resolver chain

🔹 SECTION 2: SCENARIO-BASED QUESTIONS
11. Your company runs an application in two AWS regions. How would you set up Route 53 to route users to the closest region?
Answer:
Use Latency-Based Routing (LBR) in Route 53.

Steps:

Create a record for each region (e.g., app.example.com in us-east-1 and eu-west-1).

Attach the records to the corresponding ELB or EC2 public IP.

Enable LBR so that users are routed based on latency to the nearest region.

Optionally, enable health checks for failover.

12. A customer wants their API to failover to a backup region if the primary fails. How will you configure it?
Answer:
Use Failover Routing policy.

Setup:

Primary record: api.example.com pointing to main region ELB.

Secondary record: same domain pointing to backup region.

Configure health check for primary region.

Route 53 automatically switches to backup when primary fails.

13. You need to split 80% traffic to blue environment and 20% to green. How would you do it?
Answer:
Use Weighted Routing Policy.

Steps:

Create two A/alias records for app.example.com.

One for the blue environment (weight: 80), one for green (weight: 20).

Attach health checks if needed to avoid routing to unhealthy environments.

14. Your internal microservices need DNS but should not be exposed to the internet. What’s the best approach?
Answer:
Use Private Hosted Zones (PHZ).

Setup:

Create a PHZ for service.internal.

Attach it to the relevant VPC.

Microservices can resolve names using internal Route 53 resolvers.

DNS resolution stays private and secure.

15. You are migrating your domain from another registrar to Route 53. What are the steps?
Answer:

Unlock the domain in the current registrar.

Get the auth code (EPP code).

Go to Route 53 → Domain Registration → Transfer Domain.

Enter the domain and EPP code.

Approve the transfer via confirmation email.

After transfer, configure the hosted zone and records.

Update the NS records at the registrar if not automatically handled.

🔹 SECTION 3: HIGH-LEVEL ARCHITECTURE QUESTIONS
16. Explain a high-level architecture using Route 53 to serve a global website with low latency and high availability.
Answer:

Architecture:

Global Web Application hosted in multiple AWS regions.

Elastic Load Balancers (ELB) in each region.

Route 53 Latency-Based Routing configured with health checks.

Each record has latency-based routing to the region's ELB.

Health checks monitor ELBs — in case of failure, Route 53 routes to next nearest healthy region.

CloudFront used in front of application for caching and DDoS protection.

Optional: use Geo-proximity routing if you want traffic segmentation by user region.

17. How would you architect a solution to support blue-green deployment using Route 53?
Answer:

Architecture:

Deploy both blue and green environments behind separate ELBs.

Create Route 53 records:

blue.app.example.com → Blue ELB

green.app.example.com → Green ELB

app.example.com → Alias/Weighted to blue or green

During deployment:

Change the weight gradually from blue to green.

Monitor traffic and app health.

Roll back if needed by switching weights back.

Advantages:

Zero downtime deployment

Easy rollback

DNS-level control

18. How would you secure your Route 53 setup for an enterprise-level domain?
Answer:

Key steps:

Enable DNSSEC to prevent spoofing.

Use IAM roles and policies to restrict who can modify DNS.

Use CloudTrail logging for auditability.

Set up health checks and alerts for downtime detection.

Implement failover routing for disaster recovery.

Use private hosted zones for internal-only DNS.

Regularly rotate credentials and restrict access via SCP if in Organizations.

19. How does Route 53 interact with other AWS services like ELB, CloudFront, and S3?
Answer:

ELB: Route 53 alias records can directly point to ELBs.

CloudFront: Domain names (like www.example.com) can point to a CloudFront distribution using alias.

S3: Static websites hosted in S3 can be mapped via alias records in Route 53.

Lambda / API Gateway: Used for backend APIs; Route 53 routes traffic via custom domains.

ACM (Certificate Manager): Works with Route 53 for DNS validation of SSL certificates.

20. Can Route 53 be part of a disaster recovery strategy?
Answer:
Yes, Route 53 is integral in DR strategies:

Use Cases:

Route traffic to a secondary site in another region.

Use failover routing with health checks.

Update TTL to control DNS propagation time during recovery.

Combined with RTO and RPO planning.

✅ Summary
Type	Count
🔹 Theoretical	10
🔹 Scenario-Based	5
🔹 High-Level Architecture	5
