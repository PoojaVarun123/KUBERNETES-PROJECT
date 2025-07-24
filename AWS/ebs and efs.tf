=========================================================================================================================================
1. What is Amazon EBS? How does it differ from EC2 instance store?
  Amazon EBS (Elastic Block Store) provides persistent, block-level storage volumes for EC2 instances. 
  It allows you to attach volumes to instances and retain data independently from the instance lifecycle.

Feature	-EBS	- Instance Store
    Data Persistence	- Persistent -	Ephemeral (lost on stop/terminate)
    Backup Support	Snapshots supported	- No backup
    Durability	- High (replicated within AZ)	- No replication
    Use Case	 - Databases, file systems	- Temp scratch space, buffer
-------------------------------------------------------------------------------------------------------------------------------------------------
2. Explain the different types of EBS volumes.
  Volume Type	Use Case	IOPS	Throughput	Notes
      -gp3	General-purpose SSD	- Up to 16,000	Up to 1,000 MB/s	- Default choice
      -gp2	Older general-purpose - SSD	3 IOPS/GB	Burstable -	Replaced by gp3
      -io2/io2 Block Express	- High-performance apps like DBs	Up to 256,000	- High	Durable, 99.999% SLA
      -st1	Throughput-optimized HDD	- Not for random I/O	Up to 500 MB/s	- Cost-effective for large, sequential workloads
      -sc1	Cold HDD	- Lowest cost	Max 250 MB/s	- Archival, infrequent access
-------------------------------------------------------------------------------------------------------------------------------------------------
3. What is an EBS snapshot and how is it stored?
  -An EBS snapshot is a point-in-time backup of an EBS volume stored in Amazon S3 (internally managed by AWS, not visible in your S3 buckets).
  -It's incremental – only changed blocks are saved after the first full snapshot.
  -You can use snapshots to:
      Create new volumes
      Move volumes across AZs or Regions
      Backup for disaster recovery
-------------------------------------------------------------------------------------------------------------------------------------------------
4. Can we attach an EBS volume to multiple EC2 instances simultaneously?
    Not directly. EBS volumes are AZ-specific and attached to only one EC2 instance at a time (for most use cases).
-------------------------------------------------------------------------------------------------------------------------------------------------
5. What happens when you stop or terminate an EC2 instance with EBS?
  -Action	- Effect on EBS volume
  -Stop	- Volume remains attached
  -Terminate	- If DeleteOnTermination = true, volume is deleted. Otherwise, it persists.
  -Use "DeleteOnTermination" attribute carefully based on data importance.
-------------------------------------------------------------------------------------------------------------------------------------------------
6. How do you increase the size and performance of an EBS volume?
    -You can modify volume size, type, or IOPS using the ModifyVolume API or AWS Console.
    -No downtime required (online resizing).
    -Use lsblk, growpart, and resize2fs/xfs_growfs inside the EC2 instance to expand file system.
-------------------------------------------------------------------------------------------------------------------------------------------------
7. Scenario: You have a large application database on EBS that needs to scale reads across multiple EC2 instances. How would you approach this?
    -EBS volumes are not ideal for horizontal read scaling. Instead:
    -Use EBS snapshots to create read-only clones for other EC2 instances.
    -Or better, migrate to Amazon RDS or Aurora which supports read replicas.
    -For file-based storage, use Amazon EFS (which supports multi-instance access).
-------------------------------------------------------------------------------------------------------------------------------------------------
8. High-Level Architecture: Design a backup and DR solution for EC2 instances with critical EBS volumes.
Architecture Includes:
    -Regular EBS snapshots (automated via Lifecycle Policies or Lambda scripts).
    -Cross-region snapshot replication using copy-snapshot.
    -Tag-based snapshot automation using AWS Backup.
    -DR Plan: Create AMIs or launch EC2 instances from snapshots in secondary region.
-------------------------------------------------------------------------------------------------------------------------------------------------
9. What is the performance consistency of gp2 vs gp3 EBS volumes?
    gp2: Performance tied to size (3 IOPS per GB). Smaller volumes may suffer from IOPS burst limitations.
    gp3: Consistent performance, independent of volume size. You can provision IOPS and throughput separately.
    Use gp3 for better cost-performance tuning.
-------------------------------------------------------------------------------------------------------------------------------------------------
10. Can you encrypt EBS volumes?
  Yes. EBS supports encryption at rest using KMS. It also encrypts all snapshots and data-in-transit between instance and volume.
  Encryption can be:
      -Enabled by default at account level
      -Applied to new volumes or snapshots
      -Not supported for retroactive encryption (need to create encrypted copy)
-------------------------------------------------------------------------------------------------------------------------------------------------
1. What is Amazon EFS and how is it different from EBS?
  Amazon EFS (Elastic File System) is a managed NFS-based file system that allows multiple EC2 instances to access the same data concurrently.
  Feature	- EBS	- EFS
    Access	Single EC2	- Multiple EC2 (NFS)
    Type	Block storage	- File storage
    Performance	- SSD/HDD-backed	- Bursting or Provisioned throughput
    Use Case	- DBs, boot volumes	- Shared file systems, containers, CMS
-------------------------------------------------------------------------------------------------------------------------------------------------
2. How is EFS data stored and accessed?
  -Data is stored in multiple AZs in a region, ensuring high availability and durability.
  -EC2s mount EFS using NFSv4.1/4.2 protocol.
  -EFS uses Elastic Network Interfaces (ENIs) in your VPC to expose mount targets per AZ.
-------------------------------------------------------------------------------------------------------------------------------------------------
3. Explain EFS Performance Modes and Throughput Modes.
    Performance Modes:
        General Purpose (default) – For latency-sensitive workloads.
        Max I/O – For highly parallel workloads (e.g., big data).
    Throughput Modes:
        Bursting (default) – Scales with storage size.
        Provisioned – Set a fixed throughput regardless of storage.
-------------------------------------------------------------------------------------------------------------------------------------------------
4. Scenario: You are running a WordPress application in an Auto Scaling group. How do you manage shared media file access?
    Use Amazon EFS for shared media:
      -Create EFS and mount it across all EC2s (ASG).
      -Point WordPress wp-content/uploads directory to the EFS mount.
      -This ensures high availability, consistency, and durability for shared files.
-------------------------------------------------------------------------------------------------------------------------------------------------
5. How do you mount EFS on an EC2 instance?
# Install NFS client
sudo yum install -y nfs-utils

# Create mount point
sudo mkdir /mnt/efs

# Mount EFS
sudo mount -t nfs4 -o nfsvers=4.1 fs-xxxxxxxx.efs.us-east-1.amazonaws.com:/ /mnt/efs
To persist the mount, update /etc/fstab.
-------------------------------------------------------------------------------------------------------------------------------------------------
6. How does EFS handle scaling and storage limits?
    -EFS automatically scales from gigabytes to petabytes.
    -You pay only for what you use (no pre-provisioning).
    -It’s ideal for unpredictable or growing workloads.
-------------------------------------------------------------------------------------------------------------------------------------------------
7. High-Level Architecture: Design a shared storage system for containerized microservices in EKS that need access to the same configuration files.
    Architecture:
        -Use Amazon EFS CSI driver in EKS.
        -Create a PersistentVolume (PV) and PersistentVolumeClaim (PVC) pointing to EFS.
        -Mount the PVC into containers using Kubernetes volume mounts.
        -Use EFS as a central config store.
-------------------------------------------------------------------------------------------------------------------------------------------------
8. What are the EFS storage classes?
  Class	- Description	- Use Case
  Standard	- Default, high availability	- Frequent access
  Infrequent Access (IA)	- Lower-cost tier	- Files not accessed for 30+ days
  You can enable Lifecycle Management to move files to IA automatically.
-------------------------------------------------------------------------------------------------------------------------------------------------
9. How does EFS ensure data durability and availability?
  -Stores data redundantly across multiple AZs.
  -Designed for 99.999999999% (11 9s) durability.
  -Accessed via regional endpoints with multiple mount targets per AZ for HA.
-------------------------------------------------------------------------------------------------------------------------------------------------
10. Can you encrypt EFS data?
    Yes. Encryption options:
        At Rest: Enabled using AWS KMS when file system is created.
        In Transit: Mount with TLS using Amazon EFS mount helper (amazon-efs-utils).
Example:
      sudo mount -t efs -o tls fs-xxxxxxx:/ /mnt/efs
✅ Summary Table: EBS vs EFS
      Feature	- EBS	- EFS
          -Storage Type	- Block	- File
          -Multi-AZ	- No	- Yes
          -Multi-instance access	- No (except io2 Multi-Attach)	- Yes
          -Ideal for	- Databases, boot volumes	- Web servers, shared storage
          -Mount Type	- One EC2	- Many EC2s
          -Throughput	- Provisioned per volume	- Elastic/provisioned per filesystem
          -Durability	- Within AZ	- Across AZs
          -Cost	- Per GB/month + IOPS	- Per GB + IA tier (if used)
-------------------------------------------------------------------------------------------------------------------------------------------------
11. Your EBS volume is taking a long time to restore from a snapshot. How would you speed up performance after restore?
    -When you create an EBS volume from a snapshot, data is lazy-loaded from Amazon S3 — the first read of every block incurs additional latency.
    -To improve performance:
    -Pre-warm the volume:
        -sudo dd if=/dev/xvdf of=/dev/null bs=1M
        -This forces all blocks to be fetched upfront.
    -Use Fast Snapshot Restore (FSR):
        -Enables full performance immediately after restore.
        -Must be enabled in advance per AZ.
        -Costs extra.
-------------------------------------------------------------------------------------------------------------------------------------------------
12. How do EBS Snapshots support incremental backups?
    -The first snapshot is a full copy of the volume.
    -Subsequent snapshots only copy changed blocks, significantly reducing:
        -Storage costs
        -Backup time
        -AWS manages the snapshot chain; deletion of a snapshot doesn't break the chain due to block reference handling.
-------------------------------------------------------------------------------------------------------------------------------------------------
13. How would you migrate an EBS volume from one region to another?
Steps:
    -Create a snapshot of the volume.
    -Use copy-snapshot to copy it to another region:
          aws ec2 copy-snapshot --source-region us-east-1 --source-snapshot-id snap-xxxxxx --destination-region us-west-1
    -In the destination region, create a new volume from the copied snapshot.
    -Attach the new volume to an EC2 instance in that region.
-------------------------------------------------------------------------------------------------------------------------------------------------
14. How does EBS handle data durability and availability?
    -Data is replicated within the AZ where the volume resides.
    -EBS volumes are designed for 99.999% availability and 99.999% durability.
    -EBS doesn’t support cross-AZ replication — use snapshots or other services for DR.
-------------------------------------------------------------------------------------------------------------------------------------------------
15. Design a scalable web app with high-performance backend DB using EBS. Ensure performance, DR, and backup.
  Components:
      -EC2 instances with io2 EBS volumes for databases (e.g., MySQL).
      -Use EBS Multi-Attach if shared storage required (e.g., clustered DBs).
      -Enable Fast Snapshot Restore for low RTO.
      -Automate snapshots using AWS Backup or Lambda cron.
      -Replicate snapshots to secondary region for DR.
      -Monitor EBS IOPS/latency using CloudWatch.
-------------------------------------------------------------------------------------------------------------------------------------------------
16. Can we share EBS snapshots between accounts?
Yes:
    -Share snapshots manually or via AWS Resource Access Manager.
    -Only unencrypted snapshots can be shared directly.
    -Encrypted snapshots require sharing the KMS key with the target account as well.
-------------------------------------------------------------------------------------------------------------------------------------------------
11. Your EFS throughput is insufficient during peak times. What can be done?
Options:
  -Switch to Provisioned Throughput Mode:
      Allows you to manually provision throughput independent of storage size.
  -Review performance mode:
      Use Max I/O for large-scale parallel workloads.
  -Analyze file access patterns and optimize:
      Small-file heavy workloads may underperform on EFS.
-------------------------------------------------------------------------------------------------------------------------------------------------
12. How does EFS lifecycle management work?
  EFS uses access-based tiering:
    -Files not accessed for a configured number of days (e.g., 30) are moved to Infrequent Access (IA).
    -Accessing IA files automatically moves them back to Standard tier.
    -Saves costs for cold data.
You can configure policies like AFTER_30_DAYS, AFTER_7_DAYS, etc.
-------------------------------------------------------------------------------------------------------------------------------------------------
13. You want to allow EKS containers to access shared configuration files. How do you implement this with EFS?
  Steps:
      -Create an EFS file system.
      -Install the EFS CSI Driver on your EKS cluster.
      -Create:
            PersistentVolume (PV) with EFS.
            PersistentVolumeClaim (PVC).
      -Mount the PVC into required Pods via volumeMounts.
  Benefits:
      -Shared access
      -Durable storage
      -Serverless scalability
-------------------------------------------------------------------------------------------------------------------------------------------------
14. Design a multi-region media hosting solution that allows EC2s across regions to share large media files using EFS.
  EFS is regional, not global. Cross-region sharing options:
      -Use AWS DataSync to sync EFS between regions.
      -Store media in S3 with Transfer Acceleration or CloudFront for global access.
      -In each region:
              Use EFS as a cache/local share.
              Sync nightly or periodically from primary region.
Alternative: Use S3 + EFS hybrid approach for global sync with local cache.
-------------------------------------------------------------------------------------------------------------------------------------------------
16. Can you mount EFS on on-premise systems?
    Yes, using AWS Direct Connect or AWS VPN:
      -EFS is accessed via mount targets in your VPC.
      -On-prem clients must:
            Use NFSv4.1
            Route through private link (VPN/Direct Connect)
      -EFS IPs must be resolvable via VPC DNS.
Use for hybrid cloud or migration scenarios.

