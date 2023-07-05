resource "aws_instance" "jenkins-master" {
    instance_type = "t2.micro"

    tags = {
        "Name" = "Jenkins-master"
    }
}