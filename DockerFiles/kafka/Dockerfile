FROM java:7
MAINTAINER Pawan Kumar <monu.pawan@gmail.com>
RUN apt-get update && apt-get install -y python-software-properties software-properties-common openssh-server vim
RUN apt-get install -y iputils-ping monit
# Set environment
ENV SERVICE_HOME=/usr/local/kafka \
    SERVICE_NAME=kafka \
    SCALA_VERSION=2.11 \
    SERVICE_VERSION=0.10.0.0 \
    SERVICE_USER=kafka \
    SERVICE_VOLUME=/opt/tools \
    SERVICE_URL=http://apache.mirrors.spacedump.net/kafka 
ENV SERVICE_RELEASE=kafka_"$SCALA_VERSION"-"$SERVICE_VERSION" \
    SERVICE_CONF=${SERVICE_HOME}/config/server.properties 

# Install and configure kafka
RUN curl -sS -k ${SERVICE_URL}/${SERVICE_VERSION}/${SERVICE_RELEASE}.tgz | gunzip -c - | tar -xf - -C /usr/local \
  && mv /usr/local/${SERVICE_RELEASE} ${SERVICE_HOME} \
  && rm ${SERVICE_CONF} \
  && mkdir ${SERVICE_HOME}/data ${SERVICE_HOME}/logs 
RUN touch /usr/local/kafka/logs/server.log
ADD kafka-service.sh /usr/local/kafka/bin/
ADD server.properties.sh /usr/local/kafka/bin/
ADD monit-service.conf /etc/monit/conf.d/

RUN chmod +x ${SERVICE_HOME}/bin/*.sh 

WORKDIR $SERVICE_HOME

EXPOSE 9092
