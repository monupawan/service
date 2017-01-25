#!/bin/bash

export IP=`hostname -i`
CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name`
#sed -i -e "s/%zookeeper%/$ZK_PORT_2181_TCP_ADDR/g" $STORM_HOME/conf/storm.yaml
#sed -i -e "s/%nimbus%/$IP/g" $STORM_HOME/conf/storm.yaml
sed -i "s/nimbus\.host:/nimbus.host: "\"$CONTAINER_NAME"\"/g" $STORM_HOME/conf/storm.yaml

echo "storm.local.hostname: $CONTAINER_NAME" >> $STORM_HOME/conf/storm.yaml

RESOURCES_PATH=/usr/local/aeris_lib/resources
mkdir -p /usr/local/storm/tmp
cp -vr /usr/local/aeris_lib/storm/* /usr/local/aeris_lib/

cp $RESOURCES_PATH/cache-server.properties.template $RESOURCES_PATH/cache-server.properties
cp $RESOURCES_PATH/kafka-config.properties.template $RESOURCES_PATH/kafka-config.properties
cp $RESOURCES_PATH/rabbitmq.properties.template $RESOURCES_PATH/rabbitmq.properties
#cp $RESOURCES_PATH/cassandra-cluster.properties.template $RESOURCES_PATH/cassandra-cluster.properties

curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt

zk_stack_name=`echo $ZK_SERVICE | cut -d'/' -f1`
kafka_stack_name=`echo $Kafka_SERVICE | cut -d'/' -f1`
hazeletl_stack_name=`echo $HazelcastETL_SERVICE | cut -d'/' -f1`
hazelnonetl_stack_name=`echo $HazelcastNONETL_SERVICE | cut -d'/' -f1`
rabbitmq_stack_name=`echo $RabbitMq_SERVICE | cut -d'/' -f1`
#cassandra_stack_name=`echo $Cassandra_SERVICE | cut -d'/' -f1`


for hazeletl_list in `cat containers_list.txt | grep $hazeletl_stack_name`; do
 hazeletl_container_name=$hazeletl_container_name","`echo $hazeletl_list | cut -d'=' -f2`":5701"
 echo "$hazeletl_container_name"
done
hazeletl_container_name=${hazeletl_container_name:1}
sed -i "s/cache\.server=/cache.server=$hazeletl_container_name/g" $RESOURCES_PATH/cache-server.properties

for hazelnonetl_list in `cat containers_list.txt | grep $hazelnonetl_stack_name`; do
 hazelnonetl_container_name=$hazelnonetl_container_name","`echo $hazelnonetl_list | cut -d'=' -f2`
 echo "$hazelnonetl_container_name"
done
hazelnonetl_container_name=${hazelnonetl_container_name:1}
sed -i "s/cache\.server\.offline\.alerts=/cache.server.offline.alerts=$hazelnonetl_container_name/g" $RESOURCES_PATH/cache-server.properties

for kafka_list in `cat containers_list.txt | grep $kafka_stack_name`; do
 kafka_container_name=$kafka_container_name","`echo $kafka_list | cut -d'=' -f2`":9092"
 echo "$kafka_container_name"
done
kafka_container_name=${kafka_container_name:1}
sed -i "s/metadata\.broker\.list=/metadata.broker.list=$kafka_container_name/g" $RESOURCES_PATH/kafka-config.properties

echo "storm.zookeeper.servers:" >> $STORM_HOME/conf/storm.yaml
for zk_list in `cat containers_list.txt | grep $zk_stack_name`; do
 echo " - ""\"`echo $zk_list | cut -d'=' -f2`"\" >> $STORM_HOME/conf/storm.yaml
 zk_container_name=$zk_container_name","`echo $zk_list | cut -d'=' -f2`":2181"
 echo "$zk_container_name"
done
zk_container_name=${zk_container_name:1}
sed -i "s/kafka\.broker\.zk\.hosts=/kafka.broker.zk.hosts=$zk_container_name/g" $RESOURCES_PATH/kafka-config.properties




for rabbitmq_list in `cat containers_list.txt | grep $rabbitmq_stack_name`; do
 rmq_container_name=$rmq_container_name","`echo $rabbitmq_list | cut -d'=' -f2`
 echo "$rmq_container_name"
done
rmq_container_name=${rmq_container_name:1}
sed -i "s/queue\.addresses=/queue.addresses=$rmq_container_name/g" $RESOURCES_PATH/rabbitmq.properties

#for cass_list in `cat containers_list.txt | grep $cassandra_stack_name`; do
# cass_container_name=$cass_container_name","`echo $cass_list | cut -d'=' -f2`
# echo "$cass_container_name"
#done
#cass_container_name=${cass_container_name:1}
#sed -i "s/cassandra\.cluster=/cassandra.cluster=$cass_container_name/g" $RESOURCES_PATH/cassandra-cluster.properties
cat /usr/local/aeris_lib/cron.txt > mycron
crontab mycron
/etc/init.d/cron start

/usr/bin/deploy_topologies.sh &
/usr/sbin/sshd && supervisord


