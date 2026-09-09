terraform {
  required_version = ">= 1.11"

  backend "s3" {
    bucket       = "tfstate-lab-265808837027-yosselyn"
    key          = "etapa4/ejercicio-4-6-4.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}

resource "terraform_data" "prueba_estado" {
  input = "estado recuperable del ejercicio 4.6.4"
}

output "prueba_estado" {
  value = terraform_data.prueba_estado.output
}