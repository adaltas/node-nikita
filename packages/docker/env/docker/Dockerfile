FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
    apt install -y \
      # System
      tzdata \
      # Node.js dependencies
      build-essential curl git iputils-ping \
      # SSH server and client
      openssh-server \
      # Sudo to start ssh
      sudo && \
    # SSH configuration
    ssh-keygen -A && \
    mkdir -p /run/sshd

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get -y install docker-ce-cli \
  && mkdir -p ~/.docker/cli-plugins/ \
  && curl -SL https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose \
  && chmod +x ~/.docker/cli-plugins/docker-compose

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/docker

# User as sudoer
RUN useradd nikita -d /home/nikita -m -s /bin/bash && \
    mkdir -p /home/nikita && \
    chown nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita
USER nikita

# SSH certificate
RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' && \
    cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

# Node.js
ENV NODE_VERSION stable
RUN curl -L https://git.io/n-install | bash -s -- -y
ENV PATH /home/nikita/n/bin:$PATH

ENTRYPOINT ["/entrypoint.sh"]
