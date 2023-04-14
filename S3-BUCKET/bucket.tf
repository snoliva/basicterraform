resource "aws_s3_bucket" "state-terraform" {
  bucket = "bucket-state-tf-git"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bucket" })
  )

}