#!/bin/bash

CONFHOME=/usr/local/apache-cassandra-2.2.4/conf
SEED_SERVICE=$2
SEED_SCALE=$3

export STACK_NAME=`curl -s rancher-metadata/latest/self/stack/name`
CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name`
CONTAINER_IP=`ip addr | grep inet | grep 10.42 | tail -1 | awk '{print $2}' | awk -F\/ '{print $1}'`
echo "SEED_SCALE :$SEED_SCALE"
SEED_SCALE_FIXED=$3

cp $CONFHOME/cassandra.yaml.template $CONFHOME/cassandra.yaml

while [ $SEED_SCALE -ne 0 ]
do
        HOST_IP=$(host "$STACK_NAME"_"$SEED_SERVICE"_"$SEED_SCALE" |awk 'NF>1{print $NF}')
        seed_container_name=$seed_container_name","$HOST_IP

        SEED_SCALE=`expr $SEED_SCALE - 1`
done
seed_container_name=`echo "\"${seed_container_name:1}"\"`
sed -i "s/seeds:/seeds: $seed_container_name/g" $CONFHOME/cassandra.yaml

#sed -i "s/rpc_address:/rpc_address: $CONTAINER_NAME/g" $CONFHOME/cassandra.yaml
sed -i "s/listen_address:/listen_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
sed -i "s/broadcast_rpc_address:/broadcast_rpc_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
sed -i "s/broadcast_address:/broadcast_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml

sed -i 's/\-Xss180k/\-Xss'"$JVMMEM"'k/g' $CONFHOME/cassandra-env.sh

/etc/init.d/ssh start
if [ $1 = 'seed' ]; then
        if [ ${CONTAINER_NAME: -1} -gt $SEED_SCALE_FIXED ]; then
                #CONTAINER_IP=$(host "$CONTAINER_NAME" |awk 'NF>1{print $NF}')
                sed -i '/seeds:/ s/.$/'",$CONTAINER_IP"'&/' /usr/local/apache-cassandra-2.2.4/conf/cassandra.yaml

                curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt

                for container_list in `cat containers_list.txt | grep $STACK_NAME`; do
                        container_id=`echo $container_list | cut -d'=' -f2`
                        if [ $container_id != $CONTAINER_NAME ]; then
                                ssh -o "StrictHostKeyChecking no" $container_id "sed -i '/seeds:/ s/.$/'",$CONTAINER_IP"'&/' /usr/local/apache-cassandra-2.2.4/conf/cassandra.yaml"
                                ssh -o "StrictHostKeyChecking no" $container_id "pid=\$(ps -aux | grep -i cassandra | grep -v grep | tail -1 | awk '{print \$2}');echo \$pid |xargs kill;sh /usr/local/apache-cassandra-2.2.4/bin/cassandra &"
                        fi
                done
        fi
        if [ ${CONTAINER_NAME: -1} -eq 1 ]; then
                cp -vr /usr/local/aeris_lib/cassandra/* /usr/local/aeris_lib/
                cat /usr/local/aeris_lib/cron.txt > mycron
                crontab mycron
        fi

elif [ $1 = 'peer' ]; then

        curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
        for container_list in `cat containers_list.txt | grep $SEED_SERVICE`; do
                container_id=`echo $container_list | cut -d'=' -f2`
                if [ ${container_id: -1} -gt $SEED_SCALE_FIXED ]; then
                        SEED_CONTAINER_IP=$(host "$container_id" |awk 'NF>1{print $NF}')
                        sed -i '/seeds:/ s/.$/'",$SEED_CONTAINER_IP"'&/' /usr/local/apache-cassandra-2.2.4/conf/cassandra.yaml
                fi
        done

fi


mkdir -p /mnt/cassandra/data
mkdir -p /mnt/cassandra/commitlog
mkdir -p /mnt/cassandra/saved_caches

$CONFHOME/../bin/cassandra &
if [ $? -ne 0 ]; then
        rm -rf /mnt/cassandra/data/system
        $CONFHOME/../bin/cassandra &
        tail -f /var/log/dmesg
else
        tail -f /var/log/dmesg
fi
