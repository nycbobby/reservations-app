resource "aws_dynamodb_table" "reservations" {
  name           = "Reservations"
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

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

  global_secondary_index {
    name     = "NightsIndex"
    hash_key = "Nights"
    #range_key          = "TopScore"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
    #non_key_attributes = ["UserId"]
  }

  global_secondary_index {
    name     = "RoomNumberIndex"
    hash_key = "RoomNumber"
    #range_key          = "TopScore"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
    #non_key_attributes = ["UserId"]
  }

  global_secondary_index {
    name     = "CustomerNameIndex"
    hash_key = "CustomerName"
    #range_key          = "TopScore"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
    #non_key_attributes = ["UserId"]
  }

}