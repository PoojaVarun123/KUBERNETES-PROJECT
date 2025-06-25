# SERVICES
1) ClusterIP:
-The default service type that provides an internal IP address for communication only within the Kubernetes cluster
-Used for service-to-service communication, like backend to database, or frontend to API.
EX: Your frontend app uses type: ClusterIP to connect to the backend via: http://backend-service:8080

apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
type: ClusterIP
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  
3) NodePort
-A service that exposes your app on a static port on every Kubernetes node’s IP address. This allows you to access the service from outside the cluster using NodeIP: NodePort.
-It's the simplest way to test external access without needing cloud load balancers.
Ex: You run an app and expose it via: type: NodePort,nodePort: 30001
You can access it like: http://<EC2-Node-Public-IP>:30001

apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
type: Nodeport
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      
4) Loadbalancer:
-from v1.15+, NLB is the default; Earlier Classic lb
-A service that automatically creates an external load balancer (like AWS NLB or Azure LB) and assigns a public IP or DNS name to expose your app to the internet.

apiVersion: v1
kind: Service
metadata:
  name: backend-service
annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
type: LoadBalancer
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080

6) External name
-A Kubernetes service that acts as a DNS alias, mapping a service name inside the cluster to an external DNS name outside the cluster.
-It doesn't create a real service or endpoints — it simply allows internal apps to call external services using a simpler name.
-Your app in Kubernetes connects to an AWS RDS MySQL database like this:
    type: ExternalName
    externalName: mydb.abcdefg.rds.amazonaws.com
    Inside the cluster, the app connects to 'mysql -h db-service', and db-service just resolves to the real RDS hostname.

apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  DB_HOST: db-service
  DB_USER: admin
  DB_PASS: password
  DB_NAME: testdb

apiVersion: v1
kind: Service
metadata:
  name: db-service
spec:
  type: ExternalName
  externalName: mydb.rds.amazonaws.com
  
7) Headless Service
-A Kubernetes service without a virtual IP. It lets clients connect directly to each pod using DNS, instead of load-balancing.

🌟 Features:
No load balancing
Direct pod access via DNS
Works with StatefulSets
Returns individual pod IPs

🧰 Use Cases:
Peer-to-peer apps
Databases needing stable pod names

🔍 Real Examples:
Kafka, MongoDB, Zookeeper, Cassandra, Redis Sentinel

✅ In One Line:
> Use Headless Service when each pod must be uniquely addressable — especially for stateful apps.

apiVersion: v1
kind: Service
metadata:
  name: kafka
spec:
  clusterIP: None  # 👈 This makes it Headless
  selector:
    app: kafka
  ports:
    - name: broker
      port: 9092
