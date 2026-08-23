# ============================================================
# Cloud Map Private DNS Namespace
# ============================================================

resource "aws_service_discovery_private_dns_namespace" "test" {
  name = "test.local"

  vpc = data.terraform_remote_state.vpc.outputs.vpc_id
}

# ============================================================
# Backend Service Discovery
# ============================================================

resource "aws_service_discovery_service" "nginx" {
  name = "nginxService"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.test.id

    dns_records {
      ttl  = 15
      type = "SRV"
    }
  }
}