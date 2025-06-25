===========================================================================================
                                        With EBS Storage
===========================================================================================
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "1"                  # Total CPU requested across all pods
    requests.memory: "1Gi"             # Total memory requested across all pods
    limits.cpu: "2"                    # Max total CPU limit across all pods
    limits.memory: "2Gi"               # Max total memory limit across all pods
    requests.storage: "10Gi"           # Max total storage requested across all PVCs
    persistentvolumeclaims: "5"        # Max number of PVCs allowed
-------------------------------------------------------------------------------------------
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  namespace: dev
spec:
  serviceName: "web"
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        volumeMounts:
        - name: web-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: web-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: ebs-sc
      resources:
        requests:
          storage: 1Gi
===========================================================================================
                                        With EFS Storage
===========================================================================================
1. ResourceQuota for EFS usage in namespace dev

apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-efs-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "2"                    # Guaranteed CPU for all pods
    limits.cpu: "4"                      # Max CPU for all pods
    requests.memory: "4Gi"               # Guaranteed memory for all pods
    limits.memory: "8Gi"                 # Max memory for all pods
    requests.storage: "20Gi"             # Total requested storage (tracked across PVCs, even EFS)
    persistentvolumeclaims: "10"         # Max number of PVCs in the namespace
--------------------------------------------------------------------------------------------
✅ 2. Example PVC using EFS StorageClass
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-pvc
  namespace: dev
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc              # Replace with your actual EFS SC name
  resources:
    requests:
      storage: 5Gi
---------------------------------------------------------------------------------------------
✅ 3. Deployment Using EFS with Resource Requests/Limits

apiVersion: apps/v1
kind: Deployment
metadata:
  name: efs-app
  namespace: dev
spec:
  replicas: 2
  selector:
    matchLabels:
      app: efs-web
  template:
    metadata:
      labels:
        app: efs-web
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: "300m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        volumeMounts:
        - name: efs-storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: efs-storage
        persistentVolumeClaim:
          claimName: efs-pvc
---------------------------------------------------------------------------------------------
📌 Summary
Component Key Setting
EFS PVC ReadWriteMany, dynamic SC
Deployment requests and limits on container
ResourceQuota Controls total CPU, memory, PVC count, and requested storage
