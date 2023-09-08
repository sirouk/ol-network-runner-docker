# base image
#FROM ubuntu:20.04
FROM ubuntu:22.04

#input GitHub runner version argument
ARG RUNNER_VERSION
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="sirouk"
LABEL Email=""
LABEL GitHub="https://github.com/sirouk"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && apt install sudo tasksel -y && useradd -ms /bin/bash docker && usermod -aG sudo docker

# docker in docker
VOLUME /var/run/docker.sock
#RUN ls -lhat /var/run/docker.sock
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes --no-install-recommends \
      docker-compose \
      docker.io
RUN apt-get install -qy curl && \
    apt-get install -qy curl && \
    curl -sSL https://get.docker.com/ | sh
RUN apt-get install -qy docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# fix sudoers file
RUN echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# fix docker.sock
RUN service docker start
#RUN docker run -d -v /var/run/docker.sock:/var/run/docker.sock hello-world
#RUN docker run hello-world

# rust dependencies
RUN apt-get install -qy git vim zip unzip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev lld tmux
RUN rm -rf ~/.cargo ~/.rustup && \
	curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y && \
	. ~/.bashrc && cargo install toml-cli --force


# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
