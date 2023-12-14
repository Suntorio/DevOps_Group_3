resource "aws_instance" "nodejs-app-01" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  #"ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "c6a.large" #"t2.micro" # Do not forget to turn off the instance after the test is complete (around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "Node_JS_app_L38_01"
  }
}

resource "aws_instance" "nodejs-app-02" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  #"ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "c6a.large" #"t2.micro" # Do not forget to turn off the instance after the test is complete (around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "Node_JS_app_L38_02"
  }
}

resource "aws_instance" "nodejs-app-03" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  #"ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "c6a.large" #"t2.micro" # Do not forget to turn off the instance after the test is complete (around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "Node_JS_app_L38_03"
  }
}