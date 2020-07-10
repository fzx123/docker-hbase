## Docker部署单机HBase集群

##### 1. 安装并启动docker
```
wget https://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-1.12.6-1.el7.centos.x86_64.rpm

wget https://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-selinux-1.12.6-1.el7.centos.noarch.rpm

yum localinstall -y dokcer-engine*

systemctl daemon-reload

systemctl strart docker  
```

##### 2. 创建桥接网络  
 ```
 docker network create --driver bridge --subnet=172.18.0.0/24 --gateway=172.18.0.1 hadoop
 ```
 
##### 2. 构建镜像

```
./build-image.sh
```

##### 3. 查看镜像

```
docker images
[root@localhost ~]# docker images
REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
haohan/hbase             2.0.0               14f5c375a7b3        18 hours ago        2.119 GB
```

##### 4. 启动容器

```
docker-compose up -d
```

##### 5. **查看容器**

```
docker ps
[root@localhost docker-hbase]# docker ps
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                             NAMES
6517cdf17bf4        haohan/hbase:2.0.0   "/bin/bash /root/star"   3 months ago        Up 6 weeks                                                            hadoop-slave1
8fdbf4b18f49        haohan/hbase:2.0.0   "/bin/bash /root/star"   3 months ago        Up 6 weeks                                                            hadoop-slave3
94ba1a2248c0        haohan/hbase:2.0.0   "/bin/bash /root/star"   3 months ago        Up 6 weeks                                                            hadoop-master
ac97dfe32af9        haohan/hbase:2.0.0   "/bin/bash /root/star"   3 months ago        Up 6 weeks                                                            hadoop-slave2
```

##### 6. 进入hadoop-master容器

```
docker exec -it -u root hadoop-master /bin/bash
```

`以下命令在hadoop-master容器内执行`

##### 7. 格式化namenode

```
hdfs namenode -format
```

##### 8. 启动Hadoop集群

```
./start-hadoop.sh
```

##### 9. 启动HBase集群

```
start-hbase.sh
```

------

#### 其他命令

#####  导出镜像

```
docker save -o docker-hbase-2.0.0.tar docker/hbase:2.0.0
```

##### 停止Hadoop集群

```
./stop-hadoop.sh
```

##### 停止HBase集群

```
stop-hbase.sh
```


