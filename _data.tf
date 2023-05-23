data "aws_s3_bucket" "selected" {
  count = var.module_enabled ? 1 : 0

  bucket = var.s3_bucket_id
}

data "aws_cloudfront_cache_policy" "this" {
  name = var.default_cache_policy
}

data "aws_cloudfront_response_headers_policy" "this" {
  name = var.default_response_headers_policy
}

data "aws_cloudfront_origin_request_policy" "this" {
  name = var.default_origin_request_policy
}