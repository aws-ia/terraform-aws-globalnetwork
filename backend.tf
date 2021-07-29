terraform{
    backend "s3"{

        # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
        bucket = "aws-fsf-artifacts-for-goldman"

        # Please populate with the key name the terraform.tfstate file for your transit_gateway
        key = "terraform-artifacts/transit-gateway/terraform.tfstate"

        # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
        region = "us-east-1"

    }
}
