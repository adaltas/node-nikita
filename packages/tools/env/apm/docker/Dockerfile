FROM ubuntu:22.04
MAINTAINER David Worms

RUN \
 apt update -y && \
 # Install Node.js dependencies
 apt install -y build-essential curl git && \
 # Install SSH and sudo
 apt-get install -y openssh-server sudo && \
 ssh-keygen -A && \
 mkdir -p /run/sshd

RUN \
 apt install -y curl gnupg && \
 curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add - && \
 echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list - && \
 apt update -y && \
 apt install -y atom

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/tools
ENV TERM xterm # Color output in TTY

# Sudo User
RUN useradd nikita -d /home/nikita -m -s /bin/bash && \
 mkdir -p /home/nikita && \
 chown nikita /home/nikita && \
 chmod 700 /home/nikita && \
 echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita
USER nikita

# Install Node.js
ENV NODE_VERSION stable
RUN \
  curl -L https://git.io/n-install | bash -s -- -y
# Note, bashrc not sourced unless running interactively
# RUN . ~/.bashrc && n $NODE_VERSION
ENV PATH /home/nikita/n/bin:$PATH

RUN \
 ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' && \
 cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

ENTRYPOINT ["/entrypoint.sh"]
