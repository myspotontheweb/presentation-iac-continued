
resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-20233"

  tags = {
    Name        = "My bucket"
  }
}