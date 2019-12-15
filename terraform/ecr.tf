resource "aws_ecr_repository" "this" {
  name                 = "suman-ecr"
  image_tag_mutability = "MUTABLE"
}
