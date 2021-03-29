
provider "azurerm" {
  #version = "~>2.0"
  features {}
}

resource random_id random_id_string {
  byte_length = 4
}

data http myip {
  url = "http://ipv4.icanhazip.com"
}

# Create a resource group if it doesn't exist
resource azurerm_resource_group resource_group {
  name     = "${var.prefix}-${lower(random_id.random_id_string.hex)}"
  location = var.location

  tags = var.tags
}

# Create virtual network
resource azurerm_virtual_network virtual_network {
  name                = "${var.prefix}-${lower(random_id.random_id_string.hex)}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  tags = var.tags
}

# Create subnet
resource azurerm_subnet subnet {
  name                 = "${var.prefix}-${lower(random_id.random_id_string.hex)}-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource azurerm_public_ip publicip {
  name                = "${var.prefix}-${lower(random_id.random_id_string.hex)}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.prefix}-${lower(random_id.random_id_string.hex)}"

  tags = var.tags
}

output nginx_public_ip { value = "ssh://${azurerm_public_ip.publicip.ip_address}" }
output secure_oscap_results { value = "https://${azurerm_public_ip.publicip.fqdn}" }
output secure_inspec_results { value = "https://${azurerm_public_ip.publicip.fqdn}/inspec.json" }

# Create Network Security Group and rule
resource azurerm_network_security_group network_security_group {
  name                = "${var.prefix}-${lower(random_id.random_id_string.hex)}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = chomp(data.http.myip.body)
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

# Create network interface
resource azurerm_network_interface vm_nic {
  name                = "${var.prefix}-${lower(random_id.random_id_string.hex)}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "IPConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }

  tags = var.tags
}

# Connect the security group to the network interface
resource azurerm_network_interface_security_group_association nsg_map {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}


# Create storage account for boot diagnostics
resource azurerm_storage_account storage_account {
  name                     = "diag${random_id.random_id_string.hex}"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

data template_file ssh_pub {
  template = file(var.adminPubKey)
}

data template_file init {
  template = file("cloud-init.yaml")

  vars = {
    oscapProfile    = var.oscap_profile
    lsb_release     = var.lsb_release
    owner           = var.tags["owner"]
    fqdn            = azurerm_public_ip.publicip.fqdn
    nginx_repo_cert = file("nginx-repo.crt")
    nginx_repo_key  = file("nginx-repo.key")
  }
}

data template_file script {
  template = file("init.sh")

  vars = {
    nginx_repo_cert = file("nginx-repo.crt")
    nginx_repo_key  = file("nginx-repo.key")
  }
}

# cloud-init status
# /var/log/cloud-init-output.log
# sudo cloud-init clean
# sudo cloud-init init
data template_cloudinit_config cloud_init {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "cloud-init.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.init.rendered
  }
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.script.rendered
  }

}

# Create virtual machine
resource azurerm_linux_virtual_machine nginx_vm_01 {
  name                  = "nginxvm01"
  location              = var.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.instanceType["host"]

  os_disk {
    name                 = "nginxOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  plan {
    name      = "pro-fips-18_04"
    product   = "0001-com-ubuntu-pro-bionic-fips"
    publisher = "canonical"

  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-pro-bionic-fips"
    sku       = "pro-fips-18_04"
    version   = "latest"
  }

  custom_data = data.template_cloudinit_config.cloud_init.rendered

  computer_name                   = "nginx01"
  admin_username                  = var.adminUserName
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.adminUserName
    public_key = data.template_file.ssh_pub.rendered
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
  }

  tags = var.tags
}
resource local_file onboard_init {
  content  = data.template_file.init.rendered
  filename = "${path.module}/outputs/cloud-rendered.yaml"
}
resource local_file onboard_script {
  content  = data.template_file.script.rendered
  filename = "${path.module}/outputs/script.sh"
}