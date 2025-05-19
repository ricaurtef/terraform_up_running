# Note that Terraform will use the un-aliased provider by default if you don’t set the `provider` meta-argument.
# You *can* give every provider block an alias, but in practice it’s simpler to leave most resources
# pointing at the default and only add `provider = <alias>` where you actually need a second or third.

data "aws_region" "region_1" {}

data "aws_region" "region_2" {
  provider = aws.region_2
}
