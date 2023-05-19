terraform {
    required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "=3.0.0" 
        }
    }
}

provider "azurerm" {
  features {}   
}

locals {
  location = "centralindia"
  resource_group_name = "nginx-rg"
}
//vm
//network security group
//nic
//public ip
//subnet

output "public_ip" {
  value = azurerm_public_ip.nginx
}
resource "azurerm_virtual_network" "nginx" {
  name = "nginx-vnet"
  address_space = ["10.0.0.0/16"]
  location = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "nginx" {
  name = "nginx-subnet"
  address_prefixes = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.nginx
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_interface" "nginx" {
  name = "nginx-nic"
  location = local.location
  resource_group_name = local.resource_group_name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.nginx
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.nginx
  }
  
}

resource "azurerm_public_ip" "nginx" {
  name = "nginx-pub-ip" 
  resource_group_name = local.resource_group_name
  location = local.location
  allocation_method = "Dynamic"
}

resource "azurerm_network_security_group" "nginx" {
  name                = "nginx-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
  
  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}
# Associate the linux NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "nginx" {
  subnet_id                 = azurerm_subnet.nginx.id
  network_security_group_id = azurerm_network_security_group.nginx.id
}

resource "azurerm_linux_virtual_machine" "nginx" {
  name = "nginx-vm"
  location = local.location
  resource_group_name = local.resource_group_name
  network_interface_ids = azurerm_network_interface.nginx
  admin_username = "vaibhav"
  size = "Standard_B2s"
  admin_ssh_key {
    username= "vaibhav"
    public_key = file("~/.ssh/id_rsa.pub")
  }
   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version = "latest"
  } 
}