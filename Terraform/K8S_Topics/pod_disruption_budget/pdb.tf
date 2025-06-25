==================================================================================
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: lesson-098
  region: us-east-1
  version: "1.21"
availabilityZones:
- us-east-1a
- us-east-1b
managedNodeGroups:
- name: spot
  instanceType: t3.small
  spot: true
  desiredCapacity: 3
  minSize: 1
  maxSize: 10
  volumeSize: 20
====================================================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-controller
  template:
    metadata:
      labels:
        app: nginx-controller
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - nginx-controller
              topologyKey: "kubernetes.io/hostname"
===========================================================================================
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: nginx-controller
