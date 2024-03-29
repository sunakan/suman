#################################################
# suman-qに対してだけsend_messageが可能なポリシー
#################################################
data "aws_iam_policy_document" "send_only" {
  statement {
    actions = [
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
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
# suman-ecrに対して全部許可なポリシー
#################################################
data "aws_iam_policy_document" "suman_ecr_all" {
  statement {
    actions = [
      "ecr:*",
    ]
    resources = [
      aws_ecr_repository.this.arn,
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "suman_ecr_all" {
  name   = "suman-ecr-all"
  policy = data.aws_iam_policy_document.suman_ecr_all.json
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
resource "aws_iam_group_policy_attachment" "attach_suman_ecr_all_to_suman_g" {
  group      = aws_iam_group.suman_grp.name
  policy_arn = aws_iam_policy.suman_ecr_all.arn
}

#################################################
# ユーザを作成、そしてグループに所属
#################################################
resource "aws_iam_user" "suman_usr" {
  name = "suman-usr"
}
resource "aws_iam_user" "gomen_usr" {
  name = "gomen-usr"
}
resource "aws_iam_user_group_membership" "membership" {
  user   = aws_iam_user.suman_usr.name
  groups = [aws_iam_group.suman_grp.name]
}
resource "aws_iam_user_group_membership" "gomen_membership" {
  user   = aws_iam_user.gomen_usr.name
  groups = [aws_iam_group.suman_grp.name]
}

#################################################
# suman-qを指定したユーザ以外には何もされたくない
#################################################
data "aws_iam_policy_document" "restriction" {
  statement {
    effect  = "Deny"
    actions = ["*"]
    not_principals {
      type        = "AWS"
      identifiers = [aws_iam_user.suman_usr.arn]
    }
  }
}
resource "aws_sqs_queue_policy" "restriction" {
  queue_url = module.suman_q.this_sqs_queue_id
  policy    = data.aws_iam_policy_document.restriction.json
}
