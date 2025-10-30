
output "pipeline_id" {
  description = "ID of the CodePipeline"
  value       = aws_codepipeline.pipeline.id
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.pipeline.arn
}

output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.pipeline.name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.build.name
}

output "artifact_bucket_name" {
  description = "Name of the artifact S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "artifact_bucket_arn" {
  description = "ARN of the artifact S3 bucket"
  value       = aws_s3_bucket.artifacts.arn
}
