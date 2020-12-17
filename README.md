Table of Contents (Google Cloud with Terraform with disks)
=================

- [Table of Contents (Google Cloud with Terraform with disks)](#table-of-contents-google-cloud-with-terraform-with-disks)
- [Google Cloud with Terraform](#google-cloud-with-terraform)
    - [Via Ansible terraform module](#via-ansible-terraform-module)
    - [Automatic Provisioning](#automatic-provisioning)
    - [Create a HA k8s Cluster as IAAS](#create-a-ha-k8s-cluster-as-iaas)
    - [Reporting bugs](#reporting-bugs)
    - [Patches and pull requests](#patches-and-pull-requests)
    - [License](#license)
    - [Code of Conduct](#code-of-conduct)

   [Create a HA k8s Cluster as IAAS](#create-a-ha-k8s-cluster-as-iaas)
   
5. [Reporting bugs](#reporting-bugs)
6. [Patches and pull requests](#patches-and-pull-requests)
7. [License](#license)
8. [Code of conduct](#code-of-conduct)

# Google Cloud with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. Please create Service Credential of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder.
3. Clone this repository
4. Upload your public ssh key at https://console.cloud.google.com/compute/metadata/sshKeys and use the corresponding `Username` value in the console for `default_user_name` value in `vars.tf`
5. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. Please note the Environment name prompted during plan may be dev/tst or any other stage. 

### Via Ansible terraform module
> Ansible now has a [terraform module](https://docs.ansible.com/ansible/2.7/modules/terraform_module.html) and a playbook yml file is included in this repository with a sample inventory with `localhost`

1. Clone this repository in the ansible box as `cd /data && git clone https://github.com/dwaiba/gcp-terraform && cd gcp-terraform`.

2. Check the `project_dir` variable and change accordingly as required in `gcp-terraform_playbook.yml` file.

3. **Change the variables as required in `gcp-terraform_playbook.yml`.**

4. Kick as `ansible-playbook -i inventory gcp-terraform_playbook.yml`.

 ### Automatic Provisioning

https://github.com/dwaiba/gcp-terraform

Pre-reqs: 
1. gcloud should be installed. Silent install is - 
```export USERNAME="<<you_user_name>>" && export SHARE_DATA=/data && su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USERNAME && echo "export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python" /etc/profile.d/gcloud.sh && echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh && echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh &&```

2. Please create Service Credential of type JSON via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder of the gcp-terraform

3. Default user name is the local username 

Plan:

```terraform init && terraform plan -var count_vms=1 -var default_user_name=Your_User_Name -var disk_default_size=100 -var environment=dev -var region=europe-west4 -var machinetag=dev -var zone=europe-west4-a -var projectname=The_Project_Name -out "run.plan"```

Apply:

```terraform apply "run.plan"```

Destroy:

```terraform destroy -var count_vms=1 -var default_user_name=Your_User_Name -var disk_default_size=100 -var environment=dev -var region=europe-west4 -var machinetag=dev -var zone=europe-west4-a -var projectname=The_Project_Name```


RKernel Jupyter Installation
R
From the R Console
```install.packages('IRkernel', repos="https://cran.rstudio.com")```

```Rscript -e 'IRkernel::installspec()' && nohup jupyter notebook --ip 0.0.0.0 >/dev/null 2>&1'```

```nohup jupyter notebook --ip 0.0.0.0 >nohup.out 2>&1 & ```
### Create a HA k8s Cluster as IAAS

One can create a Fully HA k8s Cluster using **[k3sup](https://k3sup.dev/)**

<pre><code><b>curl -sLSf https://get.k3sup.dev | sh && sudo install -m k3sup /usr/local/bin/</b></code></pre>

One can now use k3sup

1. Obtain the Public IPs for the instances running as such `gcloud compute instances --list` or obtain just the Public IPs as `gcloud compute instances list|awk '{print $5}'`

2. one can use to create a cluster with first ip as master <pre><code>k3sup install --cluster --ip <<<b>Any of the Public IPs</b>>> --user <<<b>Your default gcloud user</b>>> --ssh-key <<<b>the location of the gcp_compute_engine private key like ~/.ssh/google_compute_engine</b>>></code></pre>

3. one can also join another IP as master or node For master: <pre><code>k3sup join --server --ip <<<b>Any of the other Public IPs</b>>> --user <<<b>Your default gcloud user</b>>> --ssh-key <<<b>the location of the gcp_compute_engine private key like ~/.ssh/google_compute_engine</b>>> --server-ip <<<b>The Server Public IP</b>>> </code></pre>

or also as normal node:

<pre><code>k3sup join --ip <<<b>Any of the other Public IPs</b>>> --user <<<b>Your default gcloud user</b>>> --ssh-key <<<b>the location of the gcp_compute_engine private key like ~/.ssh/google_compute_engine</b>>> --server-ip <<<b>The Server Public IP</b>>> </code></pre>

<b>or one can do it on three boxes via this simple script</b>
<pre><code>
terraform init && terraform plan -var count_vms=3 -var default_user_name=<<def user name>> -var disk_default_size=20 -var environment=dev -var projectname=<<your GCP Project>> -out gcp.plan && terraform apply gcp.plan
export SERVER_IP=$(gcloud compute instances list   --filter=tags.items=rancher  --format json|jq -r '.[].networkInterfaces[].accessConfigs[].natIP'|head -n 1)
k3sup install --cluster --ip $SERVER_IP --user $(whoami)  --ssh-key ~/.ssh/google_compute_engine --k3s-extra-args '--no-deploy traefik --docker'
gcloud compute instances list   --filter=tags.items=rancher  --format json|jq -r '.[].networkInterfaces[].accessConfigs[].natIP'|tail -n+2|xargs -I {} k3sup join --server-ip $SERVER_IP --ip {}  --user $(whoami) --ssh-key ~/.ssh/google_compute_engine --k3s-extra-args --docker
export KUBECONFIG=`pwd`/kubeconfig
kubectl get nodes -o wide -w
kubectl apply -f pd.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass slow -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
</code></pre>


### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/dwaiba/gcp-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/dwaiba/gcp-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.

### License
  * Please see the [LICENSE file](https://github.com/dwaiba/gcp-terraform/blob/master/LICENSE) for licensing information.

### Code of Conduct
  * Please see the [Code of Conduct](https://github.com/dwaiba/gcp-terraform/blob/master/CODE_OF_CONDUCT.md)
