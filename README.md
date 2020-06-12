# DeltaTweets
Scraping Data Engineering tweets from TwitterAPI and storing in Delta Lake using Spark.

Unified Stream and batch jobs.

Tweets Stream -> Spark -> Delta Lake

Delta:
- Bronze (Tweet)  -> Silver (Tweet + Hashtag) -> Gold (AggByDate, AggByHashtag)
- Bronze: bronze_tweet
- Silver: silver_tweet and silver_hashtag
- Gold: gold_tweets_agg_by_date, gold_tweets_agg_by_hashtag
