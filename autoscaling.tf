# Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


# Subnet
resource "aws_subnet" "asg_subnet" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-asg-subnet"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "terraform-asg-igw"
  }
}


# Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "terraform-asg-route-table"
  }
}


# Route Table Association
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.asg_subnet.id
  route_table_id = aws_route_table.example.id
}


# Security Group
resource "aws_security_group" "asg" {
  name   = "terraform-asg-sg"
  vpc_id = aws_vpc.example.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-asg-sg"
  }
}


# Launch Template
resource "aws_launch_template" "example" {
  name_prefix   = "terraform-asg-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.asg.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform-asg-instance"
    }
  }
}


# Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name = "terraform-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 1

  vpc_zone_identifier = [
    aws_subnet.asg_subnet.id
  ]

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-asg-instance"
    propagate_at_launch = true
  }
}