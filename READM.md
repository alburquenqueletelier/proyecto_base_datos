# Proyecto Base de Datos

## Requerimientos

- MySQL 
- Docker

## Setup

1. Descargar imagen docker de MySQL Oficial (o puedes crear el Dockerfile)
`docker pull mysql`

2. Crear un contenedor de MySQL
`docker run --name consulta_medica -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:latest`

3. Copiar archivos al contenedor
`docker cp consultamedica.sql consulta_medica:/consultamedica.sql`
`docker cp sql_querys.sql consulta_medica:/sql_querys.sql`

4. Ingresar al contenedor
`docker exec -it consulta_medica bash`

5. Ingresar a terminal de MySQL
`mysql -u root -p my-secret-pw # si no especificas clave te la pide, ej: mysql -u root -p`

6. Crear base de datos
`CREATE DATABASE consultamedica;`

7. Seleccionar base de datos
`USE consultamedica;`

8. Importar datos
`SOURCE /consultamedica.sql`

9. Ejecutar consultas
`SOURCE /sql_querys.sql`