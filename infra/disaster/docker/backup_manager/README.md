# build the image

`$ infra/disaster/docker/backup_manager/_docker-build.sh`

# run the image:

1. `$ cp infra/disaster/docker/backup_manager/_docker-run.sh infra/disaster/docker/backup_manager/_docker-run-with-env.sh`
2. replace the env vars
3. start: `$ infra/disaster/docker/backup_manager/_docker-run-with-env.sh`

# connect to the image

1. find ur instance `$ docker container list`
2. connect to the instancce `$docker exec -ti $CONTAINER_ID bash`

