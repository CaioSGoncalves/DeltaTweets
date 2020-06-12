#! /bin/bash
echo export SPARK_SUBMIT_OPTIONS=\"--packages io.delta:delta-core_2.11:0.5.0,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4\" >> /usr/lib/zeppelin/conf/zeppelin-env.sh