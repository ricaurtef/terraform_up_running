provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Maintainer = "Ruben Ricaurte: rricaurte@netrixllc.com",
      ManagedBy  = "Terraform",
    }
  }
}
