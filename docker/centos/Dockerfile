FROM centos:6
MAINTAINER David Worms

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 5.8.0
RUN yum install -y xz \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1

# Install SSH
RUN yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Install epel (requirement for service nginx)
RUN yum install -y epel-release

# Install Krb5 client
RUN yum install -y krb5-workstation
ADD ./krb5.conf /etc/krb5.conf

# Install Misc dependencies
RUN yum install -y zip git

# Install docker
RUN curl -fsSL https://get.docker.com/ | sh

ADD ./run.sh /run.sh
RUN mkdir -p /mecano
WORKDIR /mecano
ENV TERM xterm

#CMD ["node_modules/.bin/mocha", "test/api/"]
ENTRYPOINT ["/run.sh"]
CMD []
