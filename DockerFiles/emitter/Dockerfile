FROM java:7
MAINTAINER Pawan Kumar
RUN apt-get update && apt-get upgrade -y && apt-get install -y python-software-properties software-properties-common openssh-server vim
RUN apt-get install -y iputils-ping
ADD startup.sh /
RUN chmod +x /startup.sh
CMD /startup.sh
