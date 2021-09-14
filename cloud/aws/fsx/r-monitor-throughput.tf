resource "datadog_monitor" "fsx_windows_throughput" {
  count   = var.fsx_windows_throughput_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] FSX for Windows througput {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"
  message = coalesce(var.fsx_windows_throughput_message, var.message)
  type    = "query alert"

  query = <<EOQ
    ${var.fsx_windows_throughput_time_aggregator}(${var.fsx_windows_throughput_timeframe}): (
      ( avg:aws.fsx.data_read_bytes${module.filter-tags.query_alert} +
        avg:aws.fsx.data_write_bytes${module.filter-tags.query_alert}) / 60 > ${var.fsx_windows_throughput_threshold_critical}
EOQ

  thresholds = {
    critical = var.fsx_windows_throughput_threshold_critical
    warning  = var.fsx_windows_throughput_threshold_warning
  }

  evaluation_delay    = var.evaluation_delay
  new_host_delay      = var.new_host_delay
  notify_no_data      = false
  renotify_interval   = 0
  require_full_window = false
  timeout_h           = 0
  include_tags        = true

  tags = concat(["env:${var.environment}", "type:cloud", "provider:aws", "resource:fsx", "team:claranet", "created-by:terraform"], var.fsx_windows_throughput_extra_tags)

  lifecycle {
    ignore_changes = [silenced]
  }
}