resource "aws_s3_bucket" "test-state-tf" {
  bucket = "test-bucket-state-tf"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "bucket-example"
  }
}