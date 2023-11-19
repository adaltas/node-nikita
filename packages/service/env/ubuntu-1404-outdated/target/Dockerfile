FROM ubuntu:14.04.5
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

RUN \
    apt update && \
    # Install SSH and sudo
    apt-get install -y openssh-server sudo && \
    ssh-keygen -A && \
    mkdir -p /run/sshd

# Sudo User
RUN useradd nikita -d /home/nikita && \
    hash=$(echo "secret" | openssl passwd -1 -stdin) && \
    usermod --pass="$hash" nikita && \
    mkdir -p /home/nikita && \
    mkdir -p /home/nikita/.ssh && \
    chown -R nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

ENTRYPOINT ["sudo", "/usr/sbin/sshd", "-D"]
