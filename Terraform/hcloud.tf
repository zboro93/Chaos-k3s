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

# Create a k3s master node server
resource "hcloud_server" "k3s-master-node" {
  name        = "k3s-master-node"
  image       = "ubuntu-24.04"
  server_type = "cpx22"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.chaos_ssh_key.id]
}


# Create the k3s worker nodes
resource "hcloud_server" "k3s-worker-nodes" {
  count       = 2
  name        = "k3s-worker-node${count.index + 1}"
  image       = "ubuntu-24.04"
  server_type = "cpx22"
  location    = "nbg1"
  ssh_keys    = [data.hcloud_ssh_key.chaos_ssh_key.id]
}


output "k3s-master-node-ip" {
  value = hcloud_server.k3s-master-node.ipv4_address
}
