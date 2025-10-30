resource "aws_codebuild_project" "main_build" {
  name         = "${var.project_name}-${var.environment}-build"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.privileged_mode
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
    compute_type    = "BUILD_GENERAL1_SMALL"
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
