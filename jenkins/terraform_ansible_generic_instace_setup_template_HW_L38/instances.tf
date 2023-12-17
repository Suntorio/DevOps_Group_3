resource "aws_instance" "k3s-master_node" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  #"ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "t2.micro" # Do not forget to turn off the instance after the test is complete (around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "K3S-Master_Node"
  }
}

resource "aws_instance" "k3s-worker_01" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  #"ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "t2.micro" # Do not forget to turn off the instance after the test is complete (around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "K3S-Worker_01"
  }
}

resource "aws_instance" "k3s-worker_02" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  #"ami-053b0d53c279acc90" # Ubuntu server 22.04
  instance_type          = "t2.micro" # Do not forget to turn off the instance after the test is complete (around $30 monthly)
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "jenkins-ansible"
  tags = {
    Name = "K3S-Worker_02"
  }
}