# --------------------------
# CONFIGURE OUR AWS PROVIDER
# --------------------------

provider "aws" {
  region = var.region
}

# ---------
# VARIABLES
# ---------
variable "website_name" {
  description = "The name of your static website. Note that this needs to be globally unique"
  type        = string
  default     = "terratest-with-gh-actions"
}

variable "region" {
  description = "AWS region this bucket should reside in"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to add to resources"
  type        = map(string)
  default = {
    CI = "true"
  }
}

# ----------------------------------------------
# CREATE THE S3 WEBSITE AND STORE SAMPLE CONTENT
# ----------------------------------------------
module "website" {
  source = "../../"

  region       = var.region
  website_name = var.website_name

  // We want to be able to destroy after the test
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_object" "index" {
  key          = "index.html"
  bucket       = module.website.s3_bucket_name
  source       = "index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error" {
  key          = "error.html"
  bucket       = module.website.s3_bucket_name
  source       = "error.html"
  acl          = "public-read"
  content_type = "text/html"
}

# -------
# OUTPUTS
# -------
output "s3_bucket_name" {
  description = "Name of of website bucket"
  value       = module.website.s3_bucket_name
}

output "s3_bucket_website_endpoint" {
  value       = module.website.s3_bucket_website_endpoint
  description = "Website endpoint for the S3 bucket"
}

