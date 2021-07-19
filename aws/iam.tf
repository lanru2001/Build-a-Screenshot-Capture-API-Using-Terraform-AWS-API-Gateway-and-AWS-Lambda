resource "aws_iam_role" "lambda_exec_role" {
  name        = "lambda_exec_role"
  description = "Execution role for Lambda functions"

  assume_role_policy = <<EOF
{
        "Version"  : "2012-10-17",
        "Statement": [
            {
                "Action"   : "sts:AssumeRole",
                "Principal": {  
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid"   : ""
            }
        ]
}
EOF
}


resource "aws_iam_role_policy" "lambda_logging" {
  name = "lambda_logging"

  role = aws_iam_role.lambda_exec_role.id

  policy = <<EOF
{
    "Version"  : "2012-10-17",
    "Statement": [
        {
            "Effect"  : "Allow",
            "Resource": "*",
            "Action"  : [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogGroup"
            ]
        }
    ]
}
EOF
}

#lambda S3 access policy
resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "lambda_s3_access"

  role = aws_iam_role.lambda_exec_role.id

  # TODO: Change resource to be more restrictive
  policy = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBuckets",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObjectAcl"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}
