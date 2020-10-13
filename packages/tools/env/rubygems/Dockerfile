FROM centos:7
MAINTAINER David Worms

LABEL project=nikita \
      project.tests="tools.rubygems"

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.13.1
RUN yum install -y xz \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install epel (requirement for service nginx)
RUN yum install -y epel-release

# Install supervisor
RUN \
  yum install -y iproute python-setuptools hostname inotify-tools yum-utils which && \
  easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Create SSH user
RUN groupadd -r sshuser && useradd --no-log-init -m -r -g sshuser sshuser

# Activate SSH connection
RUN yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && mkdir /home/sshuser/.ssh \
  && chmod 700 /home/sshuser \
  && cat ~/.ssh/id_rsa.pub > /home/sshuser/.ssh/authorized_keys \
  && chown -R sshuser /home/sshuser/.ssh \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key

# Ruby & Gem
RUN yum install -y gcc ruby ruby-devel

RUN yum clean all

ADD ./run.sh /run.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/tools
ENV TERM xterm

#CMD ["node_modules/.bin/mocha", "test/api/"]
ENTRYPOINT ["/run.sh"]
CMD []
