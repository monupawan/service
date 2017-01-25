#!/bin/bash

export CONFHOME=/usr/local/cassandra/apache-cassandra-1.1.6/conf
SEED_SERVICE=$2
SEED_SCALE=$3
PEER_SCALE=$4
export STACK_NAME=`curl -s rancher-metadata/latest/self/stack/name`
export CONTAINER_NAME=`curl -s rancher-metadata/latest/self/container/name`
export CONTAINER_IP=`ip addr | grep inet | grep 10.42 | tail -1 | awk '{print $2}' | awk -F\/ '{print $1}'`
echo "SEED_SCALE :$SEED_SCALE"
SEED_SCALE_FIXED=$3

cp /usr/local/cassandra/apache-cassandra-1.1.6/conf/cassandra.yaml.template /usr/local/cassandra/apache-cassandra-1.1.6/conf/cassandra.yaml
generateTokens() {
a=$1
python - << EOF
import os
num=$a
a=1
file=open('/usr/local/cassandra/apache-cassandra-1.1.6/conf/Token.txt','w')
for i in range(0,int(num)):
        d='%d:%d' % (a, (i*(2**127)/num))
        print d
        file.write(str(d))
        file.write('\n')
        a=a+1
file.close()
EOF

}

distributeToken() {

generateTokens $CONTAINERS_CNT
TOKENNUM=1
for container_list in `cat containers_list.txt | grep -i cass*`; do
        container_id=`echo $container_list | cut -d'=' -f2`
        TOKEN=`sed "${TOKENNUM}q;d" $CONFHOME/Token.txt | cut -d':' -f2`
        ssh -o "StrictHostKeyChecking no" $container_id "sed -i.bak '/initial_token:/d' '"$CONFHOME"'/cassandra.yaml; echo "initial_token: $TOKEN" >> "$CONFHOME"/cassandra.yaml"
        if [ $1 = 'seed' ]; then
                ssh -o "StrictHostKeyChecking no" $container_id "sed -i '/seeds:/ s/.$/'",$CONTAINER_IP"'&/' "$CONFHOME"/cassandra.yaml"
        fi

        #ssh -o "StrictHostKeyChecking no" $container_id "pid=\$(ps -aux | grep -i cassandra | grep -v grep | tail -1 | awk '{print \$2}');echo \$pid |xargs kill"
        #ssh -o "StrictHostKeyChecking no" $container_id "sh "$CONFHOME"/../bin/cassandra &"

ssh -o "StrictHostKeyChecking no" $container_id << EOF
pid=\$(ps -aux | grep -i cassandra | grep -v grep | tail -1 | awk '{print \$2}');
echo \$pid |xargs kill
sh "$CONFHOME"/../bin/cassandra &
sleep 30;
pidcnt=\$(ps -aux | grep -i cassandra | grep -v grep | wc -l);
echo \$pidcnt
if [ \$pidcnt -eq 1 ]; then sh "$CONFHOME"/../bin/cassandra & fi
EOF

        TOKENNUM=`expr $TOKENNUM + 1`
done
}

while [ $SEED_SCALE -ne 0 ]
do
        HOST_IP=$(host "$STACK_NAME"_"$SEED_SERVICE"_"$SEED_SCALE" |awk 'NF>1{print $NF}')
        seed_container_name=$seed_container_name","$HOST_IP

        SEED_SCALE=`expr $SEED_SCALE - 1`
done
seed_container_name=`echo "\"${seed_container_name:1}"\"`
sed -i "s/seeds:/seeds: $seed_container_name/g" $CONFHOME/cassandra.yaml

sed -i "s/rpc_address:/rpc_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
sed -i "s/listen_address:/listen_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
#sed -i "s/broadcast_rpc_address:/broadcast_rpc_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
#sed -i "s/broadcast_address:/broadcast_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml

sed -i 's/\-Xss180k/\-Xss'"$JVMMEM"'k/g' $CONFHOME/cassandra-env.sh

mkdir -p /mnt/cassandra/data
mkdir -p /mnt/cassandra/commitlog
mkdir -p /mnt/cassandra/saved_caches

curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
CONTAINERS_CNT=`cat containers_list.txt | grep -i cass* | wc -l`

echo "JVM_OPTS="\"'$JVM_OPTS' -Djava.rmi.server.hostname=$CONTAINER_IP"\"" >> $CONFHOME/cassandra-env.sh

/etc/init.d/ssh start
if [ $1 = 'seed' ]; then
        if [ ${CONTAINER_NAME: -1} -gt $SEED_SCALE_FIXED ]; then
                distributeToken $1
        fi

        if [ ${CONTAINER_NAME: -1} -eq 1 ]; then
                cp -vr /usr/local/aeris_lib/cassandra/* /usr/local/aeris_lib/
                cat /usr/local/aeris_lib/cron.txt > mycron
                crontab mycron
        fi

elif [ $1 = 'peer' ]; then

        if [ ${CONTAINER_NAME: -1} -eq $PEER_SCALE ]; then
                NODES_NUM=`expr $PEER_SCALE + $SEED_SCALE`
                curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
                CONTAINERS_CNT=`cat containers_list.txt | grep -i cass* | wc -l`
                if [ $NODES_NUM -eq $CONTAINERS_CNT ]; then
                        distributeToken $1
                else
                        sleep 30
                        curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
                        CONTAINERS_CNT=`cat containers_list.txt | grep -i cass* | wc -l`
                        distributeToken $1
                fi
        fi

        if [ ${CONTAINER_NAME: -1} -gt $PEER_SCALE ]; then
                for container_list in `cat containers_list.txt | grep $SEED_SERVICE`; do
                        container_id=`echo $container_list | cut -d'=' -f2`
                        SEED_CONTAINER_IP=$SEED_CONTAINER_IP","$(host "$container_id" |awk 'NF>1{print $NF}')
                done

                seed_containers=`echo "\"${SEED_CONTAINER_IP:1}"\"`
                sed -i 's/seeds:.*/seeds:/' /usr/local/cassandra/apache-cassandra-1.1.6/conf/cassandra.yaml
                sed -i "s/seeds:/seeds: $seed_containers/g" /usr/local/cassandra/apache-cassandra-1.1.6/conf/cassandra.yaml
                sed -i "s/listen_address:/listen_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
                sed -i "s/rpc_address:/rpc_address: $CONTAINER_IP/g" $CONFHOME/cassandra.yaml
		sed -i 's/\-Xss180k/\-Xss'"$JVMMEM"'k/g' $CONFHOME/cassandra-env.sh
                distributeToken $1
        fi

fi

#$CONFHOME/../bin/cassandra &
#if [ $? -ne 0 ]; then
#       rm -rf /mnt/cassandra/data/system
#       $CONFHOME/../bin/cassandra &
#       tail -f /var/log/dmesg
#else
        tail -f /var/log/dmesg
#fi

