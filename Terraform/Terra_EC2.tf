
resource "aws_instance" "ec2-instance" {
  ami               = "ami-0d7a109bf30624c99" # Image ami be changed in the future. May need to be replaced from AWS website
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key" # Grab a pem key-pair from AWS website and save it within ./Terraform

  tags = {
    Name = "my_ec2"
  }
}

output "ec2_ip_address" {
  # value = ["${aws_instance.ec2-instance.*.public_ip}"]
  value = aws_instance.ec2-instance.*.public_ip
}