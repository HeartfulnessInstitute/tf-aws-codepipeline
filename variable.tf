variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository (e.g. org/repo)"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to build"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub OAuth token"
  type        = string
  sensitive   = true
}
