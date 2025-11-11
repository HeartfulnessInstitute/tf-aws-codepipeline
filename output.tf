# --------------------------
# Outputs
# --------------------------
output "policy_arn" {
  value       = aws_iam_policy.this.arn
  description = "ARN of the created IAM policy"
}

output "attached_role_names" {
  value       = keys(local.all_role_names_map)
  description = "Role names the policy was attached to (from role_names and role_arns)"
}

output "codebuild_main_project_name" {
  value       = aws_codebuild_project.main_build.name
  description = "CodeBuild main project name"
}

output "codebuild_terraform_project_name" {
  value       = aws_codebuild_project.terraform_build.name
  description = "CodeBuild terraform project name"
}

output "codepipeline_name" {
  value = aws_codepipeline.deployment_pipeline.name
}
