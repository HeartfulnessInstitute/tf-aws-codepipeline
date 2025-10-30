variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "repository_name" {
  description = "Name of the CodeCommit repository"
  type        = string
}

variable "repository_branch" {
  description = "Branch to trigger pipeline"
  type        = string
}

variable "build_image" {
  description = "Docker image for CodeBuild"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "buildspec_path" {
  description = "Path to buildspec file"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for artifacts (optional, will create if not provided)"
  type        = string
}

variable "deploy_provider" {
  description = "Deployment provider (S3, ECS, ElasticBeanstalk, CodeDeploy)"
  type        = string
}

variable "deploy_config" {
  description = "Deployment configuration map"
  type        = map(string)
  default     = {}
}

variable "build_environment_variables" {
  description = "Environment variables for build stage"
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
