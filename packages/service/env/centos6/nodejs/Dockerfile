FROM centos:7
MAINTAINER David Worms

RUN \
  # Install Node dependencies
  yum install -y git make

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/service
ENV TERM xterm # Color output in TTY

# Sudo User
RUN useradd nikita -d /home/nikita && \
 mkdir -p /home/nikita && \
 chown nikita /home/nikita && \
 chmod 700 /home/nikita
USER nikita

# Install Node.js
ENV NODE_VERSION stable
RUN \
  curl -L https://git.io/n-install | bash -s -- -y && \
  . ~/.bashrc && n $NODE_VERSION

ENTRYPOINT ["/entrypoint.sh"]
