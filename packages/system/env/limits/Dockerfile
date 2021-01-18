FROM ubuntu:trusty
MAINTAINER David Worms

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.13.1
RUN apt-get update -y \
  && apt-get install -y curl xz-utils \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install SSH
RUN apt-get install -y openssh-server \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
  
  ADD ./run.sh /run.sh
  RUN mkdir -p /nikita
  WORKDIR /nikita/packages/system
  # Enable color output in TTY
  ENV TERM xterm

  ENTRYPOINT ["/run.sh"]
