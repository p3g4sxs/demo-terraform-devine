# ─────────────────────────────────────────────
# terraform.tfvars
# Valores para el despliegue del portal de capacitación
# Ajusta estos valores antes del terraform apply
# ─────────────────────────────────────────────

# General
aws_region   = "us-east-1"
project_name = "terraform-capacitacion"
environment  = "demo"

tags = {
  Project     = "terraform-capacitacion"
  Environment = "demo"
  ManagedBy   = "terraform"
  Owner       = "equipo-devops"
}

# Portal Web — nombre del bucket (debe ser único globalmente en AWS)
# Sugerencia: agrega un sufijo con tu nombre o fecha, ej: terraform-capacitacion-portal-2024
portal_bucket_name   = "terraform-capacitacion-portal-dievelma"
force_destroy_bucket = true

# CloudFront
cloudfront_price_class = "PriceClass_100"
cloudfront_comment     = "Portal de Capacitación Terraform"
