-- CREATING TABLES:

CREATE or replace table yelp_reviews (review_text variant)

COPY INTO yelp_reviews
FROM 's3://yelpreviewanalysis/reviews/'
CREDENTIALS = (
    AWS_KEY_ID = '<AWS_KEY_ID>'
    AWS_SECRET_KEY = '<AWS_SECRET_KEY>'
)

FILE_FORMAT = (TYPE = JSON);
------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE yelp_businesses (business_text variant)

COPY INTO yelp_businesses
FROM 's3://yelpreviewanalysis/reviews/yelp_academic_dataset_business.json'
CREDENTIALS = (
    AWS_KEY_ID = '<AWS_KEY_ID>'
    AWS_SECRET_KEY = '<AWS_SECRET_KEY>'
)

FILE_FORMAT = (TYPE = JSON);

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE tbl_yelpreviews AS
SELECT 
    review_text:review_id::string AS review_id,   
    review_text:business_id::string AS business_id,
    review_text:date::date AS review_date,
    review_text:user_id::string AS user_id,
    review_text:stars::number AS review_stars,
    review_text:text::string AS review_text,
    analyze_sentiment(review_text) AS sentiments
FROM yelp_reviews;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE tbl_yelpbusinesses AS
SELECT
business_text:business_id::string as business_id,
business_text:name::string as name,
business_text:city::string as city,
business_text:state::string as state,
business_text:review_count::string as review_count,
business_text:stars::number as stars,
business_text:categories::string as categories
FROM yelp_businesses

------------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM tbl_yelpbusinesses
LIMIT 1000

SELECT *
FROM tbl_yelpbusinesses
WHERE state = 'XMS'

DELETE FROM tbl_yelpbusinesses
WHERE state = 'XMS';


