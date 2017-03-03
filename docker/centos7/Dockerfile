FROM centos:7
MAINTAINER David Worms

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.2.2
RUN yum install -y xz \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1

# Install epel (requirement for service nginx)
RUN yum install -y epel-release

# Install supervisor
RUN \
  yum install -y iproute python-setuptools hostname inotify-tools yum-utils which && \
  easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Install SSH
RUN yum install -y openssh-server openssh-clients \
&& ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
&& cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
# Generate server key
&& ssh-keygen -f /etc/ssh/ssh_host_rsa_key

# Install Java
RUN yum install -y java

# Install Krb5 client
RUN yum install -y krb5-workstation
ADD ./krb5.conf /etc/krb5.conf

# Install Misc dependencies
RUN yum install -y zip unzip git

# Install PostgreSQL client
RUN yum install -y postgresql

## Install Mysql client
RUN yum install -y mysql

# Install docker
RUN curl -fsSL https://get.docker.com/ | sh
RUN curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Install openssl
RUN yum install -y openssl

RUN yum clean all

ADD ./run.sh /run.sh
RUN mkdir -p /mecano
WORKDIR /mecano
ENV TERM xterm

#CMD ["node_modules/.bin/mocha", "test/api/"]
ENTRYPOINT ["/run.sh"]
CMD []
