# Clasificación de hallazgos Checkov — Etapa 5.5

**Alcance:** módulos activos y autenticación OIDC de la etapa 5.

| Controles | Clasificación | Tratamiento |
|---|---|---|
| CKV_AWS_274 | Corregido | Se eliminó AdministratorAccess y se reemplazó por políticas limitadas. |
| CKV_AWS_23, CKV_AWS_130, CKV_AWS_131, CKV_AWS_226, CKV2_AWS_60 | Corregidos | Se agregaron descripciones, se desactivó la asignación automática de IP pública, se habilitó el descarte de encabezados inválidos, las actualizaciones menores y la copia de etiquetas. |
| CKV2_AWS_19 | Falso positivo | La EIP sí está utilizada por el NAT Gateway. |
| CKV_AWS_260 | Aceptado temporalmente | El ALB de demostración necesita recibir HTTP público; la aplicación solo recibe tráfico desde el SG del ALB. |
| CKV_AWS_2, CKV_AWS_103, CKV_AWS_378, CKV2_AWS_20 | Aceptados temporalmente | No existe dominio ni certificado ACM para HTTPS en este laboratorio. |
| CKV_AWS_91, CKV_AWS_150, CKV2_AWS_28 | Aceptados temporalmente | Logs, protección de eliminación y WAF se reservan para producción por costo y porque dev debe destruirse al finalizar. |
| CKV2_AWS_11, CKV2_AWS_12 | Aceptados temporalmente | Flow Logs y gestión del SG predeterminado quedan como endurecimiento de producción; dicho SG no es utilizado. |
| CKV2_AWS_30, CKV_AWS_118, CKV_AWS_129, CKV_AWS_161, CKV_AWS_353 | Aceptados temporalmente | Monitoreo avanzado, logs, IAM DB Auth y Performance Insights se omiten en la base efímera por costo y alcance. |
| CKV2_AWS_34 | No aplicable | El parámetro SSM contiene un endpoint, no una contraseña ni otro secreto. |
| CKV_AWS_111, CKV_AWS_356 | Aceptados temporalmente | Las acciones están enumeradas; S3, RDS, IAM y SSM están limitados por ARN, y el rol OIDC solo confía en este repositorio. |

Checkov se ejecuta con `soft_fail: false`. Las excepciones están registradas mediante `skip_check` o comentarios junto al recurso.
