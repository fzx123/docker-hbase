#!/bin/bash

echo ""

echo -e "\nbuild docker hbase image\n"
sudo docker build -t haohan/hbase:2.0.0 .

echo ""