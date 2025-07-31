=================================================================================================================================================
CHATGPT Scenario based questions
=================================================================================================================================================
1.You want to identify and roll back a commit that broke the deployment. How would you do that in Jenkins?
To identify a bad commit:
    -Use git bisect or review Jenkins build history.
    -Compare the last successful build commit with the current failed one.
    -Use Git plugin to link commits to builds.

To roll back:
    -Revert the commit manually using git revert <commit-id>, or
    -Use Jenkins pipeline to automate rollback.

pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Identify Commit') {
      steps {
        sh 'git log -n 5'
      }
    }
    stage('Rollback') {
      when {
        expression { currentBuild.result == 'FAILURE' }
      }
      steps {
        sh 'git revert HEAD'
        sh 'git push origin HEAD:main'
      }
    }
  }
}
Summary:
"I use Jenkins build history and Git commit logs to pinpoint the breaking change. Once identified, I revert the commit manually or 
use an automated rollback stage in the Jenkins pipeline. I ensure rollback only happens under controlled conditions, possibly requiring 
manual approval."
----------------------------------------------------------------------------------------------------------------------------------------------
2. A Jenkins job that used to take 5 minutes now takes 30 minutes. What will you check and how will you fix it?
Analysis:
    -Check Jenkins build log timestamps.
    -Identify which stage is consuming time.
Investigate for:
    -Resource contention on agents
    -External service/API latency
    -Bloated test suites
    -Disk/network issues
Fix:
    -Add parallelization
    -Use caching (e.g., Docker layers, Maven cache)
    -Replace shared agents with dedicated ones

Summary:
"I’d analyze stage timing via Jenkins logs or Blue Ocean UI, identify bottlenecks, and resolve them by introducing caching, 
parallel testing, or allocating dedicated agents. I might also use shared libraries for repeatable performance tracking."
----------------------------------------------------------------------------------------------------------------------------------------------
3. Your pipeline fails randomly without code changes. How do you diagnose and fix it?
Analysis:
    -Look for flaky tests or external service dependencies.
Check for:
    -Non-deterministic environment setup
    -Timeouts
    -Shared workspace conflicts
Fix:
    -Isolate each build using dedicated agents or containers.
    -Introduce retry logic for flaky steps.
    -Use retry block in pipeline.


stage('Test') {
  steps {
    retry(3) {
      sh './run-tests.sh'
    }
  }
}
Summary:
"Random failures often stem from flaky tests or shared environments. I add retry mechanisms, isolate jobs using ephemeral agents, 
and use test stabilization strategies to eliminate randomness."
----------------------------------------------------------------------------------------------------------------------------------------------
4. You want the job to run only when the main branch is updated. How do you configure that?
pipeline {
  agent any
  triggers {
    pollSCM('* * * * *') // Optional
  }
  stages {
    stage('Check Branch') {
      when {
        branch 'main'
      }
      steps {
        echo "This runs only on main"
      }
    }
  }
}
Or set branch filter in Multibranch Pipeline configuration.

Summary:
"I restrict job execution to the main branch using the when { branch 'main' } directive or via branch filtering in multibranch configurations."
----------------------------------------------------------------------------------------------------------------------------------------------
5. A developer accidentally committed a secret. How do you prevent secrets from being logged in Jenkins?
Analysis:
    -Integrate Git pre-commit hooks with tools like git-secrets or talisman.
    -Use Jenkins Mask Passwords plugin or withCredentials.


withCredentials([string(credentialsId: 'aws-secret', variable: 'AWS_SECRET')]) {
  sh 'echo "Deploying with secret"'
  sh 'deploy --secret=$AWS_SECRET'
}
Summary:
"I prevent secret exposure by enforcing pre-commit scanning and using Jenkins’ withCredentials block to mask and inject secrets 
securely during pipeline execution."
----------------------------------------------------------------------------------------------------------------------------------------------
6. You want to reuse pipeline logic across multiple repositories. How would you achieve that?
Options:
    -Use Shared Libraries.
    -Create custom steps or global vars in vars/ directory.

@Library('my-shared-lib') _
pipeline {
  agent any
  stages {
    stage('Deploy') {
      steps {
        deployToProd()
      }
    }
  }
}
Summary:
"I use Jenkins Shared Libraries to modularize and reuse pipeline logic across projects. This ensures consistency, scalability, and 
centralized control."
----------------------------------------------------------------------------------------------------------------------------------------------
7. You need to implement Blue-Green deployment in your Jenkins pipeline. How will you design it?
Steps:
    -Deploy to idle (Green) environment.
    -Run health checks.
    -Switch traffic (e.g., update Load Balancer).
    -Roll back if needed.


stage('Deploy to Green') {
  steps {
    sh './deploy-green.sh'
  }
}
stage('Health Check') {
  steps {
    sh './health-check.sh'
  }
}
stage('Switch Traffic') {
  steps {
    sh './switch-lb.sh'
  }
}
Summary:
"I structure Blue-Green deployment into separate pipeline stages—deploy, validate, and switch. 
This approach ensures zero-downtime releases and safer rollbacks."
----------------------------------------------------------------------------------------------------------------------------------------------
8. Your build takes too long because of test execution. How do you reduce the time using Jenkins?
Strategies:
    -Use parallel stages to split tests.
    -Run unit tests in containers.
    -Cache dependencies.


stage('Tests') {
  parallel {
    stage('Unit Tests') {
      steps {
        sh './run-unit-tests.sh'
      }
    }
    stage('Integration Tests') {
      steps {
        sh './run-integration-tests.sh'
      }
    }
  }
}
Summary:
"I reduce test execution time by parallelizing tests, introducing containers for isolation, and using caching mechanisms. 
Jenkins pipelines support this natively."
----------------------------------------------------------------------------------------------------------------------------------------------
9. You want Job B to run only if Job A is successful. How will you configure that in Jenkins?
Options:
build job: 'JobA'
build job: 'JobB', wait: true
Use Post-build action in Job A: "Trigger parameterized build on other projects".
Use upstream/downstream trigger plugin.

Summary:
"I use either pipeline chaining via build job:, or configure post-build triggers in freestyle jobs. For complex flows, 
I consolidate them into a single pipeline."
----------------------------------------------------------------------------------------------------------------------------------------------
10. Production deployment should only happen after a manual approval. How do you achieve this?
stage('Approval') {
  steps {
    input message: 'Approve production deployment?', ok: 'Deploy'
  }
}
stage('Deploy') {
  steps {
    sh './deploy-prod.sh'
  }
}
Summary:
"I use the input step in declarative pipelines to introduce manual gates before deploying to production. 
This ensures human-in-the-loop approvals."


----------------------------------------------------------------------------------------------------------------------------------------------
11. Your Jenkins master goes down. What steps will you take to restore Jenkins and prevent data loss?
Analysis:
Immediate Steps:
    -Restore Jenkins from backup (e.g., /var/lib/jenkins)
    -Validate that /jobs, /plugins, config.xml, credentials.xml, and /secrets are intact.
Prevention Strategy:
    -Use Jenkins in HA with a backup master (read-only standby)
    -Store Jenkins data in NFS or use volume snapshots (EBS, NFS, PVC)
    -Take automated periodic backups
Summary:
"I ensure Jenkins resilience by taking scheduled backups, storing job configs in Git (Jenkins as Code), and using volume snapshots. 
If the master goes down, I restore from a known-good backup and reattach agents."
----------------------------------------------------------------------------------------------------------------------------------------------
12. You want each job to run on a clean isolated agent. How do you configure dynamic agents with Jenkins?
Analysis:
    -Use Kubernetes plugin or Docker plugin for ephemeral agents.
    -Use Pod Templates for Kubernetes-based agents.
    -Avoid shared workspaces by using customWorkspaces or PVCs.


pipeline {
  agent {
    kubernetes {
      label 'build-agent'
      yaml """
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:3.8.4-jdk-11
            command:
            - cat
            tty: true
      """
    }
  }
  stages {
    stage('Build') {
      steps {
        container('maven') {
          sh 'mvn clean package'
        }
      }
    }
  }
}
Summary:
"I use Kubernetes or Docker-based dynamic agents to ensure clean, ephemeral builds. Each job runs in an isolated container or 
pod to eliminate workspace interference."
----------------------------------------------------------------------------------------------------------------------------------------------
13. How do you ensure the Jenkins build fails if code coverage is less than 80%?
Approach:
    -Use tools like JaCoCo, Cobertura, or SonarQube.
    -Set thresholds using quality gates.

stage('Code Coverage') {
  steps {
    sh 'mvn test'
    jacoco execPattern: '**/target/jacoco.exec', classPattern: '**/target/classes', sourcePattern: '**/src/main/java', exclusionPattern: ''
  }
  post {
    always {
      jacoco changeBuildStatus: true, minimumInstructionCoverage: '80'
    }
  }
}
Summary:
"I integrate JaCoCo/SonarQube in pipelines and enforce a coverage threshold. If the coverage falls below 80%, Jenkins marks 
the build as failed."
----------------------------------------------------------------------------------------------------------------------------------------------
14. How do you automatically update Jira tickets when Jenkins builds succeed or fail?
Approach:
    -Use Jira plugin.
    -Integrate REST API with credentials.


stage('Update Jira') {
  when {
    expression { currentBuild.result == 'SUCCESS' || currentBuild.result == 'FAILURE' }
  }
  steps {
    withCredentials([usernamePassword(credentialsId: 'jira-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
      sh """
        curl -u $USERNAME:$PASSWORD -X POST \
        --data '{ "transition": { "id": "31" } }' \
        -H "Content-Type: application/json" \
        https://your-jira.com/rest/api/2/issue/PROJ-123/transitions
      """
    }
  }
}
Summary:
"I automate Jira updates using either the Jenkins Jira plugin or REST API calls during post-build steps to reflect deployment status."
----------------------------------------------------------------------------------------------------------------------------------------------
15. How can you track who triggered a Jenkins job and when?
Options:
    -Jenkins Build Parameters: ${BUILD_USER}
    -Enable Build User Vars Plugin.


stage('Audit') {
  steps {
    script {
      def user = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')[0]?.userName
      echo "Triggered by: ${user}"
    }
  }
}
Summary:
"I use Build User Vars Plugin or extract build triggers from Jenkins API to audit who initiated a job and at what time."
----------------------------------------------------------------------------------------------------------------------------------------------
16. Two builds using the same workspace are interfering with each other. How do you fix this?
Fix:
    -Avoid concurrent builds by disabling Execute concurrent builds if necessary
    -Use custom workspace per job.
    -Use docker or Kubernetes for job isolation.

options {
  disableConcurrentBuilds()
}
Summary:
"I ensure jobs run in isolated workspaces by disabling concurrency and using dedicated containers or dynamic agents for each build."
----------------------------------------------------------------------------------------------------------------------------------------------
17. How can Jenkins automatically build and test code when a Pull Request is raised on GitHub?
Tools:
    -GitHub Webhook + GitHub Branch Source Plugin
    -GitHub App-based authentication
    -Jenkinsfile detection
Steps:
    -Enable GitHub webhook on repo.
    -Use Multibranch Pipeline or GitHub Organization Folder.

Configure trigger:

triggers {
  githubPullRequest()
}
Summary:
"I configure GitHub webhooks and use Multibranch Pipelines to automatically build/test PRs using webhook triggers.
I also use status checks and GitHub Checks API."
----------------------------------------------------------------------------------------------------------------------------------------------
18. You have services A and B. When A is built, B must be automatically deployed. How do you implement this?
Approach:
    -Use Pipeline chaining.
    -Trigger downstream jobs using build job: or Jenkinsfile logic.

Jenkinsfile in Job A:
post {
  success {
    build job: 'Deploy-B', parameters: [string(name: 'version', value: '1.0.2')]
  }
}
Summary:
"I use post-success triggers in Job A to deploy Service B using job chaining. Alternatively, I encapsulate both workflows 
in a single multi-stage pipeline."
----------------------------------------------------------------------------------------------------------------------------------------------
19. You're migrating from GitLab CI to Jenkins. What steps will you follow?
Steps:
    -Convert .gitlab-ci.yml to Jenkinsfile.
    -Map GitLab runners to Jenkins agents.
    -Migrate environment variables and secrets.
    -Test CI/CD logic step-by-step.
    -Use Shared Libraries for reusable logic.
    -Replace GitLab integrations with Jenkins plugins.

Summary:
"During GitLab to Jenkins migration, I translate .gitlab-ci.yml into Jenkinsfile, map runners to Jenkins agents, and test end-to-end 
to ensure parity. I modularize logic using shared libraries."
----------------------------------------------------------------------------------------------------------------------------------------------
20. How do you configure Jenkins to send a Slack or email notification when a build fails?

post {
  failure {
    slackSend(channel: '#builds', message: "Build failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
  }
}

post {
  failure {
    mail to: 'team@example.com',
         subject: "Build Failed: ${env.JOB_NAME}",
         body: "Check Jenkins for details"
  }
}
Summary:
"I configure Slack or email post-build steps using plugins like Slack Notification or Mailer. These notify relevant stakeholders immediately 
on failures."
----------------------------------------------------------------------------------------------------------------------------------------------
21. How would you dynamically provision Jenkins agents on Kubernetes for each build, ensuring isolation and scalability?
Analysis:
    -Use the Jenkins Kubernetes plugin.
    -Configure Jenkins with a Kubernetes cloud.
    -Define PodTemplates that spin up ephemeral agents for each build.
    -These agents terminate post-build, ensuring stateless and scalable execution.


pipeline {
  agent {
    kubernetes {
      label 'k8s-agent'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:alpine
  - name: build
    image: maven:3.9.1-openjdk-17
    command: ['cat']
    tty: true
"""
    }
  }
  stages {
    stage('Build') {
      steps {
        container('build') {
          sh 'mvn clean install'
        }
      }
    }
  }
}
Summary:
"I use Jenkins Kubernetes plugin to provision ephemeral agents per build. This ensures high scalability, clean environments, 
and no agent drift."
----------------------------------------------------------------------------------------------------------------------------------------------
22. You're managing 200+ pipelines. How do you enforce standard security practices (e.g., no hardcoded credentials) across all teams?
Approach:
    -Use Shared Libraries to centralize credential handling.
    -Integrate with Vault or Credentials Plugin.
    -Define policies using tools like Jenkins Configuration as Code (JCasC).
    -Use static analysis to scan Jenkinsfile for security violations.

Summary:
"I enforce security best practices using shared libraries, central credential stores (Vault/Jenkins Credentials Plugin), 
and policy-as-code with static analysis."
----------------------------------------------------------------------------------------------------------------------------------------------
23. Describe how you would implement a canary deployment using Jenkins pipelines.
Strategy:
    -Deploy to a small % of users or pods (canary slice).
    -Monitor health metrics.
    -Gradually roll out to full traffic if healthy.
    -Roll back if issues are detected.

stage('Canary Deploy') {
  steps {
    sh './deploy.sh --env=canary --replicas=2'
  }
}
stage('Health Check') {
  steps {
    sh './monitor.sh --env=canary'
  }
}
stage('Full Rollout') {
  when {
    expression { return currentBuild.result == null }
  }
  steps {
    sh './deploy.sh --env=prod --replicas=10'
  }
}
Summary:
"I implement canary deployment in Jenkins by releasing to a small slice, running automated health checks, and proceeding with full 
rollout only if metrics look good."
----------------------------------------------------------------------------------------------------------------------------------------------
24. How can Jenkins handle Terraform infrastructure deployments safely and idempotently in a pipeline?
Best Practices:
    -Use separate stages for init, plan, apply.
    -Store state in remote backend (e.g., S3 with DynamoDB locking).
    -Use plan approvals before apply.


pipeline {
  agent any
  stages {
    stage('Init') {
      steps { sh 'terraform init' }
    }
    stage('Plan') {
      steps { sh 'terraform plan -out=tfplan' }
    }
    stage('Apply') {
      input message: 'Apply Terraform changes?'
      steps { sh 'terraform apply tfplan' }
    }
  }
}
Summary:
"I integrate Terraform using Jenkins by running init, plan, and gated apply steps, with remote state management to ensure idempotency."
----------------------------------------------------------------------------------------------------------------------------------------------
25. A plugin upgrade broke several jobs. How would you prevent such incidents in future Jenkins upgrades?
Strategies:
    -Test plugin upgrades on a staging Jenkins first.
    -Use Plugin Installation Manager Tool with pinned versions.
    -Enable plugin version locking with plugins.txt.

Summary:
"I isolate upgrades in a staging Jenkins, pin plugin versions using automation, and test pipelines for regressions before 
promoting to production."
----------------------------------------------------------------------------------------------------------------------------------------------
26. You want Jenkins to automatically roll back the deployment if post-deploy health checks fail. How would you implement that?
Approach:
    -Run health checks after deployment.
    -On failure, invoke rollback logic.

✅ Jenkinsfile Snippet:
stage('Deploy') {
  steps {
    sh './deploy.sh'
  }
}
stage('Health Check') {
  steps {
    script {
      def status = sh(script: './health-check.sh', returnStatus: true)
      if (status != 0) {
        sh './rollback.sh'
        error("Health check failed. Rolled back deployment.")
      }
    }
  }
}
Summary:
"I define post-deployment health checks in the pipeline, and invoke automated rollback logic if they fail, maintaining service stability."
----------------------------------------------------------------------------------------------------------------------------------------------
27. Describe how you’d integrate Jenkins with HashiCorp Vault to fetch secrets during pipeline runtime.
Approach:
    -Use Vault Plugin or CLI.
    -Authenticate Jenkins via AppRole, token, or Kubernetes auth.
    -Inject secrets dynamically into environment variables.

Jenkinsfile Example (Using Vault CLI):
withCredentials([string(credentialsId: 'vault-token', variable: 'VAULT_TOKEN')]) {
  sh '''
    export SECRET=$(vault kv get -field=password secret/app/db)
    echo "Secret fetched"
  '''
}
Summary:
"I integrate Vault into Jenkins via plugins or CLI, securely authenticating with AppRole or Kubernetes auth and injecting secrets 
dynamically into the pipeline."
----------------------------------------------------------------------------------------------------------------------------------------------
28. You want pipeline code to be reviewed and approved before merge to main. How does Jenkins fit into this GitHub PR-based workflow?
Strategy:
    -Use GitHub Branch Source Plugin.
    -Configure Jenkins to build PRs (PR-*).
    -Integrate GitHub status checks.
    -Block merge unless Jenkins build passes.

Summary:
"I configure Jenkins to run CI pipelines for PRs and report status checks to GitHub. Merges to main are blocked until the pipeline succeeds."
----------------------------------------------------------------------------------------------------------------------------------------------
29. How would you configure Jenkins to build only when specific directories (e.g., /src or /config) are modified?
Approach:
    -Use when condition with changeset.

pipeline {
  agent any
  stages {
    stage('Build') {
      when {
        changeset "**/src/**, **/config/**"
      }
      steps {
        echo "Code changes in src or config detected"
        sh './build.sh'
      }
    }
  }
}
Summary:
"I use changeset directive to restrict builds to only trigger when specific folders like /src or /config change, improving efficiency."
----------------------------------------------------------------------------------------------------------------------------------------------
30. What strategies would you implement to scale Jenkins horizontally and ensure high availability?
Strategies:
    -Use Jenkins master as stateless controller.
    -Use Kubernetes with auto-scaling agents.
    -Deploy Jenkins on HA-compatible backend (e.g., NFS for storage).
    -Use Load balancer + Active/Passive masters or Jenkins Operator for HA.

Summary:
"I scale Jenkins using Kubernetes-based dynamic agents, shared storage backends for HA, and stateless master setups to support parallel 
workloads and resilience."

----------------------------------------------------------------------------------------------------------------------------------------------
31. How can you use Jenkins to automate disaster recovery testing for your infrastructure or applications?
Approach:
    -Schedule DR pipeline (daily/weekly).
    -Use IaC (Terraform/CloudFormation) to spin up backup infra.
    -Run app-level health checks and DB validation.
    -Tear down the environment post-check.

pipeline {
  agent any
  stages {
    stage('Provision DR Infra') {
      steps {
        sh 'terraform apply -auto-approve -var="dr=true"'
      }
    }
    stage('Validate App') {
      steps {
        sh './validate.sh'
      }
    }
    stage('Destroy DR Infra') {
      steps {
        sh 'terraform destroy -auto-approve -var="dr=true"'
      }
    }
  }
}
Summary:
"I automate DR testing via Jenkins by provisioning disaster infra using Terraform, running app validations, and auto-destroying the 
setup after health checks."
----------------------------------------------------------------------------------------------------------------------------------------------
32. You want to build and test the same code against multiple environments (e.g., Node.js 14, 16, 18). How can Jenkins help?
Strategy:
    -Use matrix builds or parallel stages.
    -Each stage uses a container with the specific runtime version.

pipeline {
  agent any
  stages {
    stage('Test Matrix') {
      parallel {
        stage('Node 14') {
          agent { docker { image 'node:14' } }
          steps { sh 'npm test' }
        }
        stage('Node 16') {
          agent { docker { image 'node:16' } }
          steps { sh 'npm test' }
        }
        stage('Node 18') {
          agent { docker { image 'node:18' } }
          steps { sh 'npm test' }
        }
      }
    }
  }
}
Summary:
"I use Jenkins pipeline parallel stages or matrix builds to test the same code on multiple runtimes like Node.js 14, 16, and 18 simultaneously."
----------------------------------------------------------------------------------------------------------------------------------------------
33. How do you implement environment promotion (e.g., dev → QA → stage → prod) using Jenkins pipelines?
Approach:
    -Use sequential stages with gated input steps.
    -Tag artifacts and pass versions across stages.

pipeline {
  agent any
  stages {
    stage('Build & Test (Dev)') {
      steps {
        sh './build.sh'
      }
    }
    stage('Promote to QA') {
      input { message "Promote to QA?" }
      steps {
        sh './deploy.sh qa'
      }
    }
    stage('Promote to Stage') {
      input { message "Promote to Staging?" }
      steps {
        sh './deploy.sh stage'
      }
    }
    stage('Promote to Prod') {
      input { message "Final Prod Approval?" }
      steps {
        sh './deploy.sh prod'
      }
    }
  }
}
Summary:
"I implement environment promotion in Jenkins using sequential stages with manual approvals between environments to ensure safe 
progression of deployments."
----------------------------------------------------------------------------------------------------------------------------------------------
34. How would you use Jenkins to enforce compliance policies (e.g., no deploy without test coverage reports)?
Approach:
    -Integrate tools like JaCoCo, SonarQube, etc.
    -Enforce pipeline rules based on coverage thresholds.
    -Block deploy stage if reports aren’t generated or fail threshold.

stage('Test Coverage') {
  steps {
    sh './coverage.sh'
  }
  post {
    success {
      archiveArtifacts artifacts: 'coverage.xml'
    }
    failure {
      error('Coverage missing or below threshold. Blocking deployment.')
    }
  }
}
✅ Candidate Summary:
"I enforce compliance by checking for mandatory test coverage and failing builds early if coverage is missing or below policy threshold."
----------------------------------------------------------------------------------------------------------------------------------------------
35. Your Jenkins agents are running out of disk space often. How do you design a cleanup and resource management strategy?
Solutions:
    -Use Workspace Cleanup Plugin.
    -Auto-cleanup old builds.
    -Use ephemeral agents (Kubernetes/Docker) for clean builds.
    -Periodic cron cleanup scripts.


options {
  buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '7'))
}
✅ Candidate Summary:
"I manage disk usage with auto-cleanup policies, workspace cleanups, and ephemeral agents. I also monitor disk space metrics with alerts."
----------------------------------------------------------------------------------------------------------------------------------------------
36. How do you design pipelines for monorepo-based applications with multiple microservices in the same repo?
✅ Strategy:
    -Detect which service has changed using Git diff.
    -Trigger specific sub-pipelines or jobs for only changed microservices.

stage('Detect Changes') {
  steps {
    script {
      def changes = sh(script: 'git diff --name-only HEAD~1', returnStdout: true)
      if (changes.contains('service-a/')) {
        build job: 'service-a-pipeline'
      }
      if (changes.contains('service-b/')) {
        build job: 'service-b-pipeline'
      }
    }
  }
}
✅ Candidate Summary:
"For monorepos, I detect directory-level changes and trigger corresponding microservice builds to avoid full repo pipelines."
----------------------------------------------------------------------------------------------------------------------------------------------
37. How can Jenkins be configured to retry failed stages with different logic (e.g., fallback strategy)?
    -Use retry block.
    -Use conditional retry logic with try/catch and fallback actions.


stage('Deploy') {
  steps {
    script {
      try {
        retry(2) {
          sh './deploy.sh'
        }
      } catch (err) {
        echo "Retry failed. Falling back."
        sh './rollback.sh'
      }
    }
  }
}
✅ Candidate Summary:
"I configure retry with conditional fallback logic using try/catch. This ensures graceful failure recovery or rollbacks."
----------------------------------------------------------------------------------------------------------------------------------------------
38. How can Jenkins integrate with SonarQube and block merges based on quality gate failures?
      -Use SonarQube Scanner Plugin.
      -Integrate SonarQube stage.
      -Check quality gate result before moving forward.


stage('SonarQube Analysis') {
  steps {
    withSonarQubeEnv('SonarQube') {
      sh 'mvn sonar:sonar'
    }
  }
}
stage('Quality Gate') {
  steps {
    timeout(time: 1, unit: 'MINUTES') {
      waitForQualityGate abortPipeline: true
    }
  }
}
✅ Candidate Summary:
"I integrate SonarQube with Jenkins and enforce quality gate results to block pipeline progress if code quality doesn't meet standards."
----------------------------------------------------------------------------------------------------------------------------------------------
39. You need to deploy infrastructure across multiple AWS accounts using Jenkins. How would you structure the pipeline and authentication securely?
      -Use separate IAM roles per AWS account.
      -Assume roles using aws sts assume-role.
      -Store credentials securely in Jenkins.

withCredentials([[
  $class: 'AmazonWebServicesCredentialsBinding',
  credentialsId: 'aws-role-dev',
  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
]]) {
  sh 'aws sts assume-role --role-arn arn:aws:iam::1111111111:role/dev-role'
  sh './deploy.sh'
}
✅ Candidate Summary:
"I structure pipelines to authenticate via assumed roles per AWS account and deploy infra using isolated credentials managed in Jenkins."
----------------------------------------------------------------------------------------------------------------------------------------------
40. Explain how you would implement a Jenkins-as-Code model using Job DSL or Pipeline-as-Code to version control all jobs.
    -Use Pipeline-as-Code (Jenkinsfile) stored in Git.
    -Use Job DSL Plugin for non-pipeline jobs.
    -Manage Jenkins system configuration using JCasC (Jenkins Configuration as Code).

pipelineJob('example-job') {
  definition {
    cpsScm {
      scm {
        git {
          remote { url('git@github.com:org/repo.git') }
          branch('main')
        }
      }
    }
  }
}
✅ Candidate Summary:
"I implement Jenkins-as-Code using Jenkinsfile, Job DSL, and JCasC to version-control pipelines, credentials, and configuration. 
This ensures reproducibility and GitOps principles."

