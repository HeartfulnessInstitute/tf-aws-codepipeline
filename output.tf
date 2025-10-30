output "build_project_name" {
  value = aws_codebuild_project.main_build.name
}

output "terraform_build_project_name" {
  value = aws_codebuild_project.terraform_build.name
}


output "pipeline_name" {
  value = aws_codepipeline.deployment_pipeline.name
}

output "pipeline_arn" {
  value = aws_codepipeline.deployment_pipeline.arn
}
