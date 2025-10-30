output "artifact_bucket_name" {
  description = "S3 bucket used for storing CodePipeline artifacts"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "codepipeline_role_arn" {
  description = "ARN of the IAM role used by CodePipeline"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  description = "ARN of the IAM role used by CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}








