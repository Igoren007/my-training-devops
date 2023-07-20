resource "aws_subnet" "subnet_1_public" {
  vpc_id     = aws_vpc.my_test_infrastructure.id
  cidr_block = "10.0.1.0/24"
  availability_zone_id = "usw2-az1"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_1_public"
  }
}

resource "aws_subnet" "subnet_2_private" {
  vpc_id     = aws_vpc.my_test_infrastructure.id
  cidr_block = "10.0.2.0/24"
  availability_zone_id = "usw2-az2"
  tags = {
    Name = "subnet_2_private"
  }
}