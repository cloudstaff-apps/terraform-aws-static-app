data "aws_s3_bucket" "selected" {
  count  = var.module_enabled ? 1 : 0
  bucket = var.s3_bucket_id
}

locals {
  response_headers_policy_names = distinct([
    for cb in coalesce(var.dynamic_ordered_cache_behavior, []) : cb.response_headers_policy_name
    if cb.response_headers_policy_name != null && cb.response_headers_policy_name != ""
  ])

  resolved_cloudfront_function_arn = var.create_cloudfront_function ? (
    try(aws_cloudfront_function.this[0].arn, null)
  ) : var.cloudfront_function_arn

}

data "aws_cloudfront_response_headers_policy" "default" {
  for_each = toset(local.response_headers_policy_names)
  name     = each.value
}
