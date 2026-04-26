# Template de 'VM' cu tot ce trebuie instalat: Ubuntu, Java, Hadoop, Spark,
# Python, Jupyter, biblioteci Python, scripturi de pornire
#
# Imagine reproductibila creata de DockerFile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV HADOOP_VERSION=3.5.0
ENV SPARK_VERSION=3.5.8
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-*-src.zip:$PYTHONPATH
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# openjdk pt. Hadoop, Spark, py+pip pt. notebooks, wget/curl descarcare Hadoop/Spark
# ssh/rsync pt. tooluri H/S, # procps/net-tools pt. debugging
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    openjdk-17-jdk-headless \
    python3 \
    python3-pip \
    wget \
    curl \
    openssh-client \
    openssh-server \
    rsync \
    net-tools \
    procps \
    netcat-openbsd \
    nano \
    && rm -rf /var/lib/apt/lists/*

# copiaza hadoop si spark descarcate (tar.gz) si le pune in pathul convenit mai sus (hadoop home)
COPY hadoop-3.5.0.tar.gz /tmp/hadoop-3.5.0.tar.gz
COPY spark-3.5.8-bin-hadoop3.tgz /tmp/spark-3.5.8-bin-hadoop3.tgz

RUN tar -xzf /tmp/hadoop-3.5.0.tar.gz -C /opt \
    && mv /opt/hadoop-3.5.0 /opt/hadoop \
    && rm /tmp/hadoop-3.5.0.tar.gz

RUN tar -xzf /tmp/spark-3.5.8-bin-hadoop3.tgz -C /opt \
    && mv /opt/spark-3.5.8-bin-hadoop3 /opt/spark \
    && rm /tmp/spark-3.5.8-bin-hadoop3.tgz

# biblioteci pt. eda, ML, grafice, parquet (pyarrow)
RUN pip3 install \
    pyspark==3.5.8 \
    py4j \
    ipykernel \ 
    jupyterlab \
    pandas \
    numpy \
    matplotlib \
    pyarrow \
    scikit-learn

RUN python3 -m ipykernel install --user --name python3 --display-name "Python 3"

# name -> metadata NameNode, /data -> blocuri dataNode, /data fisiere din host
RUN mkdir -p /hadoop/dfs/name /hadoop/dfs/data /opt/hadoop/logs /notebooks /data

# copiere scripturi de pe PC si schimbarea privilegiilor pt a permite executarea lor
# (dockerfile le copiaza automat la build)
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

WORKDIR /notebooks