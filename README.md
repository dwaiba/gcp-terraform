# Google Cloud with Terraform

1. Install Terraform
2. Please create Service Credential of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder.
3. Clone this repository
4. Upload your public ssh key at https://console.cloud.google.com/compute/metadata/sshKeys and use the corresponding `Username` value in the console for `default_user_name` value in `vars.tf`
5. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. Please note the Environment name prompted during plan may be dev/tst or any other stage. 
