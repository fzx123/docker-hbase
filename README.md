# docker部署hbase集群

### 1. 安装docker，版本要求1.13.1  
 
### 2. 加载image  
* `docker load < docker-hbase.tar`  
 
### 3. 启动一个容器作为hadoop master节点  
* `docker run -it --name hadoop-master -h hadoop-master -d -P -p 50070:50070 -p 8088:8088 -p 60010:60010 -p 8889:8889 -v /data1:/data1 haohan/hbase:1.0`

### 4. 启动三个容器作为hadoop slave节点(N=1,2,3)  
* `docker run -it --name hadoop-slaveN -h hadoop-slaveN -d -v /data1:/data1 haohan/hbase:1.0`  

### 5. 进入hadoop master和hadoop slave容器，修改/etc/hosts文件
* `echo 172.17.0.2 hadoop-master >> /etc/hosts`  
* `echo 172.17.0.3 hadoop-slave1 >> /etc/hosts`  
* `echo 172.17.0.4 hadoop-slave2 >> /etc/hosts`  
* `echo 172.17.0.5 hadoop-slave3 >> /etc/hosts`

### 6. 进入hadoop slave容器，修改zookeeper的myid文件并启动zookeeper服务(N=1,2,3)
* `docker exec -it -u root hadoop-slaveN /bin/bash`  
* `echo N > /usr/local/zookeeper/data/myid`  
* `/usr/local/zookeeper/bin/zkServer.sh start` 

### 7. 进入hadoop-master容器，启动hadoop服务  
* `docker exec -it -u root hadoop-master /bin/bash`
* ***格式化namenode:*** `hdfs namenode -format`  
* ***启动hdfs:*** `/usr/local/hadoop/sbin/start-dfs.sh`  
* ***启动yarn:*** `/usr/local/hadoop/sbin/start-yarn.sh` 

### 8. 启动hbase服务
* ***启动hbase:*** `start-hbase.sh`   
