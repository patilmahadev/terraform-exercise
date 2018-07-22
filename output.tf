
output "elb_dns" {
  value = "${aws_elb.myelb.dns_name}"
}
