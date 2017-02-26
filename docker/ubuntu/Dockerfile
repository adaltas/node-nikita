FROM ubuntu:trusty
MAINTAINER David Worms

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.2.2
RUN apt-get update -y \
  && apt-get install -y curl xz-utils \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1

# Install SSH
RUN apt-get install -y openssh-server \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Install Krb5 client
RUN apt-get install -y krb5-user
ADD ./krb5.conf /etc/krb5.conf

# Install Misc dependencies
RUN apt-get install -y zip git

# Install docker
RUN curl -fsSL https://get.docker.com/ | sh
RUN curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

ADD ./run.sh /run.sh
RUN mkdir -p /mecano
WORKDIR /mecano

#CMD ["node_modules/.bin/mocha", "test/api/"]
# CMD []
ENTRYPOINT ["/run.sh"]
