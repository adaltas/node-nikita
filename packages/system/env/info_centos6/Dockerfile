FROM centos:6
MAINTAINER David Worms

# Fix yum repo error,
# see - https://github.com/adaltas/node-nikita/issues/184
RUN sed -i -e 's/mirrorlist/#mirrorlist/g' \
  -e 's/#baseurl/baseurl/g' \
  -e 's/http:\/\/mirror.centos.org\/centos\/$releasever/https:\/\/vault.centos.org\/6.10/g' \
  /etc/yum.repos.d/CentOS-Base.repo \
  && yum clean all \
  && yum -y update

# Install Node.js
# Note: The latest working NodeJS version on CentOS 6.10 (Final) is 11.15.0,
# related error - https://github.com/nodejs/build/issues/1995
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 11.15.0
RUN yum install -y xz \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install SSH
RUN yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/system
ENV TERM xterm

ENTRYPOINT ["/entrypoint.sh"]
