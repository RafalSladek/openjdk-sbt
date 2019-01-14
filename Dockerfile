FROM amazonlinux:latest

ENV MAVEN_VERSION=3.6.0
ENV SBT_VERSION=1.2.6-0
ENV GRADLE_VERSION=4.10.2

RUN yum fs filter languages en && \
    yum fs filter documentation && \
    yum -y update && \
    yum -y reinstall glibc-common && \
    yum clean all

# Install latest version of OpenJDK 8
# We do automatic minor version updates, as it can easily be tested
# locally with Docker
RUN yum -y install java-1.8.0-openjdk-devel && \
    yum clean all

# Remove setuid bit from all files
RUN for i in `find / -perm /6000 -type f`; do chmod a-s $i; done

RUN yum install -y which && \
    # maven
    curl --create-dirs -sfSLo maven.tar.gz http://artfiles.org/apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xfz maven.tar.gz && \
    ln -s /root/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/ && \
    rm maven.tar.gz && \
    # sbt
    curl -sfSL https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo && \
    yum install -y sbt-${SBT_VERSION} && \
    echo exit | sbt && \
    # gradle
    curl --create-dirs -sfSLo gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
    mkdir -p /opt/gradle && \
    unzip -d /opt/gradle gradle.zip && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle  && \
    rm gradle.zip # && \
    # echo "export PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin:/root/apache-maven-${MAVEN_VERSION}/bin" >> ~/.bash_profile && \
    # echo "export PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin:/root/apache-maven-${MAVEN_VERSION}/bin" >> ~/.bashrc && \
    # echo "export PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin:/root/apache-maven-${MAVEN_VERSION}/bin" >> /etc/profile.d/fizz.sh
 
