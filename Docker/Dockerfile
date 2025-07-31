======================================================================================================================================
1. Node.js
======================================================================================================================================
1.1 Single-Stage Dockerfile

Use official Node.js LTS image
FROM node:14

Create app directory
WORKDIR /app

Install app dependencies
COPY package*.json ./
RUN npm install

Bundle app source
COPY . .

Expose port and start the app
EXPOSE 3000
CMD ["node", "index.js"]
----------------------------------------------------------------------------------------------------------------------------------------------
1.2 Multi-Stage Dockerfile

Stage 1: Build Dependencies
FROM node:14 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

Stage 2: Production Image
FROM node:14-alpine
WORKDIR /app
COPY --from=builder /app ./

EXPOSE 3000
CMD ["node", "index.js"]


======================================================================================================================================
2. Java (Maven / Spring Boot)
======================================================================================================================================
2.1 Single-Stage Dockerfile

Use official OpenJDK image
FROM openjdk:11

WORKDIR /app

Copy the fat JAR built locally
COPY target/myapp.jar /app/app.jar

Expose application port
EXPOSE 8080

Run the application
CMD ["java", "-jar", "app.jar"]
----------------------------------------------------------------------------------------------------------------------------------------------
2.2 Multi-Stage Dockerfile

Stage 1: Build with Maven
FROM maven:3.8.4-openjdk-11 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

Stage 2: Run the Application
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=builder /app/target/myapp.jar ./app.jar

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
======================================================================================================================================
3. Python
======================================================================================================================================
3.1 Single-Stage Dockerfile

Use official Python image
FROM python:3.9

WORKDIR /app

Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

Copy application code
COPY . .

Expose port and run
EXPOSE 5000
CMD ["python", "app.py"]
----------------------------------------------------------------------------------------------------------------------------------------------
3.2 Multi-Stage Dockerfile
Stage 1: Install Dependencies
FROM python:3.9 AS builder
WORKDIR /app
COPY requirements.txt ./
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

Stage 2: Production Image
FROM python:3.9-slim
WORKDIR /app

Copy installed packages from builder
COPY --from=builder /install /usr/local

Copy application code
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
======================================================================================================================================
Additional Tips & Best Practices
- Add a .dockerignore file to exclude unnecessary files (e.g., node_modules, target, .git) and speed up builds.
- Pin specific base-image versions (e.g., node:14-alpine, openjdk:11-jre-slim) to ensure reproducible builds.
- Leverage small runtime images (Alpine, Slim) in the final stage to minimize attack surface and image size.
- Use non-root users with USER to harden your containers.
- Cache dependency installs by separating COPY of manifests (package.json, pom.xml, requirements.txt) from the rest of your source.
