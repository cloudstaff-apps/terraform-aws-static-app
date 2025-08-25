mock_provider "aws" { }

mock_provider "aws" {
  alias = "us-east-1"
}

run "valid_required_vars" {
  command = plan
  variables {
    name            = "test-static-app"
    s3_bucket_id    = "test-bucket"
    hostnames       = ["example.com"]
    hosted_zone     = "Z123456789"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    response_header_policies = []
  }
}

run "response_headers_policy_cors_config" {
  command = plan
  variables {
    name            = "test-static-app"
    s3_bucket_id    = "test-bucket"
    hostnames       = ["example.com"]
    hosted_zone     = "Z123456789"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    response_header_policies = [
      {
        name    = "cors-policy"
        comment = "CORS policy for static app"
        cors_config = {
          access_control_allow_credentials = true
          access_control_allow_headers     = ["Content-Type", "Authorization"]
          access_control_allow_methods     = ["GET", "POST", "OPTIONS"]
          access_control_allow_origins     = ["https://example.com"]
          access_control_expose_headers    = ["X-Custom-Header"]
          access_control_max_age_sec       = 86400
          origin_override                  = true
        }
      }
    ]
  }

  assert {
    condition     = aws_cloudfront_response_headers_policy.default["cors-policy"].name == "cors-policy"
    error_message = "Response headers policy name should match the input"
  }

  assert {
    condition     = aws_cloudfront_response_headers_policy.default["cors-policy"].comment == "CORS policy for static app"
    error_message = "Response headers policy comment should match the input"
  }
}

run "response_headers_policy_custom_headers" {
  command = plan
  variables {
    name            = "test-static-app"
    s3_bucket_id    = "test-bucket"
    hostnames       = ["example.com"]
    hosted_zone     = "Z123456789"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    response_header_policies = [
      {
        name    = "custom-headers-policy"
        comment = "Custom headers policy"
        custom_headers_config = [
          {
            header   = "X-Custom-Header"
            override = true
            value    = "custom-value"
          }
        ]
      }
    ]
  }

  assert {
    condition     = aws_cloudfront_response_headers_policy.default["custom-headers-policy"].name == "custom-headers-policy"
    error_message = "Response headers policy name should match the input"
  }
}

run "response_headers_policy_server_timing" {
  command = plan
  variables {
    name            = "test-static-app"
    s3_bucket_id    = "test-bucket"
    hostnames       = ["example.com"]
    hosted_zone     = "Z123456789"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    response_header_policies = [
      {
        name    = "server-timing-policy"
        comment = "Server timing policy"
        server_timing_headers_config = {
          enabled       = true
          sampling_rate = 50
        }
      }
    ]
  }

  assert {
    condition     = aws_cloudfront_response_headers_policy.default["server-timing-policy"].name == "server-timing-policy"
    error_message = "Response headers policy name should match the input"
  }
}
