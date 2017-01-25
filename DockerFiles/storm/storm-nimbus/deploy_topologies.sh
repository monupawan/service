#!/bin/bash

sleep 10m

/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-aaa-6.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor AAA
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-lte-pgw-cdr-2.0-jar-with-dependencies.jar com.aeris.pgw.cdr.topology.PgwCdrEventProcessor PGW-CDR 
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-cdr-6.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor CDR
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-hlr-6.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor HLR
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-gsm-hlr-3.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor GSM-HLR
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-lte-hss-2.0-jar-with-dependencies.jar com.aeris.hss.topology.HssEventProcessor HSS
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-smpp-5.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor SMPP
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-tap-3.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor TAP
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-aerCloud-publisher-2.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-alerts-2.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor
/usr/local/apache-storm-0.9.3/bin/storm jar /usr/local/aeris_lib/aeris-nrt-engine-ciber-5.0-jar-with-dependencies.jar com.aeris.storm.topology.EventProcessor CIBER
