data "template_file" "filter" {
  template = "$${filter}"

  vars {
    filter = "${var.use_filter_tags == "true" ? format("dd_monitoring:enabled,dd_azure_storage:enabled,env:%s", var.environment) : "${data.template_file.filter.rendered}"}"
  }
}

resource "datadog_monitor" "too_many_jobs_failed" {
  name    = "[${var.environment}] IOT Hub Too many jobs failed on {{name}}"
  message = "${var.message}"

  query = <<EOF
          avg(last_5m):(
            avg:azure.devices_iothubs.jobs.failed{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() /
            ( avg:azure.devices_iothubs.jobs.failed{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() +
                avg:azure.devices_iothubs.jobs.completed{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() )
          ) * 100 > ${var.failed_jobs_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_jobs_rate_threshold_warning}"
    critical = "${var.failed_jobs_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_list_jobs_failed" {
  name    = "[${var.environment}] IOT Hub Too many list_jobs failure on {{name}}"
  message = "${var.message}"

  query = <<EOF
          avg(last_5m):(
            avg:azure.devices_iothubs.jobs.list_jobs.failure{${data.template_file.filter.rendered}} by {resource_group,name}.as_count() /
              ( avg:azure.devices_iothubs.jobs.list_jobs.success{${data.template_file.filter.rendered}} by {resource_group,name}.as_count() +
                  avg:azure.devices_iothubs.jobs.list_jobs.failure{${data.template_file.filter.rendered}} by {resource_group,name}.as_count() )
          ) * 100 > ${var.failed_listjobs_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_listjobs_rate_threshold_warning}"
    critical = "${var.failed_listjobs_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_query_jobs_failed" {
  name    = "[${var.environment}] IOT Hub Too many query_jobs failed on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):(
      avg:azure.devices_iothubs.jobs.query_jobs.failure{${data.template_file.filter.rendered}} by {resource_group,name}.as_count() /
        ( avg:azure.devices_iothubs.jobs.query_jobs.success{${data.template_file.filter.rendered}} by {resource_group,name}.as_count() +
            avg:azure.devices_iothubs.jobs.query_jobs.failure{${data.template_file.filter.rendered}} by {resource_group,name}.as_count() )
    ) * 100 > ${var.failed_queryjobs_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_queryjobs_rate_threshold_warning}"
    critical = "${var.failed_queryjobs_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "status" {
  name    = "[${var.environment}] IOT Hub Status is not ok on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):avg:azure.devices_iothubs.status{${data.template_file.filter.rendered}} by {name,resource_group} < 1
  EOF

  type = "query alert"

  notify_no_data      = true
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "total_devices" {
  name    = "[${var.environment}] IOT Hub Total devices is wrong on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):avg:azure.devices_iothubs.devices.total_devices{${data.template_file.filter.rendered}} by {name,resource_group} == 0
  EOF

  type = "query alert"

  notify_no_data      = true
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_c2d_methods_failed" {
  name    = "[${var.environment}] IOT Hub Too many c2d methods failure on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):(
      avg:azure.devices_iothubs.c2d.methods.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() /
        ( avg:azure.devices_iothubs.c2d.methods.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() +
            avg:azure.devices_iothubs.c2d.methods.success{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() )
    ) * 100 > ${var.failed_c2d_methods_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_c2d_methods_rate_threshold_warning}"
    critical = "${var.failed_c2d_methods_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_c2d_twin_read_failed" {
  name    = "[${var.environment}] IOT Hub Too many c2d twin read failure on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):(
      avg:azure.devices_iothubs.c2d.twin.read.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() /
        ( avg:azure.devices_iothubs.c2d.twin.read.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() +
            avg:azure.devices_iothubs.c2d.twin.read.success{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() )
    ) * 100 > ${var.failed_c2d_twin_read_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_c2d_twin_read_rate_threshold_warning}"
    critical = "${var.failed_c2d_twin_read_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_c2d_twin_update_failed" {
  name    = "[${var.environment}] IOT Hub Too many c2d twin update failure on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):(
      avg:azure.devices_iothubs.c2d.twin.update.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() /
      ( avg:azure.devices_iothubs.c2d.twin.update.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() +
          avg:azure.devices_iothubs.c2d.twin.update.success{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() )
    ) * 100 > ${var.failed_c2d_twin_update_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_c2d_twin_update_rate_threshold_warning}"
    critical = "${var.failed_c2d_twin_update_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_twin_read_failed" {
  name    = "[${var.environment}] IOT Hub Too many d2c twin read failure on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):(
      avg:azure.devices_iothubs.d2c.twin.read.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() /
        ( avg:azure.devices_iothubs.d2c.twin.read.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() +
          avg:azure.devices_iothubs.d2c.twin.read.success{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() )
    ) * 100 > ${var.failed_d2c_twin_read_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_d2c_twin_read_rate_threshold_warning}"
    critical = "${var.failed_d2c_twin_read_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_twin_update_failed" {
  name    = "[${var.environment}] IOT Hub Too many d2c twin update failure on {{name}}"
  message = "${var.message}"

  query = <<EOF
    avg(last_5m):(
      avg:azure.devices_iothubs.d2c.twin.update.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() /
        ( avg:azure.devices_iothubs.d2c.twin.update.failure{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() +
          avg:azure.devices_iothubs.d2c.twin.update.success{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() )
    ) * 100 > ${var.failed_d2c_twin_update_rate_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.failed_d2c_twin_update_rate_threshold_warning}"
    critical = "${var.failed_d2c_twin_update_rate_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_telemetry_egress_dropped" {
  name    = "[${var.environment}] IOT Hub Too many d2c telemetry egress dropped on {{name}}"
  message = "${var.message}"

  query = <<EOF
      sum(last_5m): (
        avg:azure.devices_iothubs.d2c.telemetry.egress.dropped{${data.template_file.filter.rendered}} by {name,resource_group}.as_count()
      ) > ${var.dropped_d2c_telemetry_egress_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.dropped_d2c_telemetry_egress_threshold_warning}"
    critical = "${var.dropped_d2c_telemetry_egress_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_telemetry_egress_orphaned" {
  name    = "[${var.environment}] IOT Hub Too many d2c telemetry egress orphaned on {{name}}"
  message = "${var.message}"

  query = <<EOF
    sum(last_5m): (
      avg:azure.devices_iothubs.d2c.telemetry.egress.orphaned{${data.template_file.filter.rendered}} by {name,resource_group}.as_count()
    ) > ${var.orphaned_d2c_telemetry_egress_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.orphaned_d2c_telemetry_egress_threshold_warning}"
    critical = "${var.orphaned_d2c_telemetry_egress_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_telemetry_egress_invalid" {
  name    = "[${var.environment}] IOT Hub Too many d2c telemetry egress invalid on {{name}}"
  message = "${var.message}"

  query = <<EOF
    sum(last_5m): (
      avg:azure.devices_iothubs.d2c.telemetry.egress.invalid{${data.template_file.filter.rendered}} by {name,resource_group}.as_count()
    ) > ${var.invalid_d2c_telemetry_egress_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.invalid_d2c_telemetry_egress_threshold_warning}"
    critical = "${var.invalid_d2c_telemetry_egress_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_telemetry_egress_fallback" {
  name    = "[${var.environment}] IOT Hub Too many d2c telemetry egress fallback on {{name}}"
  message = "${var.message}"

  query = <<EOF
    sum(last_5m): (
      avg:azure.devices_iothubs.d2c.telemetry.egress.fallback{${data.template_file.filter.rendered}} by {name,resource_group}.as_count()
    )  > ${var.fallback_d2c_telemetry_egress_threshold_critical}
  EOF

  type = "query alert"

  thresholds {
    warning  = "${var.fallback_d2c_telemetry_egress_threshold_warning}"
    critical = "${var.fallback_d2c_telemetry_egress_threshold_critical}"
  }

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}

resource "datadog_monitor" "too_many_d2c_telemetry_ingress_nosent" {
  name    = "[${var.environment}] IOT Hub Too many d2c telemetry ingress no sent on {{name}}"
  message = "${var.message}"

  query = <<EOF
    sum(last_5m): (
      avg:azure.devices_iothubs.d2c.telemetry.ingress.all_protocol{${data.template_file.filter.rendered}} by {name,resource_group}.as_count() -
        avg:azure.devices_iothubs.d2c.telemetry.ingress.success{${data.template_file.filter.rendered}} by {name,resource_group}.as_count()
    ) > 0
  EOF

  type = "query alert"

  notify_no_data      = false
  evaluation_delay    = "${var.delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = true
  new_host_delay      = "${var.delay}"
  no_data_timeframe   = 20

  tags = ["env:${var.environment}", "resource:${var.service}", "team:${var.provider}"]
}
