# docker部署hbase集群

### 1. 安装docker  
* `wget https://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-1.12.6-1.el7.centos.x86_64.rpm`  
* `wget https://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-selinux-1.12.6-1.el7.centos.noarch.rpm`  
* `yum localinstall -y dokcer-engine*`  
* `systemctl daemon-reload`  
* `systemctl strart docker`  

### 2. 创建桥接网络  
 * `docker network create --driver bridge --subnet=172.18.0.0/24 --gateway=172.18.0.1 hadoop`
 
### 3. 加载image（包太大上传不了）  
* `docker load < docker-hbase-3.0.tar`  

### 4. 创建目录作为hadoop的数据节点
* `mkdir -p /home/hdfs/data/namenode`  
* `mkdir -p /home/hdfs/data/datanode1`  
* `mkdir -p /home/hdfs/data/datanode2`  
* `mkdir -p /home/hdfs/data/datanode3`

### 5. 启动一个容器作为hadoop master节点  
* `docker run -it --name hadoop-master -h hadoop-master -d -P -p 50070:50070 -p 8088:8088 -p 60010:60010 -v /home/hdfs:/home/hdfs --network=mynet --ip 172.18.0.100 --add-host hadoop-slave1:172.18.0.101 --add-host hadoop-slave2:172.18.0.102 --add-host hadoop-slave3:172.18.0.103 haohan/hbase:3.0`

### 6. 启动三个容器作为hadoop slave节点(N=1,2,3)  
* `docker run -it --name hadoop-slave1 -h hadoop-slave1 -d -v /home/hdfs:/home/hdfs --network=mynet --ip 172.18.0.101  --add-host hadoop-master:172.18.0.100  --add-host hadoop-slave2:172.18.0.102 --add-host hadoop-slave3:172.18.0.103 haohan/hbase:3.0`  

* `docker run -it --name hadoop-slave2 -h hadoop-slave2 -d -v /home/hdfs:/home/hdfs --network=mynet --ip 172.18.0.102  --add-host hadoop-master:172.18.0.100 --add-host hadoop-slave1:172.18.0.101 --add-host hadoop-slave3:172.18.0.103 haohan/hbase:3.0`    

* `docker run -it --name hadoop-slave3 -h hadoop-slave3 -d -v /home/hdfs:/home/hdfs --network=mynet --ip 172.18.0.103  --add-host hadoop-master:172.18.0.100 --add-host hadoop-slave1:172.18.0.101 --add-host hadoop-slave2:172.18.0.102 haohan/hbase:3.0`

### 7. 进入hadoop slave容器，修改hadoop配置文件，修改zookeeper的myid文件并启动zookeeper服务(N=1,2,3)
* `docker exec -it -u root hadoop-slaveN /bin/bash`      
* `vim /usr/local/hadoop/etc/hadoop/hdfs-site.xml` 
```
<configuration>   
    <property>  
        <name>dfs.datanode.data.dir</name>  
        <value>file:/home/hdfs/data/datanodeN</value>  
    </property>   
</configuration> 
```

* `echo N > /usr/local/zookeeper/data/myid`  
* `/usr/local/zookeeper/bin/zkServer.sh start`

### 8. 进入hadoop-master容器，启动hadoop服务  
* `docker exec -it -u root hadoop-master /bin/bash`
* `hdfs namenode -format`(namenode格式化，第一次启动集群之前需要执行)  
* `/usr/local/hadoop/sbin/start-dfs.sh`  
* `/usr/local/hadoop/sbin/start-yarn.sh` 

### 9. 启动和停止hbase服务
* `start-hbase.sh`  
* `stop-hbase.sh`
