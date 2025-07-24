Q1. What is Amazon CloudWatch?
Amazon CloudWatch is a fully managed monitoring and observability service provided by AWS. It collects monitoring and operational data in the form of logs, metrics, and events. It allows you to monitor AWS resources like EC2, RDS, Lambda, ECS, etc., and on-premises applications, set alarms, and respond automatically to changes.
Key Features:
Real-time metrics
Log monitoring and storage
Alarms and automated actions
Dashboards
Anomaly detection
Integration with AWS services like Lambda, SNS, Auto Scaling
---------------------------------------------------------------------------------------------------------------------------------------------------
Q2. What are CloudWatch Metrics?
CloudWatch metrics are time-ordered sets of data points published to CloudWatch. Each metric consists of:
Namespace: A container for CloudWatch metrics (e.g., AWS/EC2)
Metric name: (e.g., CPUUtilization)
Dimensions: Name/value pairs (e.g., InstanceId)
Timestamp
Value (e.g., 45% CPU)
CloudWatch provides both default (AWS services) and custom (user-defined) metrics.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q3. What is a CloudWatch Alarm?
A CloudWatch Alarm watches a single metric or a math expression. When the value exceeds a threshold for a specified number of evaluation periods, the alarm performs actions such as:
Sending notifications via SNS
Auto Scaling actions
EC2 recovery actions
Invoking Lambda functions
Types of states:
OK
ALARM
INSUFFICIENT_DATA
---------------------------------------------------------------------------------------------------------------------------------------------------
Q4. What is CloudWatch Logs?
CloudWatch Logs helps you monitor, store, and access log files from AWS resources (like EC2, Lambda, API Gateway) or custom logs. You can:
Search logs using Log Insights
Set metric filters to trigger alarms
Store logs for compliance or debugging
---------------------------------------------------------------------------------------------------------------------------------------------------
Q5. What is the retention policy in CloudWatch Logs?
Retention policy determines how long CloudWatch stores log data. You can configure from 1 day to 10 years or choose to retain indefinitely.
---------------------------------------------------------------------------------------------------------------------------------------------------
Q6. What are CloudWatch Dashboards?
CloudWatch Dashboards are customizable views of your metrics and alarms. You can:
Display metrics across AWS services
Create graphs, number widgets
Monitor multi-region environments
---------------------------------------------------------------------------------------------------------------------------------------------------
Q7. What is the difference between CloudTrail and CloudWatch?
Feature	- CloudWatch	- CloudTrail
Purpose	- Monitoring and alerting (metrics, logs)	- Auditing and API activity logging
Data Type	- Metrics, logs, alarms, dashboards	- Event logs of AWS API calls
Granularity	- Operational/Performance insights	- Security, auditing, and compliance
Use Case	- System health, performance	- Who did what, where, and when
---------------------------------------------------------------------------------------------------------------------------------------------------
Q8. You notice high CPU usage on an EC2 instance. How would you use CloudWatch to investigate and resolve the issue?
Access CloudWatch Metrics for the EC2 instance:
CPUUtilization
DiskReadOps, NetworkIn/Out
Create a dashboard to visualize trends
Enable CloudWatch Logs Agent to collect application logs
Use CloudWatch Logs Insights to query logs:
fields @timestamp, @message
| filter @message like /ERROR/
Set an alarm for CPUUtilization > 80% for 5 mins to alert via SNS
Trigger Auto Scaling policy or manual analysis (e.g., memory leaks)
---------------------------------------------------------------------------------------------------------------------------------------------------
Q9. How would you implement an alerting system when an application logs an “Exception”?
Ensure application logs are pushed to CloudWatch Logs
Create a Metric Filter:

{ $.message = "*Exception*" }
Assign a custom metric to this filter (e.g., AppExceptionCount)
Create a CloudWatch Alarm:
If AppExceptionCount > 0 in 1-minute period
Trigger SNS Topic for notifications
(Optional) Invoke Lambda for remediation actions
---------------------------------------------------------------------------------------------------------------------------------------------------
Q10. An application’s response time is fluctuating. How do you monitor and diagnose using CloudWatch?
Enable detailed monitoring on EC2, ELB, and API Gateway
Track metrics:
ELB: Latency, RequestCount, HTTPCode_ELB_5XX
EC2: CPUUtilization, NetworkIn/Out
Use Log Insights on app logs to filter slow responses
Set anomaly detection alarms on latency
Visualize in a dashboard with historical trend analysis
---------------------------------------------------------------------------------------------------------------------------------------------------
Q11. How can you use CloudWatch to perform automated healing of failed instances?
Create a CloudWatch Alarm for status check failure (e.g., StatusCheckFailed_Instance > 0)
Choose alarm action: EC2 recovery
Alternatively, use SNS → Lambda to trigger:
Stop and start the instance
Replace the instance in an Auto Scaling Group
---------------------------------------------------------------------------------------------------------------------------------------------------
Q12. You are running an ECS cluster. How do you monitor container health using CloudWatch?
Enable ECS Container Insights
Monitor:
      -CPU and memory usage per task
      -Task launch failures
      -Service-level metrics
      -Use CloudWatch Logs for container logs
      -Set alarms on metrics like:
          MemoryUtilized > 80%
          CPUUtilized > 90%
Use dashboards for real-time service visibility
---------------------------------------------------------------------------------------------------------------------------------------------------
Q13. Describe a high-level architecture using CloudWatch for a production-grade web application.
✅ Architecture Overview:
Users → Route 53 → ALB → EC2 (App) → RDS
                            ↳ CloudWatch Logs (App Logs)
                            ↳ CloudWatch Metrics
                            ↳ CloudWatch Alarms
                            ↳ SNS → Email/Slack
                            ↳ Lambda (Auto-recovery)
Key Components:
    Metrics: EC2 CPU, Memory (custom), RDS connections, ELB latency
    Logs: Application, Nginx, System logs to CloudWatch
    Alarms: CPU > 85%, disk > 80%, error rate > threshold
    Dashboards: Display metrics in real time
    Automation: Lambda for healing or notifications
    Integration: Slack via SNS + Lambda for alerts
---------------------------------------------------------------------------------------------------------------------------------------------------
Q14. How can you integrate CloudWatch with AWS Lambda?
    CloudWatch Logs → Lambda: Trigger Lambda on log pattern match (via Subscription filter)
    CloudWatch Events → Lambda: On schedule (cron) or AWS service state changes
    CloudWatch Alarm → Lambda: Trigger Lambda when an alarm breaches (e.g., restart service)
---------------------------------------------------------------------------------------------------------------------------------------------------
Q15. How can you achieve centralized logging using CloudWatch in a multi-account AWS setup?
    -Use AWS Organizations
    -Enable cross-account IAM roles
    -Create CloudWatch Log Destination in a central account
    -Set resource policy on destination to allow log streams from other accounts
    -Configure log groups in spoke accounts to forward logs to central destination
    -Analyze logs using CloudWatch Logs Insights in central account
---------------------------------------------------------------------------------------------------------------------------------------------------
Q16. How do you monitor custom application metrics using CloudWatch?
-Use AWS SDK/CLI to publish custom metrics:
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "LoginFailures" \
  --value 2 \
  --dimensions App=Web
-From your app, use the SDK (Python, Java, etc.)
-Visualize in a dashboard, and create alarms
---------------------------------------------------------------------------------------------------------------------------------------------------
Q17. How would you implement a real-time alert system using CloudWatch, Lambda, and Slack?
    -Create CloudWatch Alarm (e.g., CPU > 85%)
    -Alarm triggers SNS topic
    -SNS triggers Lambda function
    -Lambda parses alarm details and sends a formatted Slack webhook message
---------------------------------------------------------------------------------------------------------------------------------------------------
Q18. What are CloudWatch Contributor Insights?
    Contributor Insights provides real-time analysis of top contributors to your metrics (e.g., top IPs causing errors).
    Use Cases:
        -Identify DDoS sources
        -Top users causing throttling
        -Most failing Lambda functions


