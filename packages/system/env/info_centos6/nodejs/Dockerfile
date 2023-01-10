FROM centos:7.9.2009
MAINTAINER David Worms

RUN \
  # Install Node dependencies
  yum install -y git make

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/system

# Sudo User
RUN useradd nikita -d /home/nikita \
 && mkdir -p /home/nikita \
 && chown nikita /home/nikita \
 && chmod 700 /home/nikita
USER nikita

# Install Node.js
# Note, CentOS 7.9.2009 incompatible with Node.js >= 18
RUN \
  curl -L https://git.io/n-install | bash -s -- -y 16.19
ENV PATH /home/nikita/n/bin:$PATH

ENTRYPOINT ["/entrypoint.sh"]
