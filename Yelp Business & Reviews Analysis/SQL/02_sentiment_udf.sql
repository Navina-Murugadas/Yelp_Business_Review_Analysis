-- SQL statement that creates a Python-based user-defined function (UDF) in Snowflake
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('textblob')
HANDLER = 'sentiment_analyzer'
AS $$
import textblob

def sentiment_analyzer(text):
    analysis = textblob.TextBlob(text)
    polarity = analysis.sentiment.polarity
    if polarity > 0:
        return 'Positive'
    elif polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;
------------------------------------------------------------------------------------------------------------------------------------------------