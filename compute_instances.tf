//resource "google_compute_address" "static" {
//  count = var.count_vms
//  name  = "${var.environment}-${format("${var.machinetag}-%03d", count.index + 1)}"
//}


resource "google_compute_disk" "default" {
  count = var.count_vms
  name  = "${var.environment}-disk-${count.index + 1}"
  type  = "pd-ssd"
  zone  = var.zone
  size  = var.disk_default_size
}
resource "google_compute_instance" "web" {
  count        = var.count_vms
  name         = "${var.environment}-${format("${var.machinetag}-%03d", count.index + 1)}"
  machine_type = var.default_machine_type
  zone         = var.zone

  tags = [
  var.machinetag]

  boot_disk {
    initialize_params {
      image = var.distro == "centos" ? "centos-cloud/centos-8" : "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }


  attached_disk {
    source = element(google_compute_disk.default.*.name, count.index)
  }

  network_interface {
    network = google_compute_network.web.name

    access_config {
      // Ephemeral IP
      // nat_ip = google_compute_address.static[count.index].address
    }
  }


  //GPU SWITCH

  //scheduling {
  //  on_host_maintenance = "TERMINATE"
  //}

  //guest_accelerator {
  //  type  = "nvidia-tesla-v100"
  //  count = 1
  //}
  metadata = {
    role = "web"
  }

  metadata_startup_script = var.distro == "ubuntu" ? "apt-get update -y && curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - && apt-get install -y nodejs && wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.15.6.linux-amd64.tar.gz && path_env='PATH=/usr/local/go/bin:$PATH' && echo $path_env | sudo tee -a /home/${var.default_user_name}/.profile > /dev/null && apt-get upgrade -y && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && apt-key fingerprint 0EBFCD88 && apt-get update -y && add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" && apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io policycoreutils unzip && gpasswd -a ${var.default_user_name} docker && systemctl enable docker && curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && cp /tmp/docker-machine /usr/local/bin/docker-machine && export PATH=$PATH:/usr/local/bin/ && systemctl restart docker && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl && mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb && mkdir -p /data && mount -o discard,defaults /dev/sdb /data && chmod a+w /data && cp /etc/fstab /etc/fstab.backup && echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data ext4 discard,defaults,nofail 0 2 |sudo tee -a /etc/fstab && systemctl stop docker && tar -zcC /var/lib docker > /data/var_lib_docker-backup-$(date +%s).tar.gz && mv /var/lib/docker /data/ && ln -s /data/docker/ /var/lib/ && systemctl start docker && curl -LO --retry 3 https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip && unzip terraform_0.14.3_linux_amd64.zip && chmod +x ./terraform && mv terraform /usr/local/bin/" : "dnf update -y && dnf install -y dnf-utils device-mapper-persistent-data lvm2 wget unzip git && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo  && dnf -y install docker-ce && systemctl stop firewalld && systemctl disable firewalld && gpasswd -a ${var.default_user_name} docker && systemctl start docker && systemctl enable docker && curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && cp /tmp/docker-machine /usr/local/bin/docker-machine && export PATH=$PATH:/usr/local/bin/ && systemctl restart docker && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl && setsebool -P httpd_can_network_connect 1 && mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb && mkdir -p /data && mount -o discard,defaults /dev/sdb /data && chmod a+w /data && cp /etc/fstab /etc/fstab.backup && echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data ext4 discard,defaults,nofail 0 2 |sudo tee -a /etc/fstab && systemctl stop docker && tar -zcC /var/lib docker > /data/var_lib_docker-backup-$(date +%s).tar.gz && mv /var/lib/docker /data/ && ln -s /data/docker/ /var/lib/ && systemctl start docker && curl -LO --retry 3 https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip && unzip terraform_0.14.3_linux_amd64.zip && chmod +x ./terraform && mv terraform /usr/local/bin/ && dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && dnf install -y dnf-plugins-core && export R_VERSION=3.6.3 && cd /data && curl -O https://cdn.rstudio.com/r/centos-8/pkgs/R-$R_VERSION-1-1.x86_64.rpm &&  dnf install -y R-$R_VERSION-1-1.x86_64.rpm && ln -s /opt/R/$R_VERSION/bin/R /usr/local/bin/R && ln -s /opt/R/$R_VERSION/bin/Rscript /usr/local/bin/Rscript && dnf install -y python3 && dnf install -y python3-paramiko && alternatives --set python /usr/bin/python3 && dnf makecache -y && dnf install -y gcc python3-devel && dnf install -y python3-pip && su -l ${var.default_user_name} -c 'pip3 install --user ipyparallel && pip3 install --user jupyter && ipcluster nbextension --user enable && jupyter nbextension install --user --py ipyparallel && jupyter nbextension enable ipyparallel --user --py && jupyter serverextension enable --user --py ipyparallel'"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "cloud-platform"]
  }
}

output "public_ip" {
  value = "add your ssh key to ~/.ssh/authorized_keys of the ${var.default_user_name} user post connecting to vm  and public ip connection would be enabled via ssh -i privatekey ${var.default_user_name}@ip"
}

output "vms" {
  value = google_compute_instance.web.*.name
}

output "startup_script_check" {
  value = "sudo tail -100f /var/log/messages (for CentOS / RHEL) OR sudo tail -100f /var/log/syslog (for Ubuntu)"
}

output "ephemeralips" {
  value = concat(google_compute_instance.web.*.network_interface.0.access_config.0.nat_ip, list(var.count_vms))
}
