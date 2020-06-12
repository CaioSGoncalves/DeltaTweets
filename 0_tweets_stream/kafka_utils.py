import csv
from kafka import KafkaProducer
import time


def publish_message(producer_instance, topic_name, key, value):
    try:
        key_bytes = bytes(key, encoding='utf-8')
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


def get_artificial_ratings():
    reader = csv.DictReader(open("jobs.csv"))
    return [row for row in reader]


if __name__ == '__main__':
    time.sleep(30)
    kafka_producer = connect_kafka_producer()

    for message in get_artificial_ratings():
        publish_message(kafka_producer, 'jobs', "", str(message))
        time.sleep(10)

    if kafka_producer is not None:
        kafka_producer.close()
