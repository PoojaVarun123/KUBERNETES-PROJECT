====================================================================
                                  NAMESPACE
====================================================================
  apiVersion: v1
kind: Namespace
metadata:
  name: 3-example
====================================================================
                              DEPLOYMENT
====================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: 3-example
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: aputra/myapp-195:v2
          ports:
            - name: http
              containerPort: 8080
          resources:
            requests:
              memory: 256Mi
              cpu: 100m
            limits:
              memory: 256Mi
              cpu: 100m
====================================================================
                            SERVICE
====================================================================
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: 3-example
spec:
  ports:
    - port: 8080
      targetPort: http
  selector:
    app: myapp
====================================================================
                        HORIZONTAL-POD-AUTOSCALING
====================================================================
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp
  namespace: 3-example
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70
