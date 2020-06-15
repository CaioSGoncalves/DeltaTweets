from pyspark import SparkContext
from pyspark.sql.session import SparkSession
from pyspark.sql.types import *
from pyspark.sql.functions import *
import time

sc = SparkContext()
spark = SparkSession(sc)

# READING STREAMING DATA FROM KAFKA
df = spark \
  .readStream \
  .format("kafka") \
  .option("kafka.bootstrap.servers", "terraform-instance.southamerica-east1-b.c.sincere-bongo-264115.internal:9094") \
  .option("subscribe", "tweets") \
  .option("failOnDataLoss", False) \
  .load()

# SETTING SCHEMA AND FORMATTING STREAMING DATA
schema = StructType([ 
                        StructField("id", LongType(), True),
                        StructField("text", StringType(), True),
                        StructField("username", StringType(), True),
                        StructField("created_at", IntegerType(), True),
                        StructField("hashtags" , ArrayType(StringType()), True),
                        StructField("links" , ArrayType(StringType()), True),
                        StructField("extracted_at", IntegerType(), True),
                    ])
                        
data = df.selectExpr("CAST(value AS STRING)")\
        .select(from_json("value", schema).alias("data")).select("data.*")

# data.dropDuplicates("id")

# WRITING STREAMING DATA TO DELTA LAKE
query = ( data
    .writeStream
    .format("delta")
    .outputMode("append")
    .option("checkpointLocation", "gs://teste-caio/delta_tweets/delta/tweets/_checkpoints/etl-from-kafka")
    .start("gs://teste-caio/delta_tweets/delta/bronze_tweet") )

time.sleep(30)
print(query.status)
print(query.lastProgress)

while True:
  time.sleep(30)
  print(query.status)
  print(query.lastProgress)