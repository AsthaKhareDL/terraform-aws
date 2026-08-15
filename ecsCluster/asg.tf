# ============================================================
# Latest Ubuntu 24.04 AMI
# ============================================================

data "aws_ami" "ubuntu_asg_new" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


# ============================================================
# Subnet
# ============================================================

resource "aws_subnet" "asg_subnet_new" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-asg-subnet-new"
  }
}


# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "asg_igw_new" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "terraform-asg-igw-new"
  }
}


# ============================================================
# Route Table
# ============================================================

resource "aws_route_table" "asg_route_table_new" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asg_igw_new.id
  }

  tags = {
    Name = "terraform-asg-route-table-new"
  }
}


# ============================================================
# Route Table Association
# ============================================================

resource "aws_route_table_association" "asg_route_assoc_new" {
  subnet_id      = aws_subnet.asg_subnet_new.id
  route_table_id = aws_route_table.asg_route_table_new.id
}

# Security Group


resource "aws_security_group" "asg_security_group_new" {
  name        = "terraform-asg-sg-new"
  description = "Security group for new Terraform ASG"
  vpc_id      = aws_vpc.example.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP - required for NGINX
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-asg-sg-new"
  }
}


# ============================================================
# Launch Template
# ============================================================

resource "aws_launch_template" "asg_launch_template_new" {
  name_prefix   = "terraform-asg-launch-new-"
  image_id      = data.aws_ami.ubuntu_asg_new.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.asg_security_group_new.id
  ]

  # NGINX installation
  user_data = base64encode(<<-EOF
    #!/bin/bash

    apt-get update -y
    apt-get install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Terraform ASG</title>
    </head>
    <body>
        <h1>NGINX is running successfully!</h1>
        <p>Created using Terraform Auto Scaling Group.</p>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform-asg-instance-new"
    }
  }
}


# ============================================================
# Auto Scaling Group
# ============================================================

resource "aws_autoscaling_group" "asg_new" {
  name = "terraform-asg-new"

  min_size         = 1
  desired_capacity = 1
  max_size         = 1

  vpc_zone_identifier = [
    aws_subnet.asg_subnet_new.id
  ]

  launch_template {
    id      = aws_launch_template.asg_launch_template_new.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-asg-instance-new"
    propagate_at_launch = true
  }
}