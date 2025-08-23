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
  name          = "${var.environment}-app-deploy"
  description   = "Build & deploy project using GitHub source for ${var.environment}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30

  artifacts {
    type      = "S3"
    location  = aws_s3_bucket.artifact_bucket.bucket  # reference to your S3 bucket
    path      = "build-output"                        # folder inside the bucket
    name      = "app.zip"                             # artifact filename
    packaging = "ZIP"                                 # (ZIP or NONE)
    encryption_disabled = false
  }


  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/HeartfulnessInstitute/hfncare.git"
    git_clone_depth = 1

    buildspec = <<EOF
version: 0.2

env:
  secrets-manager:
    EC2_SSH_KEY: "ec2-ssh-key:private_key"
  variables:
    APP_WORKING_DIR: "app_code"
    EC2_USER: "ec2-user"
    EC2_HOST: "65.0.96.46"
    DEPLOY_DIR: "/var/www/html"

phases:
  install:
    commands:
      - echo "Installing packages..." && yum install -y unzip openssh-clients zip

  build:
    commands:
      - echo "Packaging app..."
      - mkdir -p output
      - cd $APP_WORKING_DIR
      - zip -r ../output/app.zip .
      - cd ..
      - echo "Created output/app.zip"

  post_build:
    commands:
      - echo "Deploying to EC2..."
      - echo "$EC2_SSH_KEY" > ec2-key.pem
      - chmod 600 ec2-key.pem
      - scp -o StrictHostKeyChecking=no -i ec2-key.pem output/app.zip $EC2_USER@$EC2_HOST:/tmp/app.zip
      - ssh -o StrictHostKeyChecking=no -i ec2-key.pem $EC2_USER@$EC2_HOST << 'DEPLOY'
          set -e
          sudo mkdir -p $DEPLOY_DIR
          sudo unzip -o /tmp/app.zip -d $DEPLOY_DIR
          sudo chown -R $EC2_USER:$EC2_USER $DEPLOY_DIR
          rm -f /tmp/app.zip
          echo "Deployment succeeded!"
        DEPLOY

artifacts:
  files:
    - output/app.zip
EOF
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
      name             = "TerraformBuild"
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

  tags = {
    Environment = var.environment
  }
}
