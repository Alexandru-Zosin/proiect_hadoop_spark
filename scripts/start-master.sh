#!/bin/bash

cat > $HADOOP_HOME/etc/hadoop/core-site.xml <<EOF
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://master:9000</value>
  </property>
</configuration>
EOF
# cream core-site.xml si punem in el XML ul de configurare, care indica tuturor
# comenzilor HDFS ca HDFS ul principal este pe hostul master, port 9000

cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>2</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///hadoop/dfs/name</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///hadoop/dfs/data</value>
  </property>
</configuration>
EOF

# ^ fiecare bloc HDFS este copiat pe 2 DataNodes

cat > $SPARK_HOME/conf/spark-defaults.conf <<EOF
spark.master spark://master:7077
spark.eventLog.enabled false
spark.sql.shuffle.partitions 4
spark.executor.memory 1g
spark.executor.cores 1
EOF

if [ ! -d /hadoop/dfs/name/current ]; then
  hdfs namenode -format -force
fi 
# formatare NameNode prima data care creeaza metadata HDFS

hdfs --daemon start namenode # porneste NameNode

sleep 5

$SPARK_HOME/sbin/start-master.sh # porneste Spark Master (!scriptul oficial Spark! si NU FISIERUL ASTA start-master)

# pornire jupyter
jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --NotebookApp.token='' \
  --NotebookApp.password=''