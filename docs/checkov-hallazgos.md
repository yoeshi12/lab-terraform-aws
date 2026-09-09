# Clasificación de hallazgos Checkov — Etapa 5.5

**Alcance:** infraestructura activa de la etapa 5 (`modules/`, `envs/` y `bootstrap/`).

| Hallazgo | Clasificación | Tratamiento y justificación |
|---|---|---|
| CKV_AWS_274 | Corregido | Se eliminó `AdministratorAccess` del rol de GitHub Actions y se reemplazó por políticas propias con acciones explícitas y ARNs restringidos para S3, RDS, IAM y SSM. |
| CKV_AWS_111 | Aceptado temporalmente | Terraform necesita operaciones de escritura para crear, actualizar y destruir la infraestructura. Las acciones están enumeradas y el rol OIDC solo puede asumirse desde este repositorio. |
| CKV_AWS_356 | Aceptado temporalmente | Algunas operaciones de EC2, ELB y Auto Scaling utilizan `Resource: "*"`. Para producción se recomienda añadir restricciones mediante etiquetas, región y límites de permisos. |
| Hallazgos de etapas 1–4 | Fuera de alcance | Corresponden a ejercicios históricos que ya no son desplegados por el pipeline de la etapa 5. Se excluyen mediante `skip_path`, pero permanecen en Git como evidencia académica. |

## Resultado

El pipeline usa OIDC sin claves permanentes, no posee `AdministratorAccess` y Checkov se configura con `soft_fail: false`. Las excepciones temporales están documentadas junto al recurso correspondiente.
