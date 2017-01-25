#!/bin/bash

RESDIR=/usr/local/aeris_lib/resources
SERVICE_NAME=$1
LOADER_SERVICE=$2
SCALE=$3
#SCALE=`expr $SCALE - 1`
export STACK_NAME=`curl -s rancher-metadata/latest/self/stack/name`
echo "Scale :$SCALE"

/usr/local/tomcat/bin/startup.sh


if [ $CLUSTER_TYPE = 'ETL' ]; then

	cp $RESDIR/hazelcast.xml.template $RESDIR/hazelcast.xml

	while [ $SCALE -ne 0 ]
	do
		sed '/<tcp-ip enabled="true">/a <member>'"$STACK_NAME"'_'"$LOADER_SERVICE"'_'"$SCALE"'</member>' $RESDIR/hazelcast.xml > $RESDIR/hazelcast.xml.tmp
		cp $RESDIR/hazelcast.xml.tmp $RESDIR/hazelcast.xml
		SCALE=`expr $SCALE - 1`
	done


	sed '/<tcp-ip enabled="true">/a <member>'"$STACK_NAME"'_'"$SERVICE_NAME"'_1</member>' $RESDIR/hazelcast.xml > $RESDIR/hazelcast.xml.tmp
	cp $RESDIR/hazelcast.xml.tmp $RESDIR/hazelcast.xml
	rm $RESDIR/hazelcast.xml.tmp

	sed -i -e 's/%hazelcast-man%/'"$STACK_NAME"'_'"$SERVICE_NAME"'_1/g' $RESDIR/hazelcast.xml
	
	cp $RESDIR/cassandra-cluster.properties.template $RESDIR/cassandra-cluster.properties
	curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
	cassandra_stack_name=`echo $Cassandra_SERVICE | cut -d'/' -f1`

	for cass_list in `cat containers_list.txt | grep $cassandra_stack_name`; do
	 cass_container_name=$cass_container_name","`echo $cass_list | cut -d'=' -f2`
	 echo "$cass_container_name"
	done
	cass_container_name=${cass_container_name:1}
	
	sed -i "s/cassandra\.cluster=/cassandra.cluster=$cass_container_name/g" $RESDIR/cassandra-cluster.properties
	
	cp -vr /usr/local/aeris_lib/hazelcastETL/* /usr/local/aeris_lib/
	
	java $JVMFLAGS -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=$INITOCFRACTION -XX:MaxHeapFreeRatio=$MAXHEAPFREERATIO -XX:MinHeapFreeRatio=$MINHEAPFREERATIO -cp /usr/local/aeris_lib/aeris-core-1.0.0-jar-with-dependencies.jar -Dhazelcast.config=/usr/local/aeris_lib/resources/hazelcast.xml -Dhazelcast.logging.type=log4j -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1010 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dhazelcast.jmx=true -Dlog4j.configuration=file:///usr/local/aeris_lib/resources/cache-server-log4j.properties com.aeris.core.util.cache.StartCacheInstance

elif [ $CLUSTER_TYPE = 'NONETL' ]; then

	cp $RESDIR/offlinehazelcast.xml.template $RESDIR/offlinehazelcast.xml

	while [ $SCALE -ne 0 ]
	do
			sed '/<tcp-ip enabled="true">/a <member>'"$STACK_NAME"'_'"$LOADER_SERVICE"'_'"$SCALE"'</member>' $RESDIR/offlinehazelcast.xml > $RESDIR/offlinehazelcast.xml.tmp
			cp $RESDIR/offlinehazelcast.xml.tmp $RESDIR/offlinehazelcast.xml
			SCALE=`expr $SCALE - 1`
	done


	sed '/<tcp-ip enabled="true">/a <member>'"$STACK_NAME"'_'"$SERVICE_NAME"'_1</member>' $RESDIR/offlinehazelcast.xml > $RESDIR/offlinehazelcast.xml.tmp
	cp $RESDIR/offlinehazelcast.xml.tmp $RESDIR/offlinehazelcast.xml
	rm $RESDIR/offlinehazelcast.xml.tmp

	sed -i -e 's/%hazelcast-man%/'"$STACK_NAME"'_'"$SERVICE_NAME"'_1/g' $RESDIR/offlinehazelcast.xml
	cp -vr /usr/local/aeris_lib/hazelcastNONETL/* /usr/local/aeris_lib/

	java $JVMFLAGS -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=$INITOCFRACTION -XX:MaxHeapFreeRatio=$MAXHEAPFREERATIO -XX:MinHeapFreeRatio=$MINHEAPFREERATIO -cp /usr/local/aeris_lib/aeris-core-1.0.0-jar-with-dependencies.jar -Dhazelcast.config=/usr/local/aeris_lib/resources/offlinehazelcast.xml -Dhazelcast.logging.type=log4j -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1010 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dhazelcast.jmx=true -Dlog4j.configuration=file:///usr/local/aeris_lib/resources/cache-server-log4j.properties com.aeris.core.util.cache.StartCacheInstance

fi
