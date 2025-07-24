=======================================================================================================================================================
Q1. What is load balancing in AWS and why is it important?
    Load balancing is the process of distributing incoming application traffic across multiple targets, such as EC2 instances, containers, or 
    IP addresses. In AWS, Elastic Load Balancing (ELB) helps ensure fault tolerance, improves scalability, and enhances performance.
Why it's important:
    -Prevents overloading a single instance
    -Increases availability
    -Supports auto healing by redirecting traffic from failed instances
    -Works seamlessly with Auto Scaling Groups (ASGs) for dynamic environments
Types in AWS:
    -ALB (Application Load Balancer): Layer 7 (HTTP/HTTPS), supports routing, host/path-based routing, WebSocket, etc.
    -NLB (Network Load Balancer): Layer 4 (TCP/UDP), handles millions of requests/sec, best for latency-sensitive apps
    -CLB (Classic Load Balancer): Legacy, supports Layer 4 and 7
---------------------------------------------------------------------------------------------------------------------------------------------------
Q2. What is Auto Scaling in AWS?
Auto Scaling allows you to automatically adjust the number of EC2 instances in your application based on demand.
Components:
Launch Template/Configuration: Defines how instances are launched
Auto Scaling Group (ASG): Logical group of EC2 instances
Scaling Policies: Define when and how to scale (dynamic or scheduled)
Health Checks: Replaces unhealthy instances
Benefits:
High availability
Cost-efficiency (pay only for what you use)
Resiliency to traffic spikes
---------------------------------------------------------------------------------------------------------------------------------------------------
Q3. What is the difference between ALB and NLB?
    Feature	- ALB	- NLB
          -Protocol	- HTTP/HTTPS (Layer 7)	- TCP/UDP (Layer 4)
          -Use-case	- Web apps, microservices	- Real-time, low-latency apps
          -Target types	- Instance, IP, Lambda	- Instance, IP
          -Features	- Path-based routing, host headers	- High performance, static IP
          -TLS Termination -	Yes	- Yes
---------------------------------------------------------------------------------------------------------------------------------------------------
Q4. How does AWS Auto Scaling determine when to scale out or scale in?
    Auto Scaling uses CloudWatch alarms tied to scaling policies. For example:
          -If CPU utilization > 70% for 5 minutes → Scale out (add instances)
          -If CPU utilization < 30% for 10 minutes → Scale in (remove instances)
    Policies:
          -Target Tracking Scaling: Maintain a target metric (e.g., CPU = 60%)
          -Step Scaling: Scale incrementally based on thresholds
          -Scheduled Scaling: Scale based on predictable usage patterns
---------------------------------------------------------------------------------------------------------------------------------------------------
Q5. What are lifecycle hooks in Auto Scaling?
    Lifecycle hooks allow you to pause instance launch/termination processes to perform custom actions like:
        -Configuration scripts
        -Security patching
        -Integration with config management tools (Ansible, Chef)
  Two Types:
      -Launch Hook
      -Terminate Hook
---------------------------------------------------------------------------------------------------------------------------------------------------
Q6. Your application experiences traffic spikes during business hours. How would you configure Auto Scaling to handle this?
    -Use Scheduled Scaling:
        Scale out 15 minutes before business hours (e.g., 9 AM)
        Scale in after business hours (e.g., 7 PM)
    -Combine with Dynamic Scaling based on CPU or request count to adapt to real-time traffic
    -Use ALB in front of ASG to distribute traffic
---------------------------------------------------------------------------------------------------------------------------------------------------
Q7. An EC2 instance behind a load balancer is unhealthy. What happens next?
    -ELB continuously performs health checks (HTTP, TCP, etc.)
    -When an instance fails health checks:
          ELB stops routing traffic to it
          ASG detects unhealthy instance
          Auto Scaling replaces it with a new healthy instance
    -This ensures zero downtime and fault tolerance
---------------------------------------------------------------------------------------------------------------------------------------------------
Q8. You deployed an app with ALB and ASG. You notice a delay in routing after scaling. What could be the issue?
    Potential causes:
        -Warm-up time for EC2 instance → Use lifecycle hook to wait until the app is ready.
        -Health check grace period too short → Increase it to allow app boot time.
        -ALB target group deregistration delay → Modify deregistration delay settings.
        -Application not binding to correct port → Check that app is listening on the correct port defined in target group.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q9. How would you use ALB with ECS for container-based workloads?
        -Create an Application Load Balancer
        -Register ECS services as targets in ALB's target groups
        -Use path-based routing (e.g., /api → service1, /auth → service2)
        -Auto Scaling ECS tasks based on CPU/memory usage
        -Integrate with CloudWatch alarms and Service Auto Scaling
---------------------------------------------------------------------------------------------------------------------------------------------------
Q10. What would you do if a high-traffic application behind NLB starts dropping connections intermittently?
        -Check connection timeouts and target group health
        -Enable cross-zone load balancing to distribute evenly
        -Verify security groups/NACLs
        -Review CloudWatch metrics (e.g., SurgeQueueLength, ActiveConnectionCount)
        -Use Flow Logs and VPC Traffic Mirroring for deeper analysis
        -Consider scaling targets or increasing their performance class (e.g., upgrade instance types)
---------------------------------------------------------------------------------------------------------------------------------------------------
Q11. Design a highly available web application using Auto Scaling and Load Balancer.
  📌 Architecture:
      -Route 53 → DNS failover across regions
      -ALB (Application Load Balancer):
            Listens on port 80/443
            Path-based routing to microservices
      -Auto Scaling Groups (ASG):
            Multiple EC2 instances across Multi-AZ
            Launch templates with bootstrapping
            CloudWatch-based scaling
      -RDS Multi-AZ for database layer
      -S3 + CloudFront for static content
      -WAF + Shield for security

📌 Key Points:
    -Multi-AZ: Resiliency
    -Target Tracking Scaling: Handles spikes
    -Health Checks: Ensures self-healing
    -AM Roles: Secure access
    -Monitoring: CloudWatch, X-Ray
---------------------------------------------------------------------------------------------------------------------------------------------------
Q12. How do you ensure zero-downtime deployments in an Auto Scaling environment?
    Use blue-green deployment:
            -Spin up a new ASG with updated app version
            -Attach to the same ALB or a new one
            -Shift traffic gradually using weighted target groups
            -Terminate the old ASG after validation
    Alternatively use rolling update strategy:
            -Replace instances in batches
            -Maintain minimum healthy capacity
            -Leverage Launch Templates with versions
---------------------------------------------------------------------------------------------------------------------------------------------------
Q13. Explain how Auto Scaling works with Spot Instances.
    -Create MixedInstancePolicy ASG:
            Combines On-Demand + Spot Instances
            Spot can reduce cost by 70–90%
    -Define InstancePools (diversify across AZs, types)
    -Set allocation strategies:
            CapacityOptimized
            LowestPrice
    -Use fallback to On-Demand if Spot is unavailable
    -Monitor interruptions using EC2 Spot Instance Termination Notices
---------------------------------------------------------------------------------------------------------------------------------------------------
Q14. How would you load balance traffic between two regions?
    -Use Route 53 latency-based routing or geolocation routing
    -Deploy application stack in both regions with:
          ALB + ASG
          Synchronized backend (RDS with cross-region read replicas or DynamoDB global tables)
    -Use health checks to failover
    -Use CloudFront for global caching + edge delivery
---------------------------------------------------------------------------------------------------------------------------------------------------
Q15. How do you secure a Load Balancer in AWS?
        -Use SSL/TLS termination at ALB or NLB
        -Use WAF to block malicious traffic (SQL injection, XSS)
        -Restrict traffic using Security Groups
        -Enable Access Logs and Request Tracing
        -Use TLS certificates from ACM
        -Protect public ALBs with Shield Standard / Advanced
---------------------------------------------------------------------------------------------------------------------------------------------------
Q16. What are Target Groups in AWS Load Balancers?
      A Target Group is a logical grouping of resources that the Load Balancer routes traffic to. You register:
              EC2 instances
              IP addresses
              Lambda functions
      Each target group:
              Uses specific protocol (HTTP, HTTPS, TCP)
              Performs health checks
              Has a port and target type (instance, ip, or lambda)
    💡 Example:
              /api/* → Target Group A → ECS service
              /auth/* → Target Group B → Lambda function
---------------------------------------------------------------------------------------------------------------------------------------------------
Q17. What is the deregistration delay in Load Balancing?
    -It's the time Load Balancer waits before stopping traffic to a deregistered target.
    -Default: 300 seconds
    -Use case: Allows in-flight requests to complete before terminating EC2 instances during scaling in.
✅ You can reduce this to speed up scale-in, but be cautious of dropped connections.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q18. What is the cooldown period in Auto Scaling?
    -A cooldown period is a pause between scaling actions.
    -It prevents multiple scaling actions in quick succession which might be triggered by the same metric spike.
    Types:
          -Default cooldown (at ASG level)
          -Scaling policy-specific cooldown
💡 Example: If a scale-out just happened due to CPU > 70%, ASG waits 300 seconds before initiating another scale action.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q19. How does Connection Draining (ALB/NLB) work in AWS?
      Connection draining (now called deregistration delay) ensures:
            Ongoing requests to an instance continue before terminating or removing the instance from the target group.
      Used in scenarios like:
                        -Deployments
                        -Instance health failure
                        -Manual or auto scale-in
---------------------------------------------------------------------------------------------------------------------------------------------------
Q20. Difference between Horizontal and Vertical Scaling?
    Feature	- Horizontal Scaling (Auto Scaling) -	Vertical Scaling (Manual)
          Approach	- Add more instances	- Increase instance size (e.g., t3 → m6)
          Downtime	-No	- May require downtime
          Flexibility -	More flexible	- Limited to instance type max specs
          Cost	- Optimized with Spot + ASG	- Costly at higher instance types
          AWS Service	- Auto Scaling Group	- EC2 instance resizing
---------------------------------------------------------------------------------------------------------------------------------------------------
Q21. You're running a stateless web app on EC2 with ALB and ASG. How do you ensure sticky sessions?
    Enable session stickiness in ALB using "load balancer-generated cookies".
    Steps:
          -Enable stickiness in ALB target group
          -Choose duration (e.g., 300 seconds)
          -ALB routes same user to the same instance (if available)
⚠️ Use only when required, can impact load distribution.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q22. Your application experiences high CPU but low request count. What scaling metric should you use?
      Use CPUUtilization as the scaling metric, not request count.
      Also investigate:
          -Memory pressure (not natively in CloudWatch)
          -Garbage collection (in Java apps
          -Misconfigured processes
✅ If memory is an issue, use CloudWatch Agent or Custom Metrics to scale based on memory usage.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q23. Your application has long-lived TCP connections. Would you use ALB or NLB? Why?
    Use NLB (Network Load Balancer) because:
          -It’s optimized for high-performance, long-lived TCP/UDP connections
          -It has lower latency
          -Can handle millions of connections per second
⚠️ ALB is not optimal for apps that require stable low-latency TCP behavior.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q24. Your app should scale based on number of messages in SQS. How would you implement this?
    Steps:
        -Set up a CloudWatch Alarm on ApproximateNumberOfMessagesVisible
        -Create a Step Scaling Policy in Auto Scaling Group
        -Trigger scale-out when message count > threshold
        -Optionally, scale-in when queue length drops
  💡 Example:
        If SQS > 100 messages → Scale out 2 instances
        If SQS < 10 messages → Scale in 1 instance
---------------------------------------------------------------------------------------------------------------------------------------------------
Q25. How do you debug why an ALB is not routing traffic correctly?
      Steps:
          -Check Target Group health checks (common cause)
          -Verify security group allows ALB to reach EC2 port
          -Confirm application is listening on correct port
          -Use ALB access logs to trace requests
          -Check priority/order of routing rules (for path or host routing)
---------------------------------------------------------------------------------------------------------------------------------------------------
Q26. Design an Auto Scaled architecture for a batch processing system
    📌 Architecture:
            -Input to S3 or SQS
            -Trigger Lambda or CloudWatch Event
            -Launch EC2 instances via Auto Scaling Group
            -Batch jobs run from cron or user-data
            -Output stored back in S3 or RDS
    📌 Key Features:
          -Spot Instances with fallback to On-Demand
          -Scale based on queue depth (SQS)
          -Use Lifecycle Hooks to wait for job completion
          -Secure with IAM roles, VPC endpoints
---------------------------------------------------------------------------------------------------------------------------------------------------
Q27. How would you implement blue/green deployment using Auto Scaling and ALB?
    -Create two Auto Scaling Groups:
          -Green (active)
          -Blue (new version)
    -Attach both ASGs to same ALB, but different target groups
    -Use weighted target group routing (Progressive rollout)
    -Route all traffic to Blue once verified
    -Delete/scale down Green group
💡 Integrate with CodeDeploy or use tools like Spinnaker, Argo Rollouts
---------------------------------------------------------------------------------------------------------------------------------------------------
Q28. What happens when you terminate an EC2 instance that’s part of an Auto Scaling Group?
      -ASG recognizes that the desired capacity has dropped
      -It launches a replacement instance
      -If termination policies are defined (e.g., oldest instance), it respects them
      -Lifecycle hooks (if configured) will be triggered before termination
---------------------------------------------------------------------------------------------------------------------------------------------------
Q29. How would you architect a scalable and fault-tolerant web backend using AWS-native services only?
    📌 Architecture:
          Route 53 (latency or geolocation routing)
          ALB (path-based routing)
          Auto Scaling Group across Multi-AZ
          EC2 Launch Template with baked AMI or user-data scripts
          Amazon RDS with Multi-AZ or Aurora
          S3 for static files
          CloudFront CDN
          WAF, Shield, ACM for security
          CloudWatch + X-Ray for monitoring & tracing
---------------------------------------------------------------------------------------------------------------------------------------------------
Q30. How do you ensure Auto Scaling doesn’t terminate a newly launched instance that’s still initializing?
    -Use Health Check Grace Period in ASG settings (default: 300s)
    -Configure lifecycle hooks to pause and wait for:
          -App setup
          -Agent installation
          -Service registration
    -Only mark instance as "InService" after setup
This prevents premature termination during bootstrapping.
====================================================================================================================================================




