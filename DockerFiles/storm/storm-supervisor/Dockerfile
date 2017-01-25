FROM 035824440926.dkr.ecr.us-east-1.amazonaws.com/nrt/storm:base
MAINTAINER Pawan Kumar
RUN apt-get install -y cron
RUN mkdir -p /var/run/sshd
EXPOSE 6700
EXPOSE 6701
EXPOSE 6702
EXPOSE 6703
EXPOSE 8000

ADD start-supervisor.sh /usr/bin/
ADD storm.yaml $STORM_HOME/conf/
RUN chmod +x /usr/bin/start-*.sh
RUN /usr/bin/config-supervisord.sh supervisor
RUN /usr/bin/config-supervisord.sh logviewer
CMD /usr/bin/start-supervisor.sh




