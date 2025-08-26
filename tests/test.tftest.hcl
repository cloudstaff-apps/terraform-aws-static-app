mock_provider "aws" {}

mock_provider "aws" {
  alias = "us-east-1"
}

run "valid_required_vars" {
  command = plan
  variables {
    name                     = "test-static-app"
    s3_bucket_id             = "test-bucket"
    hostnames                = ["example.com"]
    hosted_zone              = "Z123456789"
    certificate_arn          = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}

run "ordered_cache_behaviors" {
  command = plan
  variables {
    name            = "test-static-app"
    s3_bucket_id    = "test-bucket"
    hostnames       = ["example.com"]
    hosted_zone     = "Z123456789"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    dynamic_ordered_cache_behavior = [
      {
        path_pattern                 = "/images/*"
        allowed_methods              = ["GET", "HEAD"]
        cached_methods               = ["GET", "HEAD"]
        viewer_protocol_policy       = "redirect-to-https"
        target_origin_id             = "s3Origin"
        response_headers_policy_name = "cors-policy"
        cache_policy_id              = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
        min_ttl                      = 0
        default_ttl                  = 3600
        max_ttl                      = 86400
        forwarded_values = [
          {
            query_string    = false
            headers         = []
            cookies_forward = "none"
          }
        ]
      }
    ]
  }
}
