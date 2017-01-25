#!/bin/bash


RESDIR=/usr/local/zookeeper/conf
CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name`
SERVICE_NAME=`echo "${CONTAINER_NAME::-2}"`
export STACK_NAME=`curl -s rancher-metadata/latest/self/stack/name`
CONTAINER_IP=`ip addr | grep inet | grep 10.42 | tail -1 | awk '{print $2}' | awk -F\/ '{print $1}'`
SCALE_FIXED=$1
SCALE=$1
mkdir -p /var/run/sshd
mkdir -p /usr/local/zookeeper/tmp
mkdir -p /usr/local/zookeeper/logs
service ssh start

echo $SCALE

cp $RESDIR/zoo.cfg.template $RESDIR/zoo.cfg

while [ $SCALE -ne 0 ]
do

	echo "server.$SCALE="$SERVICE_NAME"_$SCALE:2888:3888" >> $RESDIR/zoo.cfg

	SCALE=`expr $SCALE - 1`
done

echo "CONTAINER_NAME : $CONTAINER_NAME"
echo "${CONTAINER_NAME: -1}" > /usr/local/zookeeper/tmp/myid

rm $RESDIR/zoo.cfg.template



if [ ${CONTAINER_NAME: -1} -gt $SCALE_FIXED ]; then
		
		curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
		
		for container_list in `cat containers_list.txt | grep $STACK_NAME`; do
			container_id=`echo $container_list | cut -d'=' -f2`
			if [ $container_id != $CONTAINER_NAME ]; then
				LINE=server."${CONTAINER_NAME: -1}"="$CONTAINER_NAME":2888:3888
				FILE="$RESDIR"/zoo.cfg
				ssh -o "StrictHostKeyChecking no" $container_id "grep -q "$LINE" "$FILE" || echo "$LINE" >> "$FILE"; /usr/local/zookeeper/bin/zkServer.sh restart"
			fi
		done
		echo "server."${CONTAINER_NAME: -1}"="$CONTAINER_NAME":2888:3888" >> $RESDIR/zoo.cfg
		
		SCALE=`expr $SCALE_FIXED + 1`
		
		while [ $SCALE -lt ${CONTAINER_NAME: -1} ]
		do

			echo "server.$SCALE="$SERVICE_NAME"_$SCALE:2888:3888" >> $RESDIR/zoo.cfg

			SCALE=`expr $SCALE + 1`
		done
		
		
fi

/usr/local/zookeeper/bin/zkServer.sh start

cp -vr /usr/local/aeris_lib/zookeeper/* /usr/local/aeris_lib/
cat /usr/local/aeris_lib/cron.txt > mycron
crontab mycron

if [ $? -eq 0 ]; then
/etc/init.d/cron start
tail -f /usr/local/zookeeper/zookeeper.out
fi
