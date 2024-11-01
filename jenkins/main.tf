# Get the current AWS region
data "aws_region" "current" {}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

# Add cluster role binding
resource "kubernetes_cluster_role_binding" "jenkins_agent" {
  metadata {
    name = "jenkins-agent"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "jenkins-agent"
    namespace = "jenkins"
  }

  depends_on = [helm_release.jenkins]
}

resource "random_password" "password" {
  length      = 8
  lower       = true
  upper       = true
  numeric     = true
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1

  lifecycle {
    ignore_changes = [
      length,
      lower,
    ]
  }
}
locals {
  jenkins_agent_base_image    = "${var.base_agent_repo}:latest@${docker_registry_image.base.sha256_digest}"
  jenkins_agent_ruby_image    = "${var.ruby_agent_repo}:latest@${docker_registry_image.ruby.sha256_digest}"
  jenkins_agent_react_image   = "${var.react_agent_repo}:latest@${docker_registry_image.react.sha256_digest}"
  jenkins_agent_cypress_image = "${var.cypress_agent_repo}:latest@${docker_registry_image.cypress.sha256_digest}"
  values_config               = <<EOT
persistence:
  enabled: true
rbac:
  create: true
serviceAccountAgent:
  annotations:
    "eks.amazonaws.com/role-arn": "${aws_iam_role.jenkins_agent_role.arn}"
  create: true
controller:
  adminPassword: "${random_password.password.result}"
  ingress:
    enabled: true
    hostName: "${var.domain}"
  installPlugins:
    - "analysis-model-api:11.15.0"
    - "antisamy-markup-formatter:162.v0e6ec0fcfcf6"
    - "apache-httpcomponents-client-4-api:4.5.14-208.v438351942757"
    - "authentication-tokens:1.53.v1c90fd9191a_b_"
    - "bootstrap5-api:5.3.2-3"
    - "bouncycastle-api:2.30.1.77-225.v26ea_c9455fd9"
    - "branch-api:2.1128.v717130d4f816"
    - "caffeine-api:3.1.8-133.v17b_1ff2e0599"
    - "checks-api:2.0.2"
    - "cloudbees-folder:6.858.v898218f3609d"
    - "commons-lang3-api:3.13.0-62.v7d18e55f51e2"
    - "commons-text-api:1.11.0-95.v22a_d30ee5d36"
    - "config-file-provider:959.vcff671a_4518b_"
    - "configuration-as-code:1670.v564dc8b_982d0"
    - "credentials:1311.vcf0a_900b_37c2"
    - "credentials-binding:642.v737c34dea_6c2"
    - "cucumber-reports:5.8.0"
    - "data-tables-api:1.13.6-5"
    - "display-url-api:2.200.vb_9327d658781"
    - "durable-task:543.v262f6a_803410"
    - "echarts-api:5.4.0-7"
    - "font-awesome-api:6.5.1-1"
    - "forensics-api:2.3.0"
    - "git:5.2.0"
    - "git-client:4.6.0"
    - "github:1.37.3.1"
    - "github-api:1.318-461.v7a_c09c9fa_d63"
    - "github-branch-source:1751.v90e17c48a_6a_c"
    - "grypescanner:1.8"
    - "gson-api:2.10.1-15.v0d99f670e0a_7"
    - "htmlpublisher:1.36"
    - "instance-identity:185.v303dc7c645f9"
    - "ionicons-api:70.v2959a_b_74e3cf"
    - "jackson2-api:2.17.0-379.v02de8ec9f64c"
    - "jacoco:3.3.5"
    - "jakarta-activation-api:2.0.1-3"
    - "jakarta-mail-api:2.0.1-3"
    - "javax-activation-api:1.2.0-6"
    - "javax-mail-api:1.6.2-9"
    - "jaxb:2.3.9-1"
    - "jjwt-api:0.11.5-77.v646c772fddb_0"
    - "job-dsl:1.87"
    - "jquery3-api:3.7.1-1"
    - "json-path-api:2.8.0-21.v8b_7dc8b_1037b_"
    - "junit:1304.vc85a_b_ca_96613"
    - "kubernetes:4029.v5712230ccb_f8"
    - "kubernetes-client-api:6.9.2-239.ve49a_3f285167"
    - "kubernetes-credentials:0.11"
    - "mailer:463.vedf8358e006b_"
    - "metrics:4.2.18-442.v02e107157925"
    - "mina-sshd-api-common:2.12.0-90.v9f7fb_9fa_3d3b_"
    - "mina-sshd-api-core:2.12.0-90.v9f7fb_9fa_3d3b_"
    - "nodejs:1.6.1"
    - "okhttp-api:4.11.0-157.v6852a_a_fa_ec11"
    - "pipeline-build-step:540.vb_e8849e1a_b_d8"
    - "pipeline-github:2.8-155.8eab375ac9f8"
    - "pipeline-githubnotify-step:49.vf37bf92d2bc8"
    - "pipeline-graph-analysis:202.va_d268e64deb_3"
    - "pipeline-graph-view:205.vb_8e3a_b_51f12e"
    - "pipeline-groovy-lib:700.v0e341fa_57d53"
    - "pipeline-input-step:477.v339683a_8d55e"
    - "pipeline-milestone-step:111.v449306f708b_7"
    - "pipeline-model-api:2.2150.v4cfd8916915c"
    - "pipeline-model-definition:2.2150.v4cfd8916915c"
    - "pipeline-model-extensions:2.2150.v4cfd8916915c"
    - "pipeline-rest-api:2.34"
    - "pipeline-stage-step:305.ve96d0205c1c6"
    - "pipeline-stage-tags-metadata:2.2150.v4cfd8916915c"
    - "pipeline-stage-view:2.34"
    - "plain-credentials:143.v1b_df8b_d3b_e48"
    - "plugin-util-api:3.8.0"
    - "prism-api:1.29.0-8"
    - "scm-api:676.v886669a_199a_a_"
    - "script-security:1335.vf07d9ce377a_e"
    - "snakeyaml-api:2.2-111.vc6598e30cc65"
    - "sonar:2.16.1"
    - "ssh-credentials:308.ve4497b_ccd8f4"
    - "sshd:3.303.vefc7119b_ec23"
    - "structs:337.v1b_04ea_4df7c8"
    - "token-macro:400.v35420b_922dcb_"
    - "trilead-api:2.133.vfb_8a_7b_9c5dd1"
    - "variant:60.v7290fc0eb_b_cd"
    - "warnings-ng:10.5.1"
    - "workflow-aggregator:596.v8c21c963d92d"
    - "workflow-api:1291.v51fd2a_625da_7"
    - "workflow-basic-steps:1042.ve7b_140c4a_e0c"
    - "workflow-cps:3837.v305192405b_c0"
    - "workflow-durable-task-step:1313.vcb_970b_d2a_fb_3"
    - "workflow-job:1385.vb_58b_86ea_fff1"
    - "workflow-multibranch:773.vc4fe1378f1d5"
    - "workflow-scm-step:415.v434365564324"
    - "workflow-step-api:657.v03b_e8115821b_"
    - "workflow-support:865.v43e78cc44e0d"
  jenkinsUrlProtocol: "https"
  tagLabel: jdk17
  JCasC:
    configScripts:
      0-server-settings: |-
        jenkins:
          clouds:
          - kubernetes:
              containerCap: 10
              containerCapStr: "10"
              jenkinsTunnel: "jenkins-agent.jenkins.svc.cluster.local:50000"
              jenkinsUrl: "http://jenkins.jenkins.svc.cluster.local:8080"
              name: "rapid"
              namespace: "jenkins"
              podLabels:
              - key: "jenkins/jenkins-jenkins-agent"
                value: "true"
              serverUrl: "https://kubernetes.default"
              templates:
              - containers:
                - alwaysPullImage: true
                  args: "^$${computer.jnlpmac} ^$${computer.name}"
                  command: "/usr/local/bin/jenkins-agent"
                  envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://jenkins.jenkins.svc.cluster.local:8080/"
                  image: "${local.jenkins_agent_base_image}"
                  livenessProbe:
                    failureThreshold: 0
                    initialDelaySeconds: 0
                    periodSeconds: 0
                    successThreshold: 0
                    timeoutSeconds: 0
                  name: "jnlp"
                  resourceLimitCpu: "4"
                  resourceLimitMemory: "4Gi"
                  resourceRequestCpu: "512m"
                  resourceRequestMemory: "512Mi"
                  workingDir: "/tmp/jenkins"
%{for agent_type in var.kaniko_container_types~}
                - alwaysPullImage: true
                  args: "1h"
                  command: "/busybox/sleep"
                  envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://jenkins.jenkins.svc.cluster.local:8080/"
                  image: "gcr.io/kaniko-project/executor:v1.18.0-debug"
                  livenessProbe:
                    failureThreshold: 0
                    initialDelaySeconds: 0
                    periodSeconds: 0
                    successThreshold: 0
                    timeoutSeconds: 0
                  name: "kaniko-${agent_type}"
                  resourceLimitCpu: "4"
                  resourceLimitMemory: "4Gi"
                  resourceRequestCpu: "512m"
                  resourceRequestMemory: "512Mi"
                  workingDir: "/tmp/jenkins"
%{endfor~}
                - alwaysPullImage: true
                  args: "^$${computer.jnlpmac} ^$${computer.name}"
                  command: "/usr/local/bin/jenkins-agent"
                  envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://jenkins.jenkins.svc.cluster.local:8080/"
                  image: "${local.jenkins_agent_ruby_image}"
                  livenessProbe:
                    failureThreshold: 0
                    initialDelaySeconds: 0
                    periodSeconds: 0
                    successThreshold: 0
                    timeoutSeconds: 0
                  name: "ruby"
                  resourceLimitCpu: "4"
                  resourceLimitMemory: "4Gi"
                  resourceRequestCpu: "512m"
                  resourceRequestMemory: "512Mi"
                  workingDir: "/tmp/jenkins"
                - alwaysPullImage: true
                  args: "^$${computer.jnlpmac} ^$${computer.name}"
                  command: "/usr/local/bin/jenkins-agent"
                  envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://jenkins.jenkins.svc.cluster.local:8080/"
                  image: "${local.jenkins_agent_react_image}"
                  livenessProbe:
                    failureThreshold: 0
                    initialDelaySeconds: 0
                    periodSeconds: 0
                    successThreshold: 0
                    timeoutSeconds: 0
                  name: "react"
                  resourceLimitCpu: "4"
                  resourceLimitMemory: "4Gi"
                  resourceRequestCpu: "512m"
                  resourceRequestMemory: "512Mi"
                  workingDir: "/tmp/jenkins"
                - alwaysPullImage: true
                  args: "^$${computer.jnlpmac} ^$${computer.name}"
                  command: "/usr/local/bin/jenkins-agent"
                  envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://jenkins.jenkins.svc.cluster.local:8080/"
                  image: "${local.jenkins_agent_cypress_image}"
                  livenessProbe:
                    failureThreshold: 0
                    initialDelaySeconds: 0
                    periodSeconds: 0
                    successThreshold: 0
                    timeoutSeconds: 0
                  name: "cypress"
                  resourceLimitCpu: "4"
                  resourceLimitMemory: "4Gi"
                  resourceRequestCpu: "512m"
                  resourceRequestMemory: "512Mi"
                  workingDir: "/tmp/jenkins"
                label: "jenkins-jenkins-agent"
                name: "default"
                namespace: "jenkins"
                nodeUsageMode: "NORMAL"
                podRetention: "never"
                serviceAccount: "jenkins-agent"
                slaveConnectTimeout: 100
                slaveConnectTimeoutStr: "100"
                yamlMergeStrategy: "override"
          systemMessage: "Welcome to the FALCON CI/CD server"
          globalNodeProperties:
          - envVars:
              env:
              - key: "PATH+KANIKO"
                value: "/kaniko"
              - key: "PATH+BUSYBOX"
                value: "/busybox"
%{for k, v in var.env~}
              - key: "${k}"
                value: "${v}"
%{endfor~}
      1-load-credentials: |
        unclassified:
          gitHubPluginConfig:
            configs:
            - credentialsId: "github-secret"
              name: "Github Secret"
            hookUrl: "https://${var.domain}/github-webhook/"
          globalDefaultFlowDurabilityLevel:
            durabilityHint: PERFORMANCE_OPTIMIZED
          sonarGlobalConfiguration:
            buildWrapperEnabled: false
            installations:
            - credentialsId: "sonarqube-token"
              name: "SonarQube"
              serverUrl: "${var.sonarqube_url}"
              triggers:
                skipScmCause: false
                skipUpstreamCause: false
        credentials:
          system:
            domainCredentials:
              - credentials:
                  - string:
                      scope: GLOBAL
                      id: github-secret
                      description: "Github Secret"
                      secret: "${var.github_pat}"
                  - string:
                      scope: GLOBAL
                      id: sonarqube-token
                      description: "SonarQube Token"
                      secret: "${nonsensitive(var.sonarqube_token)}"
                  - usernamePassword:
                      scope: GLOBAL
                      id: github-credentials
                      description: "Github Credentials"
                      username: "${var.github_user}"
                      password: "${var.github_pat}"
%{for k, v in var.secret_env~}
                  - string:
                      scope: GLOBAL
                      id: "${k}"
                      description: "${k} Secret"
                      secret: "${v}"
%{endfor~}
      2-tool-settings: |-
        tool:
          git:
            installations:
            - home: "git"
              name: "Default"
          nodejs:
            installations:
            - name: "node"
              properties:
              - installSource:
                  installers:
                  - nodeJSInstaller:
                      id: "21.2.0"
                      npmPackagesRefreshHours: 72
          mavenGlobalConfig:
            globalSettingsProvider: "standard"
            settingsProvider: "standard"
          sonarRunnerInstallation:
            installations:
              - name: "sonar-scanner"
                properties:
                  - installSource:
                      installers:
                        - sonarRunnerInstaller:
                            id: "5.0.1.3006"
      3-init-jobs: |-
        jobs:
%{for repo_name in var.github_repo_names~}
          - script: >
              multibranchPipelineJob('${repo_name}') {
                branchSources {
                  github {
                    scanCredentialsId('github-credentials')
                    checkoutCredentialsId('github-credentials')
                    repoOwner('${var.github_repo_owner}')
                    repository('${repo_name}')
                    id('${repo_name}-${var.cluster_name}')

                    // Build fork PRs (unmerged head).
                    buildForkPRHead(false)
                    // Build fork PRs (merged with base branch).
                    buildForkPRMerge(false)
                    // Build origin branches.
                    buildOriginBranch(true)
                    // Build origin branches also filed as PRs.
                    buildOriginBranchWithPR(true)
                    // Build origin PRs (unmerged head).
                    buildOriginPRHead(false)
                    // Build origin PRs (merged with base branch).
                    buildOriginPRMerge(true)
                    // Sets a pattern for branches to include.
                    includes('main dev test prod PR*')
                  }
                }
              }
%{endfor~}

EOT
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "4.8.2"
  wait       = false

  namespace        = "jenkins"
  create_namespace = true

  values = [local.values_config]
}

resource "aws_iam_role" "jenkins_agent_role" {
  name = "${var.base_name}-jenkins-agent-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_arn
        }
        Condition = {
          StringEquals = {
            (var.cluster_oidc_subject)  = "system:serviceaccount:jenkins:jenkins-agent"
            (var.cluster_oidc_audience) = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  inline_policy {
    name = "agent"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::*/*"]
        },
        {
          Action = [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::*"]
        }
      ]
    })
  }

  inline_policy {
    name = "aws-secrets-manager"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*"
          ]
        },
        {
          Action = [
            "secretsmanager:GetRandomPassword",
            "secretsmanager:ListSecrets",
            "kms:Decrypt"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "update-lambda-functions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "lambda:UpdateFunctionCode",
            "lambda:GetFunction",
            "lambda:ListFunctions"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.stages)
  metadata {
    name = each.key
    labels = {
      name = each.key
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_role" "agent_role" {
  for_each = toset(var.stages)
  metadata {
    name      = "jenkins-agent-role-${each.key}"
    namespace = each.key
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  depends_on = [kubernetes_namespace.namespaces]
}

resource "kubernetes_role_binding" "agent_role_binding" {
  for_each = toset(var.stages)
  metadata {
    name      = "jenkins-agent-role-binding-${each.key}"
    namespace = each.key
  }
  subject {
    kind      = "ServiceAccount"
    name      = "jenkins-agent"
    namespace = "jenkins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.agent_role[each.key].metadata[0].name
  }

  depends_on = [kubernetes_namespace.namespaces]
}
