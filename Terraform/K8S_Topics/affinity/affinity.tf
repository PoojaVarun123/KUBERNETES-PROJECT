===============================================================================
                               NODE AFFINITY
===============================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-node-selector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      nodeSelector:
        role: spot
===============================================================================
                               NODE AFFINITY-HARD
===============================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-affinity-hard
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: role
                operator: In
                values:
                - spot
===============================================================================
                               NODE AFFINITY-SOFT
===============================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-affinity-soft
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: role
                operator: In
                values:
                - spot
================================================================================
                       Pod affinity
================================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-affinity
spec:
  replicas: 2
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
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - nginx-controller
            topologyKey: "kubernetes.io/hostname"
================================================================================
                       Pod-anti-affinity
================================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-anti-affinity
spec:
  replicas: 2
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
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - nginx-controller
            topologyKey: "kubernetes.io/hostname"
