# ─────────────────────────────────────────────
# VARIABLES GENERALES
# ─────────────────────────────────────────────

variable "aws_region" {
  description = "Región de AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, se usa como prefijo en los recursos"
  type        = string
  default     = "terraform-capacitacion"
}

variable "environment" {
  description = "Ambiente de despliegue: dev, staging, prod"
  type        = string
  default     = "demo"
}

variable "tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────
# VARIABLES DEL PORTAL WEB (S3)
# ─────────────────────────────────────────────

variable "portal_bucket_name" {
  description = "Nombre del bucket S3 que aloja el portal web (debe ser único globalmente)"
  type        = string
}

variable "force_destroy_bucket" {
  description = "Permite destruir el bucket aunque tenga contenido (útil en demos)"
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────
# VARIABLES DE CLOUDFRONT
# ─────────────────────────────────────────────

variable "cloudfront_price_class" {
  description = "Clase de precio de CloudFront (ALL = global, 100 = USA/Europa, 200 = + Asia)"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "El valor debe ser PriceClass_All, PriceClass_200 o PriceClass_100."
  }
}

variable "cloudfront_comment" {
  description = "Descripción de la distribución CloudFront"
  type        = string
  default     = "Portal de Capacitación Terraform"
}
