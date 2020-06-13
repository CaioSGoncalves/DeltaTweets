import csv
from kafka import KafkaProducer
import time


def publish_message(producer_instance, topic_name, value):
    try:
        print('Sending message to Kafka.')
        value_bytes = bytes(value, encoding='utf-8')
        future = producer_instance.send(topic_name, value=value_bytes)
        result = future.get(timeout=60)
        # producer_instance.flush()
        print('Message published successfully.')
    except Exception as ex:
        print('Exception in publishing message')
        print(str(ex))


def connect_kafka_producer():
    _producer = None
    try:
        _producer = KafkaProducer(bootstrap_servers=['kafka:9092'])
    except Exception as ex:
        print('Exception while connecting Kafka')
        print(str(ex))
    finally:
        return _producer
