FROM java:7
MAINTAINER Pawan Kumar <pawan.s.kumar@impetus.co.in>
RUN apt-get update && apt-get upgrade -y && apt-get install -y python-software-properties software-properties-common openssh-server vim
ADD authorized_keys /root/.ssh/
ADD id_rsa /root/.ssh/
ADD id_rsa.pub /root/.ssh/
RUN chmod 700 /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa.pub
#RUN mkdir /var/run/sshd
RUN mkdir /usr/local/cassandra/
RUN apt-get install -y iputils-ping cron

RUN wget --no-verbose http://archive.apache.org/dist/cassandra/1.1.6/apache-cassandra-1.1.6-bin.tar.gz && tar zxf apache-cassandra*.tar.gz -C /usr/local/cassandra/ && rm -f apache-ca*.tar.gz

ENV CASSANDRA_HOME=/usr/local/cassandra/apache-cassandra-1.1.6
EXPOSE 7000 7001 7199 9042 9160
WORKDIR $CASSANDRA_HOME
ADD cassandra.yaml.template /usr/local/cassandra/apache-cassandra-1.1.6/conf/
ADD start-cass-service.sh  /usr/local/cassandra/apache-cassandra-1.1.6/bin/ 
RUN chmod 755  /usr/local/cassandra/apache-cassandra-1.1.6/bin/start-cass-service.sh
