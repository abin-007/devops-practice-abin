# container
-> base image
-> share common operating system
-> light weight in nature
-> it is a appliaction bundle or package which contains your appliaction, system dependencies and  libraries
-> how does it work?
 #    docker file -> submitting it to a docker engine using the docker command -> docker image -> container
spof (single point of failure)
layer problem
# buildat 

docker ps --format 'table {{.Names}}\t{{.Ports}}’
 docker image ls
 docker image history alpin

## commands- docker
docker compose logs -f frontend

-> docker version 
shoulf give the output as client and server, which means it is running perfectly locally on your machine


1)the command to create the jwt token key for the commpose yaml file 
##  openssl rand -hex 3

-> the command used under the  docker compose yaml file 
# docker compose config -q (no output is valid)
# docker compose cofig —services (it should display all the services)
# docker compose config
# docker compose build  --progress=plain
# docker compose up -d
# docker compose ps

to check the logs of backend or frontend wqe use the following command 
# docker compose logs --tail=200 backend
to recreate  the backend , we need to execute the following command 

# docker compose up -d  --force-recreate backend

and immediately chck the logs of the backed which is created using
# docker compose logs  --tail=200 backend

-> inorder to stop the running container , instead of the restarting loop , execute the follwoing command 
# docker compose stop backend
	
-> once you chnged the docker file , execute the  following command
# docker compose build backend --progress=plain
	
# docker compose build \ --no-cache \ --progress=plain \ backend
after building , recreate the backend container 
# docker compose up -d --force-recreate backend
-> 
# docker compose down
# docker compose build backend
# docker compose up -d
# docker compose up -d —build
# docker build -t YOUR_DOCKER_USERNAME/docker-quickstart .
# docker run -d -p 8080:8080 YOUR_DOCKER_USERNAME/docker-quickstart