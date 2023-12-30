provider "aws" {
  region  = "us-east-1"
  profile = "aws-clean-rooms-lab-account-1"
}

provider "aws" {
  alias = "account_2"

  region  = "us-east-1"
  profile = "aws-clean-rooms-lab-account-2"
}
