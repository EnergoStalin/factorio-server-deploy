locals {
  availability_zone = "msk-1"
}

data "twc_presets" "this" {
  cpu = 2
  ram = 1024 * 2
  cpu_frequency = "5.5"
  preset_type = "high_cpu"

  price_filter {
    from = 2000
    to = 2400
  }
}

resource "twc_ssh_key" "factorio-shared" {
  name = "factorio-shared"
  body = file(var.ssh_key)
}

data "twc_os" "ubuntu" {
  name = "ubuntu"
  version = "22.04"
}

data "twc_software" "docker" {
  name = "Docker"

  os {
    name = "ubuntu"
    version = "22.04"
  }
}

resource "twc_floating_ip" "this" {
  availability_zone = local.availability_zone
  ddos_guard = false
}

resource "twc_server" "this" {
  name = "Factorio Heaven"
  os_id = data.twc_os.ubuntu.id
  software_id = data.twc_software.docker.id
  preset_id = data.twc_presets.this.id

  is_root_password_required = false
  ssh_keys_ids = [resource.twc_ssh_key.factorio-shared.id]

  availability_zone = local.availability_zone
  floating_ip_id = twc_floating_ip.this.id

  cloud_init = templatefile("${path.module}/cloud_init.yaml", {
    AWS_ACCESS_KEY_ID = var.aws_access_key_id
    AWS_SECRET_KEY_ID = var.aws_secret_key_id
    AWS_ENDPOINT = var.aws_endpoint
    FACTORIO_VERSION = var.factorio_version
    BUCKET_NAME = var.bucket_name
  })
}

output "ip" {
  value = resource.twc_floating_ip.this.ip
}
