resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.project_name}-${var.environment}-artifacts"
  force_destroy = var.artifact_bucket_force_destroy

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-artifacts"
      Project     = var.project_name
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "artifact_bucket" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# CodeBuild IAM Role
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-${var.environment}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-codebuild-role"
      Environment = var.environment
    }
  )
}

# CodeBuild IAM Policy
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-${var.environment}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.artifact_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.artifact_bucket.arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_manager_arns
      }
    ]
  })
}

# Attach additional policies to CodeBuild role if provided
resource "aws_iam_role_policy_attachment" "codebuild_additional_policies" {
  for_each = toset(var.codebuild_additional_policy_arns)

  role       = aws_iam_role.codebuild_role.name
  policy_arn = each.value
}

# CodeBuild Project
resource "aws_codebuild_project" "this" {
  name          = "${var.project_name}-${var.environment}-build"
  description   = var.codebuild_description
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = var.codebuild_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    type                        = var.codebuild_type
    privileged_mode             = var.codebuild_privileged_mode
    image_pull_credentials_type = var.codebuild_image_pull_credentials_type

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_file
  }

  dynamic "cache" {
    for_each = var.codebuild_cache_type != null ? [1] : []
    content {
      type     = var.codebuild_cache_type
      location = var.codebuild_cache_type == "S3" ? "${aws_s3_bucket.artifact_bucket.bucket}/cache" : null
    }
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/${var.project_name}-${var.environment}"
      stream_name = "build-log"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-build"
      Project     = var.project_name
      Environment = var.environment
    }
  )
}

# CodePipeline IAM Role
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-${var.environment}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-pipeline-role"
      Environment = var.environment
    }
  )
}

# CodePipeline IAM Policy
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project_name}-${var.environment}-pipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.artifact_bucket.arn,
          "${aws_s3_bucket.artifact_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.this.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codeconnections:UseConnection"
        ]
        Resource = var.codestar_connection_arn
      }
    ]
  })
}

# CodeDeploy resources (optional)
resource "aws_iam_role" "codedeploy_role" {
  count = var.enable_codedeploy ? 1 : 0
  name  = "${var.project_name}-${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-codedeploy-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_attach" {
  count      = var.enable_codedeploy ? 1 : 0
  role       = aws_iam_role.codedeploy_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy" "codedeploy_additional_policy" {
  count = var.enable_codedeploy ? 1 : 0
  name  = "${var.project_name}-${var.environment}-codedeploy-additional-policy"
  role  = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codedeploy:CreateDeployment",
        "codedeploy:GetApplication",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:RegisterApplicationRevision"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_codedeploy_app" "this" {
  count            = var.enable_codedeploy ? 1 : 0
  name             = "${var.project_name}-${var.environment}-app"
  compute_platform = var.codedeploy_compute_platform

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-app"
      Environment = var.environment
    }
  )
}

resource "aws_codedeploy_deployment_group" "this" {
  count                 = var.enable_codedeploy ? 1 : 0
  app_name              = aws_codedeploy_app.this[0].name
  deployment_group_name = "${var.project_name}-${var.environment}-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role[0].arn
  deployment_config_name = var.codedeploy_deployment_config

  dynamic "ec2_tag_set" {
    for_each = length(var.codedeploy_ec2_tag_filters) > 0 ? [1] : []
    content {
      dynamic "ec2_tag_filter" {
        for_each = var.codedeploy_ec2_tag_filters
        content {
          key   = ec2_tag_filter.value.key
          type  = ec2_tag_filter.value.type
          value = ec2_tag_filter.value.value
        }
      }
    }
  }

  dynamic "auto_rollback_configuration" {
    for_each = var.codedeploy_auto_rollback_enabled ? [1] : []
    content {
      enabled = true
      events  = var.codedeploy_auto_rollback_events
    }
  }
}

# CodePipeline
resource "aws_codepipeline" "this" {
  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  # Source Stage
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
        OutputArtifactFormat = var.source_output_artifact_format
      }
    }
  }

  # Build Stage
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  # Deploy Stage (optional)
  dynamic "stage" {
    for_each = var.enable_codedeploy ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeploy"
        version         = "1"
        input_artifacts = ["build_output"]

        configuration = {
          ApplicationName     = aws_codedeploy_app.this[0].name
          DeploymentGroupName = aws_codedeploy_deployment_group.this[0].deployment_group_name
        }
      }
    }
  }

  # Additional custom stages
  dynamic "stage" {
    for_each = var.additional_stages
    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions
        content {
          name             = action.value.name
          category         = action.value.category
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          input_artifacts  = lookup(action.value, "input_artifacts", [])
          output_artifacts = lookup(action.value, "output_artifacts", [])
          configuration    = lookup(action.value, "configuration", {})
          role_arn         = lookup(action.value, "role_arn", null)
          run_order        = lookup(action.value, "run_order", null)
        }
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-pipeline"
      Project     = var.project_name
      Environment = var.environment
    }
  )
}
