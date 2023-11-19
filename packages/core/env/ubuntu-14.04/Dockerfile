FROM ubuntu:trusty
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

RUN apt update -y && \
    # Install Node.js dependencies
    apt install -y build-essential curl git iputils-ping && \
    # Install SSH and sudo
    apt-get install -y openssh-server sudo && \
    ssh-keygen -A && \
    mkdir -p /run/sshd

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core

# Sudo User
RUN useradd nikita -d /home/nikita -m -s /bin/bash && \
    mkdir -p /home/nikita && \
    chown nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita
USER nikita

# Install Node.js
# Note, Ubuntu 14.04 incompatible with Node.js >= 18
RUN curl -L https://git.io/n-install | bash -s -- -y 16.19
ENV PATH /home/nikita/n/bin:$PATH

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' && \
    cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

ENTRYPOINT ["/entrypoint.sh"]
