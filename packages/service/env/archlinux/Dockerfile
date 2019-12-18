FROM base/archlinux
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

# Install Java
RUN pacman --noconfirm -S jdk8-openjdk

# Install Misc dependencies
RUN pacman --noconfirm -S zip git

# Install docker
RUN pacman -Syy && pacman --noconfirm -S docker docker-compose

# Install arch-chroot
RUN pacman --noconfirm -S arch-install-scripts tar gzip \
 && curl -L https://mirrors.kernel.org/archlinux/iso/2018.07.01/archlinux-bootstrap-2018.07.01-x86_64.tar.gz -o /var/tmp/archlinux-bootstrap-2018.07.01-x86_64.tar.gz \
 && tar xzf /var/tmp/archlinux-bootstrap-2018.07.01-x86_64.tar.gz -C /var/tmp \
 && rm -f /var/tmp/archlinux-bootstrap-2018.07.01-x86_64.tar.gz

ADD ./run.sh /run.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/service

#CMD ["node_modules/.bin/mocha", "test/api/"]
# CMD []
ENTRYPOINT ["/run.sh"]
