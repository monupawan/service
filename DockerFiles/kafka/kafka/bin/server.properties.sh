KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-${SERVICE_HOME}"/logs"}
KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}
KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}
KAFKA_ZK_HOST=${KAFKA_ZK_HOST:-"127.0.0.1"}
KAFKA_ZK_PORT=${KAFKA_ZK_PORT:-"2181"}
KAFKA_EXT_IP=${KAFKA_EXT_IP:-""}
KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}
KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:${KAFKA_ADVERTISE_PORT}"}

if [ "$KAFKA_EXT_IP" == "" ]; then
        KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-${KAFKA_LISTENER}}
else
        KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-"PLAINTEXT://"${KAFKA_EXT_IP}":"${KAFKA_ADVERTISE_PORT}}
fi

curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
zk_stack_name=`echo $ZK_SERVICE | cut -d'/' -f1`

for zk_list in `cat containers_list.txt | grep $zk_stack_name`; do
 zk_container_name=`echo $zk_list | cut -d'=' -f2`
 KAFKA_ZK_HOST=`echo $KAFKA_ZK_HOST,$zk_container_name:$KAFKA_ZK_PORT`
done

export CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name`
BROKER_ID=`echo ${CONTAINER_NAME: -1}`

cat << EOF > ${SERVICE_CONF}
############################# Server Basics #############################
broker.id=${BROKER_ID}
############################# Socket Server Settings #############################
listeners=${KAFKA_LISTENER}
advertised.listeners=${KAFKA_ADVERTISE_LISTENER}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
############################# Log Basics #############################
log.dirs=${KAFKA_LOG_DIRS}
num.partitions=${KAFKA_NUM_PARTITIONS}
num.recovery.threads.per.data.dir=1
delete.topic.enable=false
############################# Log Flush Policy #############################
#log.flush.interval.messages=10000
#log.flush.interval.ms=1000
############################# Log Retention Policy #############################
log.retention.hours=${KAFKA_LOG_RETENTION_HOURS}
#log.retention.bytes=1073741824
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
log.cleaner.enable=true
############################# Connect Policy #############################
zookeeper.connect=${KAFKA_ZK_HOST}
zookeeper.connection.timeout.ms=6000
EOF

