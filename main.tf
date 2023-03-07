resource "grafana_contact_point" "contact_point" {
  name = "Contact Point"

  email {
    addresses               = ["varshabhat221@gmail.com"]
    message                 = "Take care of this." 
    subject                 = "HIGH ALERT"
    single_email            = true
    disable_resolve_message = false
  }
}

resource "grafana_message_template" "my_template" {
  name     = "Message Template"
  template = "{{define \"My Reusable Template\" }}\n template content\n{{ end }}"
}


resource "grafana_notification_policy" "my_policy" {
    group_by = ["alertname"]
    contact_point = grafana_contact_point.contact_point.name

    group_wait = "45s"
    group_interval = "6m"
    repeat_interval = "3h"

    policy {
        matcher {
            label = "alertname"
            match = "="
            value = "demo1"
        }
        group_by = ["..."]
        contact_point = grafana_contact_point.contact_point.name
        mute_timings = [grafana_mute_timing.my_mute_timing.name]
    }
}

resource "grafana_mute_timing" "my_mute_timing" {
    name = "Mute Timing"

    intervals {
        times {
          start = "01:30"
          end = "13:30"
        }
        weekdays = ["saturday", "sunday", "tuesday:thursday"]
        months = ["january:march"]
        years = ["2023:2024"]
    }
}

resource "grafana_data_source" "testdata_datasource" {
    name = "TestData"
    type = "testdata"
}

resource "grafana_folder" "rule_folder" {
    title = "My Rule Folder"
}

resource "grafana_rule_group" "my_rule_group" {
    name = "My Alert Rules"
    folder_uid = grafana_folder.rule_folder.uid
    interval_seconds = 60
    org_id = 1

    rule {
        name = "My Random Walk Alert"
        condition = "C"
        for = "0s"
        data {
            ref_id = "A"
            relative_time_range {
                from = 600
                to = 0
            }
            datasource_uid = grafana_data_source.testdata_datasource.uid
            model = jsonencode({
                intervalMs = 1000
                maxDataPoints = 43200
                refId = "A"
            })
        }
        data {
            datasource_uid = "__expr__"
             model = <<EOT
{"conditions":[{"evaluator":{"params":[0,0],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A"]},"reducer":{"params":[],"type":"last"},"type":"avg"}],"datasource":{"name":"Expression","type":"__expr__","uid":"__expr__"},"expression":"A","hide":false,"intervalMs":1000,"maxDataPoints":43200,"reducer":"last","refId":"B","type":"reduce"}
EOT
            ref_id = "B"
            relative_time_range {
                from = 0
                to = 0
            }
        }
        data {
            datasource_uid = "__expr__"
            ref_id = "C"
            relative_time_range {
                from = 0
                to = 0
            }
            model = jsonencode({
                expression = "$B > 70"
                type = "math"
                refId = "C"
            })
        }
    }
}
    