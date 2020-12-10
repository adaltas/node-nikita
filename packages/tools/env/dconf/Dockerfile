FROM ubuntu:trusty
MAINTAINER David Worms

LABEL project=nikita \
      project.tests="tools.dconf"

# Install Node.js
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.13.1
RUN apt-get update -y \
  && apt-get install -y curl xz-utils \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install SSH
#RUN apt-get install -y openssh-server \
#&& ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
#&& cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Create SSH user
RUN groupadd -r sshuser && useradd --no-log-init -m -r -g sshuser sshuser

# Activate SSH connection
RUN apt-get install -y openssh-server \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && mkdir /home/sshuser/.ssh \
  && chmod 700 /home/sshuser \
  && cat ~/.ssh/id_rsa.pub > /home/sshuser/.ssh/authorized_keys \
  && chown -R sshuser /home/sshuser/.ssh

COPY ./run.sh /run.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/tools

# Install local dependencies
RUN apt-get install -y dconf-cli gnome-terminal

#CMD ["node_modules/.bin/mocha", "test/api/"]
# CMD []
ENTRYPOINT ["/run.sh"]
