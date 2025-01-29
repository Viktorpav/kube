terraform {
  required_providers {
    proxmox = {
      source  = "Terraform-for-Proxmox/proxmox"
      version = "0.0.1"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = "https://192.168.0.21:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "6abb50c7-af2a-4391-b44f-9e03cb141c4b"
}

provider "proxmox" {
  alias               = "pve2"
  pm_tls_insecure     = true
  pm_api_url          = "https://192.168.0.31:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "040b5f4e-d2cf-415c-8508-5bdc2fe082c5"
}
