resource "aws_spot_instance_request" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  spot_price             = var.spot_price
  spot_type              = "one-time"
  wait_for_fulfillment   = true
  user_data              = var.user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
  instance_interruption_behavior = "terminate"
}


resource "aws_ec2_tag" "this" {
  for_each    = merge(var.tags, { Name = var.name })
  resource_id = aws_spot_instance_request.this.spot_instance_id
  key         = each.key
  value       = each.value

  depends_on = [aws_spot_instance_request.this]
}
