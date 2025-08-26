variable "name" {
  type        = string
  description = "Name of static app"
}

variable "s3_bucket_id" {
  type = string
}

variable "hostnames" {
  type = list(string)
}

variable "hosted_zone" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "hostname_create" {
  description = "Create hostname in the hosted zone passed?"
  type        = bool
  default     = true
}

variable "hostname_alias" {
  description = "Create an Alias host in route53 for Cloudfront (instead of CNAME)?"
  type        = bool
  default     = false
}

variable "cloudfront_logging_bucket" {
  type        = string
  default     = ""
  description = "Bucket to store logs from app"
}

variable "cloudfront_logging_prefix" {
  type        = string
  default     = ""
  description = "Logging prefix"
}

variable "minimum_protocol_version" {
  description = <<EOF
    The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. 
    Can only be set if cloudfront_default_certificate = false. One of SSLv3, TLSv1, TLSv1_2016, 
    TLSv1.1_2016, TLSv1.2_2018 or TLSv1.2_2019. Default: TLSv1. NOTE: If you are using a custom 
    certificate (specified with acm_certificate_arn or iam_certificate_id), and have specified 
    sni-only in ssl_support_method, TLSv1 or later must be specified. If you have specified vip 
    in ssl_support_method, only SSLv3 or TLSv1 can be specified. If you have specified 
    cloudfront_default_certificate, TLSv1 must be specified.
    EOF
  type        = string
  default     = "TLSv1.2_2019"
}

variable "restriction_type" {
  description = "The restriction type of your CloudFront distribution geolocation restriction. Options include none, whitelist, blacklist"
  type        = string
  default     = "none"
}

variable "restriction_location" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)"
  type        = list(any)
  default     = []
}

variable "cloudfront_web_acl_id" {
  default     = ""
  type        = string
  description = "Optional web acl (WAF) to attach to CloudFront"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Set the default file for the application"
}

variable "dynamic_custom_origin_config" {
  description = "Configuration for the custom origin config to be used in dynamic block"
  type        = any
  default     = []
}

variable "dynamic_ordered_cache_behavior" {
  description = "Ordered Cache Behaviors to be used in dynamic block"
  type = list(object({
    path_pattern                 = optional(string)
    allowed_methods              = optional(list(string))
    cached_methods               = optional(list(string))
    viewer_protocol_policy       = optional(string)
    target_origin_id             = optional(string)
    smooth_streaming             = optional(bool, false)
    compress                     = optional(bool, true)
    cache_policy_id              = optional(string)
    response_headers_policy_id   = optional(string)
    response_headers_policy_name = optional(string)
    min_ttl                      = optional(number)
    default_ttl                  = optional(number)
    max_ttl                      = optional(number)
    forwarded_values = optional(list(object({
      query_string              = optional(bool)
      headers                   = optional(list(string))
      cookies_forward           = optional(string)
      cookies_whitelisted_names = optional(list(string))
    })), [])
    lambda_function_association = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool)
    })), [])
  }))
  default = null
  # validation {
  #   condition = length([
  #     for cb in try(var.dynamic_ordered_cache_behavior, []) : cb.path_pattern
  #     ]) == length(distinct([
  #       for cb in try(var.dynamic_ordered_cache_behavior, []) : cb.path_pattern
  #   ]))
  #   error_message = "You have duplicate path_pattern in dynamic_ordered_cache_behavior"
  # }
  # validation {
  #   condition = alltrue([
  #     for cb in try(var.dynamic_ordered_cache_behavior, []) : (
  #       (cb.response_headers_policy_id != null && cb.response_headers_policy_id != "") ||
  #       (cb.response_headers_policy_name != null && cb.response_headers_policy_name != "")
  #       ) || (
  #       (cb.response_headers_policy_id == null || cb.response_headers_policy_id == "") &&
  #       (cb.response_headers_policy_name == null || cb.response_headers_policy_name == "")
  #     )
  #   ])
  #   error_message = "You must provide either response_headers_policy_id or response_headers_policy_name in dynamic_ordered_cache_behavior"
  # }
}

variable "module_enabled" {
  description = "Enable the module to create resources"
  default     = true
  type        = bool
}

variable "default_cache_behavior_forward_query_string" {
  default     = true
  type        = bool
  description = "Default cache behavior forward"
}

variable "default_cache_behavior_forward_headers" {
  default     = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]
  type        = list(string)
  description = "Default cache behavior headers forward"
}

variable "default_cache_behavior_cookies_forward" {
  default     = "all"
  type        = string
  description = "Default cache behavior cookies forward"
}

variable "default_cache_behavior_allowed_methods" {
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  type        = list(string)
  description = "Methods allowed for default origin cache behavior"
}

variable "default_cache_behavior_response_headers_id" {
  default     = ""
  type        = string
  description = "The identifier for a response headers policy"
}

variable "wait_for_deployment" {
  default     = false
  type        = bool
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed"
}

variable "response_page_path" {
  default     = "/index.html"
  type        = string
  description = "Custom error response page path"
}

variable "lambda_edge" {
  default     = []
  type        = any
  description = "Lambda EDGE configuration"
}

variable "default_threshold" {
  description = "The default threshold for the metric."
  default     = 5
  type        = number
}

variable "default_evaluation_periods" {
  description = "The default amount of evaluation periods."
  default     = 2
  type        = number
}

variable "default_period" {
  description = "The default evaluation period."
  default     = 60
  type        = number
}

variable "default_comparison_operator" {
  description = "The default comparison operator."
  default     = "GreaterThanOrEqualToThreshold"
  type        = string
}

variable "default_statistic" {
  description = "The default statistic."
  type        = string
  default     = "Average"
}

variable "alarms" {
  type        = map(any)
  default     = {}
  description = <<EOF
The keys of the map are the metric names. This list must be given as a comma-separated string.
The following arguments are supported:
  - comparison_operator: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold
  - evaluation_periods: The number of periods over which data is compared to the specified threshold.
  - period: The period in seconds over which the specified statistic is applied.
  - statistic: The statistic to apply to the alarm's associated metric.
  - threshold: The number of occurances over a given period.
  - actions: The actions to execute when the alarm transitions into an ALARM state (ARN). 
  - ok_actions: The list of actions to execute when this alarm transitions into an OK state from any other state (ARN). 
EOF
}

variable "trusted_key_groups" {
  type = list(object({
    name                = string
    public_key_contents = string
  }))
  default     = []
  description = "A list with `name` and `public_key` to create and attach a trusted key group to the distribution"
}

variable "response_header_policies" {
  description = "Response headers policies to add to the cloudfront"
  default     = []
  type = list(object({
    name    = string
    comment = optional(string, "")
    cors_config = optional(object({
      access_control_allow_credentials = bool
      access_control_allow_headers     = list(string)
      access_control_allow_methods     = list(string)
      access_control_allow_origins     = list(string)
      access_control_expose_headers    = list(string)
      access_control_max_age_sec       = number
      origin_override                  = bool
    }), null)
    custom_headers_config = optional(list(object({
      header   = string
      override = bool
      value    = string
    })), null)
    remove_headers_config = optional(list(object({
      header = string
    })), null)
    server_timing_headers_config = optional(object({
      enabled       = bool
      sampling_rate = number
    }), null)
  }))
}
