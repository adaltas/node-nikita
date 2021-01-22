FROM archlinux:latest
MAINTAINER David Worms

RUN pacman --noconfirm -Syu && pacman --noconfirm -S procps grep which sed

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
RUN pacman --noconfirm -S nodejs npm

# Install supervisor
RUN pacman --noconfirm -S supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Install SSH
RUN pacman --noconfirm -S openssh \
 && /usr/bin/ssh-keygen -A \
 && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
 && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Install Misc dependencies
RUN pacman --noconfirm -S zip git

# Install arch-chroot
ENV ARCHLINUX_VERSION 2021.01.01
RUN pacman --noconfirm -S arch-install-scripts tar gzip \
 && curl -L "https://mirrors.edge.kernel.org/archlinux/iso/$ARCHLINUX_VERSION/archlinux-bootstrap-$ARCHLINUX_VERSION-x86_64.tar.gz" -o /var/tmp/archlinux-bootstrap.tar.gz \
 && tar xzf /var/tmp/archlinux-bootstrap.tar.gz -C /var/tmp \
 && rm -f /var/tmp/archlinux-bootstrap.tar.gz

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/engine

ENTRYPOINT ["/entrypoint.sh"]
