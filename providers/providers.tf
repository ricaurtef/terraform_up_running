# Note that Terraform will use the un-aliased provider by default if you don’t set the `provider` argument.
# You *can* give every provider block an alias, but in practice it’s simpler to leave most resources
# pointing at the default and only add `provider = <alias>` where you actually need a second or third.

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-2"
  alias  = "region_2"
}
