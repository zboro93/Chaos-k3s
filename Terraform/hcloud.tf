# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Use existing ssh_key
data "hcloud_ssh_key" "chaos_ssh_key" {
  name = "chaos-k3s"
}


#Create primary IP
resource "hcloud_primary_ip" "primary_ip_1" {
  name          = "primary_ip_1"
  location      = "nbg1"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

# Create a server
resource "hcloud_server" "k3s-master-node" {
  name        = "k3s-master-node"
  image       = "ubuntu-24.04"
  server_type = "cpx22"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.chaos_ssh_key.id]
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.primary_ip_1.id
    ipv6_enabled = false
  }
}

output "k3s-master-node-ip" {
  value = hcloud_server.k3s-master-node.ipv4_address
}
