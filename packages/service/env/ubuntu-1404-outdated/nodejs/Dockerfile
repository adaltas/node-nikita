FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

ARG DEBIAN_FRONTEND=nonintercative
RUN \
    apt update -y && \
    # Install Node.js dependencies
    apt install -y build-essential curl git iputils-ping

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/service

# User
RUN useradd nikita -d /home/nikita -m -s /bin/bash && \
    mkdir -p /home/nikita && \
    chown nikita /home/nikita && \
    chmod 700 /home/nikita
USER nikita

# Install Node.js
ENV NODE_VERSION stable
RUN curl -L https://git.io/n-install | bash -s -- -y
# Note, bashrc not sourced unless running interactively
ENV PATH /home/nikita/n/bin:$PATH

ENTRYPOINT ["/entrypoint.sh"]
