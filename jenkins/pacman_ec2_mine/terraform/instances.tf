resource "aws_instance" "nodejs-app" {
  ami                    = "ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "t3.nano" # Do not forget to turn off the instance after the test is complete ( around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "Pacman_NodeJS_App"
  }
}