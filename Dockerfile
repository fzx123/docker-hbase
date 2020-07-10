FROM centos:7.6.1810

MAINTAINER fangzhongxiang <fangzhongxiang@haohandata.com.cn>

WORKDIR /root

# install openssh、crond and wget
RUN yum -y update && \
    yum install -y openssl && \
    yum install -y openssh-server && \
    yum install -y openssh-clients && \
    yum install -y cronie && \
    yum install -y crontabs && \	
    yum install -y wget && \
    yum install -y which && \
    yum clean all

COPY lib/* /tmp/ 

# install jdk 1.8、hadoop 2.7.7、hbase 2.0.0 and zookeeper 3.4.6
RUN tar -xzvf /tmp/jdk-8u181-linux-x64.tar.gz -C /usr/local/ && \
    rm -rf /tmp/jdk-8u181-linux-x64.tar.gz && \
    tar -xzvf /tmp/hadoop-2.7.7.tar.gz -C /usr/local/ && \
    mv /usr/local/hadoop-2.7.7 /usr/local/hadoop && \
    rm -rf /tmp/hadoop-2.7.7.tar.gz && \
    tar -xzvf /tmp/hbase-2.0.0-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/hbase-2.0.0 /usr/local/hbase && \
    rm -rf /tmp/hbase-2.0.0-bin.tar.gz && \
    tar -xzvf /tmp/zookeeper-3.4.6.tar.gz -C /usr/local/ && \
    mv /usr/local/zookeeper-3.4.6 /usr/local/zookeeper && \
    rm -rf /tmp/zookeeper-3.4.6.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/local/jdk1.8.0_181
ENV HADOOP_HOME=/usr/local/hadoop
ENV HBASE_HOME=/usr/local/hbase
ENV ZOOKEEPER_HOME=/usr/local/zookeeper 
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin:$ZOOKEEPER_HOME/bin
ENV TZ=Asia/Shanghai
ENV LANG en_US.utf8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# crond
RUN sed -i '/session required pam_loginuid.so/c#session required pam_loginuid.so' /etc/pam.d/crond

# ssh
RUN mkdir -p /var/run/sshd/ && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key	

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir $HADOOP_HOME/logs && \
    mkdir $ZOOKEEPER_HOME/logs && \
    mkdir $ZOOKEEPER_HOME/data && \
    touch $ZOOKEEPER_HOME/data/myid

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/hbase-env.sh && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml && \
    mv /tmp/regionservers $HBASE_HOME/conf/regionservers && \
    mv /tmp/zoo.cfg $ZOOKEEPER_HOME/conf/ && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/stop-hadoop.sh ~/stop-hadoop.sh && \
    mv /tmp/start-service.sh ~/start-service.sh

RUN chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x ~/start-hadoop.sh && \
    chmod +x ~/stop-hadoop.sh && \
    chmod +x ~/start-service.sh

ENTRYPOINT ["/bin/bash"]
CMD ["/root/start-service.sh"]