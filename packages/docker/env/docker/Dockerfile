FROM ubuntu:focal
MAINTAINER David Worms

# Install Node.js
# ping used in compose test
ENV NODE_VERSION stable
RUN \
     apt update -y \
  && apt install -y build-essential curl git iputils-ping \
  && curl -L https://git.io/n-install | bash -s -- -y \
  && /root/n/bin/n $NODE_VERSION

# Install SSH
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y openssh-server \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  && ssh-keygen -A \
  && mkdir -p /run/sshd

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install docker-ce-cli \
  && mkdir -p ~/.docker/cli-plugins/ \
  && curl -SL https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose \
  && chmod +x ~/.docker/cli-plugins/docker-compose

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/docker

ENTRYPOINT ["/entrypoint.sh"]
