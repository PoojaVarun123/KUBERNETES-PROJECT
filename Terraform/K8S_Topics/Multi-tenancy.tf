=========================================================================================================
                                   Multi-Tenancy in Kubernetes?
=========================================================================================================
Multi-tenancy means multiple users, teams, or applications (tenants) share the same Kubernetes cluster while staying isolated 
from each other — in terms of security, resources, and network.

Think of it like different companies or teams living in different “apartments” within the same building (cluster), 
each with their own access control, resources, and boundaries.

--------------------------------------------------------------------------------------------------------
Types of Multi-Tenancy

1. Soft Multi-Tenancy:
Tenants share the same Kubernetes cluster but are isolated using namespaces, RBAC, quotas, and network policies.
Best for internal teams within an organization.
Less secure between untrusted tenants.

2. Hard Multi-Tenancy:
Each tenant has stronger isolation, often with separate clusters or virtual clusters.
Used when tenants are from different organizations or require strict security.

--------------------------------------------------------------------------------------------------------
How Multi-Tenancy is Achieved in Kubernetes

Namespaces Logical separation of tenant resources (Pods, Services, ConfigMaps, etc.)
RBAC (Role-Based Access Control) Controls who can access what in each namespace
Resource Quotas Limits CPU, memory, storage per tenant to avoid overuse
Network Policies Restrict traffic between namespaces or pods
Pod Security Admission (PSA) Enforces security levels per namespace (e.g., baseline, restricted)
LimitRanges Sets default resource limits and requests within a namespace
OPA/Gatekeeper Enforce custom policies (e.g., restrict container images, enforce labels)
Ingress/Service Mesh isolation Manages external/internal access per tenant
Virtual Clusters (vCluster) Each tenant gets a lightweight “virtual” Kubernetes API on the same physical cluster (hard multi-tenancy)

--------------------------------------------------------------------------------------------------------
Real-Time Example
> You have a Kubernetes cluster shared by:
Team A (Dev)
Team B (QA)
Team C (Prod)

You can create three namespaces: dev, qa, prod.
Team A gets access only to dev namespace via RBAC.
Each namespace has its own resource quota.
Network policies ensure QA can't access Dev services.
PSA restricts root containers in prod.
Ingress routes and SSL termination are scoped per team.

Feature Use:
Namespaces - Logical separation
RBAC - Access control
Quotas & LimitRanges - Resource management
Network Policies - Traffic isolation
OPA/Gatekeeper - Policy enforcement
PSA - Pod-level security
vCluster/Separate clusters - Hard isolation for strict security
--------------------------------------------------------------------------------------------------------
