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

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/service

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
