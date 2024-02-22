resource "aws_launch_template" "k3s_worker" {
  name_prefix   = "k3s-worker-"
  image_id      = "ami-0fc5d935ebf8bc3bc" # Update with the correct AMI ID
  instance_type = "t2.small"              # Update as necessary
  key_name      = "jenkins-ansible"

  vpc_security_group_ids = [data.aws_security_group.k3s_sg.id] 
  # user_data = base64encode(<<EOF
  # #!/bin/bash
  # # Install K3s worker and join the cluster with the predefined token
  # curl -sfL https://get.k3s.io | K3S_URL=https://10.0.1.49:6443 K3S_TOKEN=u2Qw5PbXC887MMv85LeG sh -s - agent
  # EOF
  # )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "K3s_Worker"
    }
  }
}