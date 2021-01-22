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
# RUN pacman --noconfirm -S zip git

# Install docker
# RUN pacman -Syy && pacman --noconfirm -S docker docker-compose

ADD ./run.sh /run.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/system

ENTRYPOINT ["/run.sh"]
