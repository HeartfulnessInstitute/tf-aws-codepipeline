// modules/cicd-pipeline/outputs.tf
output "artifact_bucket_name" {
  value       = aws_s3_bucket.artifact_bucket.bucket
  description = "S3 bucket used for pipeline artifacts (name)"
}

output "artifact_bucket_arn" {
  value       = aws_s3_bucket.artifact_bucket.arn
  description = "S3 bucket used for pipeline artifacts (arn)"
}

output "codebuild_project_name" {
  value       = aws_codebuild_project.this.name
  description = "CodeBuild project name"
}

output "codebuild_project_arn" {
  value       = aws_codebuild_project.this.arn
  description = "CodeBuild project arn"
}

# Role outputs (roles are declared in iam.tf)
output "codebuild_role_arn" {
  value       = aws_iam_role.codebuild_role.arn
  description = "ARN of the CodeBuild service role"
}

output "codebuild_role_name" {
  value       = aws_iam_role.codebuild_role.name
  description = "Name of the CodeBuild service role"
}

output "codepipeline_name" {
  value       = aws_codepipeline.this.name
  description = "CodePipeline name"
}

output "codepipeline_arn" {
  value       = aws_codepipeline.this.arn
  description = "CodePipeline ARN"
}

output "codepipeline_id" {
  value       = aws_codepipeline.this.id
  description = "CodePipeline ID"
}

output "codepipeline_role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = "ARN of the CodePipeline role"
}

output "codepipeline_role_name" {
  value       = aws_iam_role.codepipeline_role.name
  description = "Name of the CodePipeline role"
}

# CodeDeploy outputs (conditionally exported if codedeploy is enabled)
output "codedeploy_app_name" {
  value       = var.enable_codedeploy ? aws_codedeploy_app.this[0].name : null
  description = "CodeDeploy application name (or null)"
}

output "codedeploy_deployment_group_name" {
  value       = var.enable_codedeploy ? aws_codedeploy_deployment_group.this[0].deployment_group_name : null
  description = "CodeDeploy deployment group name (or null)"
}

output "codedeploy_role_arn" {
  value       = var.enable_codedeploy ? aws_iam_role.codedeploy_role[0].arn : null
  description = "ARN of the CodeDeploy role (or null)"
}

output "codedeploy_role_name" {
  value       = var.enable_codedeploy ? aws_iam_role.codedeploy_role[0].name : null
  description = "Name of the CodeDeploy role (or null)"
}
