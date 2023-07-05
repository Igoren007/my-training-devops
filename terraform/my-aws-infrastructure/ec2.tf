resource "aws_instance" "gitlab-srv" {
    instance_type = "t2.micro"
    ami = "ami-0c65adc9a5c1b5d7c"
    vpc_security_group_ids = ["sg-0c470427bf1e2955b"]
    key_name = aws_key_pair.my_key.key_name
    tags = {
        "Name" = "Gitlab-server"
    }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file("/home/igor/.ssh/id_ed25519.pub")
}