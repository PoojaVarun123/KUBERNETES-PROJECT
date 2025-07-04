===================================================================================================================================================
CONFIGMAP AND SECRETS
===================================================================================================================================================
1. What is a ConfigMap in Kubernetes?
A ConfigMap stores non-sensitive key-value pairs such as:
-App settings
-Environment-specific variables
-Config files
👉 Use when the data does not require encryption.
--------------------------------------------------------------------------------------------------------------------------------------------------
Example: configmap.yaml
apiVersion: v1 
kind: ConfigMap 
metadata: 
  name: my-app-config 
  namespace: default 
  data: 
    APP_ENV: "production" 
    APP_VERSION: "v1.0.0" 
    LOG_LEVEL: "debug" 
===================================================================================================================================================    
2. What is a Secret in Kubernetes?
A Secret stores sensitive information such as:
-Passwords
-API tokens
-Database credentials
Use when the data must be protected and Base64-encoded.
--------------------------------------------------------------------------------------------------------------------------------------------------
Example: secret.yaml
apiVersion: v1 
kind: Secret 
metadata: 
  name: my-app-secret 
  namespace: default 
  type: Opaque 
  data: 
    DB_USERNAME: YWRtaW4= # base64 of 'admin' 
    DB_PASSWORD: c2VjcmV0MTIz # base64 of 'secret123' 
--------------------------------------------------------------------------------------------------------------------------------------------------
--Encode values using:
echo -n 'admin' | base64 
echo -n 'secret123' | base64 
===================================================================================================================================================    
3. Integrate ConfigMap and Secret in a Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        # From ConfigMap
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: my-app-config
              key: APP_ENV
        - name: APP_VERSION
          valueFrom:
            configMapKeyRef:
              name: my-app-config
              key: APP_VERSION
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: my-app-config
              key: LOG_LEVEL

        # From Secret
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: my-app-secret
              key: DB_USERNAME
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: my-app-secret
              key: DB_PASSWORD 
This injects the ConfigMap and Secret as environment variables inside the container.
===================================================================================================================================================
4. Apply All YAMLS:
kubectl apply -f configmap.yaml 
kubectl apply -f secret.yaml 
kubectl apply -f deployment.yaml 

Verify:
kubectl get configmap my-app-config -o yaml 
kubectl get secret my-app-secret -o yaml 
kubectl describe deployment my-app 
kubectl exec -it <pod-name> -- env 

Key Takeaways:
Feature
Stores Non-sensitive settings Sensitive data (passwords, tokens)
Encoding Plain text Base64-encoded
Mounted As Environment variables or volumes Same
===================================================================================================================================================
5. Mount ConfigMap and Secret as Volumes (Instead of Environment Variables)
✅ This is useful when:
You need the data as files (e.g., config files, certificates, etc.)
Your app reads configuration from the filesystem.
---
📄 Example: Deployment with Volumes (configmap + secret)

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
        - name: secret-volume
          mountPath: /etc/secrets

      volumes:
      - name: config-volume
        configMap:
          name: my-app-config
      - name: secret-volume
        secret:
          secretName: my-app-secret

✅ In this case:
ConfigMap data will be available as files in /etc/config/
Secret data will be available as files in /etc/secrets/
===================================================================================================================================================
🚀 6. Create a ConfigMap & Secret using Terraform (Infrastructure as Code)

📄 Terraform for ConfigMap (kubernetes_config_map.tf):
resource "kubernetes_config_map" "app_config" {
  metadata {
    name = "my-app-config"
    namespace = "default"
  }
  data = {
    APP_ENV     = "production"
    APP_VERSION = "v1.0.0"
    LOG_LEVEL   = "debug"
  }
}
===================================================================================================================================================
📄 Terraform for Secret (kubernetes_secret.tf):

resource "kubernetes_secret" "app_secret" {
  metadata {
    name = "my-app-secret"
    namespace = "default"
  }
  data = {
    DB_USERNAME = base64encode("admin")
    DB_PASSWORD = base64encode("secret123")
  }
  type = "Opaque"
}

✅ Run:
terraform init
terraform apply

===================================================================================================================================================

✅ Key Notes: 
| ConfigMap | Secret | 
| Stored as plain key-value | ✅ | ✅ | 
| Encrypted at rest | ❌ | ✅ (with Kubernetes or KMS) | 
| Can be mounted as file | ✅ | ✅ | 
| Can be injected as env var | ✅ | ✅ | 
| Can be managed by Terraform | ✅ | ✅ |

