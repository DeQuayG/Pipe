resource "aws_lb" "ecs-lb" {
  name               = "test-ecs-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [elb_pub_subnet, aws_subnet.elb_pub_subnet.id]
  tags = {
    Name = "ecs_lb"
  }
  security_groups = [ecs_sg.id]
}


resource "aws_lb_target_group" "lb_target_group" {
  name        = "webscrape-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.big_project_vpc.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
  resource "aws_vpc" "ecs_target_group" {
    cidr_block = "172.18.1.0/26"
  }
}

resource "aws_lb_listener" "bg_lb_listener" {
  load_balancer_arn = aws_lb.lb_target_group.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}