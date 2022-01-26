FROM centos:7
MAINTAINER David Worms

# Install SSH
RUN yum install -y openssh-server openssh-clients sudo \
 && /usr/bin/ssh-keygen -A

# Install PostgreSQL client
RUN yum install -y postgresql

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/db
ENV TERM xterm # Color output in TTY

# Sudo User
RUN useradd nikita -d /home/nikita \
 && mkdir -p /home/nikita \
 && chown nikita /home/nikita \
 && chmod 700 /home/nikita \
 && echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita
USER nikita

# Install Node.js
ENV NODE_VERSION stable
RUN \
     sudo yum install -y git make \
  && curl -L https://git.io/n-install | bash -s -- -y \
  && . ~/.bashrc && n $NODE_VERSION

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' \
 && cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

ENTRYPOINT ["/entrypoint.sh"]
