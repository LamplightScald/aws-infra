# create IAM policy
resource "aws_iam_policy_attachment" "cloudWatch" {
  name       = "CloudWatchAgentServerPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  roles      = [aws_iam_role.EC2-CSYE6225.name]
}