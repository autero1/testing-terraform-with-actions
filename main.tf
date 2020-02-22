# ~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A STATIC WEBSITE
# ~~~~~~~~~~~~~~~~~~~~~~~

# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
terraform {
  required_version = ">= 0.12.20"
}

# ---------
# VARIABLES
# ---------
variable "website_name" {
  description = "The name of your static website."
  type        = string
}

variable "region" {
  description = "AWS region this bucket should reside in"
  type        = string
}

variable "force_destroy" {
  description = "Delete all objects from the bucket so that the bucket can be destroyed even when not empty"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to add to resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------
# CREATE THE S3 WEBSITE BUCKET AND ATTACH A POLICY
# ------------------------------------------------
resource "aws_s3_bucket" "website" {
  bucket        = var.website_name
  acl           = "public-read"
  tags          = var.tags
  region        = var.region
  force_destroy = var.force_destroy

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website.json
}

data "aws_iam_policy_document" "website" {
  statement {
    actions = [
    "s3:GetObject"]

    resources = [
    "${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# -------
# OUTPUTS
# -------
output "s3_bucket_website_endpoint" {
  value       = aws_s3_bucket.website.website_endpoint
  description = "Website endpoint for the S3 bucket"
}

output "s3_bucket_name" {
  description = "Name of of website bucket"
  value       = aws_s3_bucket.website.id
}
