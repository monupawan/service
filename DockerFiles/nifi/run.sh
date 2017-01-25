#!/bin/bash
export HOSTNAME=`curl -s rancher-metadata/latest/self/container/name`
CLUSTER_MANAGER=$1

#export HOSTNAME=`hostname`
#NIFI_INSTANCE_ROLE="cluster-node"

splash() {
  echo 'Environment:'
  echo "NIFI_UI_BANNER_TEXT=$NIFI_UI_BANNER_TEXT"
}

configure_common() {
  sed -i 's/\.\/flowfile_repository/\/flowrepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/content_repository/\/contentrepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/conf\/flow\.xml\.gz/\/flowconf\/flow.xml.gz/' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/conf\/archive/\/flowconf\/archive/' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/database_repository/\/databaserepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/provenance_repository/\/provenancerepo/g' $NIFI_HOME/conf/nifi.properties
  mkdir -p  $NIFI_HOME/./state/zookeeper
  echo 1 > $NIFI_HOME/./state/zookeeper/myid
  sed -i "s/nifi\.ui\.banner\.text=/nifi.ui.banner.text=${NIFI_UI_BANNER_TEXT}/g" $NIFI_HOME/conf/nifi.properties
}
configureEmbeddedZooKeeper() { 
sed '$ a server.1=nrt_Nifi-ncm_1:2888:3888' $NIFI_HOME/conf/zookeeper.properties
sed '$ a server.2=nrt_Nifi-worker_1:2888:3888' $NIFI_HOME/conf/zookeeper.properties
sed '$ a server.3=nrt_Nifi-worker_2:2888:3888' $NIFI_HOME/conf/zookeeper.properties
}

configure_site2site() {
  # configure the receiving end of site2site
 # sed -i "s/nifi\.remote\.input\.socket\.host=/nifi.remote.input.socket.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.remote\.input\.socket\.port=/nifi.remote.input.socket.port=/g" $NIFI_HOME/conf/nifi.properties
  # unsecure for now so we don't complicate the setup with certificates
  sed -i "s/nifi\.remote\.input\.secure=true/nifi.remote.input.secure=false/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.zookeeper\.connect\.string=/nifi.zookeeper.connect.string=${ZK_HOST}/g" $NIFI_HOME/conf/nifi.properties
}

configure_cluster_node() {
  # can't set to 0.0.0.0, as this address is then sent verbatim to NCM, which, in turn
  # does not resolve it back to the node. If it's set to the ${HOSTNAME}, the cluster works,
  # but the node's web ui is not accessible on the external network
  #sed -i "s/nifi\.web\.http\.host=/nifi.web.http.host=0.0.0.0/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.http\.host=/nifi.web.http.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.http\.port=8080/nifi.web.http.port=8081/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.is\.node=false/nifi.cluster.is.node=true/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.address=/nifi.cluster.node.address=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.protocol\.port=/nifi.cluster.node.protocol.port=8083/g" $NIFI_HOME/conf/nifi.properties
  # the following properties point to the NCM - note we are using the network alias (implicitly created by docker-compose)

  echo " " >> $NIFI_HOME/conf/nifi.properties
  #echo "nifi.cluster.node.unicast.manager.address=$CLUSTER_MANAGER" >> $NIFI_HOME/conf/nifi.properties
  #echo "nifi.cluster.node.unicast.manager.protocol.port=8082" >> $NIFI_HOME/conf/nifi.properties

}

configure_cluster_manager() {
  sed -i "s/nifi\.web\.http\.host=/nifi.web.http.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  #sed -i "s/nifi\.cluster\.is\.manager=false/nifi.cluster.is.manager=true/g" $NIFI_HOME/conf/nifi.properties
  #sed -i "s/nifi\.cluster\.manager\.address=/nifi.cluster.manager.address=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  #sed -i "s/nifi\.cluster\.manager\.protocol\.port=/nifi.cluster.manager.protocol.port=8082/g" $NIFI_HOME/conf/nifi.properties

}

ZK_HOST=127.0.0.1
curl  http://rancher-metadata/2015-07-25/containers > containers_list.txt
zk_stack_name=`echo $ZK_SERVICE | cut -d'/' -f1`

for zk_list in `cat containers_list.txt | grep $zk_stack_name`; do
 zk_container_name=`echo $zk_list | cut -d'=' -f2`
 ZK_HOST=`echo $ZK_HOST,$zk_container_name:2181`
done
cp $NIFI_HOME/conf/nifi.properties.template $NIFI_HOME/conf/nifi.properties
cp $NIFI_HOME/conf/zookeeper.properties.temp $NIFI_HOME/conf/zookeeper.properties
splash
configure_common
configureEmbeddedZooKeeper
# we don't configure acquisition node to serve site-to-site requests,
# the node initiates push/pull only

if [ "$NIFI_INSTANCE_ROLE" == "node" ]; then
  configure_site2site
fi

if [ "$NIFI_INSTANCE_ROLE" == "cluster-node" ]; then
  configure_site2site
  configure_cluster_node
fi

if [ "$NIFI_INSTANCE_ROLE" == "cluster-manager" ]; then
  configure_site2site
  configure_cluster_manager
fi

# must be an exec so NiFi process replaces this script and receives signals
exec $NIFI_HOME/bin/nifi.sh run

