FROM centos:7.9.2009
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

RUN \
    # Install Node dependencies
    yum install -y git make && \
    # Install openssl for user password
    yum install -y openssl \
    # Install SSH and sudo
    yum install -y openssh-server openssh-clients sudo && \
    ssh-keygen -A

RUN yum clean all

# ADD ./entrypoint.sh /entrypoint.sh
# RUN mkdir -p /nikita

# Sudo User
RUN useradd nikita -d /home/nikita && \
    hash=$(echo "secret" | openssl passwd -1 -stdin) && \
    usermod --pass="$hash" nikita && \
    mkdir -p /home/nikita && \
    mkdir -p /home/nikita/.ssh && \
    chown -R nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

# USER nikita

ENTRYPOINT ["sudo", "/usr/sbin/sshd", "-D"]
