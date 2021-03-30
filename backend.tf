terraform{
    backend "s3"{
        # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
        bucket = "aws-fsf-team-terraform-state-storage" # myterraform_state_bucket
        # Please populate with the key name the terraform.tfstate file for your transit_gateway
        key = "aws-fsf-terraform-network-state/transit-gateway/terraform.tfstate" #terraform-aws-fsf-state-file-backend/terraform.tfstate
        # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
        region = "us-east-2" #eu-north-1
    }
}



