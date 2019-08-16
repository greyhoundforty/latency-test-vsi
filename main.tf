resource "ibm_compute_ssh_key" "test_ssh_key" {
    label = "test_ssh_key_name"
    notes = "test_ssh_key_notes"
    public_key = "ssh-rsa <rsa_public_key>"
}

resource "ibm_compute_vm_instance" "first_node" {
  hostname             = "${var.datacenter["us-east1"]}-node"
  domain               = "${var.domain}"
  os_reference_code    = "${var.os_reference_code["u18"]}"
  datacenter           = "${var.datacenter["us-east1"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  local_disk           = false
  user_metadata        = "${file("install.yml")}"
  flavor_key_name      = "${var.flavor_key_name["bsan-medium"]}"
  tags                 = ["${var.datacenter["us-east1"]}"]
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.test_ssh_key.id}"]
}

resource "ibm_compute_vm_instance" "second_node" {
  hostname             = "${var.datacenter["us-east2"]}-node"
  domain               = "${var.domain}"
  os_reference_code    = "${var.os_reference_code["u18"]}"
  datacenter           = "${var.datacenter["us-east2"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  local_disk           = false
  user_metadata        = "${file("install.yml")}"
  flavor_key_name      = "${var.flavor_key_name["bsan-medium"]}"
  tags                 = ["${var.datacenter["us-east2"]}"]
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.test_ssh_key.id}"]
}

resource "local_file" "inventory_file" {
  content = <<EOF
[servers]
wdc04 ansible_host=${ibm_compute_vm_instance.first_node.ipv4_address} ansible_ssh_user=deployer
wdc06 ansible_host=${ibm_compute_vm_instance.second_node.ipv4_address} ansible_ssh_user=deployer

EOF

  filename = "${path.module}/inventory.env"
}

output "private_ips" {
  value = "First Node = ${ibm_compute_vm_instance.first_node.ipv4_address_private}, Second Node = ${ibm_compute_vm_instance.second_node.ipv4_address_private}"
}
