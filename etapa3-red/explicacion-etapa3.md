# Explicación de la arquitectura – Etapa 3

## Recorrido de un paquete

Cuando el usuario accede a la URL pública, la solicitud HTTP llega al Application Load Balancer mediante el Internet Gateway. El ALB se encuentra distribuido entre las subnets públicas `10.0.0.0/24` y `10.0.1.0/24`, selecciona uno de los destinos saludables y reenvía la solicitud por el puerto 80 a una instancia EC2 ubicada en las subnets privadas `10.0.10.0/24` o `10.0.11.0/24`.

El Security Group de las instancias solo permite tráfico procedente del Security Group del ALB, por lo que las EC2 no pueden ser accedidas directamente desde Internet. Nginx procesa la solicitud y devuelve la respuesta al ALB, que finalmente la entrega al navegador del usuario. Cuando las instancias necesitan iniciar una conexión hacia Internet, utilizan la ruta `0.0.0.0/0` dirigida al NAT Gateway de la subnet pública y luego al Internet Gateway.

## Resultado del experimento sin NAT

Al establecer `habilitar_nat = false`, Terraform eliminó la ruta privada, el NAT Gateway y su IP elástica. Las instancias existentes continuaron respondiendo porque Nginx ya estaba instalado. Sin embargo, después de terminar manualmente una instancia, el Auto Scaling Group lanzó un reemplazo que no pudo acceder a los repositorios de Amazon Linux para instalar Nginx. Por esta razón, el ALB marcó el nuevo destino como `unhealthy` con el motivo `Target.FailedHealthChecks`.

Al restaurar el NAT Gateway, las instancias privadas recuperaron la salida a Internet. El experimento demuestra que una instancia privada necesita un mecanismo de salida, como un NAT Gateway, una imagen previamente configurada o VPC Endpoints, para descargar dependencias y comunicarse con servicios externos sin tener una IP pública.
