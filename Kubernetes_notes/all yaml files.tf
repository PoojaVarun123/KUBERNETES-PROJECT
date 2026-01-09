==================================================================
                            POD
==================================================================
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
  labels:
    app: my-app
spec:
  containers:
    - name: my-app-container
      image: nginx:latest
      ports:
        - containerPort: 80
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 10
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5
=======================================================================
                               DEPLOYMENT
=======================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  labels:
    app: my-app
spec:
  replicas: 3

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1

  selector:
    matchLabels:
      app: my-app

  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app-container
          image: nginx:1.25
          ports:
            - containerPort: 80

          # Resource allocation
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"

          # Startup probe
          startupProbe:
            httpGet:
              path: /
              port: 80
            failureThreshold: 30
            periodSeconds: 10

          # Liveness probe
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 10
            failureThreshold: 3

          # Readiness probe
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3

          # Volume mount
          volumeMounts:
            - name: app-storage
              mountPath: /usr/share/nginx/html

      # Volume definition
      volumes:
        - name: app-storage
          emptyDir: {}
============================================================
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
-------------------------------------------------------------
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
----------------------------------------------------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 3

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1

  selector:
    matchLabels:
      app: my-app

  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app-container
          image: nginx:1.25
          ports:
            - containerPort: 80

          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"

          startupProbe:
            httpGet:
              path: /
              port: 80
            failureThreshold: 30
            periodSeconds: 10

          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 10

          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5

          volumeMounts:
            - name: app-storage
              mountPath: /usr/share/nginx/html

      volumes:
        - name: app-storage
          persistentVolumeClaim:
            claimName: app-pvc
======================================================
              CONFIGMAP
======================================================
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  APP_ENV: production
  LOG_PATH: /data/logs
-------------------------------------------------------
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  # Application behavior
  APP_NAME: backend-service
  APP_ENV: production
  LOG_LEVEL: info
  FEATURE_FLAG_X: "true"

  # Networking & URLs
  SERVICE_PORT: "8080"
  USER_SERVICE_URL: http://user-service:8080
  PAYMENT_SERVICE_URL: http://payment-service:8080

  # Paths & runtime settings
  LOG_PATH: /data/logs
  TEMP_PATH: /tmp/app
  MAX_CONNECTIONS: "100"
===================================================
                 SECRETES
===================================================
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  # Database credentials
  DB_HOST: db.prod.internal
  DB_PORT: "5432"
  DB_NAME: appdb
  DB_USERNAME: appuser
  DB_PASSWORD: strongpassword

  # API & security keys
  API_KEY: abc123xyz
  JWT_SECRET: jwt-secret-key

  # External integrations
  REDIS_PASSWORD: redispass
  SMTP_PASSWORD: smtppass
===============================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 2

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0

  selector:
    matchLabels:
      app: backend

  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: myrepo/backend:1.0
        ports:
        - containerPort: 8080

        # Environment variables from ConfigMap & Secret
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secret

        # Health Probes
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10

        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5

        # Persistent Volume
        volumeMounts:
        - name: app-storage
          mountPath: /data

      volumes:
      - name: app-storage
        persistentVolumeClaim:
          claimName: app-pvc
============================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
spec:
  replicas: 2

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0

  selector:
    matchLabels:
      app: backend

  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: myrepo/backend:1.0
        ports:
        - containerPort: 8080

        # ENV from ConfigMap & Secret
        env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: APP_ENV

        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: DB_USERNAME

        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: DB_PASSWORD

        # Probes
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10

        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5

        # PVC Volume Mount
        volumeMounts:
        - name: backend-storage
          mountPath: /data

      volumes:
      - name: backend-storage
        persistentVolumeClaim:
          claimName: backend-pvc
=====================================================
            SERVICE
=====================================================
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - name: http
    port: 80
    targetPort: 8080
=====================================================
              INGRESS
=====================================================
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  annotations:
    kubernetes.io/ingress.class: alb

    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
    alb.ingress.kubernetes.io/healthcheck-path: /health
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80

      - path: /users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80

      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
===================================================
                HPA
===================================================
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment

  minReplicas: 2
  maxReplicas: 5

  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
===================================================
        STATEFULSET
===================================================
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db-statefulset
spec:
  serviceName: db-headless
  replicas: 3
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: nginx
        volumeMounts:
        - name: data
          mountPath: /var/lib/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 5Gi
============================================================
EC2 CREATION
============================================================
provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c02fb55956c7d316"   # Amazon Linux 2 (example)
  instance_type = "t2.micro"
  key_name = "my-keypair"

  tags = {
    Name = "my-ec2-instance"
    Env  = "dev"
  }
}
==============================================================
VPC
==============================================================
provider "aws" {
  region = "us-east-1"
}
---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}
---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}
---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}
---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
---
resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}
---
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316"  # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "my-keypair"

  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF

  tags = {
    Name = "web-ec2"
  }
}
=======================================================================
                S3 Bucket
=======================================================================
resource "aws_s3_bucket" "prod" {
  bucket = "prod-secure-bucket-123"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    expiration { days = 90 }
  }

  tags = {
    Env = "prod"
  }
}
=======================================================================
                  s3 backend
=======================================================================
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
---
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-123"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
==============================================================
1. COUNT
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami_id"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index}"
  }
}
Terraform creates:
web-server-0
web-server-1
web-server-2
---
2. How to make Terraform start numbering from 1
 resource "aws_instance" "web" {
  count         = 3
  ami           = "ami_id"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}
web-server-1
web-server-2
web-server-3
==================================================================
FOR EACH
==================================================================
resource "aws_instance" "multi" {
  for_each      = {
    web  = "t3.micro"
    app  = "t3.small"
    db   = "t3.medium"
  }

  ami           = "ami-0c1a7f89451184c8b"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
| Instance Name | Instance Type |
| ------------- | ------------- |
| web           | t3.micro      |
| app           | t3.small      |
| db            | t3.medium     |
 
variable "servers" {
  type = map(string)
  default = {
    app   = "t3.medium"
    db    = "t3.large"
    cache = "t3.small"
  }
}
resource "aws_instance" "multi" {
  for_each      = var.servers
  ami           = var.ami_id
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
| Name  | Type      |
| ----- | --------- |
| app   | t3.medium |
| db    | t3.large  |
| cache | t3.small  |

TO SET
resource "aws_instance" "multi_instances" {
  for_each      = toset(["web", "app", "db"])
  ami           = "ami-0c1a7f89451184c8b"
  instance_type = "t3.micro"  # Same type for all

  tags = {
    Name = each.value
  }
}
| Instance Name | Instance Type |
| ------------- | ------------- |
| web           | t3.micro      |
| app           | t3.micro      |
| db            | t3.micro      |
========================================================
CREATION OF EKS CLUSTER
=======================================================
resource "aws_eks_cluster" "eks" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_1.id,
      aws_subnet.eks_subnet_2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]
}
========================================================
WORKER NODES
=======================================================
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.eks_subnet_1.id,
    aws_subnet.eks_subnet_2.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}
==========================================================
