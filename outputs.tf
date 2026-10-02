# ═══════════════════════════════════════════════════════════════
# OUTPUTS — Lo que Terraform muestra al finalizar el apply
# Esto es lo que verá la audiencia en pantalla al terminar
# ═══════════════════════════════════════════════════════════════

output "portal_url" {
  description = "🌐 URL del portal de capacitación (abre esto en el navegador)"
  value       = "https://${aws_cloudfront_distribution.portal.domain_name}"
}

output "cloudfront_domain" {
  description = "Dominio de CloudFront asignado automáticamente"
  value       = aws_cloudfront_distribution.portal.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront (útil para invalidar caché)"
  value       = aws_cloudfront_distribution.portal.id
}

output "portal_bucket_name" {
  description = "Nombre del bucket S3 que contiene el portal"
  value       = aws_s3_bucket.portal.bucket
}

output "portal_bucket_arn" {
  description = "ARN del bucket S3 del portal"
  value       = aws_s3_bucket.portal.arn
}

output "resumen_despliegue" {
  description = "Resumen del despliegue para mostrar en la capacitación"
  value = <<-EOT

    ╔══════════════════════════════════════════════════════╗
    ║         DESPLIEGUE COMPLETADO CON TERRAFORM          ║
    ╠══════════════════════════════════════════════════════╣
    ║  Portal URL  : https://${aws_cloudfront_distribution.portal.domain_name}
    ║  S3 Portal   : ${aws_s3_bucket.portal.bucket}
    ║  Región      : ${var.aws_region}
    ║  Ambiente    : ${var.environment}
    ╚══════════════════════════════════════════════════════╝

  EOT
}
