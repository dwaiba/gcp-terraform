# Google Cloud with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. Please create Service Credential of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder.
3. Clone this repository
4. Upload your public ssh key at https://console.cloud.google.com/compute/metadata/sshKeys and use the corresponding `Username` value in the console for `default_user_name` value in `vars.tf`
5. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. Please note the Environment name prompted during plan may be dev/tst or any other stage. 
### Terraform Graph
Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

`terraform graph | dot -Tsvg > graph.svg`
s
Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
Please shoot in dockerized format:

`docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf gcp-terraform && git clone https://github.com/dwaiba/gcp-terraform && cd gcp-terraform && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5001:5000 -v $(pwd):/workdir:ro 28mm/blast-radius && cd ../`

 A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5001/) for this project. 