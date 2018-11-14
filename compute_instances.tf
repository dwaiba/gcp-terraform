resource "google_compute_disk" "default" {
  count = "${var.count_vms}"
  name  = "${var.environment}-disk-${count.index + 1}"
  type  = "pd-ssd"
  zone  = "${var.zone}"
  size  = "${var.disk_default_size}"
}

resource "google_compute_instance" "web" {
  count        = "${var.count_vms}"
  name         = "${var.environment}-${format("web-%03d", count.index + 1)}"
  machine_type = "${var.default_machine_type}"
  zone         = "${var.zone}"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  /**
      attached_disk {
        source = "${google_compute_disk.default.self_link}"
      }
    **/
  attached_disk {
    source = "${element(google_compute_disk.default.*.name, count.index)}"
  }

  network_interface {
    network = "${google_compute_network.web.name}"

    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
  }

  guest_accelerator {
    type  = "nvidia-tesla-v100"
    count = 1
  }

  metadata {
    role = "web"
  }

  metadata_startup_script = "yum update -y && yum install -y yum-utils device-mapper-persistent-data lvm2 wget ansible unzip git && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && yum makecache fast && yum -y install docker-ce && systemctl stop firewalld && systemctl disable firewalld && gpasswd -a ${var.default_user_name} docker && systemctl start docker && systemctl enable docker && curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && curl -L https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && cp /tmp/docker-machine /usr/local/bin/docker-machine && export PATH=$PATH:/usr/local/bin/ && systemctl restart docker && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl && setsebool -P httpd_can_network_connect 1 && mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb && mkdir -p /data && mount -o discard,defaults /dev/sdb /data && chmod a+w /data && cp /etc/fstab /etc/fstab.backup && echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data ext4 discard,defaults,nofail 0 2 |sudo tee -a /etc/fstab && systemctl stop docker && tar -zcC /var/lib docker > /data/var_lib_docker-backup-$(date +%s).tar.gz && mv /var/lib/docker /data/ && ln -s /data/docker/ /var/lib/ && systemctl start docker && su -c 'export CLOUDSDK_INSTALL_DIR=/data && export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash' ${var.default_user_name} && echo 'source /data/google-cloud-sdk/path.bash.inc' >> /etc/profile.d/gcloud.sh && echo 'source /data/google-cloud-sdk/completion.bash.inc' >> /etc/profile.d/gcloud.sh && curl -LO --retry 3 https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip && unzip terraform_0.11.10_linux_amd64.zip && chmod +x ./terraform && mv terraform /usr/local/bin/ && wget https://copr.fedorainfracloud.org/coprs/g/ansible-service-broker/ansible-service-broker-latest/repo/epel-7/group_ansible-service-broker-ansible-service-broker-latest-epel-7.repo -O /etc/yum.repos.d/ansible-service-broker.repo && yum -y install apb"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

output "public_ip" {
  value = "add your ssh key to ~/.ssh/authorized_keys of the ${var.default_user_name} user post connecting to vm ${google_compute_instance.web.0.name}  and public ip connection would be enabled via ssh -i privatekey ${var.default_user_name}@${google_compute_instance.web.0.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "connect_vm" {
  value = "gcloud compute ssh ${google_compute_instance.web.0.name} --zone ${var.zone}"
}

output "startup_script_check" {
  value = "sudo tail -100f /var/log/messages"
}
