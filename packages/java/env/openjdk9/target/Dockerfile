FROM adoptopenjdk/openjdk9:latest
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

RUN apt update -y && \
    # Install SSH and sudo
    apt-get install -y openssh-server sudo && \
    ssh-keygen -A && \
    mkdir -p /run/sshd

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core

# Sudo User
RUN useradd nikita -d /home/nikita && \
    hash=$(echo "secret" | openssl passwd -1 -stdin) && \
    usermod --pass="$hash" nikita && \
    mkdir -p /home/nikita && \
    mkdir -p /home/nikita/.ssh && \
    chown -R nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

USER nikita

ENTRYPOINT ["sudo", "/usr/sbin/sshd", "-D"]
