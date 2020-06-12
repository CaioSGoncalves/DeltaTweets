#! /bin/bash
gcloud beta dataproc jobs submit pyspark \
    --cluster streaming-cluster --region southamerica-east1 \
    --properties ^#^spark.jars.packages=io.delta:delta-core_2.11:0.5.0,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4 \
    gs://teste-caio/movie_ratings/jobs/kafka_ingestion.py &
