FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

LABEL project=nikita \
  project.tests="tools.dconf"

# Install Node.js
ENV NODE_VERSION stable
RUN apt update -y && \
    apt install -y build-essential curl git iputils-ping && \
    curl -L https://git.io/n-install | bash -s -- -y && \
    /root/n/bin/n $NODE_VERSION

# Install SSH
RUN apt-get install -y openssh-server && \
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' && \
    cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys && \
    ssh-keygen -A && \
    mkdir -p /run/sshd

# Install dbus-x11 required by dbus-launch in entrypoint.sh
RUN apt install -y dbus-x11

# Install local dependencies
RUN apt-get install -y dconf-cli gnome-terminal
COPY dbus.conf /etc/dbus-1/session.d/dbus.conf

COPY ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/tools

ENTRYPOINT ["/entrypoint.sh"]
