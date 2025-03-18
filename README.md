### Create cluster RabbitMQ

This is a simple example repository for creating a rabbitmq cluster with three nodes.


To start the configuration, you need to have the aws credentials already set.


In the Terraform directory, run
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

In the ansible directory:
```bash
$ ansible-playbook -i aws_ec2.yml generate_inventory.yml [Optional]
$ ansible-playbook main.yml
```
