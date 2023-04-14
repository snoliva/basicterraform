resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "state-devops-git-tf"
  billing_mode   = "PROVISIONED"
  read_capacity  = "1"
  write_capacity = "1"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-dynamodb" })
  )

}