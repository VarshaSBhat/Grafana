terraform {
    required_providers {
        grafana = {
            source = "grafana/grafana"
            version = "~> 1.28.2"
        }
    }
}

provider "grafana" {
    url = "http://localhost:8080"
    auth =  var.grafana_auth
}


