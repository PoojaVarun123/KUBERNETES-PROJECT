================================================================================================================================================
1) How Can I Make My Instances Highly Available?
        High Availability (HA) in AWS ensures that your application or workload remains operational even in the event of failures 
        (hardware, network, zone-level). Here's how to design for HA:

✅ Strategies to Achieve HA for Instances:
a) Use Multiple Availability Zones (AZs):
        -Deploy EC2 instances across at least two AZs within a single region.
        -This protects against AZ-level failures like power outages, natural disasters, etc.

b) Use Auto Scaling Group (ASG) with Multi-AZ:
        -Create an ASG with a minimum and desired capacity across AZs.
        -It will automatically replace failed instances, scale in/out based on demand.

c) Use Elastic Load Balancer (ELB):
        -Place your EC2 instances behind an Application Load Balancer (ALB) or Network Load Balancer (NLB).
        -ELB automatically distributes traffic across multiple healthy instances in different AZs.

d) Health Checks and Self-Healing:
        -Configure ELB health checks and ASG EC2 instance health checks.
        -Unhealthy instances are terminated and replaced automatically.

e) Use Launch Templates with AMIs:
        -Prepare golden AMIs with all dependencies baked-in.
        -When ASG spins up new instances, it uses the AMI to bootstrap in minutes.

f) Use EBS with Snapshots or Use Amazon EC2 Instance Store (for stateless):
        -If using EBS, enable EBS Volume replication and automated snapshots for fast restore.

🏗️ Architecture:
Clients --> Route 53 (health check based DNS) -->
        --> ALB --> ASG in multiple AZs --> EC2 instances with pre-baked AMI
--------------------------------------------------------------------------------------------------------------------------------------------------
2) How Can I Set Up Disaster Recovery (DR) for the App?
        Disaster Recovery (DR) ensures business continuity when a region-level failure or major infrastructure outage occurs.
✅ Key DR Strategies in AWS (based on RTO/RPO):
Strategy   -	RTO -	RPO -	Cost  -	Notes
Backup & Restore -	Hours -	Hours -	Low -	Backups stored in S3/Glacier
Pilot Light - Minutes - Minutes	- Medium -	Core infrastructure running in standby
Warm Standby  -	Minutes	- Seconds - High -	Partial workload running in secondary region
Active-Active  -Seconds	- Seconds - Very High -	Fully deployed in multiple regions

🛠️ Implementation Steps (Warm Standby or Active-Passive):
Backup Strategy:
        Use AWS Backup or custom Lambda to backup EC2 AMIs, RDS snapshots, S3 objects (versioned).
        Use cross-region replication for RDS, S3, DynamoDB, and EBS snapshots.
Infrastructure as Code (IaC):
        Store Terraform/CloudFormation scripts in source control for fast redeployment in another region.
Cross-region Replication:
        S3 Cross-Region Replication (CRR)
        RDS Read Replica in another region
        DynamoDB Global Tables
        EBS snapshot copy to another region
Route 53 Failover:
        Use Route 53 health checks + failover routing policy to switch traffic to DR site.
DR Test Automation:
        Run regular DR drills using scripts or pipelines to validate recovery capability.
--------------------------------------------------------------------------------------------------------------------------------------------------
3) How Can I Achieve Data Migration?
Data migration is needed during cloud adoption, app re-platforming, or region/account migration.

✅ Types of Data and Tools:
Data Type	- AWS Service/Tool	- Notes
Files (S3)	- S3 Transfer Acceleration, AWS DataSync, AWS Snowball	- Fast/bulk movement
DB (SQL/NoSQL)	- AWS DMS (Database Migration Service)	- Supports homogeneous and heterogeneous
EBS Volumes	- Snapshots + Copy	- Used with AMI-based migration
VMs	- AWS Application Migration Service (MGN) - 	Lift-and-shift EC2 migration
Large Datasets	- AWS Snowball/Snowmobile	- Offline transfer for Petabyte scale

🛠️ Steps for DB Migration Using AWS DMS:
        -Create source & target endpoints (MySQL → RDS, for example)
        -Create replication instance
        -Define migration task (full load, CDC or both)
        -Enable CloudWatch logs for monitoring
        -Test data integrity post migration

🔁 Real-Time Sync:
Enable Change Data Capture (CDC) for zero-downtime migrations.
--------------------------------------------------------------------------------------------------------------------------------------------------
4) How Can I Secure AWS Infrastructure?
        Securing AWS infrastructure requires a multi-layered approach covering network, access, data, and monitoring.

✅ Best Practices for AWS Infra Security:
a) IAM and Access Management:
        -Enforce least privilege principle.
        -Use IAM Roles, not long-lived access keys.
        -Enable MFA for users and root account.
        -Use permission boundaries and service control policies (SCPs) in org.

b) Network Security:
        -Use VPC with private/public subnets (segregate tiers).
        -Apply Security Groups (SGs) and NACLs with strict rules.
        -Enable VPC Flow Logs for traffic monitoring.

c) Data Protection:
        -Encrypt data at rest using KMS-managed keys (SSE-KMS) for EBS, RDS, S3.
        -Encrypt in-transit using TLS/HTTPS.
        -Enable Object Lock + Versioning in S3.

d) Logging & Auditing:
        -Enable CloudTrail for API logging.
        -Use AWS Config for compliance auditing.
        -Aggregate logs to CloudWatch or S3.

e) Patch Management:
        Use AWS Systems Manager Patch Manager to patch OS and apps regularly.

f) Infrastructure as Code Scanning:
        Use Checkov, TFSec, CloudFormation Guard to validate IaC against security policies.
--------------------------------------------------------------------------------------------------------------------------------------------------
5) How Can I Secure My Application?
Application security covers code, API, runtime, data, and deployment pipeline security.

✅ Best Practices:
a) API Security:
        -Use API Gateway + Cognito/OAuth2.0 for secure access.
        -Throttle API requests (rate limiting).
        -Enable WAF rules to protect against SQLi/XSS.

b) Secret Management:
        -Use AWS Secrets Manager or SSM Parameter Store (encrypted) for DB passwords, API keys.
        -Never hardcode secrets into code/repos.

c) CI/CD Pipeline Security:
        -Enable code scanning (Snyk, SonarQube) in pipelines.
        -Use signed artifacts, store securely in ECR/S3 with versioning.

d) Runtime Security:
        -Use Amazon Inspector for vulnerability scanning of EC2/ECR.
        -Use AppArmor/SELinux for OS-level security in containers.

e) Web Application Firewall (WAF):
        -Use AWS WAF with OWASP Top 10 rules to protect frontends.
        -Integrate with CloudFront or ALB.

f) HTTPS and TLS:
        -Enforce HTTPS-only access using ACM certificates.
        -Use TLS 1.2 or above.
--------------------------------------------------------------------------------------------------------------------------------------------------
6) How Can I Monitor AWS Infrastructure?
Monitoring ensures observability, alerting, and proactive response to incidents.

✅ Key Monitoring Tools in AWS:
a) Amazon CloudWatch:
        -Metrics: CPU, memory, disk, custom metrics.
        -Logs: Centralized log aggregation.
        -Alarms: Threshold-based alarms (e.g., CPU > 80%)
        -Dashboards: Visualize metrics across services.

b) AWS X-Ray:
        -Distributed tracing for microservices and Lambda.
        -Helps identify bottlenecks and performance issues.

c) CloudTrail:
        -Records API-level actions across AWS accounts.
        -Detects unauthorized activity or changes.

d) AWS Config:
        -Tracks configuration changes.
        -Validates against compliance rules (e.g., “EBS should be encrypted”).

e) 3rd Party Integrations:
        -Prometheus + Grafana for advanced monitoring (EKS, EC2).
        -Datadog, NewRelic, Splunk, PagerDuty for enterprise setups.

f) Anomaly Detection:
        -Use CloudWatch Anomaly Detection for dynamic thresholds.
        -Integrate with SNS, Lambda, or OpsCenter for automation.

📈 Example Monitoring Stack:
CloudWatch Logs --> Log Groups --> Metric Filters --> Alarms --> SNS
CloudTrail --> S3 + CloudWatch
X-Ray --> Trace Segments
Prometheus (Node Exporter + Kube Metrics) --> Grafana Dashboards
