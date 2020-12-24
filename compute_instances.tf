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
    role = "webnode"
  }

  metadata_startup_script = var.distro == "ubuntu" ? "apt-get update -y && curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - && apt-get install -y nodejs && wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.15.6.linux-amd64.tar.gz && path_env='PATH=/usr/local/go/bin:$PATH' && echo $path_env | tee -a /home/${var.default_user_name}/.profile > /dev/null && apt-get upgrade -y && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && apt-key fingerprint 0EBFCD88 && apt-get update -y && add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" && apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io policycoreutils unzip protobuf-compiler && gpasswd -a ${var.default_user_name} docker && systemctl enable docker && curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && cp /tmp/docker-machine /usr/local/bin/docker-machine && export PATH=$PATH:/usr/local/bin/ && systemctl restart docker && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl && mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb && mkdir -p /data && mount -o discard,defaults /dev/sdb /data && chmod a+w /data && cp /etc/fstab /etc/fstab.backup && echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data ext4 discard,defaults,nofail 0 2 |sudo tee -a /etc/fstab && systemctl stop docker && tar -zcC /var/lib docker > /data/var_lib_docker-backup-$(date +%s).tar.gz && mv /var/lib/docker /data/ && ln -s /data/docker/ /var/lib/ && systemctl start docker && curl -LO --retry 3 https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip && unzip terraform_0.14.3_linux_amd64.zip && chmod +x ./terraform && mv terraform /usr/local/bin/ && go_mod_on='export GO111MODULE=on' && echo $go_mod_on| tee -a /home/${var.default_user_name}/.profile > /dev/null && sudo su -c \"/usr/local/go/bin/go get google.golang.org/protobuf/cmd/protoc-gen-go google.golang.org/grpc/cmd/protoc-gen-go-grpc\" ${var.default_user_name} && go_path_bin='export PATH=$PATH:$(go env GOPATH)/bin' && echo $go_path_bin|tee -a /home/${var.default_user_name}/.profile > /dev/null && apt-get install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && add-apt-repository \"deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/\" && apt-get install -y r-base-core build-essential gcc python3-pip && su -c \"pip3 install --user ipyparallel && pip3 install --user sklearn &&  pip3 install --user xlrd && pip3 install --user numpy && pip3 install --user matplotlib &&  pip3 install --user pandas && pip3 install --user jupyter && /home/${var.default_user_name}/.local/bin/jupyter nbextension install --user --py ipyparallel && /home/${var.default_user_name}/.local/bin/jupyter nbextension enable ipyparallel --user --py && /home/${var.default_user_name}/.local/bin/jupyter serverextension enable --user --py ipyparallel\" ${var.default_user_name} && su -c \"/home/${var.default_user_name}/.local/bin/ipcluster nbextension --user enable\" ${var.default_user_name} && su -c \"cd /data && /home/${var.default_user_name}/.local/bin/jupyter notebook --ip 0.0.0.0> /data/jupyter-notebook-server.log 2>&1 &\" ${var.default_user_name}" : "dnf update -y && dnf install -y dnf-utils device-mapper-persistent-data lvm2 wget unzip git && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo  && dnf -y install docker-ce && systemctl stop firewalld && systemctl disable firewalld && gpasswd -a ${var.default_user_name} docker && systemctl start docker && systemctl enable docker && curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && cp /tmp/docker-machine /usr/local/bin/docker-machine && export PATH=$PATH:/usr/local/bin/ && systemctl restart docker && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl && setsebool -P httpd_can_network_connect 1 && mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb && mkdir -p /data && mount -o discard,defaults /dev/sdb /data && chmod a+w /data && cp /etc/fstab /etc/fstab.backup && echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /data ext4 discard,defaults,nofail 0 2 |sudo tee -a /etc/fstab && systemctl stop docker && tar -zcC /var/lib docker > /data/var_lib_docker-backup-$(date +%s).tar.gz && mv /var/lib/docker /data/ && ln -s /data/docker/ /var/lib/ && systemctl start docker && curl -LO --retry 3 https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip && unzip terraform_0.14.3_linux_amd64.zip && chmod +x ./terraform && mv terraform /usr/local/bin/ && dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && dnf install -y dnf-plugins-core && export R_VERSION=4.0.3 && cd /data && curl -O https://cdn.rstudio.com/r/centos-8/pkgs/R-$R_VERSION-1-1.x86_64.rpm &&  dnf install -y R-$R_VERSION-1-1.x86_64.rpm && ln -s /opt/R/$R_VERSION/bin/R /usr/local/bin/R && ln -s /opt/R/$R_VERSION/bin/Rscript /usr/local/bin/Rscript && dnf install -y python3 && dnf install -y python3-paramiko && alternatives --set python /usr/bin/python3 && dnf makecache -y && dnf install -y gcc python3-devel && dnf install -y python3-pip && su -c \"pip3 install --user ipyparallel && pip3 install --user jupyter && ipcluster nbextension --user enable && jupyter nbextension install --user --py ipyparallel && jupyter nbextension enable ipyparallel --user --py && path_env='PATH=/usr/local/go/bin:$PATH' && echo $path_env | tee -a /home/${var.default_user_name}/.profile > /dev/nulljupyter serverextension enable --user --py ipyparallel\" ${var.default_user_name}"

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
