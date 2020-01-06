#!/bin/bash

apt update
apt upgrade -y

cd /root

sudo apt -y install wget openjdk-8-jdk-headless

if [ ! -d /home/kafka ]; then
  useradd kafka -m 2>/dev/null
fi

if [ ! -d /home/kafka/Downloads ]; then
  mkdir /home/kafka/Downloads
fi

cd /home/kafka/Downloads

if [ ! -f kafka_2.12-2.3.0.tgz ]; then
  wget http://mirror.cc.columbia.edu/pub/software/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz
fi

if [ ! -d kafka_2.12-2.3.0 ] && [ ! -d /home/kafka/kafka ]; then
  tar -xzf kafka_2.12-2.3.0.tgz
  mv kafka_2.12-2.3.0 /home/kafka/kafka
  cd /home/kafka/kafka
  cat << EOF > env.sh
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
EOF

  sudo chown kafka.kafka * -R
fi

cat << EOF > /etc/systemd/system/zookeeper.service
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/systemd/system/kafka.service
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /home/kafka/kafka/kafka.log 2>&1'
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF
