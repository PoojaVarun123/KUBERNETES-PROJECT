1. What is Amazon CloudFront?
Answer:
Amazon CloudFront is a highly secure, global Content Delivery Network (CDN) service that securely delivers static, dynamic, streaming, and interactive content using edge locations distributed around the world. It caches content at edge locations to reduce latency and improve performance.

🔸 Key Concepts:

Edge Locations: Cache content closer to users.

Origin: The backend source (S3 bucket, ALB, EC2, etc.)

Distribution: A configuration that tells CloudFront where to get content and how to deliver it.

TTL: Time to Live for cached content.

HTTPS support: Encrypted delivery using ACM or custom SSL.

2. What are the different types of origins supported by CloudFront?
Answer:
CloudFront supports:

Amazon S3 buckets (public or private content)

Elastic Load Balancer (ALB/NLB)

EC2 instances

Any HTTP(S) server, including on-prem or third-party servers

You define these origins while creating the distribution, and CloudFront fetches content from them.

3. How does caching work in CloudFront?
Answer:
Caching in CloudFront uses:

Edge Locations: Cache content near the user.

Cache-Control Headers and TTL: Define how long content stays in cache.

Invalidation: Used to remove cached objects before TTL expiry.

Query Strings, Cookies, Headers: You can configure cache behavior based on these.

4. What are CloudFront Distributions and their types?
Answer:
Distributions define how CloudFront delivers content.

There are two types:

Web Distribution (deprecated): For HTTP/HTTPS content (used for websites)

RTMP Distribution (deprecated): For streaming with Adobe Flash (no longer recommended)

Currently, AWS recommends using Web distributions for all content, including video via HLS/DASH.

5. What is Signed URL vs Signed Cookie in CloudFront?
Answer:
Used to restrict access to private content:

Signed URL: Grants access to a single file for a limited time.

Signed Cookie: Grants access to multiple files (e.g., in a media player session).

Both require a CloudFront key pair and use a trusted signer (typically an IAM user).

6. What is an Origin Access Control (OAC) and Origin Access Identity (OAI)?
Answer:

OAI (older method): Allows CloudFront to access private S3 content securely.

OAC (recommended): Newer method for enhanced security and flexibility. It integrates with S3 bucket policies and uses SigV4 authentication.

7. How does CloudFront integrate with AWS WAF and Shield?
Answer:

AWS WAF: Protects CloudFront from malicious traffic (SQL injection, XSS, bot traffic).

AWS Shield: Protects against DDoS attacks.

Shield Standard: Included by default.

Shield Advanced: Additional features for enterprises.

These services can be directly associated with a CloudFront distribution.

8. How is HTTPS/SSL handled in CloudFront?
Answer:
CloudFront supports SSL for secure content delivery.

You can attach a certificate using AWS Certificate Manager (ACM) or import a custom certificate.

SNI (Server Name Indication) is used to allow multiple certificates on the same IP.

9. What is the role of a Cache Policy and Origin Request Policy in CloudFront?
Answer:

Cache Policy: Determines how CloudFront caches content (headers, cookies, query strings).

Origin Request Policy: Controls what information CloudFront passes to the origin.

They help optimize cache hit ratio and reduce origin load.

10. What is Field-Level Encryption in CloudFront?
Answer:
Field-Level Encryption (FLE) is used to encrypt sensitive data (e.g., PII) at the edge before it's sent to the origin.

It uses public key encryption.

Only the origin can decrypt the specific fields.

✅ SECTION 2: SCENARIO-BASED QUESTIONS
11. You want to serve private videos stored in S3 using CloudFront. How would you do it?
Answer:

Use CloudFront distribution with S3 origin.

Set bucket to private.

Use OAC or OAI to allow CloudFront to access the bucket.

Use Signed URLs or Signed Cookies to restrict viewer access.

Configure proper cache policy to avoid caching sensitive content.

12. Your website performance is slow for users in Europe. How can CloudFront help?
Answer:

Deploy CloudFront with your existing website backend as origin.

CloudFront will serve cached content from EU edge locations.

This reduces latency, TCP handshakes, and time-to-first-byte (TTFB) for European users.

Use Geo restriction if needed.

13. How do you prevent someone from bypassing CloudFront and directly accessing your S3 bucket?
Answer:

Use OAC (Origin Access Control) and update S3 bucket policy to allow only CloudFront service principal.

This blocks all other direct access (including S3 URL access).

14. A file was updated in S3 but users still see the old version. What could be the issue?
Answer:

Likely due to CloudFront caching.

Solutions:

Invalidate the object using CreateInvalidation API or AWS Console.

Set a lower TTL value or use Cache-Control: no-cache headers.

Use versioned URLs (e.g., /file-v2.jpg)

15. How would you implement IP whitelisting for access to CloudFront?
Answer:

Associate an AWS WAF WebACL with CloudFront.

Create IP set containing allowed IPs.

Use allow rules for this IP set, and default action to block.

16. How would you enable multi-origin routing in CloudFront (e.g., S3 + API backend)?
Answer:

Define multiple origin definitions in CloudFront.

Create cache behaviors based on path patterns:

/static/* → S3 bucket

/api/* → API Gateway/ALB/EC2

Set cache policy differently for static vs dynamic content.

17. Your app uses sensitive user data. How do you secure CloudFront edge communication?
Answer:

Use HTTPS-only viewer protocol policy.

Enable field-level encryption for PII fields.

Enable Shield and WAF for security protection.

Enforce custom headers or origin custom auth.

18. CloudFront is not caching dynamic API responses. What can be done?
Answer:

Dynamic responses often include Cache-Control: no-cache.

To cache them:

Modify backend to add Cache-Control: public, max-age=XYZ

Adjust cache policy to include query strings, headers, etc.

Consider Lambda@Edge to manipulate responses or headers.

✅ SECTION 3: HIGH-LEVEL ARCHITECTURE QUESTIONS
19. How would you architect a global content delivery system for a media platform using CloudFront?
Answer:
🧱 Architecture Components:

Origins: S3 (static assets), ALB/API Gateway (dynamic content)

CloudFront:

Serve static files from S3

Stream video (HLS/DASH)

Restrict access using signed URLs

Enable WAF for security

Use geo-restriction for compliance

Edge Functions: Use Lambda@Edge to modify headers, redirect, A/B testing

Shield Advanced: For DDoS protection

Logs: Enable CloudFront logs to S3 + Athena for analysis

🌍 Benefits:

Lower latency due to caching at global edge locations

Secure private delivery

Offload origin to reduce cost and improve scalability

20. Design a secure and scalable website delivery architecture using CloudFront + S3 + ALB.
Answer:
✅ Architecture Design:

sql
Copy
Edit
User → CloudFront (Edge) → Origin Group:
   ├── S3 Bucket (static assets)
   └── ALB → EC2/Container backend (dynamic content)
🔐 Security:

S3 bucket private with OAC

Viewer protocol policy: Redirect HTTP to HTTPS

AWS WAF and Shield

ACM-managed certificate

⚙️ Scalability:

Content cached at edge

EC2/Containers auto scaled behind ALB

CloudFront scales automatically with traffic

📈 Monitoring:

Enable CloudFront logs to S3

Use CloudWatch for performance metrics

Use CloudTrail for audit

21. How can CloudFront help in achieving low-latency delivery for an e-commerce platform?
Answer:

Serve static content (images, CSS, JS) from edge caches

Cache dynamic HTML using custom headers or Cache-Control

Use Lambda@Edge to:

Personalize content at edge

Redirect based on location

Use origin failover to redirect traffic in case of origin outage

Accelerate API access by caching API Gateway responses

22. How do you manage versioning and cache busting in CloudFront?
Answer:

Use versioned object URLs (e.g., /app-v1.js, /logo-v2.png)

Avoid relying solely on invalidations

Automate content deployment via CI/CD to:

Upload to S3

Update versioned references in HTML

Deploy new CloudFront invalidation if needed

✅ BONUS INTERVIEW TIP:
When asked about CloudFront, always highlight:

Global latency reduction

Integration with WAF, Shield, Lambda@Edge

Real-world use cases (e.g., S3-backed websites, streaming, private content delivery)

Caching strategies and cache invalidation

Cost optimization (offload origin, compress content)

