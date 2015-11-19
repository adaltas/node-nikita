#Apache Zeppelin on centos 6.6 OS
#(sudo) docker build -t mecano/test_suit .

FROM centos:6.6

##------------------------##
#  BUILDING TOOLS INSTALL  #
##------------------------##

RUN yum clean all
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y wget unzip openssl git rpm tar bzip2 git yum-utils make gcc-c++ tar  words
RUN yum install -y  python krb5-server krb5-libs krb5-workstation vim
RUN yum install -y libxslt-devel
RUN yum install -y mysql mysql-connector-java
RUN yum install -y snappy
RUN yum install -y python-devel
RUN yum install -y openssl-devel
RUN yum install -y cyrus-sasl-gssapi unzip
RUN yum groupinstall -y 'Developement Tools'
RUN yum install -y npm node

##--------------##
#  JAVA INSTALL  #
##--------------##

RUN curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm"
RUN rpm -ivh jdk-7u79-linux-x64.rpm
ENV JAVA_HOME /usr/java/default

##---------------##
#  MAVEN INSTALL  #
##---------------##

RUN wget http://apache.websitebeheerjd.nl/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.zip
RUN unzip apache-maven-3.3.3-bin.zip
RUN mv apache-maven-3.3.3/ /opt/maven
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$PATH
RUN export PATH MAVEN_HOME
RUN export CLASSPATH=.

WORKDIR /mecano

ENTRYPOINT ['npm','run','test']