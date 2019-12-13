module "suman_q" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 2.0"
  name    = "suman-q"
}
