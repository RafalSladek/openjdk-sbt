FROM amazonlinux:latest

ENV MAVEN_VERSION=3.6.0
ENV SBT_VERSION=1.2.6-0
ENV GRADLE_VERSION=4.10.2
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.5

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v

RUN yum fs filter languages en && \
    yum fs filter documentation && \
    yum -y update && \
    yum -y reinstall glibc-common && \
    yum install -y tar.x86_64 unzip gzip git && \
    yum clean all

# Install latest version of OpenJDK 8
# We do automatic minor version updates, as it can easily be tested
# locally with Docker
RUN yum -y install java-1.8.0-openjdk-devel && \
    yum clean all

# Remove setuid bit from all files
RUN for i in `find / -perm /6000 -type f`; do chmod a-s $i; done

RUN yum install -y which
    # maven
RUN curl --create-dirs -sfSLo maven.tar.gz http://artfiles.org/apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xfz maven.tar.gz && \
    ln -s /root/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/ && \
    rm maven.tar.gz

    # sbt
 RUN curl -sfSL https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo && \
    yum install -y sbt-${SBT_VERSION} && \
    echo exit | sbt

    # gradle
 RUN curl --create-dirs -sfSLo gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
    mkdir -p /opt/gradle && \
    unzip -d /opt/gradle gradle.zip && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle  && \
    rm gradle.zip
