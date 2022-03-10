/*
terraform {
  backend "gcs" {
    bucket  = "BUCKET NAME"
    prefix  = "SUBDIRECTORY FOR TFSTATE"
  }
}
*/

provider "google" {
}


module "fluid_run" {
  source = "github.com/FluidNumerics/fluid-run//tf"
  bq_location = var.bq_location
  project = var.project
}
