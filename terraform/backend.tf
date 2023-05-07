terraform {
  cloud {
    organization = "tpabb"

    workspaces {
      name = "reservations-demo"
    }
  }
}