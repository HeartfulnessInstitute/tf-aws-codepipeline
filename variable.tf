variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod/stage)."
}

variable "project_name" {
  type        = string
  description = "Project name used in naming."
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket used for artifact access (only bucket name). Leave blank to allow all."
}

variable "codebuild_project_arn" {
  type        = string
  description = "ARN of CodeBuild project to scope codebuild permissions. If empty, the CodeBuild statement will use '*'"
}

variable "codedeploy_application_arns" {
  type        = list(string)
  description = "List of CodeDeploy application ARNs to include in the policy."
  default     = []
}

variable "codedeploy_deploymentgroup_arns" {
  type        = list(string)
  description = "List of CodeDeploy deployment group ARNs to include in the policy."
  default     = []
}

variable "role_names" {
  type        = list(string)
  description = "List of IAM role NAMES to attach the policy to (e.g. CodeBuild/CodePipeline role names)."
  default     = []
}

variable "role_arns" {
  type        = list(string)
  description = "List of IAM role ARNs to attach the policy to (alternative), module extracts the role name from ARN."
  default     = []
}

variable "pass_role_resource" {
  type        = string
  description = "Resource(s) allowed for iam:PassRole. Default '*' (be stricter if possible)."
  default     = ""
}

variable "tags" {
  description = "Tags to add to resources"
  type        = map(string)
  default     = {}
}

# CodeBuild related variables
variable "codebuild_role_arn" {
  type        = string
  description = "Service role ARN for CodeBuild projects"
}

variable "image" {
  type        = string
  description = "Docker image to use for the app CodeBuild project"
  default     = "aws/codebuild/standard:7.0"
}

variable "terraform_image" {
  type        = string
  description = "Docker image to use for terraform CodeBuild project"
  default     = "hashicorp/terraform:light"
}

variable "privileged_mode" {
  type        = bool
  description = "Whether to enable privileged mode for CodeBuild (for docker builds)"
}

variable "buildspec" {
  type        = string
  description = "Inline buildspec for the app build or path to buildspec in repo. Default is empty (use project defaults)."
}

variable "terraform_buildspec" {
  type        = string
  description = "Inline buildspec for the terraform build."
}

variable "build_timeout" {
  type        = number
  description = "Timeout (minutes) for terraform build project"
  default     = 60
}

variable "build_timeout_compute_type" {
  type        = string
  description = "Compute type for terraform build"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_compute_type" {
  type        = string
  description = "Compute type for app build"
  default     = "BUILD_GENERAL1_SMALL"
}

# CodeDeploy variables
variable "codedeploy_role_arn" {
  type        = string
  description = "IAM role ARN for CodeDeploy to assume"
}

variable "deployment_config_name" {
  type        = string
  description = "Deployment configuration name for CodeDeploy (e.g., CodeDeployDefault.AllAtOnce)"
}

variable "ec2_tag_key" {
  type        = string
  description = "Tag key to select EC2 instances for deployment"
}

variable "ec2_tag_value" {
  type        = string
  description = "Tag value to select EC2 instances for deployment"
}

# CodePipeline variables
variable "codepipeline_role_arn" {
  type        = string
  description = "IAM role ARN for CodePipeline to assume"
}

variable "artifact_bucket_name" {
  type        = string
  description = "S3 bucket name used as artifact store for CodePipeline"
}

variable "github_connection_arn" {
  type        = string
  description = "CodeStar Connections ARN for GitHub repository"
}

variable "github_owner" {
  type        = string
  description = "GitHub repository owner (org or username)"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch to use"
}

variable "codebuild_project_name" {
  type        = string
  description = "Name of the CodeBuild project to run in the pipeline 'Build' stage'"
}

variable "codedeploy_app_name" {
  type        = string
  description = "Name of CodeDeploy application (for pipeline action)"
}

variable "codedeploy_group_name" {
  type        = string
  description = "Name of CodeDeploy deployment group (for pipeline action)"
}
