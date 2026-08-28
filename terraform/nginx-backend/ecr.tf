# ============================================================
# Nginx Backend ECR Repository
# ============================================================

resource "aws_ecr_repository" "nginx_backend" {
  name                 = "nginx-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}