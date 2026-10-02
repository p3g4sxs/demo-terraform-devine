# 🏗️ Terraform — Portal de Capacitación

Portal web interactivo desplegado **con Terraform** para la capacitación del equipo.
La demostración inicia ejecutando `terraform apply` en vivo — el resultado es este mismo portal.

---

## 📋 Prerequisitos (instalar antes del día)

### 1. Terraform
```bash
# macOS
brew install terraform

# Windows
choco install terraform

# Verificar instalación
terraform version   # debe ser >= 1.5.0
```

### 2. AWS CLI
```bash
# macOS
brew install awscli

# Verificar
aws --version
```

### 3. Credenciales AWS — perfil `hackaton-aws`

Agrega el perfil en `~/.aws/credentials`:
```ini
[hackaton-aws]
aws_access_key_id     = TU_ACCESS_KEY_ID
aws_secret_access_key = TU_SECRET_ACCESS_KEY
region                = us-east-1
```

Verificar que funciona:
```bash
aws sts get-caller-identity --profile hackaton-aws
```

---

## 🚀 Día de la capacitación — paso a paso

### Antes de empezar (solo la primera vez)

No hay nada que crear manualmente. El state vive localmente en `terraform.tfstate`.
En producción lo movemos a S3 — pero eso lo explicamos en los slides, no lo necesitamos para la demo.

---

### Durante la capacitación (en vivo frente al equipo)

**1. Ajustar el nombre del bucket del portal en `terraform.tfvars`:**
```hcl
# El nombre debe ser único globalmente en AWS
portal_bucket_name = "terraform-capacitacion-portal-demo"
```

**2. Inicializar Terraform:**
```bash
terraform init
```
> Descarga el provider de AWS y conecta con el backend S3.

**3. Ver el plan (sin hacer cambios):**
```bash
terraform plan
```
> Muestra exactamente qué recursos se van a crear. Ideal para explicar a la audiencia.

**4. Aplicar — el momento WOW:**
```bash
terraform apply
```
> Escribe `yes` cuando lo pida. En ~2 minutos aparecerá la URL del portal.

**5. Ver los outputs:**
```bash
terraform output
```
```
portal_url = "https://xxxxx.cloudfront.net"
```

**6. Abrir el portal:**
```bash
open $(terraform output -raw portal_url)
```

> ⏱️ CloudFront puede tardar 5-15 minutos en propagarse. El portal ya está accesible, solo puede ser algo más lento al inicio.

---

## 📁 Estructura del proyecto

```
terraform-capacitacion/
├── backend.tf          # Remote state en S3 + DynamoDB lock
├── providers.tf        # AWS provider (perfil hackaton-aws)
├── main.tf             # Todos los recursos AWS
├── variables.tf        # Definición de variables con tipos y validaciones
├── outputs.tf          # URLs y datos del despliegue
├── terraform.tfvars    # Valores del ambiente (ajustar antes del apply)
├── .gitignore          # Excluye .terraform/, *.tfstate, etc.
└── web/
    └── index.html      # Portal con Reveal.js (todos los slides)
```

---

## 🏗️ Recursos que crea Terraform

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| `aws_s3_bucket.portal` | S3 | Archivos del portal web |
| `aws_cloudfront_origin_access_control.portal` | CloudFront OAC | Acceso seguro S3→CF |
| `aws_cloudfront_distribution.portal` | CloudFront | CDN global con HTTPS |
| `aws_s3_bucket_policy.portal` | IAM Policy | Permite a CloudFront leer S3 |
| `aws_s3_object.web_files` | S3 Objects | Archivos del portal (subida automática) |

**Total: ~7 recursos creados por un solo `terraform apply`**

> En producción Terraform también gestiona el bucket S3 del remote state
> y la tabla DynamoDB del lock — pero eso lo vemos en los slides del módulo de stack real.

---

## 🔧 Comandos útiles durante la demo

```bash
# Ver todos los recursos gestionados
terraform state list

# Ver detalles de un recurso
terraform state show aws_cloudfront_distribution.portal

# Ver outputs
terraform output

# Invalidar caché de CloudFront (si actualizas el portal)
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*" \
  --profile hackaton-aws

# Verificar el state en S3
aws s3 ls s3://terraform-capacitacion-state/ --recursive --profile hackaton-aws
```

---

## 🧹 Limpiar al finalizar

```bash
terraform destroy
```

Destruye todos los recursos: S3 portal, CloudFront, bucket policy y archivos.
El state local `terraform.tfstate` queda en tu máquina — puedes borrarlo manualmente si quieres.

---

## ⚙️ Personalización

Para cambiar el contenido de los slides, edita `web/index.html`.
Cada sección `<section>` es un slide. Después de editar, ejecuta:

```bash
terraform apply   # sube automáticamente los cambios a S3
```

Para cambiar el nombre del bucket o la región, edita `terraform.tfvars`.

---

## 🔐 Seguridad

- El bucket S3 del portal **no es público** — CloudFront accede via OAC (Origin Access Control)
- El state está **cifrado en reposo** con AES-256
- Las credenciales AWS están en `~/.aws/credentials` — nunca en el código
- La tabla DynamoDB asegura que **dos pipelines no apliquen al mismo tiempo**

---

## 📚 Recursos para continuar aprendiendo

- [Documentación oficial de Terraform](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry (providers y módulos)](https://registry.terraform.io)
- [AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com)
