resource "aws_security_group" "ecs_sg" {
    vpc_id = aws_vpc.big_project_vpc.id 
    description = "Security Group for ECS"

#The application needs access to web pages, so it needs external access
    
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

