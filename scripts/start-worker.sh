#!/bin/bash

until nc -z master 9000; do
  echo "Waiting for HDFS NameNode on master:9000..."
  sleep 2
done

until nc -z master 7077; do
  echo "Waiting for Spark Master on master:7077..."
  sleep 2
done

cat > $HADOOP_HOME/etc/hadoop/core-site.xml <<EOF
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://master:9000</value>
  </property>
</configuration>
EOF

# configureaza workerul sa stie unde este HDFS

cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>2</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///hadoop/dfs/data</value>
  </property>
</configuration>
EOF

hdfs --daemon start datanode
$SPARK_HOME/sbin/start-worker.sh spark://master:7077

# porneste spark wrker si il conecteaza la spark master 

tail -f /dev/null # urmareste fisierul (nu face munca reala ci tine contianerul viu,
# daca scriptul s-ar incheia, Docker ar opri containerul)