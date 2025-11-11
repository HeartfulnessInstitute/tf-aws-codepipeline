# --------------------------
# Data & locals
# --------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = var.region != "" ? var.region : data.aws_region.current.name

  # If role ARNs are provided, extract role name by splitting on '/'
  role_names_from_arns = [
    for arn in var.role_arns :
    (
      length(split("/", arn)) > 0 ? element(split("/", arn), length(split("/", arn)) - 1) : arn
    )
  ]

  # Combine explicit role_names and ones derived from role_arns (de-duplicated)
  all_role_names_map = {
    for n in distinct(concat(var.role_names, local.role_names_from_arns)) : n => n
  }

  # Build policy document
  policy = {
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "AllowCodeBuildTrigger"
          Effect = "Allow"
          Action = [
            "codebuild:StartBuild",
            "codebuild:BatchGetBuilds"
          ]
          Resource = var.codebuild_project_arn == "" ? "*" : var.codebuild_project_arn
        },
        {
          Sid    = "AllowArtifactAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:PutObject",
            "s3:GetBucketLocation",
            "s3:ListBucket"
          ]
          Resource = var.s3_bucket == "" ? ["*"] : [
            "arn:aws:s3:::${var.s3_bucket}",
            "arn:aws:s3:::${var.s3_bucket}/*"
          ]
        },
        {
          Sid    = "AllowCodeDeployActions"
          Effect = "Allow"
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeployment",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeploymentGroup",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:List*"
          ]
          Resource = length(concat(var.codedeploy_application_arns, var.codedeploy_deploymentgroup_arns)) == 0 ?
            ["arn:aws:codedeploy:${local.region}:${local.account_id}:deploymentconfig:*"] :
            concat(var.codedeploy_application_arns, var.codedeploy_deploymentgroup_arns, [
              "arn:aws:codedeploy:${local.region}:${local.account_id}:deploymentconfig:*"
            ])
        },
        {
          Sid    = "AllowEC2AccessForDeployments"
          Effect = "Allow"
          Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeTags",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstanceAttribute",
            "ec2:DescribeImages",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeAvailabilityZones",
            "ec2:GetConsoleOutput"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowAutoScalingAccess"
          Effect = "Allow"
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:CompleteLifecycleAction",
            "autoscaling:RecordLifecycleActionHeartbeat",
            "autoscaling:PutLifecycleHook",
            "autoscaling:DeleteLifecycleHook",
            "autoscaling:DescribeLifecycleHooks",
            "autoscaling:SuspendProcesses",
            "autoscaling:ResumeProcesses"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowCloudWatchAndLogs"
          Effect = "Allow"
          Action = [
            "cloudwatch:PutMetricData",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowS3AccessForDeployments"
          Effect = "Allow"
          Action = [
            "s3:Get*",
            "s3:List*"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowTaggingResources"
          Effect = "Allow"
          Action = [
            "tag:GetResources",
            "tag:GetTagKeys",
            "tag:GetTagValues"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowIAMPassRole"
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = var.pass_role_resource == "" ? "*" : var.pass_role_resource
        }
      ],
      [
        # Additional statements merged in
        {
          Sid    = "AllowCodeDeployCoreActions"
          Effect = "Allow"
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeployment",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeploymentGroup",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:List*"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowEC2AndAutoScalingAccess"
          Effect = "Allow"
          Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeTags",
            "ec2:DescribeInstanceAttribute",
            "ec2:DescribeImages",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeAvailabilityZones",
            "ec2:GetConsoleOutput",
            "ec2:DescribeAddresses",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLifecycleHooks",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:CompleteLifecycleAction",
            "autoscaling:RecordLifecycleActionHeartbeat",
            "autoscaling:PutLifecycleHook",
            "autoscaling:DeleteLifecycleHook",
            "autoscaling:SuspendProcesses",
            "autoscaling:ResumeProcesses",
            "autoscaling:AttachLoadBalancers",
            "autoscaling:DetachLoadBalancers",
            "autoscaling:AttachLoadBalancerTargetGroups",
            "autoscaling:DetachLoadBalancerTargetGroups"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowElasticLoadBalancingAccess"
          Effect = "Allow"
          Action = [
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeListeners"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowCloudWatchAndLogs_2"
          Effect = "Allow"
          Action = [
            "cloudwatch:PutMetricData",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowS3AccessForAppRevisions"
          Effect = "Allow"
          Action = [
            "s3:Get*",
            "s3:List*"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowTaggingAndPassRole"
          Effect = "Allow"
          Action = [
            "tag:GetResources",
            "tag:GetTagKeys",
            "tag:GetTagValues",
            "iam:PassRole"
          ]
          Resource = "*"
        }
      ]
    )
  }
}

# --------------------------
# IAM policy resource + attachments
# --------------------------
resource "aws_iam_policy" "this" {
  name        = "${var.environment != "" ? var.environment : "default"}-${var.project_name}-policy"
  description = "Permissions for CodePipeline/CodeBuild/CodeDeploy for ${var.project_name}"
  policy      = jsonencode(local.policy)
  tags        = var.tags
}

# Attach to roles passed in variable.role_names or derived from role_arns
resource "aws_iam_role_policy_attachment" "attachments_by_name" {
  for_each   = local.all_role_names_map
  role       = each.value
  policy_arn = aws_iam_policy.this.arn
}

# --------------------------
# CodeBuild projects
# --------------------------
resource "aws_codebuild_project" "main_build" {
  name         = "${var.project_name}-${var.environment}-build"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.codebuild_compute_type
    image           = var.image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.privileged_mode
    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  tags = var.tags
}

resource "aws_codebuild_project" "terraform_build" {
  name          = "${var.environment}-terraform-build"
  description   = "Build project for ${var.environment} environment"
  service_role  = var.codebuild_role_arn
  build_timeout = var.build_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_timeout_compute_type
    image           = var.terraform_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.privileged_mode
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.terraform_buildspec
  }

  tags = var.tags
}

# --------------------------
# CodeDeploy app + deployment group
# --------------------------
resource "aws_codedeploy_app" "donation_app" {
  name             = "${var.environment}-${var.project_name}-donation-app"
  compute_platform = "Server"

  tags = var.tags
}

resource "aws_codedeploy_deployment_group" "donation_app_group" {
  app_name              = aws_codedeploy_app.donation_app.name
  deployment_group_name = "${var.environment}-${var.project_name}-donation-app-group"
  service_role_arn      = var.codedeploy_role_arn

  deployment_config_name = var.deployment_config_name

  ec2_tag_set {
    ec2_tag_filter {
      key   = var.ec2_tag_key
      type  = "KEY_AND_VALUE"
      value = var.ec2_tag_value
    }
  }

  tags = var.tags
}

# --------------------------
# CodePipeline
# --------------------------
resource "aws_codepipeline" "deployment_pipeline" {
  name     = "${var.environment}-${var.project_name}-deployment-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHubSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "TerraformBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy"

      action {
      name             = "CodeDeploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ApplicationName     = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_group_name
      }
    }
  }

  tags = var.tags
}
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowCodePipelinePutObject"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.codepipeline_role_arn]   # the role ARN that assumes the pipeline
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.artifact_bucket_name}/*"
    ]
  }

  statement {
    sid = "AllowCodePipelineListBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.codepipeline_role_arn]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.artifact_bucket_name}"
    ]
  }
}

resource "aws_s3_bucket_policy" "artifact_bucket_policy" {
  bucket = var.artifact_bucket_name
  policy = data.aws_iam_policy_document.bucket_policy.json
}


