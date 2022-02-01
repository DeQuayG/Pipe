###Task Execution Role for the App 
resource "aws_iam_role" "task_execution_role" {
  name = "task_execution_role"
## Here we set aparamteres for when/if it is allowed for 
## A user to assume this role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "task_execution_policy" {
  name        = "task-policy"
  description = "Policy that allows the task to pull from ECR, Write to S3, Make Logs"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:StartMetricStreams",
                "cloudwatch:PutMetricStream",
                "cloudwatch:EnableInsightRules",
                "cloudwatch:PutInsightRule",
                "cloudwatch:PutDashboard",
                "logs:GetLogRecord",
                "logs:PutDestinationPolicy",
                "logs:StartQuery",
                "logs:StopQuery",
                "logs:TestMetricFilter",
                "logs:PutQueryDefinition",
                "logs:CreateLogGroup",
                "logs:GetLogDelivery",
                "logs:CreateLogStream",
                "logs:TagLogGroup",
                "logs:GetQueryResults",
                "logs:UpdateLogDelivery",
                "logs:GetLogEvents",
                "logs:FilterLogEvents",
                "logs:GetLogGroupFields",
                "logs:PutDestination",
                "logs:CreateLogStream",
                "ecr:GetDownloadUrlForLayer",
                "ecr:ReplicateImage",
                "ecr:BatchGetImage",
                "ecr:GetAuthorizationToken",
                "logs:PutLogEvents",
                "ecr:BatchCheckLayerAvailability",
                "s3:*", 
                "ecs:CreateService", 
                "ecs:ExecuteCommand", 
                "ec2:AssociateIamInstanceProfile",
                "ec2:AssociateInstanceEventWindow", 
                "ec2:ImportInstance", 
                "iam:GetRole"
              ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
# role = takes this specified role, connects it to the specified policy ARN
resource "aws_iam_role_policy_attachment" "task-attach" {
  role       = aws_iam_role.task_execution_role.id
  policy_arn = aws_iam_policy.task_execution_policy.arn
} 

### Role to be attached to the Lambda fundtion
## Alows it to read from S3 and write to DynamoDB

resource "aws_iam_role" "dynamo_role" {
  name = "access_dynamodb"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_policy" "dynamodb" {
  name        = "task-policy-dynamodb"
  description = "Allows READ access from S3, and WRITE access to DynamoDB"
 
 policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": [
               "s3:*",
               "dynamodb:CreateTable",
               "dynamodb:UpdateTimeToLive",
               "dynamodb:PutItem",
               "dynamodb:DescribeTable",
               "dynamodb:ListTables",
               "dynamodb:DeleteItem",
               "dynamodb:GetItem",
               "dynamodb:Scan",
               "dynamodb:Query",
               "dynamodb:UpdateItem",
               "dynamodb:UpdateTable"
           ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

 
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.dynamo_role.name
  policy_arn = aws_iam_policy.dynamodb.arn
} 

data "aws_iam_policy_document" "instance_assume_role_policy" {
statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.task_execution_role.arn]
    }
  }
}