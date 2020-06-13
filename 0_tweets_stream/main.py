from typing import List
import json
import re
from datetime import datetime

from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener

import config
from kafka_utils import connect_kafka_producer, publish_message


kafka_producer = connect_kafka_producer()


class GetDataTwitter(StreamListener):
    def on_data(self, data):
        formated_data = dict()

        all_data = json.loads(data)
        formated_data["id"] = all_data["id"]
        formated_data["text"] = all_data["text"]
        formated_data["username"] = all_data["user"]["screen_name"]

        formated_created_at = all_data["created_at"][:19] + all_data["created_at"][-5:]
        formated_data["created_at"] = int(datetime.strptime(formated_created_at, '%a %b %d %H:%M:%S %Y').timestamp())
        # 'quote_count' 'reply_count' 'retweet_count' 'favorite_count'

        formated_data["hashtags"] = [h["text"] for h in all_data["entities"]["hashtags"]]
        formated_data["links"] = self.extract_links(formated_data["text"])
        formated_data["extracted_at"] = int(datetime.now().timestamp())

        print(formated_data["id"], formated_data["created_at"], formated_data["username"], formated_data["text"],
              formated_data["links"], formated_data["extracted_at"], formated_data["hashtags"])

        message = json.dumps(formated_data)
        publish_message(kafka_producer, "tweets", message)

        return True

    def on_error(self, status):
        print(status)

    @staticmethod
    def extract_links(text: str) -> List[str]:
        return re.findall(r'(https?://\S+)', text)


if __name__ == '__main__':
    auth = OAuthHandler(config.consumer_key, config.consumer_secret)
    auth.set_access_token(config.access_token, config.access_secret)

    stream = Stream(auth, GetDataTwitter())

    track = ["dataengineer", "dataenginnering", "bigdata", "spark", "hadoop", "databricks", "kafka"]

    stream.filter(track=track)
