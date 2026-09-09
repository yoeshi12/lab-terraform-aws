terraform {
  backend "s3" {
    bucket       = "tfstate-lab-265808837027-yosselyn"
    key          = "envs/prod/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}
