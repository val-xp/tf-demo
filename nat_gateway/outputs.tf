output "nat_gateway_id" {
  value = azurerm_nat_gateway.nat.id
}

output "pip_id" {
  value = azurerm_public_ip.pip.id
}

output "pip_address" {
  value = azurerm_public_ip.pip.ip_address
}

output "pip_nat_association_id" {
  value = azurerm_nat_gateway_public_ip_association.nat_pip_assc.id
}