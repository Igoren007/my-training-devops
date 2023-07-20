resource "aws_internet_gateway" "my_test_infrastructure_gw" {
  vpc_id = aws_vpc.my_test_infrastructure.id

  tags = {
    Name = "my_test_infrastructure_gw"
  }
}