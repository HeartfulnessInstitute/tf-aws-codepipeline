# S3 Outputs
output "artifact_bucket_id" {
  description = "ID of the S3 artifact bucket"
  value       = aws_s3_bucket.artifact_bucket.id
}

output "artifact_bucket_arn" {
  description = "ARN of the S3 artifact bucket"
  value       = aws_s3_bucket.artifact_bucket.arn
}

# CodeBuild Outputs
output "codebuild_project_id" {
  description = "ID of the CodeBuild project"
  value       = aws_codebuild_project.this.id
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.this.arn
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.this.name
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_name" {
  description = "Name of the CodeBuild IAM role"
  value       = aws_iam_role.codebuild_role.name
}

# CodePipeline Outputs
output "codepipeline_id" {
  description = "ID of the CodePipeline"
  value       = aws_codepipeline.this.id
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.this.arn
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.this.name
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_name" {
  description = "Name of the CodePipeline IAM role"
  value       = aws_iam_role.codepipeline_role.name
}

# CodeDeploy Outputs
output "codedeploy_app_id" {
  description = "ID of the CodeDeploy application"
  value       = var.enable_codedeploy ? aws_codedeploy_app.this[0].id : null
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = var.enable_codedeploy ? aws_codedeploy_app.this[0].name : null
}

output "codedeploy_deployment_group_id" {
  description = "ID of the CodeDeploy deployment group"
  value       = var.enable_codedeploy ? aws_codedeploy_deployment_group.this[0].id : null
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = var.enable_codedeploy ? aws_iam_role.codedeploy_role[0].arn : null
}
