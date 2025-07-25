1. What is AWS Lambda? How does it work?
AWS Lambda is a serverless compute service that allows you to run code without provisioning or managing servers. 
You simply upload your code, and Lambda takes care of everything required to run and scale your application.

How it works:
You write your code and upload it to Lambda (via ZIP or container image).
Lambda is triggered by events (e.g., API Gateway, S3 uploads, DynamoDB streams).
Lambda runs your function in a managed container and shuts it down once the task completes.
You only pay for execution time, measured in milliseconds.
--------------------------------------------------------------------------------------------------------------------------------------------------
2. What are the key features of AWS Lambda?
Event-driven execution
Automatic scaling
Short-lived executions (max 15 minutes)
Granular billing (per millisecond)
Integrated with over 200 AWS services
Supports multiple runtimes (Node.js, Python, Java, Go, .NET, etc.)
Built-in error handling and retries
Environment variable support
Versioning and Aliases
--------------------------------------------------------------------------------------------------------------------------------------------------
3. What runtimes does AWS Lambda support?
AWS Lambda supports the following runtimes natively:
Node.js
Python
Java
Go
Ruby
.NET (C#)
Custom Runtime (via Lambda Runtime API)
Container images (up to 10 GB, using Docker)
--------------------------------------------------------------------------------------------------------------------------------------------------
4. What are cold starts in AWS Lambda? How do you minimize them?
A cold start occurs when Lambda needs to create a new container instance to serve a request. This results in extra latency due to:
Bootstrapping the runtime
Downloading the function code
Initializing dependencies
Minimization techniques:
Use provisioned concurrency
Keep the package size small
Use lightweight runtimes (e.g., Node.js, Go)
Avoid heavy initialization in global scope
--------------------------------------------------------------------------------------------------------------------------------------------------
5. What is provisioned concurrency vs. on-demand concurrency in Lambda?
On-demand concurrency: Lambda spins up instances only when requests arrive. Can cause cold starts.
Provisioned concurrency: Keeps a specified number of Lambda instances warm and ready, eliminating cold start latency.
--------------------------------------------------------------------------------------------------------------------------------------------------
6. What is the maximum execution timeout for AWS Lambda?
The maximum timeout for a Lambda function is 15 minutes (900 seconds).
--------------------------------------------------------------------------------------------------------------------------------------------------
7. How does Lambda handle scaling?
AWS Lambda automatically scales horizontally by spawning multiple instances of the function in parallel, depending on the number of 
incoming requests. It can handle thousands of concurrent executions without manual configuration.
--------------------------------------------------------------------------------------------------------------------------------------------------
8. What is the Lambda execution environment?
Lambda runs your code inside an isolated execution environment:
Based on Amazon Linux
Includes the specified runtime (Node.js, Python, etc.)
Provides 512MB–10GB memory
Allocates CPU proportionally
Offers ephemeral /tmp disk space (512MB)
--------------------------------------------------------------------------------------------------------------------------------------------------
9. What is the use of environment variables in Lambda?
Environment variables allow you to:
Store config settings (e.g., DB endpoints, API keys)
Secure sensitive data using KMS encryption
Avoid hardcoding values into function code
--------------------------------------------------------------------------------------------------------------------------------------------------
10. What’s the difference between Lambda Layers and container images?
Lambda Layers: Share common dependencies (e.g., libraries) across functions. Max 5 layers per function.
Container Images: Use Docker to build Lambda functions (max size 10 GB). Ideal for complex dependencies or custom runtimes.
--------------------------------------------------------------------------------------------------------------------------------------------------
11. You need to process S3 uploads (images, PDFs) and generate thumbnails. How would you design this using Lambda?
Architecture:
Trigger: S3 Event → Lambda
Lambda function processes the file, resizes it using Pillow (Python) or Sharp (Node.js), and stores the output in another S3 bucket/prefix.
Steps:
User uploads file to raw-images/ S3 bucket.
S3 triggers Lambda.
Lambda downloads the file, generates a thumbnail.
Lambda uploads thumbnail to thumbnails/ prefix.
(Optional) Logs status to CloudWatch.

Best Practices:
Use Layers for image processing libraries.
Use S3 event filtering for specific file types.
Handle errors and retry logic.
--------------------------------------------------------------------------------------------------------------------------------------------------
12. You observe high cold start latency in production. What would you do?
Enable Provisioned Concurrency for high-traffic functions.
Reduce package size (remove unused libraries)
Move heavy initialization code inside handler instead of global scope.
Choose lighter runtime (e.g., Go instead of Java).
Prewarm the function by periodically invoking it.
--------------------------------------------------------------------------------------------------------------------------------------------------
13. You need to validate API requests and write them to DynamoDB. How will you implement this with Lambda?
API Gateway → HTTP endpoint
Integration with Lambda function
Lambda:
Validates input
Parses body
Inserts record into DynamoDB
Return status response to client
Extras:
Use IAM role with DynamoDB access
Add input validation (via code or API Gateway request validator)
Monitor with CloudWatch
--------------------------------------------------------------------------------------------------------------------------------------------------
14. Your Lambda function hits the timeout. What would you check?
Check CloudWatch Logs to find where execution stalls.
Confirm that:
External services are responsive (e.g., DB, API)
Network connectivity (VPC configs) is correct
Function logic has no infinite loops
Consider increasing timeout (up to 15 min)
Optimize logic and external calls (use async or batching)
--------------------------------------------------------------------------------------------------------------------------------------------------
15. You want to run a nightly data aggregation job. How would you schedule it in Lambda?
Use Amazon EventBridge (CloudWatch Events):
Create a scheduled rule (e.g., cron expression: cron(0 0 * * ? *))
Set Lambda as the target
Lambda fetches data, aggregates, and writes output
Benefits:
Serverless cron job
No infrastructure to manage
Easy to monitor and retry
--------------------------------------------------------------------------------------------------------------------------------------------------
16. How would you build a serverless REST API using Lambda?
Architecture:

Client → API Gateway → Lambda → DynamoDB (or RDS)
Details:
API Gateway routes HTTP methods to respective Lambda functions
Lambda contains business logic
Connect to DynamoDB or RDS
Use IAM roles for secure access
Return HTTP responses to client
Enhancements:
Use Authorizers (JWT/OAuth)
Add WAF for security
Enable Caching in API Gateway
Monitor with X-Ray and CloudWatch
--------------------------------------------------------------------------------------------------------------------------------------------------
17. How would you handle state management in a Lambda-based workflow?
Lambda is stateless. For state:
Use Step Functions to manage orchestration
Use DynamoDB or S3 to store intermediate data
For long workflows:
Break into smaller functions
Use task tokens to pause/wait
--------------------------------------------------------------------------------------------------------------------------------------------------
18. How do you secure a Lambda function?
Use least privilege IAM role
Encrypt environment variables using KMS
VPC integration with security groups + NACLs
Enable X-Ray + CloudTrail for auditing
Sign payloads from sources (e.g., webhook signature validation)
Use resource-based policies (for S3, SNS triggers)
--------------------------------------------------------------------------------------------------------------------------------------------------
19. Explain a real-world use case for Lambda in DevOps automation.
Use case: Automated AMI Cleanup
EventBridge rule (weekly)
Triggers Lambda function
Lambda:
Lists AMIs tagged as "old"
Deregisters AMIs older than 30 days
Deletes snapshots
Benefits:
Automated, scheduled task
Saves cost
Fully serverless DevOps automation
--------------------------------------------------------------------------------------------------------------------------------------------------
20. How do you monitor and debug Lambda functions in production?
CloudWatch Logs: Default logging of every invocation
CloudWatch Metrics: Invocations, errors, duration, throttles
X-Ray: End-to-end tracing and performance analysis
Structured logging: Use JSON format for better log filtering
Alarm setup: Alert on error rates or duration spikes
Let me know if you want:
More advanced or hands-on questions
Terraform/IaC examples for deploying Lambda
CI/CD pipeline integration examples
Sample projects using Lambda with API Gateway, S3, Step Functions, etc.
