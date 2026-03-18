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

# Create private network for servers
resource "hcloud_network" "k3s-priv-network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

# Create subnet
resource "hcloud_network_subnet" "k3s-priv-subnet" {
  network_id   = hcloud_network.k3s-priv-network.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Add servers to subnet
resource "hcloud_server_network" "k3s-master-network" {
  server_id = hcloud_server.k3s-master-node.id
  subnet_id = hcloud_network_subnet.k3s-priv-subnet.id
  ip        = "10.0.1.1"
}

resource "hcloud_server_network" "k3s-worker-network" {
  count     = 2
  server_id = hcloud_server.k3s-worker-nodes[count.index].id
  subnet_id = hcloud_network_subnet.k3s-priv-subnet.id
  ip        = "10.0.1.${count.index + 2}"
}


#Output master IP
output "k3s-master-node-ip" {
  value = hcloud_server.k3s-master-node.ipv4_address
}
