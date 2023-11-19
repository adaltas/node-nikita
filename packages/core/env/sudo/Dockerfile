FROM centos:7.9.2009
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

RUN \
     # Install Node dependencies
     yum install -y git make

# Sudo User
RUN useradd nikita -d /home/nikita \
&& mkdir -p /home/nikita \
&& chown nikita /home/nikita \
&& chmod 700 /home/nikita \
&& yum install -y sudo \
&& echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

# Install Node.js
# Note, CentOS 7.9.2009 incompatible with Node.js >= 18
RUN \
     su - nikita -c 'curl -L https://git.io/n-install | bash -s -- -y 16.19'
ENV PATH /home/nikita/n/bin:$PATH

RUN \
     # Install SSH
     yum install -y openssh-server openssh-clients \
  && ssh-keygen -A \
     # Install openssl
  && yum install -y openssl \
     # Finalize
  && yum clean all

ADD ./entrypoint.sh /entrypoint.sh
WORKDIR /home/nikita/work/packages/core
USER nikita

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''\
 && cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys

ENTRYPOINT ["/entrypoint.sh"]
