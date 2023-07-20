resource "aws_vpc" "my_test_infrastructure" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_test_infrastructure"
  }
}