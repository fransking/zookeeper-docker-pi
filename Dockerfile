
# Based on https://github.com/wurstmeister/zookeeper-docker/blob/master/Dockerfile

ARG zookeeper_version=3.4.14

FROM adoptopenjdk/openjdk8:debian-slim as BUILD

ARG zookeeper_version
ENV ZOOKEEPER_VERSION=$zookeeper_version

RUN set -ex; \
    apt-get update; \
    apt-get -y install wget gpg; \
    rm -rf /var/lib/apt/lists/*

#Download Zookeeper
RUN wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz; \
    wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz.sha512 \
    wget -q https://www.apache.org/dist/zookeeper/KEYS; \
    wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz.asc

#Verify download
RUN sha512sum -c zookeeper-${ZOOKEEPER_VERSION}.tar.gz.sha512; \
    gpg --import KEYS; \
    gpg --verify zookeeper-${ZOOKEEPER_VERSION}.tar.gz.asc


FROM adoptopenjdk/openjdk8:debian-slim

ARG zookeeper_version
ENV ZOOKEEPER_VERSION=$zookeeper_version

#Install
COPY --from=BUILD zookeeper-${ZOOKEEPER_VERSION}.tar.gz /
RUN tar -xzf zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C /opt; \
    rm zookeeper-${ZOOKEEPER_VERSION}.tar.gz

#Configure
RUN mv /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo_sample.cfg /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo.cfg

ENV ZK_HOME /opt/zookeeper-${ZOOKEEPER_VERSION}
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh 
EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper-${ZOOKEEPER_VERSION}
VOLUME ["/opt/zookeeper-${ZOOKEEPER_VERSION}/conf", "/opt/zookeeper-${ZOOKEEPER_VERSION}/data"]

CMD /usr/bin/start-zk.sh