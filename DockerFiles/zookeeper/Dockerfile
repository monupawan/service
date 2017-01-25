FROM java:7

RUN apt-get update && apt-get install -y openssh-server 
RUN mkdir /var/run/sshd
ADD id_rsa /root/.ssh/
ADD id_rsa.pub /root/.ssh/
ADD authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa.pub
RUN chmod 700 /root/.ssh/authorized_keys
ENV SERVICE_NAME=zk \
    SERVICE_HOME=/usr/local/zookeeper \
    SERVICE_CONF=/usr/local/zookeeper/conf/zoo.cfg \
    SERVICE_VERSION=3.4.6 \
    PATH=/usr/local/zookeeper/bin:${PATH}

# Install service software
RUN SERVICE_RELEASE=zookeeper-${SERVICE_VERSION} && \
    mkdir -p ${SERVICE_HOME}/logs ${SERVICE_HOME}/data && \
    cd /tmp && \
	wget  http://www-eu.apache.org/dist/zookeeper/${SERVICE_RELEASE}/${SERVICE_RELEASE}.tar.gz && \
    tar -zx -C ${SERVICE_HOME} --strip-components=1 --no-same-owner -f ${SERVICE_RELEASE}.tar.gz && \
	export CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name` && \
	rm -rf /usr/local/zookeeper/conf/zoo.cfg.templete && \
    rm -rf \
      /tmp/* \
      /root/.gnupg \
      /var/cache/apk/* \
      ${SERVICE_HOME}/contrib/fatjar \
      ${SERVICE_HOME}/dist-maven \
      ${SERVICE_HOME}/docs \
      ${SERVICE_HOME}/src \
      ${SERVICE_HOME}/bin/*.cmd

ADD start-zookeeper.sh ${SERVICE_HOME}/bin/
ADD zoo.cfg.template ${SERVICE_HOME}/conf/	  
RUN chmod +x ${SERVICE_HOME}/bin/*.sh 
WORKDIR $SERVICE_HOME

EXPOSE 2181 2888 3888 22

CMD ["/usr/bin/ssh", "-D"] 
