# resource "aws_route53_record" "root_record" {
#   zone_id = "Z0547195332AIZ9J83AFC"
#   name    = "lamplight1.me"
#   type    = "A"
#   ttl     = "60"
#   records = [aws_instance.testEc2.public_ip]
# }

# resource "aws_route53_record" "dev_record" {
#   zone_id = "Z0547195332AIZ9J83AFC"
#   name    = "dev.lamplight1.me"
#   type    = "A"
#   ttl     = "60"
#   records = [aws_instance.testEc2.public_ip]
# }

resource "aws_route53_record" "prod_record" {
  zone_id = "Z01916091JTI2BDZS4QGR"
  name    = "prod.lamplight1.me"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.testEc2.public_ip]
}