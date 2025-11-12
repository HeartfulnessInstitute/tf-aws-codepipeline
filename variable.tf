variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}
variable "codebuild_role_arn" {
    type = string
}

variable "image" {
  type    = string
  default = "aws/codebuild/standard:5.0"
}

variable "terraform_image" {
  type    = string
  default = "aws/codebuild/standard:6.0"
}

variable "buildspec" {
  type    = string
}

variable "terraform_buildspec" {
  type    = string
}

variable "build_timeout" {
  type    = number
}

variable "privileged_mode" {
  type    = bool
  default = true
}
variable "codedeploy_role_arn" {
type = string
}

variable "deployment_config_name" {
  type    = string
  default = "CodeDeployDefault.AllAtOnce"
}

variable "ec2_tag_key" {
type = string
default = "project"
}
variable "ec2_tag_value" {
type = string
}
variable "artifact_bucket_name" {
type = string
}
variable "codepipeline_role_arn" {
type = string
}

variable "github_connection_arn" {
type = string
}
variable "github_owner" {
type = string
}
variable "github_repo"  {
type = string
}
variable "github_branch" {
type = string
}

# consuming CodeBuild/CodeDeploy created elsewhere
variable "codebuild_project_name" {
type = string
}
variable "codedeploy_app_name"   {
type = string
}
variable "codedeploy_group_name" {
type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
