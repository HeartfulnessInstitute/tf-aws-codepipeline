provider "aws" {
  region = "ap-south-1"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "github-oauth-token"
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.project_name}-${var.environment}-artifacts"
  force_destroy = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_codebuild_project" "deploy_app" {
  name          = "${var.environment}-app-build"
  description   = "Build & package app for ${var.environment}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30

  artifacts {
    type = "CODEPIPELINE"   
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml" 
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



resource "aws_codedeploy_app" "care_app" {
  name             = "${var.environment}-care-app"
  compute_platform = "Server" 
}

resource "aws_codedeploy_deployment_group" "care_app_group" {
  app_name              = aws_codedeploy_app.care_app.name
  deployment_group_name = "${var.environment}-care-app-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Project"
      type  = "KEY_AND_VALUE"
      value = "hfn-project"
    }
  }
}

resource "aws_codepipeline" "deployment_pipeline" {
  name     = "${var.environment}-deployment-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
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
      name             = "AppBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_app.name
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
        ApplicationName     = aws_codedeploy_app.care_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.care_app_group.deployment_group_name
      }
    }
  }
}