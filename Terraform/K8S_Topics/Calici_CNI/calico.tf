🚀 1️⃣ Default Deny All (Strict Baseline)
✅ Blocks all traffic until specifically allowed.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
----------------------------------------------------------------------------------
🚀 2️⃣ Frontend: Allow Only Ingress from Internet on Port 80/443
✅ Only public HTTP/HTTPS access allowed.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-to-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: frontend
  ingress:
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0
  - ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
--------------------------------------------------------------------------------------
🚀 3️⃣ Backend: Allow Only Ingress from Frontend on Port 8080
✅ Only frontend can call backend.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
  ports:
    - protocol: TCP
      port: 8080
--------------------------------------------------------------------------------
🚀 4️⃣ Database: Allow Only Ingress from Backend on Port 3306
✅ Only backend can talk to database.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-database
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: database
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
  ports:
    - protocol: TCP
      port: 3306


---

👉 Apply these in your namespace:

kubectl apply -f default-deny-all.yaml
kubectl apply -f allow-ingress-to-frontend.yaml
kubectl apply -f allow-frontend-to-backend.yaml
kubectl apply -f allow-backend-to-database.yaml


---

✅ This gives you:

Strict zero-trust networking

Clear separation between app tiers

No east-west pod traffic unless explicitly allowed


👉 Let me know if you want Helm charts, app deployment YAMLs, or Terraform for this too.
