terraform {
  backend "s3" {
    bucket       = "oneclick-tf-state-anuu"
    key          = "infra/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
