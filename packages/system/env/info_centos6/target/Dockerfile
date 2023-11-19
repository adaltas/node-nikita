FROM centos:6
LABEL org.opencontainers.image.authors="David Worms <david@adaltas.com>"

# Fix yum repo error,
# see - https://github.com/adaltas/node-nikita/issues/184
RUN sed -i -e 's/mirrorlist/#mirrorlist/g' \
    -e 's/#baseurl/baseurl/g' \
    -e 's/http:\/\/mirror.centos.org\/centos\/$releasever/https:\/\/vault.centos.org\/6.10/g' \
    /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all
# Note, nov 2023, `yum update` fail to update gcc, commenting for now
# yum -y update

# Install SSH
#RUN \
#  # Install SSH and sudo
#  yum install -y openssh-server openssh-clients sudo && \
#  ssh-keygen -A
RUN yum install -y openssh-server openssh-clients sudo && \
    # Avoid `Could not load host key: /etc/ssh/ssh_host_rsa_key`
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key && \
    # Avoid `Could not load host key: /etc/ssh/ssh_host_dsa_key`
    cp -rp /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita

# Sudo User
RUN useradd nikita -d /home/nikita && \
    hash=$(echo "secret" | openssl passwd -1 -stdin) && \
    usermod --pass="$hash" nikita && \
    mkdir -p /home/nikita && \
    mkdir -p /home/nikita/.ssh && \
    chown -R nikita /home/nikita && \
    chmod 700 /home/nikita && \
    echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

USER nikita

ENTRYPOINT ["sudo", "/usr/sbin/sshd", "-D"]
