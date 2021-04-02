resource "google_compute_instance" "ad" {
  name         = var.ad
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["ad"]

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2019-dc-v20210212"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  metadata = {
    windows-startup-script-cmd = "powershell -c \"Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))\""
  }
}

resource "google_compute_instance" "wkstn1" {
  name         = var.wkstn1
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["wkstn1"]
  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2019-dc-v20210212"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
  metadata = {
    windows-startup-script-cmd = "powershell -c \"Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))\""
  }
}

resource "google_compute_instance" "wkstn2" {
  name         = var.wkstn2
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["wkstn2"]
  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2019-dc-v20210212"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  metadata = {
    windows-startup-script-cmd = "powershell -c \"Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))\""
  }
}

resource "null_resource" "invoke_ansible" {
  provisioner "local-exec" {
    command = "scripts/configure-systems.sh"
  }
  depends_on = [google_compute_instance.ad, google_compute_instance.wkstn1, google_compute_instance.wkstn2]
}
