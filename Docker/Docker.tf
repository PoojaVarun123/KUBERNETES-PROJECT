========================================================================================================================================
1. Definitions: Docker Ecosystem Components
Docker	- A platform that enables developers to build, ship, and run applications in isolated containers	Simplifies app deployment and ensures 
consistency across dev, test, and prod stages.

Docker Container	- A lightweight, standalone, executable package of software that includes everything needed to run it 
(code, runtime, libraries, etc.)	Like a mini virtual machine but faster and uses fewer resources.

Docker Image	- A read-only blueprint used to create Docker containers. Includes app code + dependencies.	You build an image once 
and deploy containers from it across multiple environments.

Dockerfile	- A script with instructions to build a Docker image.	Contains commands like FROM, COPY, RUN, CMD, etc.
Docker Registry	- A storage system for Docker images. It can be public or private.	Used to store and share Docker images 
(like versioned app builds).

Docker Hub	- Docker's default public registry hosted online.	Images like nginx, mysql, ubuntu are hosted here and widely used.
-----------------------------------------------------------------------------------------------------------------------------------------
2. Difference: Containerization vs Virtualization
Feature	> Containerization	> Virtualization
Definition	> OS-level virtualization using containers	> Hardware-level virtualization using VMs
Startup Time	> Seconds > 	Minutes
Overhead	> Very low (shares host OS)	> Higher (each VM runs full OS)
Isolation	> Process-level	> Full OS-level
Image Size	> Small (MBs)	> Large (GBs)
Use Case	> Microservices, CI/CD pipelines	> Legacy apps, OS-level isolation

Conclusion: Containers are faster, more efficient for cloud-native apps. Use VMs for strong isolation or OS-level testing.
-----------------------------------------------------------------------------------------------------------------------------------------
3. Docker Image Layers – How It Works
    -Docker images are built in layers for efficiency and caching.

Concept of Layers
    -Each command in a Dockerfile (like RUN, COPY, ADD) creates a new layer.
    -Layers are read-only and cached for faster builds.
    -When you update a single line, only that layer and the ones after it are rebuilt.

Example:
    FROM ubuntu:20.04         # Layer 1
    RUN apt-get update        # Layer 2
    RUN apt-get install -y nginx # Layer 3
    COPY ./app /var/www       # Layer 4
If only the app changes, only Layer 4 is rebuilt — not the entire image.

Best Practice
    -Place frequently changing commands (like COPY, ADD) after less-changing commands to use cache efficiently.
    -Minimize the number of layers for smaller images (e.g., combine RUN statements).
-----------------------------------------------------------------------------------------------------------------------------------------
4. Docker Compose: What & Why
    -A tool for defining and running multi-container Docker applications using a docker-compose.yml file.

🔧 Key Benefits
    -Manage multi-container apps (e.g., web + db + redis) as a single unit
    -Simplifies orchestration for local development and testing

version: '3'
services:
  web:
    image: nginx
    ports:
      - "80:80"
  db:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: example

Best Practices
    -Use named volumes for persistent data
    -Separate compose files for dev vs prod (docker-compose.override.yml)
    -Integrate with CI/CD pipelines for test environments
-----------------------------------------------------------------------------------------------------------------------------------------
5. Docker Volumes: Explanation, Types, Use Case, and Best Practice
    -A volume is a persistent storage mechanism that exists outside of the container lifecycle. Useful for:
    -Storing logs, DB data, configurations
    -Preserving data even if container is deleted

📑 Types of Volumes
Type	> Description	Use Case
Named Volume	> Managed by Docker	> Persistent DB data (mysql_data)
Anonymous	> Random name by Docker	> Temporary cache/data
Host Bind Mount	> Maps a host path to a container path	> Use local code or logs inside container

docker volume create mydata
docker run -v mydata:/data nginx

Production Recommendation
    -Use named volumes for production (portable and safer)
    -Avoid bind mounts in production (host dependency)

Security Tip
    -Don't mount sensitive files without strict access control
    -Avoid mounting /var/run/docker.sock unless necessary (security risk)
-----------------------------------------------------------------------------------------------------------------------------------------
6. Components of Docker
Docker is made up of several key components:
    Docker Engine	- Core client-server app: runs and manages containers
    Docker Daemon (dockerd)	- Background service that manages Docker objects (images, containers, volumes)
    Docker CLI (docker)	- Command-line tool to interact with Docker daemon
    Docker Images	- Read-only templates used to create containers
    Docker Containers	- Running instances of Docker images
    Dockerfile	- Text file containing instructions to build Docker images
    Docker Compose	- Tool for defining multi-container applications
    Docker Registry	- Storage/repository for Docker images (e.g., Docker Hub, ECR, Harbor)

Interview Tip: 
Emphasize how dockerd and docker CLI communicate over a socket (/var/run/docker.sock), and highlight how registries enable portability.
-----------------------------------------------------------------------------------------------------------------------------------------
7. Features of Docker
Feature	> Description & Usefulness
    Portability	- Run the same container image across different environments (dev/test/prod)
    Isolation	- Containers run independently, with their own filesystem and process space
    Lightweight	- Shares host OS kernel — faster than VMs
    Layered Filesystem	- Efficient caching and reuse of layers for image builds
    Version Control	- Image tags support versioning (e.g., myapp:1.0, myapp:latest)
    Security	- Supports seccomp, AppArmor, and user namespaces
    CI/CD Friendly	- Easily integrated into pipelines (e.g., build, test, push)
    Multi-architecture support	- ARM, x86, etc., supported through platform targeting
-----------------------------------------------------------------------------------------------------------------------------------------
8. Multi-Stage Builds: Deep Analysis
    -A technique in Dockerfile that allows you to use multiple FROM statements to:
    -Separate build environment from runtime environment
    -Produce small, production-ready images

Why Use It?
    -Reduce image size by discarding unnecessary build tools
    -Improve security (no compilers/tools in production image)
    -Clear separation of concerns (build vs runtime)

🧪 Example: Node.js App with Multi-Stage

# First stage: build
FROM node:18 as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Second stage: production
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html

Explanation:
Stage 1 installs packages and builds the app (using full Node.js image)
Stage 2 uses a tiny nginx:alpine image to serve the app — build tools aren’t carried over

Best Practices
    -Use descriptive names for stages: as builder, as base
    -Use COPY --from=<stage> to pull only required artifacts
    -Keep final image minimal — smaller attack surface
    -Include HEALTHCHECK and EXPOSE in final image

Security Tip
    -Final image should not include source code, node_modules, or compilers.

Interview Summary:
“Multi-stage builds drastically improve image efficiency and security by separating build-time dependencies from the 
production image, resulting in faster deployments and reduced vulnerabilities.”
-----------------------------------------------------------------------------------------------------------------------------------------
9. Dockerfile Keywords (with Usage & Importance)
Keyword	> Purpose	> Example
    FROM	- Base image to build from (first instruction)	FROM python:3.11-alpine
    RUN	- Executes commands during build (each creates a layer)	RUN apt-get update && apt-get install
    CMD	- Default command to run in container	CMD ["node", "app.js"]
    ENTRYPOINT	- Main process, can’t be overridden easily	ENTRYPOINT ["python", "script.py"]
    COPY	- Copies files from host into image	COPY . /app
    ADD	Like COPY + supports URLs and extracting tar archives	ADD app.tar.gz /src
    WORKDIR	- Sets working directory inside container	WORKDIR /app
    EXPOSE	- Documents port the app listens on	EXPOSE 80
    ENV	- Set environment variables	ENV NODE_ENV=production
    VOLUME	- Declares mount point for external volume	VOLUME /data
    USER	- Sets user for following commands or container runtime	USER nginx
    LABEL	- Metadata (e.g., version, maintainer)	LABEL maintainer="pooja@example.com"
    ARG	- Build-time variable (vs ENV = runtime)	ARG VERSION=1.0
    HEALTHCHECK	- Monitors container health status	`HEALTHCHECK CMD curl -f http://localhost
    ONBUILD	- Triggers actions in child images	Useful for base images
-----------------------------------------------------------------------------------------------------------------------------------------
10. How to Update an Existing Docker Image
You can update images in two main ways:

Option 1: Rebuild Locally
    -Modify your Dockerfile or source code.

Rebuild the image:
docker build -t myapp:latest .

Restart container:
docker stop myapp && docker rm myapp
docker run -d --name myapp myapp:latest

Option 2: Pull Latest from Registry
docker pull myrepo/myapp:latest
docker stop myapp && docker rm myapp
docker run -d --name myapp myrepo/myapp:latest

Best Practices
    -Use version tags instead of :latest for better control
    -Automate with CI/CD: push updated image to registry and trigger deploy
    -Use docker-compose up -d --build for multi-container rebuilds
-----------------------------------------------------------------------------------------------------------------------------------------
11. How to Improve the Performance of Docker Containers
Use Alpine base images	- Smaller image size → faster startup, less attack surface
Minimize image layers	- Combine RUN instructions to reduce filesystem layers
Use .dockerignore	- Prevent unnecessary files from being copied to image
Multi-stage builds	- Avoid shipping unnecessary build tools or files
Use tmpfs for temp data	- Store in memory instead of disk: --tmpfs /tmp
Avoid root user	- Use a dedicated user → lower resource abuse risk
Limit resources	- Use flags like --memory, --cpus to avoid hogging
Tune container startup	- Ensure fast init by optimizing entrypoints and startup scripts
Use volumes for heavy data I/O	- Avoid writing to container layer (slower)

Performance Monitoring:
Use Docker stats:
docker stats <container_name>

Interviewer Summary:
“Performance tuning in Docker starts with lean images, optimal file system usage, and proper resource control using flags and 
multi-stage builds. Lightweight base images like Alpine and .dockerignore are key optimizations.”
-----------------------------------------------------------------------------------------------------------------------------------------
12. Difference Between ENTRYPOINT and CMD
Property	> ENTRYPOINT	> CMD
    Purpose	> Defines the fixed executable for the container	> Default arguments passed to ENTRYPOINT or shell
    Overridable?	> No (unless using --entrypoint)	> Yes (by arguments in docker run)
    Use Case	> When container should always run a specific binary	> When arguments or commands are optional
    Syntax (exec)	> ["executable", "param1"]	["param1", "param2"]

🔍 Example:
ENTRYPOINT ["python3", "app.py"]
CMD ["--port=8000"]
Run: docker run myapp --port=9000
Result: python3 app.py --port=9000

Interviewer Summary:
“ENTRYPOINT defines the core process that always runs, while CMD provides default arguments which can be overridden. 
Using both together offers flexibility and consistency.”
-----------------------------------------------------------------------------------------------------------------------------------------
13. Difference Between COPY and ADD
Feature	> COPY	> ADD
Basic Copying	> Yes	> Yes
URL Support	> ❌	> ✅ (Downloads files from URL)
Tar Extraction	> ❌	> ✅ (Auto-extracts local tar archives)
Best Practice	> Use for simple copying	> Use only when needed for tar/URL

🔍 Example:
COPY ./src /app/src
ADD https://example.com/app.tar.gz /app/

Interviewer Summary:
“COPY is preferred for predictable, simple file copying. ADD is more powerful but often misused — use it only for its unique 
capabilities like downloading or extracting.”
-----------------------------------------------------------------------------------------------------------------------------------------
✅ 14. Difference Between Daemon-level and Container-level Logging
Daemon-Level Logging
    -Configured globally in /etc/docker/daemon.json
    -Affects all containers

Common drivers:
json-file (default)
journald
syslog
awslogs

Example:
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
Apply: sudo systemctl restart docker

🔥 Container-Level Logging
Set per container during docker run

docker run --log-driver=syslog nginx

🔍 Viewing Logs:
docker logs <container_name>

Interviewer Summary:
“Daemon-level logging is global and set in the Docker engine config, while container-level logging offers more granular control. 
Logging drivers help forward logs to external systems.”
-----------------------------------------------------------------------------------------------------------------------------------------
15. How Docker Volume is Stored
📦 Volume Storage Location
Docker volumes are stored under:
/var/lib/docker/volumes/<volume_name>/_data
These are managed by Docker and persist even if container is removed.

Use Cases for Volumes
    -Storing databases (PostgreSQL, MySQL data)
    -Shared config files
    -Uploads, persistent app data

📌 Volume Types:
Type	> Description	> Use Case
Named Volume	> Managed by Docker	> Persistent MySQL data
Anonymous Volume	> No explicit name	> Temp storage
Host Bind Mount	> Maps host path	> Debugging, configs, secrets
tmpfs	> Stored in memory	> High-speed, temp storage

🧪 Example:
docker volume create mydata
docker run -v mydata:/var/lib/mysql mysql

Interviewer Summary:
“Docker volumes are used for persistent data and live under /var/lib/docker/volumes. Named volumes are safer and easier to 
manage than bind mounts in production.”
-----------------------------------------------------------------------------------------------------------------------------------------
✅ Recap (Q11–Q15 Interview Summary)
11	Performance	Optimize with lean images, multi-stage builds, tmpfs, and .dockerignore
12	Entrypoint vs CMD	ENTRYPOINT is fixed; CMD is overridable — use both wisely
13	COPY vs ADD	COPY is safer and more predictable; ADD only for URLs or tars
14	Logging	Daemon-level is global, container-level is granular; logs viewed with docker logs
15	Volumes	Persist data outside containers, use named volumes for best production use
-----------------------------------------------------------------------------------------------------------------------------------------
16. Docker Restart Policies — Use Cases & Commands
    -Restart policies control if and when Docker should restart a container when it exits.

Types of Restart Policies:
no (default)	> Do not restart the container when it exits	> Manual-only use cases
always	> Always restart the container no matter what	> Critical services (e.g., web servers)
on-failure	> Restart only if container exits with a non-zero status (error)	> Apps that crash occasionally
unless-stopped	> Like always, but won’t restart after a manual docker stop	> Long-running daemons that don’t need boot persistence

Syntax:
docker run --restart=always nginx
Or with Docker Compose:

restart: on-failure

Interviewer Summary:
“Restart policies ensure resilience. always is good for core services; on-failure fits error-prone apps. unless-stopped 
prevents restart after manual shutdowns — ideal for controlled environments.”
-----------------------------------------------------------------------------------------------------------------------------------------
17. What is Docker Swarm and Its Importance?
Docker Swarm is Docker’s native clustering and orchestration tool, allowing containers to run across multiple nodes.

Key Features:
    High Availability: Replica services auto-restart on failure
    Scaling: Run services with multiple replicas (--replicas=3)
    Service Discovery: Built-in DNS for container-to-container communication
    Load Balancing: Distributes requests among replicas
    Rolling Updates: Zero-downtime deploys

🔍 Example:
docker swarm init
docker service create --name web --replicas 3 nginx

Interviewer Summary:
“Docker Swarm enables native container orchestration — making multi-node deployments fault-tolerant and scalable. 
Though Kubernetes dominates, Swarm is simpler for small-scale setups.”
-----------------------------------------------------------------------------------------------------------------------------------------
18. How Do You Update a Docker Container Without Losing Data?
Key Concept: Containers are ephemeral. To persist data across updates:
    -Use named volumes for persistent storage
    -Keep configuration in bind mounts or external configs
    -Stop → remove → re-create the container with same volume

🧪 Steps:
docker run -d --name app -v mydata:/app/data myimage:v1

# Update: remove old container (not volume)
docker rm -f app
docker run -d --name app -v mydata:/app/data myimage:v2

Interviewer Summary:
“Containers should be stateless. Persist state using named volumes, so even if a container is destroyed and recreated, the data 
remains intact.”
-----------------------------------------------------------------------------------------------------------------------------------------
19. How to Secure Docker Containers
Key Security Practices:
    Non-root user	> Define a non-root user inside container with USER
    Read-only FS	> Run with --read-only to prevent tampering
    Limit capabilities	> Drop unneeded Linux capabilities
    Seccomp profiles	> Limit syscalls container can make
    Use trusted base images	> Always pull from official or verified registries
    Scan images	Tools: Trivy, Docker Scan, Clair
    Isolate networks	> Use custom user-defined bridges
    Use SELinux/AppArmor	> OS-level mandatory access control
    Resource limits	> Prevent DoS using --memory, --cpu-shares

🧪 Dockerfile Example:
FROM alpine
RUN adduser -D appuser
USER appuser

Interviewer Summary:
“Security begins with minimizing privileges. Always run containers as non-root, restrict syscalls, limit access via capabilities, 
and scan images regularly.”
-----------------------------------------------------------------------------------------------------------------------------------------
20. Common Docker Security Vulnerabilities and How to Mitigate Them
Vulnerability	>Mitigation
    Running as root	> Use non-root user (USER) in Dockerfile
    Outdated images	> Regularly pull & rebuild from secure registries
    Unscanned images	> Use image scanning tools (Trivy, Snyk)
    Insecure container network	> Isolate networks using Docker bridges
    Privilege escalation	> Drop Linux capabilities and enable seccomp profiles
    Secrets in images	> Store secrets outside (e.g., Docker secrets, Vault)
    Open host sockets	> Avoid mounting Docker socket unless required

Tools for Hardening:
    Trivy – Fast vulnerability scanner
    Docker Bench Security – Audit host Docker configuration
    Aqua, Snyk, Clair – Commercial and open-source image scanning

Interviewer Summary:
“Docker security issues revolve around image trust, privilege use, and misconfiguration. Proactively scanning, isolating, and 
least-privilege execution greatly reduce attack surface.”
-----------------------------------------------------------------------------------------------------------------------------------------
Q#	Topic	Summary
16	Restart Policies	Ensures fault tolerance with policies like always and on-failure
17	Docker Swarm	Native clustering for load balancing, failover, rolling updates
18	Updating Containers	Use volumes to persist data, re-create containers with same volume
19	Securing Containers	Follow least-privilege, read-only FS, capabilities restriction
20	Vulnerabilities	Scan, isolate, avoid root use, and secure secrets & networks
-----------------------------------------------------------------------------------------------------------------------------------------
21. How Do You Monitor Docker Container Resource Usage?
Key Tools and Methods:
Method	> Description	> Example
    docker stats	> Real-time container metrics	docker stats <container>
    docker inspect	> View detailed container config/resources	docker inspect <container>
    Prometheus + cAdvisor	> Container metrics exporter for dashboards	Custom Grafana dashboards
    Sysdig / Datadog	> Advanced container visibility	Commercial monitoring tools

Sample:
    -docker stats nginx
    -Metrics You Can Monitor:
    -CPU %, Memory %, Memory Usage
    -Network I/O
    -Block I/O

Interviewer Summary:
“For lightweight checks, docker stats is quick. For enterprise-grade monitoring, integrate Prometheus + cAdvisor or Datadog for 
long-term insights and alerting.”
-----------------------------------------------------------------------------------------------------------------------------------------
22. How Do You Manage Docker Container Logs?
Docker Logging Drivers:
Driver	>  Description	> Usage Scenario
json-file	> Default logging mechanism (stored on disk)	> Local debugging
syslog	> Sends logs to syslog daemon > 	Syslog-based infra
fluentd	> Push logs to Fluentd pipeline	> Centralized log collection
awslogs, gelf, splunk	> Cloud or third-party integration > 	Cloud-native monitoring

Example:
    docker run --log-driver=json-file nginx
    docker logs <container-name>

Production Practice:
    -Use a centralized logging system (e.g., ELK, Loki, or Fluent Bit with Fluentd) to collect logs from containers.

Interviewer Summary:
“Use docker logs for local dev, but switch to drivers like Fluentd or Splunk for production, pushing logs to a centralized, 
searchable system.”
-----------------------------------------------------------------------------------------------------------------------------------------
23. Difference Between Docker Image and Docker Layer
Docker Image:
    -Immutable snapshot used to create containers
    -Built from a Dockerfile
    -Consists of multiple layers

Docker Layer:
    -Each line in the Dockerfile adds a layer
    -Layers are cached and shared across images to reduce size and speed up builds

Example:
    FROM alpine          # Layer 1
    RUN apk add curl     # Layer 2
    COPY app.sh /app.sh  # Layer 3
    This image has 3 layers. If you rebuild without changing app.sh, only Layer 3 is rebuilt.
-----------------------------------------------------------------------------------------------------------------------------------------
Interviewer Summary:
“Docker images are composed of read-only layers. Layering makes builds efficient and storage reusable. Understanding this is key 
to debugging, optimization, and caching.”
-----------------------------------------------------------------------------------------------------------------------------------------
24. How Do You Troubleshoot Issues with Docker Containers?
🔍 Key Troubleshooting Steps:
    Container not running> docker ps -a, check STATUS
    Logs	> docker logs <container>
    Shell Access	> docker exec -it <container> sh/bash
    Healthcheck	> Review Dockerfile or compose healthcheck
    Networking	> docker inspect for IP/port issues
    File issues > 	Use docker diff <container>

Common Troubleshooting Tools:
    docker events → View real-time events
    docker inspect → Full metadata
    docker top <container> → Running processes

Interviewer Summary:
“Container troubleshooting revolves around logs, events, and shell access. Always begin with docker ps, logs, and inspect for 
root cause analysis.”
-----------------------------------------------------------------------------------------------------------------------------------------
25. Common Docker Container Issues & Solutions
Top Issues & Fixes:
  Container exits immediately	- No foreground process or bad command	- Use CMD tail -f, check docker logs
  Port not accessible	- Port not published	- Use -p 8080:80, or define in Compose
  Resource limits exceeded	- Out-of-memory or CPU throttled -	Adjust --memory, --cpus flags
  Permission denied inside container	- Running as wrong user	- Use USER directive or adjust file perms
  Volume mount error	- Wrong path or permissions	- Double-check host path and mount format

Example:
    docker run -d -p 80:80 nginx         # Ensure port published
    docker logs <container>              # Check logs
    docker exec -it <container> bash     # Debug inside

Interviewer Summary:
“Most issues relate to entrypoints, network configs, or volume paths. Proper image setup, logging, and structured debugging 
reduce downtime and frustration.”
-----------------------------------------------------------------------------------------------------------------------------------------
Q#	Topic	Summary
21	Resource Monitoring	Use docker stats, Prometheus, or Datadog for real-time insights
22	Log Management	Switch from json-file to centralized log drivers for production
23	Image vs. Layer	Images are made of layers; layers enable caching and reuse
24	Container Troubleshooting	Use logs, exec shell, inspect, and healthchecks for root cause
25	Common Container Issues	Learn patterns like exit codes, permission errors, and OOM crashes
-----------------------------------------------------------------------------------------------------------------------------------------
26. Docker Image Troubleshooting: Common Issues & Solutions
Common Issues with Docker Images:
    Image too large	- Installing unnecessary packages, not cleaning cache	Use multi-stage build, alpine base, clean cache
    Build failing	- Syntax errors, invalid Dockerfile instructions	Use docker build --no-cache . and --progress=plain
    Cache not used	- Changing order of Dockerfile steps	Place static instructions (e.g., COPY requirements.txt) early
    Inconsistent builds	- External file changes or no pinned versions	Use fixed versioning (pip install package==1.2.3)
    Broken image	- Corrupt pull or tag	Use docker pull --disable-content-trust=false

Example:
    docker build --no-cache --progress=plain .
    docker image history <image>       # Analyze layers
    docker inspect <image>             # Metadata

Interviewer Summary:
“Image issues often relate to caching, bloat, and bad layering. A clean multi-stage build and Alpine base image solve most 
size and security problems.”
-----------------------------------------------------------------------------------------------------------------------------------------
27. Docker Volume Troubleshooting: Issues & Fixes
Common Volume Issues:
    File not found inside container	- Volume not mounted properly	Double-check -v syntax or Compose file
    Permission denied -	Host file has root-only access	Use chmod, chown, or run container with correct UID
    Data not persisting	- Bind mount used temporarily	Use named volumes instead of anonymous or host paths
    Unexpected data	- Overlaying container path with host dir	Ensure container path is empty before mount

Example:
    docker volume ls
    docker volume inspect my-volume
    docker run -v my-volume:/app/data busybox ls /app/data

Interviewer Summary:
“Use named volumes in production. Troubles arise from host path issues, permission mismatches, or misunderstanding 
bind vs named volumes.”
-----------------------------------------------------------------------------------------------------------------------------------------
28. Docker Network Troubleshooting: Common Issues & Solutions
    Container can’t reach others	- Not on same network	Use --network or create user-defined bridge
    Port not accessible externally	- Host port not published	Use -p flag to map ports correctly
    DNS resolution inside container	- No Docker DNS used	Use container name as hostname only in user-defined bridge networks
    Connection refused	- App not listening on 0.0.0.0 or wrong port	Fix application binding and verify EXPOSE port

🧪 Troubleshooting Steps:
    docker network ls
    docker inspect <network>
    docker exec -it <container> ping <other-container>
    docker run --network=container:<id> ...   # Share net namespace

Interviewer Summary:
“Networking failures often stem from isolated containers or improper publishing. Use user-defined networks for proper 
NS and connectivity.”
-----------------------------------------------------------------------------------------------------------------------------------------
29. Docker Networks: Types, Use Cases, and Examples
    Bridge (default)	- Internal communication between containers on the same host	Simple local apps
    Host	- Shares host’s network stack	Low latency or network-intensive workloads
    None	- Container is isolated (no networking)	Security/enforcement
    Overlay	- Cross-host communication for Docker Swarm or Kubernetes	Distributed microservices
    Macvlan	- Assign real MAC/IP from LAN to container	IoT, legacy apps needing static IPs

Create User-Defined Bridge Network:
    docker network create my-bridge
    docker run -d --name web --network=my-bridge nginx
    docker run -it --network=my-bridge busybox ping web

Overlay Example (Docker Swarm):
    docker swarm init
    docker network create -d overlay my-overlay
    docker service create --name web --network my-overlay nginx

Real-Time Use Cases:
Use Case	> Network Type
    WordPress + MySQL on same host	> Bridge (user-defined)
    Containers needing host ports (e.g., monitoring)	> Host
    Highly secure isolated container	> None
    Cross-node Redis/MongoDB in Swarm	> Overlay
    Static IP device simulating hardware	> Macvlan

Interviewer Summary:
“Bridge is default, but use user-defined bridge for custom DNS and better isolation. For multi-host setups, overlay is essential. 
Choose network mode based on performance, security, and reachability.”
-----------------------------------------------------------------------------------------------------------------------------------------
Q#	Topic	Summary
26	Docker Image Issues	Focus on layer optimization, cache invalidation, reproducibility
27	Docker Volume Issues	Prefer named volumes; solve permission and mount path mismatches
28	Docker Network Issues	Solve via user-defined networks, correct port mapping, DNS
29	Docker Network Types	Choose bridge, host, overlay, macvlan based on scenario needs
-----------------------------------------------------------------------------------------------------------------------------------------
🔁 Types of Restart Policies:
Policy	Description	Use Case
    no (default)	- Container won’t restart automatically	Debug or test containers
    always	- Always restarts the container if it stops, regardless of exit status	Production services
    on-failure[:max]	- Restart only on non-zero exit codes; optional max retries	Fault-tolerant microservices
    unless-stopped	- Restart unless explicitly stopped by user	Long-running background services

Commands:
    docker run --restart always nginx
    docker update --restart unless-stopped <container>

Interviewer Summary:
“Restart policies ensure resilience. In production, use always or unless-stopped. on-failure is useful for controlled retries.”
-----------------------------------------------------------------------------------------------------------------------------------------
31. How to Update a Docker Container Without Losing Data
🔄 Steps to Safely Update a Container:

Use Volumes for persistent data:
    docker run -v mydata:/app/data myapp:v1
    Stop and remove old container (but not volume):

docker stop myapp && docker rm myapp

Pull new image and recreate container:
    docker pull myapp:v2
    docker run -v mydata:/app/data myapp:v2
Tip: Use Docker Compose or Portainer to simplify zero-downtime upgrades.

Interviewer Summary:
“Use volumes to decouple state from containers. Updating means replacing the container, not modifying it. Don’t store critical 
data inside containers.”
-----------------------------------------------------------------------------------------------------------------------------------------
32. How to Secure Docker Containers
    Image	> Use verified base images, avoid latest, scan with tools like Trivy
    User Privileges	> Avoid running as root; use USER in Dockerfile
    Networking	> Use user-defined networks and disable inter-container communication
    Secrets	> Use Docker secrets (in Swarm) or external secrets manager
    Host Access	> Avoid mounting Docker socket inside containers
    Capabilities	> Drop unnecessary Linux capabilities with --cap-drop

🧪 Example Dockerfile Snippet:

FROM node:18-alpine
USER node
Tools:
Trivy

Interviewer Summary:
“Security starts with minimal base images and non-root execution. Regular scans, limited host interaction, and secrets management 
are crucial.”
-----------------------------------------------------------------------------------------------------------------------------------------
33. Common Docker Security Vulnerabilities & Mitigation
Vulnerability	> Mitigation Strategy
    Running containers as root	> Use USER directive or drop privileges
    Using untrusted images	> Use trusted registries, sign images
    Docker socket exposed to container	> Never bind mount /var/run/docker.sock unless required
    Insecure secrets handling	> Use Docker secrets, not ENV or Dockerfiles
    Open host ports	> Limit -p exposure, use firewalls or reverse proxies
    Unused capabilities enabled	> Use --cap-drop and --cap-add selectively
    Outdated base images	> Regularly update and scan with Trivy or Clair

Interviewer Summary:
“Most vulnerabilities stem from poor defaults or convenience shortcuts. Principle of least privilege and regular scanning 
mitigate most risks.”
-----------------------------------------------------------------------------------------------------------------------------------------
34. Monitoring Docker Container Resource Usage
    docker stats	- Live CPU, memory, IO stats per container
    Prometheus + cAdvisor	- Collect & visualize resource metrics
    Grafana Dashboards	- Graph resource usage over time
    Datadog / New Relic / Dynatrace	- Advanced APM with alerting
    docker inspect	- View container limits like Memory, CPU

🧪 Quick Check:
    docker stats <container_name>
    docker inspect <container> | grep -i cpu

Interviewer Summary:
“For production, integrate Prometheus + cAdvisor. docker stats is useful for local monitoring. Always set resource limits per container.”
-----------------------------------------------------------------------------------------------------------------------------------------
35. Managing Docker Container Logs
    Container-level	Default JSON logging driver	docker logs <container>
    Daemon-level	Define logging driver in daemon.json	/etc/docker/daemon.json
    External driver	Fluentd, AWS CloudWatch, syslog	--log-driver=fluentd etc.

🛠️ Sample JSON Log Configuration:
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
🧪 Examples:
    docker logs mycontainer
    docker logs -f --tail 100 mycontainer

Interviewer Summary:
“Use log rotation for JSON logging. For centralized logs, use Fluentd or ELK/EFK stack. Always collect and retain logs for 
debugging and auditing.”
-----------------------------------------------------------------------------------------------------------------------------------------
Q#	Topic	Key Takeaway
30	Restart Policies	Ensure resilience using always or unless-stopped
31	Update Containers Safely	Use named volumes; replace not update containers
32	Securing Docker	Use non-root, verified images, drop capabilities
33	Common Vulnerabilities	Avoid Docker socket, hardcoded secrets, unscanned images
34	Monitoring	Use docker stats locally, Prometheus+cAdvisor in prod
35	Logging	Rotate logs, prefer central logging drivers in prod
-----------------------------------------------------------------------------------------------------------------------------------------
1. Node.js Dockerfile
✅ Normal Dockerfile (Single-stage)
dockerfile
Copy
Edit
# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy app source code
COPY . .

# Expose port
EXPOSE 3000

# Start the app
CMD ["node", "index.js"]
✅ Multi-Stage Dockerfile
dockerfile
Copy
Edit
# --- Builder Stage ---
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# --- Production Stage ---
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app .

EXPOSE 3000
CMD ["node", "index.js"]
🎯 Why multi-stage: Reduces image size by excluding devDependencies, build artifacts, test files.

🟨 2. Java (Spring Boot) Dockerfile
✅ Normal Dockerfile
dockerfile
Copy
Edit
# Build using Maven outside or package the JAR before using this Dockerfile

FROM openjdk:17-jdk-slim
WORKDIR /app

COPY target/myapp.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
✅ Multi-Stage Dockerfile with Maven
dockerfile
Copy
Edit
# --- Build Stage ---
FROM maven:3.9.3-eclipse-temurin-17 AS builder

WORKDIR /build
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# --- Runtime Stage ---
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY --from=builder /build/target/myapp.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
🧪 Note: You must place this Dockerfile in root of your Maven project for multi-stage to work seamlessly.

🟦 3. Python (Flask) Dockerfile
✅ Normal Dockerfile
dockerfile
Copy
Edit
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
✅ Multi-Stage Dockerfile
dockerfile
Copy
Edit
# --- Builder stage for dependencies (optional) ---
FROM python:3.11-slim AS builder

WORKDIR /install
COPY requirements.txt .

RUN pip install --prefix=/install/deps -r requirements.txt

# --- Runtime stage ---
FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /install/deps /usr/local
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
💡 Alternative: Use Poetry or Pipenv in the build stage for stricter dependency management.

🧠 Summary Table
Language	Base Image	Build Tool	Port	Multi-stage Benefit
Node.js	node:18-alpine	npm	3000	Smaller image, skips devDependencies
Java	openjdk:17-jdk	Maven	8080	No need for Maven in final image
Python	python:3.11-slim	pip / requirements	5000	Optimized layer cache and size reduction

