output "instance_id" {
  value = aws_instance.pub_inst.id

}

output "instance_id2" {
  value = aws_instance.pri_inst.id

}

output "private_ip" {
  value = aws_instance.pri_inst.private_ip
}

output "web_ip" {
  value = aws_instance.pub_inst.public_ip
}

output "instance_name" {
  value = aws_instance.pri_inst.tags
}

output "instance_name2" {
  value = aws_instance.pub_inst.tags
}