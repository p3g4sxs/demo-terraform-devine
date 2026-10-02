# ─────────────────────────────────────────────
# BACKEND — State local para la demo
#
# En esta capacitación el state vive localmente en terraform.tfstate
# En producción usamos remote state en S3 con lock en DynamoDB:
#
# terraform {
#   backend "s3" {
#     bucket         = "nombre-del-bucket-state"
#     key            = "proyecto/ambiente/terraform.tfstate"
#     region         = "us-east-1"
#     profile        = "hackaton-aws"
#     dynamodb_table = "nombre-tabla-lock"
#     encrypt        = true
#   }
# }
# ─────────────────────────────────────────────
