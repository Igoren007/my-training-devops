resource "aws_route_table" "my_test_infrastructure_route_table" {
  vpc_id = aws_vpc.my_test_infrastructure.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_test_infrastructure_gw.id
  }

  tags = {
    Name = "my_test_infrastructure_route"
  }
}