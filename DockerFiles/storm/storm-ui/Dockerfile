FROM 035824440926.dkr.ecr.us-east-1.amazonaws.com/nrt/storm:base
MAINTAINER Wurstmeister
RUN apt-get install -y cron
RUN mkdir -p /var/run/sshd
RUN /usr/bin/config-supervisord.sh ui
ADD storm.yaml $STORM_HOME/conf/
ADD start-supervisor.sh /usr/bin/
RUN chmod +x /usr/bin/start-supervisor.sh
EXPOSE 8080
CMD /usr/bin/start-supervisor.sh





