# Network Load Balancer (Internal)
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-nlb"
  }
}

# Target Group for NodePort
resource "aws_lb_target_group" "eks_nodes" {
  name     = "${var.project_name}-tg"
  port     = 30080
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = 30080
  }
}

# Listener
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_nodes.arn
  }
}

# Attach EKS Node Group ASG to Target Group
# We need to look up the ASG created by the EKS Node Group
locals {
  asg_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_attachment" "eks_nodes" {
  autoscaling_group_name = local.asg_name
  lb_target_group_arn    = aws_lb_target_group.eks_nodes.arn
}

# API Gateway VPC Link
resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.project_name}-vpc-link"
  security_group_ids = []
  subnet_ids         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

# Integration
resource "aws_apigatewayv2_integration" "main" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.nlb_listener.arn
  
  integration_method = "ANY"
  connection_type    = "VPC_LINK" 
  connection_id      = aws_apigatewayv2_vpc_link.main.id
}

# Route
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.main.api_endpoint
}
