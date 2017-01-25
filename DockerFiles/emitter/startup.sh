#!/bin/bash

cp -vr /usr/local/aeris_lib/emitter/* /usr/local/aeris_lib/


SCRIPT_PATH=/usr/local/aeris_lib/scripts

curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
rabbitmq_stack_name=`echo $RabbitMq_SERVICE | cut -d'/' -f1`

rmq_container_name1=`cat containers_list.txt | grep $rabbitmq_stack_name | sed -n 1p | cut -d'=' -f2`
rmq_container_name2=`cat containers_list.txt | grep $rabbitmq_stack_name | sed -n 2p | cut -d'=' -f2`
echo "$rmq_container_name1"
echo "$rmq_container_name2"

cd $SCRIPT_PATH
find . -type f -print0 | xargs -0 -n 1 sed -i -e 's/rabbit1/'"$rmq_container_name1"'/g'
find . -type f -print0 | xargs -0 -n 1 sed -i -e 's/rabbit2/'"$rmq_container_name2"'/g'


cat /usr/local/aeris_lib/cron.txt > mycron
crontab mycron
tail -f /var/log/dmesg
