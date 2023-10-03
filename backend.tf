terraform {
  backend "s3" {
    bucket         = "s3tfgbucket"  
    key            = "terraform.tfstate"
    region         = "us-west-2"              
    
  }
}
