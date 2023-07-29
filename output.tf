output "web_jenkins_instance_ip" {
    value = aws_instance.web_jenkins.public_ip
}

output "web_Wildfly_instance_ip" {
    value = aws_instance.web_Wildfly.public_ip
}