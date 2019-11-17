#!/bin/bash

cd /root

sudo apt -y install wget openjdk-8-jdk-headless

if [ ! -d "kafka" ]; then
  mkdir kafka
fi

cd kafka

if [ ! -f kafka_2.12-2.3.0.tgz ]; then
  wget http://mirror.cc.columbia.edu/pub/software/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz
fi

if [ ! -d kafka_2.12-2.3.0 ]; then
  tar -xzf kafka_2.12-2.3.0.tgz
fi

cd kafka_2.12-2.3.0

cat << EOF > env.sh
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
EOF
