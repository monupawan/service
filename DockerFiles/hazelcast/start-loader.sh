#!/bin/bash

RESDIR=/usr/local/aeris_lib/resources
SERVICE_NAME=$1
LOADER_SERVICE=$2
SCALE=$3
#SCALE=`expr $SCALE - 1`
export STACK_NAME=`curl -s rancher-metadata/latest/self/stack/name`
echo "Scale :$SCALE"

if [ $CLUSTER_TYPE = 'ETL' ]; then

	
	cp -vr /usr/local/aeris_lib/hazelcastETL/* /usr/local/aeris_lib/
	cat /usr/local/aeris_lib/cron.txt > mycron
	crontab mycron
	
	mkdir -p /mnt/sidelined_replay_events
	mkdir -p /mnt/sidelined_replay_processed
	mkdir -p /mnt/sidelined_replay_logs
	mkdir -p /mnt/aeris_logs/app_logs_errors
	mkdir -p /mnt/aeris_logs

	/usr/local/initial_load_etl.sh &
	java $JVMFLAGS -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=$INITOCFRACTION -XX:MaxHeapFreeRatio=$MAXHEAPFREERATIO -XX:MinHeapFreeRatio=$MINHEAPFREERATIO -cp /usr/local/aeris_lib/aeris-core-1.0.0-jar-with-dependencies.jar -Dhazelcast.config=/usr/local/aeris_lib/resources/hazelcast.xml -Dhazelcast.logging.type=log4j -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1010 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dhazelcast.jmx=true -Dlog4j.configuration=file:///usr/local/aeris_lib/resources/cache-server-log4j.properties com.aeris.core.util.cache.StartCacheInstance

elif [ $CLUSTER_TYPE = 'NONETL' ]; then

	
	cp -vr /usr/local/aeris_lib/hazelcastNONETL/* /usr/local/aeris_lib/
	cat /usr/local/aeris_lib/cron.txt > mycron
	crontab mycron

	mkdir -p /mnt/aeris_logs
	/usr/local/initial_load_nonetl.sh &
	java $JVMFLAGS -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=$INITOCFRACTION -XX:MaxHeapFreeRatio=$MAXHEAPFREERATIO -XX:MinHeapFreeRatio=$MINHEAPFREERATIO -cp /usr/local/aeris_lib/aeris-core-1.0.0-jar-with-dependencies.jar -Dhazelcast.config=/usr/local/aeris_lib/resources/offlinehazelcast.xml -Dhazelcast.logging.type=log4j -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1010 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dhazelcast.jmx=true -Dlog4j.configuration=file:///usr/local/aeris_lib/resources/cache-server-log4j.properties com.aeris.core.util.cache.StartCacheInstance

fi

