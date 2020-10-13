FROM centos:7
MAINTAINER David Worms

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.13.1
RUN yum install -y xz \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install epel (requirement for service nginx)
RUN yum install -y epel-release

# Sudo User
RUN useradd nikita -d /home/nikita \
  && mkdir -p /home/nikita \
  && chown nikita /home/nikita \
  && chmod 700 /home/nikita \
  && yum install -y sudo \
  && echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

# Install supervisor
RUN \
  yum install -y iproute python-setuptools hostname inotify-tools yum-utils which && \
  easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Install SSH
RUN yum install -y openssh-server openssh-clients \
  && mkdir -p /home/nikita/.ssh \
  && chmod 700 /home/nikita/.ssh \
  && ssh-keygen -t rsa -f /home/nikita/.ssh/id_rsa -N '' \
  && cat /home/nikita/.ssh/id_rsa.pub > /home/nikita/.ssh/authorized_keys \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key \
  && chown -R nikita /home/nikita/.ssh

# Install openssl
RUN yum install -y openssl

# Finalize
RUN yum clean all
ADD ./run.sh /run.sh
WORKDIR /home/nikita/work
ENV TERM xterm
USER nikita
ENTRYPOINT ["/run.sh"]
CMD []
