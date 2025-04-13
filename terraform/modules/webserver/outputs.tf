# output "ec2"{
#     value = aws_instance.webserver
# }

output "ec2" {
  value = aws_instance.web.public_ip
}
