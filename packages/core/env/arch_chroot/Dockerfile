FROM archlinux:latest
MAINTAINER David Worms

RUN \
     pacman --noconfirm -Syu \
  && pacman --noconfirm -S procps grep which sed zip git

# Install Node.js
RUN pacman --noconfirm -S nodejs npm

# Install SSH and sudo
RUN pacman --noconfirm -S openssh sudo \
 && /usr/bin/ssh-keygen -A

# Install arch-chroot
# Get the latest version from
# https://mirrors.edge.kernel.org/archlinux/iso/
ENV ARCHLINUX_VERSION 2021.11.01
RUN pacman --noconfirm -S arch-install-scripts tar gzip \
 && curl -L "https://mirrors.edge.kernel.org/archlinux/iso/$ARCHLINUX_VERSION/archlinux-bootstrap-$ARCHLINUX_VERSION-x86_64.tar.gz" -o /var/tmp/archlinux-bootstrap.tar.gz \
 && tar xzf /var/tmp/archlinux-bootstrap.tar.gz -C /var/tmp \
 && rm -f /var/tmp/archlinux-bootstrap.tar.gz

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core

# Sudo User
RUN useradd nikita -d /home/nikita \
 && mkdir -p /home/nikita \
 && chown nikita /home/nikita \
 && chmod 700 /home/nikita \
 && echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita
USER nikita

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' \
 && cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

ENTRYPOINT ["/entrypoint.sh"]
