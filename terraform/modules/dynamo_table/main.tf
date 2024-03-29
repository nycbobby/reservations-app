resource "aws_dynamodb_table" "reservations" {
  name           = "${var.customer}-reservations"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ReservationId"

  attribute {
    name = "ReservationId"
    type = "N"
  }

  attribute {
    name = "CustomerName"
    type = "S"
  }

  attribute {
    name = "RoomNumber"
    type = "N"
  }

  attribute {
    name = "Nights"
    type = "N"
  }

  global_secondary_index {
    name            = "NightsIndex"
    hash_key        = "Nights"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "RoomNumberIndex"
    hash_key        = "RoomNumber"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "CustomerNameIndex"
    hash_key        = "CustomerName"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }

}