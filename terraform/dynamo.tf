module "customer_table" {
  source = "./modules/dynamo_table"
  for_each = toset(var.customers)
  customer = each.key
}
