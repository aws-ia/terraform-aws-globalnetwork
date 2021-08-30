# Terraform AWS Global Network
Terraform AWS Global Network is a system primarily written in Terraform that you use to deploy and automate the configuration of a transitive network on the AWS Cloud. You can deploy a single transit gateway in one AWS Region, multiple gateways in multiple Regions, or a globally meshed network of gateways in every Region. For more information about the configurations available and the system's components, see [README.md](README.md), also in this repository.

Author: [Androski Spicer](mailto:androsks@amazon.com)

## Deploy Terraform AWS Global Network

1. Install Terraform. See [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) for a tutorial. 
2. Sign up and log into [Terraform Cloud](https://app.terraform.io/signup/account). There is a free tier available.
3. Generate a Terraform Cloud token.<br>

   `terraform login`

4. Export the `TERRAFORM_CONFIG` variable.<br>
   *  Mac/Linux
   
      `export TERRAFORM_CONFIG="$HOME/.terraform.d/credentials.tfrc.json"`

   *  Windows
   
      `export TERRAFORM_CONFIG="$HOME/AppData/Roaming/terraform.d/credentials.tfrc.json"`

5. Configure the AWS Command Line Interface (AWS CLI). For more information, see [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

6. If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 

7. Clone the **aws-ia/terraform-aws-globalnetwork-1** repository.

   `git clone https://github.com/aws-ia/terraform-aws-globalnetwork-1.git`

8. Change to the module root directory.

   `cd terraform-aws-globalnetwork-1/`

9. Set up your Terraform cloud workspace.<br>
   
   `cd setup_workspace`<br>
   `terraform init`<br>
   `terraform apply`<br>
   
10. Change to the **deploy** directory.<br>
   
    `cd ../deploy`

11. Initialize the **deploy** directory.

    `terraform init`.
   
12. Run `terraform apply`  or `terraform apply -var-file="$HOME/.aws/terraform.tfvars"`

   **Note:** `terraform apply` runs remotely in the Terraform Cloud.
