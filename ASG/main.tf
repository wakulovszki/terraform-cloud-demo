module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "example-asg"

  min_size                  = 3
  max_size                  = 99
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.public_subnets

  # Launch template
  launch_template_name        = "example-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = "data.aws_ami.ubuntu.id"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

}


resource "aws_security_group" "lb-firewall" {
  name        = "lb-firewall"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_elb" "bar" {
  name = "foobar-terraform-elbs"
  availability_zones = data.terraform_remote_state.vpc.outputs.azs
  security_groups = [
    aws_security_group.lb-firewall.id
  ]


listener {
instance_port = 80
instance_protocol = "http"
lb_port = 80
lb_protocol = "http"
}


health_check {
healthy_threshold = 2
unhealthy_threshold = 2
timeout = 3
target = "TCP:80"
interval = 30
}

cross_zone_load_balancing = true
idle_timeout = 400
connection_draining = true
connection_draining_timeout = 400



}