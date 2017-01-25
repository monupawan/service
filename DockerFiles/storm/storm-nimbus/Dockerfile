FROM 035824440926.dkr.ecr.us-east-1.amazonaws.com/nrt/storm:base
MAINTAINER Pawan Kumar
RUN apt-get install -y cron
RUN mkdir -p /var/run/sshd
RUN /usr/bin/config-supervisord.sh nimbus 
RUN /usr/bin/config-supervisord.sh drpc

EXPOSE 6627
EXPOSE 3772
EXPOSE 3773
ADD storm.yaml $STORM_HOME/conf/
ADD start-supervisor.sh /usr/bin/start-supervisor.sh
ADD deploy_topologies.sh /usr/bin/
RUN chmod +x /usr/bin/start-supervisor.sh /usr/bin/deploy_topologies.sh
CMD /usr/bin/start-supervisor.sh
