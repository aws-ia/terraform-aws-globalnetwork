terraform{
    backend "s3"{

        # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
        bucket = "my-terraform-state-bucket-name"

        # Please populate with the key name the terraform.tfstate file for your transit_gateway
        key = "my-terraform-state-bucket-name/transit-gateway/terraform.tfstate"

        # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
        region = "us-east-2"

    }
}



