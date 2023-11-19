FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

# # Install Misc dependencies
# RUN yum install -y zip unzip bzip2 git

# # Install PostgreSQL client
# RUN yum install -y postgresql

# ## Install Mysql client
# RUN yum install -y mysql

# # Install openssl
# RUN yum install -y openssl

# # Install docker
# RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# RUN yum install -y docker-ce
# RUN curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
# RUN chmod +x /usr/local/bin/docker-compose

# # Ruby & Gem
# RUN yum install -y gcc ruby ruby-devel

# # Cgroup
# RUN yum install -y libcgroup-tools

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
      sudo \
      # Java and Kerberos
      ldap-utils && \
    # SSH configuration
    ssh-keygen -A && \
    mkdir -p /run/sshd

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/ldap

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
