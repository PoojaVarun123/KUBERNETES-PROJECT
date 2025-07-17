===========================================================================================================
                                                      kubectl logs
===========================================================================================================
Purpose:
    Shows the application logs (stdout/stderr) from a container running in a pod.
Used For:
    Debugging runtime issues inside the container
    Viewing application output
    Checking crash or error logs
Example:
    kubectl logs my-pod-name
    kubectl logs my-pod-name -c my-container
Output Includes:
    Application-specific logs (e.g., Python errors, Nginx access logs)
    Print statements or logs written by the app to console
===========================================================================================================
                                                      kubectl describe
===========================================================================================================
Purpose:
    Gives detailed information about a Kubernetes object (like Pod, Node, Service, Deployment, etc.)
Used For:
    Checking pod events (e.g., image pull failures, scheduling issues)
    Viewing environment variables, mounted volumes, node info
    Seeing probe statuses, reasons for restarts
Example:
    kubectl describe pod my-pod-name
    kubectl describe deployment my-deployment
Output Includes:
    Metadata (labels, annotations)
    Node assigned
    Container specs (image, ports)
    Events (e.g., FailedScheduling, Unhealthy)
    Volume mounts, environment vars
    Probe results (readiness, liveness)
Comparison Table
    Feature > kubectl logs > kubectl describe
    Purpose > View container logs  > View full pod or resource details
    Scope > Container runtime (inside pod) > Kubernetes-level metadata and events
    Shows Events >  No > Yes (e.g., crash loops, probe failures)
    Shows Pod Spec >  No > Yes (container specs, node info, etc.)
    Debugging Use > Runtime app issues > Pod lifecycle and configuration issues
Use Them Together in Real Life:
    If a pod is not running correctly:
        1. Use kubectl describe pod <pod> → check for scheduling/image/probe issues
        2. Use kubectl logs <pod> → check internal application errors
===========================================================================================================
