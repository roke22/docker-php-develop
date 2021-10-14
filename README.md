# English docker-php-develop

Docker compose with nginx, postgres and php that can change easily the version (7.0, 7.1, 7.2, 7.3, 7.4 and 8.0)

## How to use?
1. Create the postgres volume with "docker volume create --name=postgres-data", so the data you store in postgres will not be removed.
2. Rename the env-example to .env
3. Edit .env to enter the paths of the projects, you can put 3 projects at the same time
4. Start the service. "docker-compose up -d --build nginx postgres php" to start all service. The services are nginx, postgres and php.
5. To stop the services run "docker-compose down"

## How to change php version?
Go to the docker-compose.yml at line 38 and change the version of the image. Then restart the services.
<br/><br/>
<br/><br/>
# Spanish docker-php-develop

Docker compose con nginx, postgres y php que puede modificar facilmente la version de php (7.0, 7.1, 7.2, 7.3, 7.4 y 8.0)

## ¿Como se usa?
1. Crea el volumen de postgres con "docker volume create --name=postgres-data", asi los datos almacenados en postgres no seran borrados.
2. Renombrar el fichero env-example a .env
3. Edita el fichero .env y pon las rutas de los proyectos, puedes configurar hasta 3 proyectos a la vez.
4. Inicia los servicios con "docker-compose up -d --build nginx postgres php", esto inicia todos los servicios. Los servicios son nginx, postgres y php.
5. Para parar los servicios ejecuta "docker-compose down"

## ¿Como cambio la version de php?
Ves al fichero docker-compose.yml en la linea 38 cambia la version de la imagen. Luego reinicia los servicios.


