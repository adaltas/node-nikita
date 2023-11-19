FROM ubuntu:20.04
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

ARG DEBIAN_FRONTEND=nonintercative
RUN apt update -y && \
    # Install Node.js dependencies
    apt install -y build-essential curl git iputils-ping && \
    # Install SSH and sudo
    apt-get install -y openssh-server sudo && \
    ssh-keygen -A && \
    mkdir -p /run/sshd

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/system

# Sudo User
RUN useradd nikita -d /home/nikita -m -s /bin/bash && \
    mkdir -p /home/nikita && \
    chown nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita
USER nikita

# Install Node.js
ENV NODE_VERSION stable
RUN curl -L https://git.io/n-install | bash -s -- -y
ENV PATH /home/nikita/n/bin:$PATH

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' && \
  cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

ENTRYPOINT ["/entrypoint.sh"]
