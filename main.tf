
locals {
  prefix = "jeffery-coaching17"
  YOUR-TASKDEFINITION-NAME = "jeffery-coaching17-task" #task definition and service name -> Change
  YOUR-CONTAINER-NAME = "jeffery-coaching17-container" #container name
}

resource "aws_security_group" "allow_ssh" {
  name        = "${local.prefix}-security-group" 
  description = "Allow SSH inbound"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}