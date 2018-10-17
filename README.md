Table of Contents (Google Cloud with Terraform with disks)
=================

1. [Google Cloud with Terraform ](#google-cloud-with-erraform)
2. [Terraform graph](#terraform-graph)
3. [Automatic provisioning](#automatic-provisioning)
4. [Reporting bugs](#reporting-bugs)
5. [Patches and pull requests](#patches-and-pull-requests)

# Google Cloud with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. Please create Service Credential of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder.
3. Clone this repository
4. Upload your public ssh key at https://console.cloud.google.com/compute/metadata/sshKeys and use the corresponding `Username` value in the console for `default_user_name` value in `vars.tf`
5. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. Please note the Environment name prompted during plan may be dev/tst or any other stage. 
### Terraform Graph
Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

`terraform graph | dot -Tsvg > graph.svg`

Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
Please shoot in dockerized format:

`docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf gcp-terraform && git clone https://github.com/dwaiba/gcp-terraform && cd gcp-terraform && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5001:5000 -v $(pwd):/workdir:ro 28mm/blast-radius && cd ../`

 A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5001/) for this project. 

 ### Automatic Provisioning

https://github.com/dwaiba/gcp-terraform

Pre-reqs: 
1. gcloud should be installed. Silent install is - 
`export $USERNAME="<<you_user_name>>" && export SHARE_DATA=/data && su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME && echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh && echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh &&`

2. Please create Service Credential of type JSON via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder of the gcp-terraform

3. Default user name is the local username 

Plan:

`terraform init && terraform plan -var count_vms=2 -var default_user_name=<<your local username>> -var disk_default_size=20 -var environment=dev -var projectname=<<your-google-cloud-project-name>> -out "run.plan"`

Apply:

terraform apply "run.plan"

Destroy:

`terraform destroy -var count_vms=2 -var default_user_name=buildadmin -var disk_default_size=20 -var environment=dev -var projectname=<<your-google-cloud-project-name>>`

### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/dwaiba/gcp-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/dwaiba/gcp-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.