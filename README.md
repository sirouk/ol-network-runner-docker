# ol-network-runner-docker


## GitHub Actions Runner Config (Docker)
### CRED: https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh
### Build container: docker build [OPTIONS] PATH

`export GH_OWNER='0LNetworkCommunity'`

`export GH_REPOSITORY='libra-framework'`


### get the version and token
https://github.com/0LNetworkCommunity/libra-framework/settings/actions/runners/new?arch=x64&os=linux
### KEEP PAGE OPEN
`export GH_RUNNER_VERSION='versionfromgitrunneraddpage'`

`export GH_TOKEN='tokenfromgitrunneraddpage'`

### set host machine perms for docker.sock
`sudo chown 777 /var/run/docker.sock`

### Build the image (can be used by multiple runners)
`docker build --build-arg RUNNER_VERSION=$GH_RUNNER_VERSION --tag docker-git-runner-ol-network .`

### Run the container in detached mode
`docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -e GH_TOKEN=$GH_TOKEN -e GH_OWNER=$GH_OWNER -e GH_REPOSITORY=$GH_REPOSITORY -d docker-git-runner-ol-network`
### Check the logs
docker logs idhere

### OR: Run the container in interactive mode
`docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -e GH_TOKEN=$GH_TOKEN -e GH_OWNER=$GH_OWNER -e GH_REPOSITORY=$GH_REPOSITORY -ti docker-git-runner-ol-network /bin/bash`


### stopping the container removes it from GitHub Actions
`docker stop $(docker ps -q)`
