#!/bin/bash

# 启动ssh服务
/usr/sbin/sshd -D &

# 启动crond服务
/usr/sbin/crond

if [ -n "${N_NUM}" ]; then
    # 设置zookeeper的myid
    echo ${N_NUM} > /usr/local/zookeeper/data/myid

    # 启动zookeeper
    /usr/local/zookeeper/bin/zkServer.sh start
	
    if [ ! -d "/home/hdfs/data/datanode${N_NUM}" ]; then
        # 设置Hadoop集群的数据目录
        sed -i "s/file:\/\/\/home\/hdfs\/data\/datanode/file:\/\/\/home\/hdfs\/data\/datanode${N_NUM}/g" $HADOOP_HOME/etc/hadoop/hdfs-site.xml

        # 创建Hadoop集群的数据目录
        mkdir -p /home/hdfs/data/datanode${N_NUM}
    fi
else
    # 创建Hadoop集群的namenode目录
    mkdir -p /home/hdfs/data/namenode
fi

/bin/bash
