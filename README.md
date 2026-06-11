# wordpress-aws-ecs

Despliegue automatizado de **WordPress en AWS ECS Fargate** usando **Terraform + GitHub Actions**.

---

## ¿Qué hace este repositorio?

Este repositorio contiene toda la infraestructura como código (IaC) necesaria para desplegar WordPress en AWS de forma completamente automatizada. Incluye:

- VPC con subredes públicas y privadas en 2 zonas de disponibilidad
- Application Load Balancer (ALB) en subredes públicas
- ECS Cluster con Fargate corriendo WordPress en subredes privadas
- RDS MySQL en subredes privadas (base de datos gestionada)
- EFS (Elastic File System) para persistencia de ficheros de WordPress (`wp-content`)
- Security Groups correctamente segmentados por capa
- Pipeline CI/CD con GitHub Actions que ejecuta `terraform plan` y `terraform apply` automáticamente

---

## ClickOps vs GitOps — Por qué importa esto

### ¿Qué es ClickOps?

**ClickOps** significa gestionar tu infraestructura a través de la consola web de AWS haciendo clic: crear una VPC aquí, lanzar una instancia allá, configurar un security group manualmente.

**¿Cuándo tiene sentido ClickOps?**
- Cuando estás aprendiendo — es la mejor forma de entender qué hace cada servicio y cómo se relacionan.
- Para explorar servicios nuevos antes de automatizarlos.
- Para troubleshooting puntual cuando necesitas ver algo rápido.

**El problema de ClickOps en producción:**

| Problema | Consecuencia |
|---|---|
| No hay trazabilidad | No sabes quién cambió qué ni cuándo |
| No es reproducible | Si tienes que montar otro entorno, empiezas de cero |
| Propenso a errores | Un clic equivocado puede tirar producción |
| No escala | Con 10 entornos, es inviable |
| Sin revisión | Nadie revisa un cambio antes de aplicarlo |

### ¿Qué es GitOps / IaC?

**GitOps** es el paradigma donde **Git es la única fuente de verdad de tu infraestructura**. Cualquier cambio en infraestructura pasa por un Pull Request, se revisa, y se aplica automáticamente mediante un pipeline.

**Infraestructura como Código (IaC)** significa describir tu infraestructura en ficheros de código (en este caso, Terraform) que se versionan, revisan y ejecutan de forma automatizada.

```
Desarrollador → Git commit → Pull Request → Review → Merge → GitHub Actions → Terraform Apply → AWS
```

**Ventajas reales:**

| Ventaja | Detalle |
|---|---|
| Trazabilidad total | Cada cambio tiene autor, fecha y descripción en Git |
| Reproducible | `terraform apply` monta el mismo entorno en cualquier cuenta |
| Revisable | Los cambios pasan por Pull Request antes de aplicarse |
| Recuperable | Si algo falla, `git revert` + pipeline vuelve al estado anterior |
| Auditable | Cumplimiento normativo con historial completo |

### La realidad del sector

Hoy **ninguna empresa seria gestiona su infraestructura por ClickOps**. El estándar es IaC con pipelines automatizados. Aprender ClickOps está bien para entender los servicios, pero el objetivo real es esto: código versionado + automatización.

Este repo es exactamente ese patrón aplicado a un caso real.

---

## Arquitectura

```
Internet
    │
    ▼
[ALB] ← subredes públicas AZ-a + AZ-b (SG: :80, :443)
    │
    ▼
[ECS Fargate - WordPress] ← subredes privadas AZ-a + AZ-b (SG: solo desde ALB)
    │              │
    ▼              ▼
[RDS MySQL]    [EFS wp-content]
(privado)      (compartido entre tasks)
```

- El ALB es el único recurso expuesto a Internet.
- WordPress corre en subredes privadas, sin IP pública.
- RDS y EFS nunca son accesibles desde fuera de la VPC.
- `desired_count = 2` — alta disponibilidad real con una task por AZ.

---

## Estructura del repositorio

```
wordpress-aws-ecs/
├── README.md                        # Este fichero
├── .github/
│   └── workflows/
│       └── terraform.yml            # Pipeline CI/CD (plan en PR, apply en merge)
└── terraform/
    ├── envs/
    │   └── dev/
    │       ├── main.tf              # Orquestación: llama a todos los módulos
    │       ├── variables.tf         # Variables del entorno dev
    │       ├── outputs.tf           # Outputs (URL del ALB, etc.)
    │       ├── terraform.tfvars     # Valores concretos para dev
    │       └── versions.tf          # Versiones de Terraform y providers
    └── modules/
        ├── vpc/                     # VPC, subredes, IGW, route tables
        ├── security_groups/         # SGs por capa (ALB, ECS, RDS, EFS)
        ├── alb/                     # Application Load Balancer + Target Group
        ├── rds/                     # RDS MySQL en subred privada
        ├── efs/                     # EFS + mount targets por AZ
        └── ecs/                     # ECS Cluster, Task Definition, Service
```

---

## Requisitos previos

- Cuenta AWS (compatible con AWS Academy / LabRole)
- Terraform >= 1.5 instalado localmente (solo para desarrollo)
- Repositorio en GitHub con los siguientes **Secrets** configurados:

### Secrets de GitHub necesarios

Ve a tu repositorio → **Settings → Secrets and variables → Actions** y añade:

| Secret | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access Key de tu sesión de AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Secret Key de tu sesión de AWS Academy |
| `AWS_SESSION_TOKEN` | Session Token de tu sesión de AWS Academy |
| `DB_PASSWORD` | Contraseña para la base de datos MySQL de WordPress |

> **Nota AWS Academy:** Las credenciales de AWS Academy expiran cada pocas horas. Cuando renueves la sesión, actualiza los tres secrets de AWS en GitHub.

---

## Cómo usar este repositorio

### Primera vez (bootstrap)

1. Haz fork o clona este repo y súbelo a tu cuenta de GitHub.
2. Añade los 4 secrets en GitHub (ver tabla arriba).
3. Revisa `terraform/envs/dev/terraform.tfvars` y ajusta la región si es necesario.
4. Haz un commit en `main` → el pipeline ejecutará `terraform apply` automáticamente.
5. Al finalizar, el output del pipeline mostrará la URL del ALB para acceder a WordPress.

### Flujo de trabajo diario

- **Cambios en infraestructura:** abre una rama, haz tus cambios en Terraform, abre un Pull Request → el pipeline ejecuta `terraform plan` y muestra el diff en el PR.
- **Aplicar cambios:** merge a `main` → el pipeline ejecuta `terraform apply` automáticamente.
- **Destruir entorno:** ejecuta manualmente el workflow `destroy` desde la pestaña Actions de GitHub.

---

## Outputs

Tras el `terraform apply`, el pipeline mostrará:

| Output | Descripción |
|---|---|
| `alb_dns_name` | URL pública para acceder a WordPress |
| `rds_endpoint` | Endpoint interno de RDS (para troubleshooting) |
| `ecs_cluster_name` | Nombre del cluster ECS |

Accede a `http://<alb_dns_name>` para completar la instalación de WordPress.

---

## Notas sobre AWS Academy / LabRole

- Este Terraform **no crea roles IAM** — usa el rol `LabRole` preexistente en tu cuenta de Academy.
- No se crea ningún usuario IAM ni política IAM.
- Si ves errores de permisos, verifica que tu sesión de Academy sigue activa y que los secrets de GitHub están actualizados.
