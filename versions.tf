terraform {
    required_version = ">= 1.5"
    /*
    backend "s3" {
        bucket = "devops-directive-tf-state"
        key = "s3-backup-proj/terraform.tfstate"
        region = "us-east-1"
        use_lockfile = true
        encrypt = true
    }
    */
    backend "local" {
        path = "terraform.tfstate"
    }

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

