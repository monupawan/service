FROM java:8-jre
MAINTAINER Pawan Kumar
RUN apt-get update && apt-get upgrade -y && apt-get install -y python-software-properties software-properties-common openssh-server vim

# add ping for checkrancher function in entrypoint
RUN apt-get install -y iputils-ping

RUN wget --no-verbose https://archive.apache.org/dist/nifi/1.1.0/nifi-1.1.0-bin.tar.gz && tar zxf nifi*.tar.gz -C /usr/local/ && rm -f nifi*.tar.gz


ENV NIFI_HOME=/usr/local/nifi-1.1.0
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# web port
EXPOSE 8080
# listen port for web listening processor
EXPOSE 8081
# additional ports for user apps (bind them in a docker-compose.yml 'ports' section)
EXPOSE 10000
EXPOSE 10001
EXPOSE 10002
EXPOSE 10003
EXPOSE 10004

WORKDIR $NIFI_HOME
ADD run.sh /usr/local/nifi-1.1.0/bin/
ADD zookeeper.properties.temp /usr/local/nifi-1.1.0/conf/
ADD nifi.properties.template /usr/local/nifi-1.1.0/conf/
RUN chmod +x /usr/local/nifi-1.1.0/bin/run.sh
#ENTRYPOINT ["./run.sh"]
