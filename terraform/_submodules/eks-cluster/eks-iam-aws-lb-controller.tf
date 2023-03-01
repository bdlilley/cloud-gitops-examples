# resource "aws_iam_policy" "secrets-csi" {
#   name        = "${var.cluster.name}-aws-lb"
#   path        = "/"
#   description = "aws lb controller"

#   policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Sid" : "VisualEditor0",
#           "Effect" : "Allow",
#           "Action" : [
#             "secretsmanager:GetResourcePolicy",
#             "secretsmanager:GetSecretValue",
#             "secretsmanager:DescribeSecret",
#             "secretsmanager:ListSecretVersionIds"
#           ],
#           "Resource" : ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:*"]
#         }
#       ]
#   })
# }
