variable "project_name" {
  description = "Name of the project"
  type        = string
}
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile name"
  type        = string
}


variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# S3 Artifact Bucket
variable "artifact_bucket_force_destroy" {
  description = "Force destroy S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

# CodeBuild Variables
variable "codebuild_description" {
  description = "Description for the CodeBuild project"
  type        = string
}

variable "codebuild_timeout" {
  description = "Build timeout in minutes"
  type        = number
}

variable "codebuild_compute_type" {
  description = "Compute type for CodeBuild (BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE)"
  type        = string
}

variable "codebuild_image" {
  description = "Docker image to use for CodeBuild"
  type        = string
}

variable "codebuild_type" {
  description = "Type of build environment (LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER, ARM_CONTAINER)"
  type        = string
}

variable "codebuild_privileged_mode" {
  description = "Whether to enable privileged mode for Docker builds"
  type        = bool
  default     = false
}

variable "codebuild_image_pull_credentials_type" {
  description = "Type of credentials CodeBuild uses to pull images (CODEBUILD or SERVICE_ROLE)"
  type        = string
}

variable "codebuild_environment_variables" {
  description = "List of environment variables for CodeBuild"
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  default = []
}

variable "buildspec_file" {
  description = "Path to buildspec file in the repository"
  type        = string
}

variable "codebuild_cache_type" {
  description = "Cache type for CodeBuild (S3, LOCAL, or null for no cache)"
  type        = string
  default     = null
}

variable "codebuild_additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to CodeBuild role"
  type        = list(string)
  default     = []
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that CodeBuild can access"
  type        = list(string)
  default     = ["*"]
}

# Source Stage Variables
variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection for GitHub"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner/organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}

variable "source_output_artifact_format" {
  description = "Output artifact format (CODE_ZIP or CODEBUILD_CLONE_REF)"
  type        = string
  default     = "CODE_ZIP"
}

# CodeDeploy Variables
variable "enable_codedeploy" {
  description = "Whether to enable CodeDeploy stage in the pipeline"
  type        = bool
  default     = false
}

variable "codedeploy_compute_platform" {
  description = "Compute platform for CodeDeploy (Server, Lambda, or ECS)"
  type        = string
}

variable "codedeploy_deployment_config" {
  description = "Deployment configuration for CodeDeploy"
  type        = string
  default     = "CodeDeployDefault.AllAtOnce"
}

variable "codedeploy_ec2_tag_filters" {
  description = "List of EC2 tag filters for CodeDeploy deployment group"
  type = list(object({
    key   = string
    type  = string
    value = string
  }))
  default = []
}

variable "codedeploy_auto_rollback_enabled" {
  description = "Whether to enable auto-rollback"
  type        = bool
  default     = true
}

variable "codedeploy_auto_rollback_events" {
  description = "Events that trigger auto-rollback"
  type        = list(string)
  default     = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
}
