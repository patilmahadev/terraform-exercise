
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.10.0.0/16"
  tags {
    Name = "myvpc"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags {
    Name = "myigw"
  }
}

resource "aws_subnet" "mypubsub" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags {
    Name = "mypubsub"
  }
}

resource "aws_subnet" "myprisub" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "${var.region}b"
  tags {
    Name = "myprisub"
  }
}

resource "aws_route_table" "mypubrt" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myigw.id}"
  }
  tags {
    Name = "mypubrt"
  }
}

resource "aws_route_table" "myprirt" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags {
    Name = "myprirt"
  }
}

resource "aws_route_table_association" "mypubrtasso" {
  subnet_id = "${aws_subnet.mypubsub.id}"
  route_table_id = "${aws_route_table.mypubrt.id}"
}

resource "aws_route_table_association" "myprirtasso" {
  subnet_id = "${aws_subnet.myprisub.id}"
  route_table_id = "${aws_route_table.myprirt.id}"
}

resource "aws_security_group" "elbsg" {
  name = "myelbsg"
  vpc_id = "${aws_vpc.myvpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2sg" {
  name = "myec2sg"
  vpc_id = "${aws_vpc.myvpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "myelb" {
  name = "myelb"
  subnets = ["${aws_subnet.mypubsub.id}"]
  security_groups = ["${aws_security_group.elbsg.id}"]
  instances = ["${aws_instance.instance1.id}", "${aws_instance.instance2.id}"]
  connection_draining = true
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
    target = "HTTP:80/index.html"
    interval = 30
  }
}

resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = "${file(var.pub_key_path)}"
}

resource "aws_instance" "instance1" {
  ami = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instancetype}"
  key_name = "${aws_key_pair.mykey.id}"
  vpc_security_group_ids = ["${aws_security_group.ec2sg.id}"]
  subnet_id = "${aws_subnet.mypubsub.id}"
  user_data = "${file("userdata.sh")}"
}

resource "aws_instance" "instance2" {
  ami = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instancetype}"
  key_name = "${aws_key_pair.mykey.id}"
  vpc_security_group_ids = ["${aws_security_group.ec2sg.id}"]
  subnet_id = "${aws_subnet.mypubsub.id}"
  user_data = "${file("userdata.sh")}"
}

