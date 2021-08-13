provider "aws" {
region = "us-east-1"
}



resource "aws_instance" "airflow_terraform_test_intance" {
  ami                                   = "ami-0c2b8ca1dad447f8a"
  instance_type                         = "t2.micro"
  subnet_id                             = "subnet-a9386688"
  iam_instance_profile                  = "terraform-jenkins-role"
  tenancy                               = "default"
  key_name                              ="id_rsa.pub"
  vpc_security_group_ids                = ["sg-0749755cfee8834aa"]

  tags = {
    Name = "airflow_terraform_test_intance"
  }

   provisioner "file" {
    source      = "/home/ec2-user/test/test2/airflow/setup.sh"
    destination = "/home/ec2-user/setup.sh"
  }

   

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /home/ec2-user/setup.sh",
      "sh /home/ec2-user/setup.sh"
    ]
  }

provisioner "remote-exec" {
    inline = [
     "docker-compose up airflow-init",
     "docker-compose up"
    ]
  }

connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file("/home/ec2-user/.ssh/id_rsa")
    timeout = "4m"
    
    }

   
  
   
}


resource "aws_key_pair" "deployer" {
  key_name   = "id_rsa.pub"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHrePzu0aN2EIp92HQ3ypFDLaW8dzdId5o5Evf7dSQE9jM2YeuA5jYi63mwNU3A1nm/fhAEa11T9heocjGVCcS9tUxp7JMS/2NxzC4+9dva5Hp0NAaxFmENgh6RnrMBN6TSNcgenZBCrUnq50x6XEu7b+XS10/KaGLtrPkGabH7GH5rkUpExEF+22v89w5bBgzSaw5YsYuJ78tj8c2OrNghvOhQM/qa/EhP7pS8l+0HM8BTwO1UfDXxcf4aB1nanu+T1EnjB9Em5fZaG5rPuC3xgjySNJedG71WITxhkuS9DRLfQwz3W48EkGAe+Iq3mJdYybZwZYbL296hmP/EBHt ec2-user@ip-172-31-82-125.ec2.internal"
}


output "ip" {
  value=aws_instance.airflow_terraform_test_intance.public_ip
}


