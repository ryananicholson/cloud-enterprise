data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_virtual_network" "cent_vnet" {
  name                = "${var.org_name}_net"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name
}

resource "azurerm_subnet" "cent_workstations" {
  name                 = "${var.org_name}_Workstations"
  resource_group_name  = azurerm_resource_group.cent_rg.name
  virtual_network_name = azurerm_virtual_network.cent_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "cent_servers" {
  name                 = "${var.org_name}_Servers"
  resource_group_name  = azurerm_resource_group.cent_rg.name
  virtual_network_name = azurerm_virtual_network.cent_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "cent_wkstn_nsg" {
  name                = "${var.org_name}_wkstn_nsg"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name
  security_rule {              
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${chomp(data.http.myip.body)}/32" 
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WINRM"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "${chomp(data.http.myip.body)}/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "cent_server_nsg" {
  name                = "${var.org_name}_server_nsg"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name
  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WINRM"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "${chomp(data.http.myip.body)}/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WorkstationTraffic"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "wkstn_01_pip" {
  name                = "${var.wkstn1}_pubip"
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "wkstn_02_pip" {
  name                = "${var.wkstn2}_pubip"
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "ad_pip" {
  name                = "${var.ad}_pubip"
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "linux1_pip" {
  name                = "${var.linux1}_pubip"
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "cent_wkstn01_nic" {
  name                = "${var.wkstn1}_nic"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cent_workstations.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.101"
    public_ip_address_id          = azurerm_public_ip.wkstn_01_pip.id
  }
}

resource "azurerm_network_interface" "cent_wkstn02_nic" {
  name                = "${var.wkstn2}_nic"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cent_workstations.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.102"
    public_ip_address_id          = azurerm_public_ip.wkstn_02_pip.id
  }
}

resource "azurerm_network_interface" "cent_ad_nic" {
  name                = "${var.ad}_nic"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cent_servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.5"
    public_ip_address_id          = azurerm_public_ip.ad_pip.id
  }
}

resource "azurerm_network_interface" "cent_linux1_nic" {
  name                = "${var.linux1}_nic"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cent_servers.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.50"
    public_ip_address_id          = azurerm_public_ip.linux1_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "cent_wkstn01_association" {
  network_interface_id      = azurerm_network_interface.cent_wkstn01_nic.id
  network_security_group_id = azurerm_network_security_group.cent_wkstn_nsg.id
}

resource "azurerm_network_interface_security_group_association" "cent_wkstn02_association" {
  network_interface_id      = azurerm_network_interface.cent_wkstn02_nic.id
  network_security_group_id = azurerm_network_security_group.cent_wkstn_nsg.id
}

resource "azurerm_network_interface_security_group_association" "cent_ad_association" {
  network_interface_id      = azurerm_network_interface.cent_ad_nic.id
  network_security_group_id = azurerm_network_security_group.cent_server_nsg.id
}

resource "azurerm_network_interface_security_group_association" "cent_linux1_association" {
  network_interface_id      = azurerm_network_interface.cent_linux1_nic.id
  network_security_group_id = azurerm_network_security_group.cent_server_nsg.id
}
