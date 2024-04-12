resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Customer"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "accountNumber"
  attribute {
    name = "name"
    type = "S"
  }
  attribute {
    name = "email"
    type = "S"
  }
  attribute {
    name = "accountNumber"
    type = "N"
  }
}



