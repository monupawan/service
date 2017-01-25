FROM 035824440926.dkr.ecr.us-east-1.amazonaws.com/nrt/tomcat:5

RUN apt-get update && apt-get install -y cron vim
ENV SERVICE_HOME=/usr/local/tomcat/bin

ADD start-mancenter-loader.sh /usr/local/tomcat/bin/
ADD start-loader.sh /usr/local/tomcat/bin/
ADD mancenter-3.4.6.war ${SERVICE_HOME}/../webapps/	  
ADD initial_load_etl.sh /usr/local/
ADD initial_load_nonetl.sh /usr/local/
RUN chmod +x /usr/local/tomcat/bin/start*.sh /usr/local/initial_load_etl.sh /usr/local/initial_load_nonetl.sh
WORKDIR $SERVICE_HOME

EXPOSE 8080 22
