# ═══════════════════════════════════════════════════════════════
# MAIN.TF — Portal de Capacitación Terraform
# Recursos: S3 (portal) + CloudFront
#
# NOTA: En producción también gestionamos con Terraform el bucket
# S3 del remote state y la tabla DynamoDB para el lock.
# En esta demo usamos state local para simplificar.
# ═══════════════════════════════════════════════════════════════

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# ─────────────────────────────────────────────
# 1. BUCKET S3 — PORTAL WEB (sitio estático)
# ─────────────────────────────────────────────

resource "aws_s3_bucket" "portal" {
  bucket        = var.portal_bucket_name
  force_destroy = var.force_destroy_bucket

  tags = merge(local.common_tags, {
    Name    = var.portal_bucket_name
    Purpose = "static-website"
  })
}

resource "aws_s3_bucket_versioning" "portal" {
  bucket = aws_s3_bucket.portal.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "portal" {
  bucket = aws_s3_bucket.portal.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# El bucket NO es público — CloudFront accede via OAC
resource "aws_s3_bucket_public_access_block" "portal" {
  bucket = aws_s3_bucket.portal.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────
# 2. CLOUDFRONT — CDN para el portal
# Origin Access Control (OAC) — método moderno y seguro
# ─────────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "portal" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC para el portal de capacitación"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "portal" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = var.cloudfront_comment
  price_class         = var.cloudfront_price_class

  origin {
    domain_name              = aws_s3_bucket.portal.bucket_regional_domain_name
    origin_id                = "S3-${var.portal_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.portal.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.portal_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # 1 hora
    max_ttl     = 86400 # 24 horas
  }

  # Manejo de errores — SPA friendly
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-distribution"
    Purpose = "cdn-portal"
  })
}

# ─────────────────────────────────────────────
# 3. BUCKET POLICY — Permite a CloudFront leer el bucket
# ─────────────────────────────────────────────

data "aws_iam_policy_document" "portal_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.portal.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.portal.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "portal" {
  bucket = aws_s3_bucket.portal.id
  policy = data.aws_iam_policy_document.portal_bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.portal]
}

# ─────────────────────────────────────────────
# 4. SUBIDA DE ARCHIVOS WEB AL BUCKET S3
# Terraform sube automáticamente el contenido de /web
# ─────────────────────────────────────────────

# Busca todos los archivos dentro del directorio web/
locals {
  web_files = fileset("${path.module}/web", "**/*")

  mime_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "woff" = "font/woff"
    "woff2"= "font/woff2"
    "ttf"  = "font/ttf"
    "txt"  = "text/plain"
  }
}

resource "aws_s3_object" "web_files" {
  for_each = local.web_files

  bucket       = aws_s3_bucket.portal.id
  key          = each.value
  source       = "${path.module}/web/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
  etag         = filemd5("${path.module}/web/${each.value}")

  tags = local.common_tags
}
