#!/bin/bash

CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name`
sed -i "s/nimbus\.host:/nimbus.host: "\"$1"\"/g" $STORM_HOME/conf/storm.yaml
mkdir -p /usr/local/storm/tmp
echo "storm.local.hostname: "\"$CONTAINER_NAME"\"" >> $STORM_HOME/conf/storm.yaml

curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt

zk_stack_name=`echo $ZK_SERVICE | cut -d'/' -f1`

echo "storm.zookeeper.servers:" >> $STORM_HOME/conf/storm.yaml
for zk_list in `cat containers_list.txt | grep $zk_stack_name`; do
 echo " - ""\"`echo $zk_list | cut -d'=' -f2`"\" >> $STORM_HOME/conf/storm.yaml
done
cp -vr /usr/local/aeris_lib/storm/* /usr/local/aeris_lib/
cat /usr/local/aeris_lib/cron.txt > mycron
crontab mycron

/usr/sbin/sshd && supervisord
