resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-${var.environment}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-${var.environment}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow" ,
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy" "codepipeline_codestar_policy" {
  name = "codepipeline-codestar-policy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = "arn:aws:codestar-connections:ap-south-1:502390415551:connection/0b862296-0dd7-4b96-b0bb-c5e6d6ff775e"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  name = "codepipeline-inline-policy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::hfn-project-dev-artifacts",
          "arn:aws:s3:::hfn-project-dev-artifacts/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "codestar-connections:UseConnection"
        Resource = "arn:aws:codestar-connections:ap-south-1:502390415551:connection/0b862296-0dd7-4b96-b0bb-c5e6d6ff775e"
      },
      {
        Effect   = "Allow"
        Action   = "codedeploy:*"
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "codedeploy_role_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Minimum permissions for CodePipeline
resource "aws_iam_role_policy_attachment" "codepipeline_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# Needed for S3 artifact access
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# (Optional) If using CodeBuild
resource "aws_iam_role_policy_attachment" "codebuild_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# (Optional) If using CodeDeploy
resource "aws_iam_role_policy_attachment" "codedeploy_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}


resource "aws_iam_role_policy" "codebuild_secrets_access" {
  name = "${var.project_name}-${var.environment}-codebuild-secrets-access"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          "arn:aws:secretsmanager:ap-south-1:502390415551:secret:githubtoken-codepipeline-*",
          "arn:aws:secretsmanager:ap-south-1:502390415551:secret:ec2-ssh-key-*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "arn:aws:kms:ap-south-1:502390415551:key/43e287b0-63e6-4202-81db-fea4a8ddbaf8"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_logs_policy" {
  name = "codebuild-cloudwatch-logs"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:ap-south-1:502390415551:log-group:/aws/codebuild/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
resource "aws_iam_role_policy_attachment" "s3_artifacts_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy" "codebuild_s3_access" {
  name = "${var.project_name}-${var.environment}-codebuild-s3-artifact-access"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = "arn:aws:s3:::hfn-project-dev-artifacts/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::hfn-project-dev-artifacts"
      }
    ]
  })
}

