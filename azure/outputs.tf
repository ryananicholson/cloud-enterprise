data "external" "ad_ip" {
  program = ["${path.module}/scripts/get-ad-ip.sh"]
  depends_on = [azurerm_windows_virtual_machine.ad, azurerm_public_ip.ad_pip]
}

output "ad_ip" {
  value = data.external.ad_ip.result.ip
}
