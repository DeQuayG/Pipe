resource "aws_cloudwatch_log_group" "b_soup" {
  name = "bsoup"
}

resource "aws_ecs_cluster" "webscraper" {
  name = "webscraper" 

   setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_iam_role" "task_role" {
  name               = "s3_task_role"
  assume_role_policy =  data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = "task_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ecr:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name   = "task_inline_policy"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.task_role.arn]
    }

    actions = [ 
      "logs:*",
      "ecr:*",
      "s3:*",
    ]

    resources = [
       "arn:aws:s3:::kyoanibuck3t/*",
    ]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.task_role.arn]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::kyoanibuck3t/*",
    ]
  }
}

resource "aws_ecs_task_definition" "MyAnimeList_task_definition" {
  task_role_arn               = aws_iam_role.task_role.arn
  execution_role_arn          = aws_iam_role.task_execution_role.arn
  family                      = "BSoup"
  network_mode                = "awsvpc"
  requires_compatibilities    = ["FARGATE"]
  cpu                         = 256
  memory                      = 512
  

container_definitions = <<DEFINITION
  [
    {
      "image": var.image,
      "name": "b_soup",
      "networkMode": "awsvpc", 
      "portMappings": [
        {
          "containerPort": 80
        }
      ],   
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "us-east-1",
          "awslogs-group": "bsoup",
          "awslogs-stream-prefix": "bsoup"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "app_service" {
 name                               = "AnimeList_task_definition"
 cluster                            = aws_ecs_cluster.webscraper.arn
 task_definition                    = aws_ecs_task_definition.MyAnimeList_task_definition.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA" 

## If using containers in a task with the awsvpc or host network mode, 
# the hostPort can either be left blank or set to the same value as the containerPort
load_balancer {
    target_group_arn = aws_lb_target_group.app_service.arn
    container_name   = "b_soup"
    container_port   = "80"
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
    ]

    subnets = [
      aws_subnet.private_ecs_subnet.id,
      aws_subnet.private_data_subnet.id,
    ]
  }
} 

##########Application Load Balancers########## 

resource "aws_lb_target_group" "app_service" {
  name        = "app-service"
  port        =  80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.app_vpc.id

  health_check {
    enabled = true
    path    = "/ecs/health_check"
  }
}

resource "aws_alb" "app_service_alb" {
  name               = "app-service-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_sub_1.id,
    aws_subnet.public_sub_2.id,
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.egress_all.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "app_service_http" {
  load_balancer_arn = aws_alb.app_service_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_service.arn
  } 
}
