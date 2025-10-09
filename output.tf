output "artifact_bucket_name" {
  description = "S3 bucket used for storing CodePipeline artifacts"
  value       = aws_s3_bucket.artifact_bucket.bucket
}
output "codebuild_project_name" {
  description = "Name of the CodeBuild project created by pipeline module"
  value       = aws_codebuild_project.this.name
}

output "codepipeline_name" {
  description = "Name of the CodePipeline created by pipeline module"
  value       = aws_codepipeline.this.name
}

output "codepipeline_role_arn" {
  description = "ARN of the IAM role used by CodePipeline"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  description = "ARN of the IAM role used by CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}


