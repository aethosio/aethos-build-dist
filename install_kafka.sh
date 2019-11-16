#!/bin/bash

cd /root

sudo apt -y install wget

if [ ! -d "kafka" ]; then
  mkdir kafka
fi

cd kafka

if [ ! -f "kafka_2.12-2.3.0.tgz " ]; then
  wget http://mirror.cc.columbia.edu/pub/software/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz
fi
