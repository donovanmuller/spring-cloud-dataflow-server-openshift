#!/usr/bin/env bash

echo "Pulling images..."

declare -a images=(
  "mysql:5.6"
  "redis:3-alpine"
  "donovanmuller/spring-cloud-dataflow-server-openshift:1.1.0.RELEASE"
  "rabbitmq:3-management"
  "digitalwonderland/zookeeper"
  "wurstmeister/kafka:0.10.1.0"
  )

for((i=0;i<${#images[@]};i++))
do
   echo "Pulling '${images[$i]}' - `expr $i + 1` of ${#images[@]}"
   docker pull ${images[$i]}
done
