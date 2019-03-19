FROM ubuntu:trusty
MAINTAINER David Worms

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 11.12.0
RUN apt-get update -y \
  && apt-get install -y curl xz-utils \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install SSH
RUN apt-get install -y openssh-server \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Install Java
RUN apt-get install -y openjdk-7-jdk

# Install Misc dependencies
RUN apt-get install -y zip git

# Install docker
RUN curl -fsSL https://get.docker.com/ | sh
RUN curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Install Ruby gems
RUN apt-get update -y
RUN apt-get install -y gcc make ruby ruby-dev
RUN curl -sSL https://get.rvm.io | bash -s stable
# RUN source /etc/profile.d/rvm.sh && rvm install 2.0.0
ENV PATH "/usr/local/rvm/bin:$PATH"
RUN rvm requirements
RUN rvm install 2.4.1

ADD ./run.sh /run.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core

#CMD ["node_modules/.bin/mocha", "test/api/"]
# CMD []
ENTRYPOINT ["/run.sh"]
