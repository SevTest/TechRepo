 # deploy resource group #
 resource "azurerm_resource_group" "postgresql-rg" {
  name     = "servian-postgresql-rg"
  location = "Australia East"
}

resource "azurerm_postgresql_server" "postgresql-server" {
  name = "servian-postgresql-server"
  location = azurerm_resource_group.postgresql-rg.location
  resource_group_name = azurerm_resource_group.postgresql-rg.name
 
  administrator_login          = var.postgresql-admin-login
  administrator_login_password = var.postgresql-admin-password
 
  sku_name = var.postgresql-sku-name
  version  = var.postgresql-version
 
  storage_mb        = var.postgresql-storage
  auto_grow_enabled = true
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_postgresql_database" "postgresql-db" {
  name                = "app"
  resource_group_name = azurerm_resource_group.postgresql-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "utf8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "postgresql-fw-rule" {
  name                = "PostgreSQL Office Access"
  resource_group_name = azurerm_resource_group.postgresql-rg.name
  server_name         = azurerm_mysql_server.postgresql-server.name
  start_ip_address    = "210.170.94.100"
  end_ip_address      = "210.170.94.120"
}

# Use the Azure Resource Manager Provider
provider "azurerm" {
  version = "~> 1.15"
}

# Create a new Resource Group
resource "azurerm_resource_group" "group" {
  name     = "servianTest-webapp-containers-demo"
  location = "australiaeast"
}

# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${azurerm_resource_group.group.name}-plan"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"

  # Define Linux as Host OS
  kind = "Linux"

  # Choose size
  sku {
    tier = "Standard"
    size = "S1"
  }

  properties {
    reserved = true # Mandatory for Linux plans
  }
}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "dockerapp" {
  name                = "${azurerm_resource_group.group.name}-dockerapp"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"

  # Do not attach Storage by default
  app_settings {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    /*
    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = ""
    DOCKER_REGISTRY_SERVER_USERNAME = ""
    DOCKER_REGISTRY_SERVER_PASSWORD = ""
    */
  }

  # Configure Docker Image to load on start
  site_config {
    linux_fx_version = "DOCKER|servian/techchallengeapp:latest"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}

