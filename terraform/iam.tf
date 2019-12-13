#################################################
# suman-qに対してだけsend_messageが可能なポリシー
#################################################
data "aws_iam_policy_document" "send_only" {
  statement {
    actions = [
      "sqs:GetQueueUrl",
      "sqs:SendMessage"
    ]
    resources = [
      module.suman_q.this_sqs_queue_arn
    ]
  }
}
resource "aws_iam_policy" "send_only" {
  name   = "suman-q-send-only"
  policy = data.aws_iam_policy_document.send_only.json
}

#################################################
# グループに対してポリシーをアタッチ！
#################################################
resource "aws_iam_group" "suman_grp" {
  name = "suman-grp"
}
resource "aws_iam_group_policy_attachment" "attach_to_suman_g" {
  group      = aws_iam_group.suman_grp.name
  policy_arn = aws_iam_policy.send_only.arn
}

#################################################
# ユーザを作成、そしてグループに所属
#################################################
resource "aws_iam_user" "suman_usr" {
  name = "suman-usr"
}
resource "aws_iam_user_group_membership" "membership" {
  user = aws_iam_user.suman_usr.name
  groups = [aws_iam_group.suman_grp.name]
}
