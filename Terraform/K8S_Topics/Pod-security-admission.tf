=================================================================================================================
                                   PSA (Pod Security Admission)
=================================================================================================================
PSA (Pod Security Admission) is a built-in admission controller in Kubernetes that enforces security standards on pods before they are created.
It was introduced in Kubernetes v1.22 and became stable in v1.25, replacing the deprecated PodSecurityPolicy (PSP).
-----------------------------------------------------------------------------------------------------------------
Purpose of PSA
To prevent risky or insecure pods from being admitted into the cluster by applying security profiles (policies) at the namespace level.
-----------------------------------------------------------------------------------------------------------------
Key Features of PSA
Built-in controller No third-party tools needed
Namespace-based Applies security rules at namespace level
Pod-level control Validates pod specs before creation
Modes Enforce, Audit, and Warn modes for flexible policy application
Standards-based Uses three predefined security levels (profiles)
-----------------------------------------------------------------------------------------------------------------
PSA Security Levels
privileged - Most permissive (allows everything) — for trusted workloads
baseline - Minimally restrictive — allows common safe settings
restricted -Most secure — follows strict security practices (no root, no host access, etc.)
-----------------------------------------------------------------------------------------------------------------
How PSA Works (Step-by-Step)
1. Label the Namespace to apply a policy:
kubectl label namespace dev \
  pod-security.kubernetes.io/enforce=restricted

2. When a pod is created, PSA:
Checks its security settings
Applies the relevant policy (based on namespace labels)
Blocks, warns, or logs depending on the configured mode

3. Three PSA modes:
enforce: Reject pods that violate the policy
audit: Log violations (but allow pod)
warn: Show warning to the user/client
-----------------------------------------------------------------------------------------------------------------
Example Namespace with All Modes
kubectl label namespace dev \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=baseline \
  pod-security.kubernetes.io/warn=baseline

Enforce: Must follow restricted
Audit/Warning: Log/show messages if baseline is violated
-----------------------------------------------------------------------------------------------------------------
Real-World Use Case
In a production environment, I would label all critical namespaces (e.g., payments, orders) with:
    pod-security.kubernetes.io/enforce=restricted
    This ensures no developer can accidentally deploy insecure containers (like running as root, using host networking, or privileged mode).
-----------------------------------------------------------------------------------------------------------------
PSA vs PSP (Quick Comparison)
Feature PSP PSA
Built-in Yes (deprecated) Yes (stable in v1.25+)
Applied at Pod level (via RBAC) Namespace level (via labels)
Complexity High (hard to configure) Low (simple labels)
Flexibility High but error-prone Simpler with predefined profiles
Replacement Deprecated in v1.21, removed v1.25 PSA is the official replacement
-----------------------------------------------------------------------------------------------------------------
Component Details
What Admission controller to enforce pod security
How Applies security profiles via namespace labels
Modes Enforce, Audit, Warn
Profiles Privileged, Baseline, Restricted
Why Prevent risky pods, enforce security standards
-----------------------------------------------------------------------------------------------------------------

