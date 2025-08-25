resource "aws_cloudfront_response_headers_policy" "default" {
  for_each = { for policy in var.response_header_policies : policy.name => policy }
  name     = each.key
  comment  = each.value.comment

  dynamic "cors_config" {
    for_each = each.value.cors_config != null ? [each.value.cors_config] : []
    content {
      access_control_allow_credentials = cors_config.value.access_control_allow_credentials

      access_control_allow_headers {
        items = cors_config.value.access_control_allow_headers
      }

      access_control_allow_methods {
        items = cors_config.value.access_control_allow_methods
      }

      access_control_allow_origins {
        items = cors_config.value.access_control_allow_origins
      }

      dynamic "access_control_expose_headers" {
        for_each = cors_config.value.access_control_expose_headers != null ? [cors_config.value.access_control_expose_headers] : []
        content {
          items = access_control_expose_headers.value
        }
      }

      access_control_max_age_sec = cors_config.value.access_control_max_age_sec
      origin_override            = cors_config.value.origin_override
    }
  }

  dynamic "custom_headers_config" {
    for_each = each.value.custom_headers_config != null ? [each.value.custom_headers_config] : []
    content {
      dynamic "items" {
        for_each = custom_headers_config.value
        content {
          header   = items.value.header
          override = items.value.override
          value    = items.value.value
        }
      }
    }
  }

  dynamic "remove_headers_config" {
    for_each = each.value.remove_headers_config != null ? [each.value.remove_headers_config] : []
    content {
      dynamic "items" {
        for_each = remove_headers_config.value
        content {
          header = items.value.header
        }
      }
    }
  }

  dynamic "server_timing_headers_config" {
    for_each = each.value.server_timing_headers_config != null ? [each.value.server_timing_headers_config] : []
    content {
      enabled       = server_timing_headers_config.value.enabled
      sampling_rate = server_timing_headers_config.value.sampling_rate
    }
  }
}
