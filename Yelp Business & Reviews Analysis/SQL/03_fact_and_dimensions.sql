-- FACT & DIMENSION VIEWS/TABLES:
-- FACT TABLES:
CREATE OR REPLACE VIEW vw_yelp_business_category_summary AS
SELECT 
    bu.business_id,
    bu.name AS business_name,
    bu.city,
    bu.state,
    TRIM(cat.value) AS category,
    COUNT(re.review_text) AS total_reviews,
    ROUND(AVG(re.review_stars), 2) AS avg_rating,
    SUM(CASE WHEN re.sentiments = 'Positive' THEN 1 ELSE 0 END) AS positive_reviews,
    SUM(CASE WHEN re.sentiments = 'Neutral' THEN 1 ELSE 0 END) AS neutral_reviews,
    SUM(CASE WHEN re.sentiments = 'Negative' THEN 1 ELSE 0 END) AS negative_reviews
FROM tbl_yelpbusinesses bu
JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') AS cat
LEFT JOIN tbl_yelpreviews re
    ON bu.business_id = re.business_id
GROUP BY 
    bu.business_id,
    bu.name,
    bu.city,
    bu.state,
    TRIM(cat.value);

SELECT *
FROM vw_yelp_business_category_summary
LIMIT 20;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Fact_YelpDedupedReviews AS
SELECT DISTINCT
    business_id,
    user_id,
    review_date,
    review_stars,
    sentiments
FROM tbl_yelpreviews;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_YELP_REVIEWS_UNPIVOTED AS
SELECT
    re.review_id,  -- ✅ add unique identifier
    re.business_id,
    re.user_id,
    re.review_date,
    re.review_stars,
    re.sentiments,
    bu.name AS business_name,
    bu.city,
    bu.state,
    TRIM(cat.value) AS category
FROM tbl_yelpreviews re
JOIN tbl_yelpbusinesses bu
    ON re.business_id = bu.business_id
JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') AS cat;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_CityCategoryRatingMatrix AS
SELECT
    city,
    category,
    ROUND(AVG(review_stars), 2) AS avg_rating,
    COUNT(*) AS total_reviews
FROM VW_YELP_REVIEWS_UNPIVOTED
WHERE city IN (
    SELECT city FROM (
        SELECT city, COUNT(*) AS review_count
        FROM VW_YELP_REVIEWS_UNPIVOTED
        GROUP BY city
        ORDER BY review_count DESC
        LIMIT 10
    )
)
AND category IN (
    SELECT category FROM (
        SELECT category, COUNT(*) AS review_count
        FROM VW_YELP_REVIEWS_UNPIVOTED
        GROUP BY category
        ORDER BY review_count DESC
        LIMIT 10
    )
)
GROUP BY city, category
HAVING COUNT(*) >= 100;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Fact_CityCategoryReviews AS
SELECT
    b.city,
    TRIM(cat.value) AS category,
    r.review_stars,
    r.sentiments,
    COUNT(*) AS review_count
FROM tbl_yelpreviews r
JOIN tbl_yelpbusinesses b 
    ON r.business_id = b.business_id,
    TABLE(SPLIT_TO_TABLE(b.categories, ',')) cat
GROUP BY b.city, TRIM(cat.value), r.review_stars, r.sentiments;

------------------------------------------------------------------------------------------------------------------------------------------------
-- BRIDGE TABLE:
CREATE OR REPLACE VIEW Bridge_BusinessCategory AS
SELECT DISTINCT
    TRIM(cat.value) AS Category,
    bu.business_id
FROM tbl_yelpbusinesses bu,
LATERAL SPLIT_TO_TABLE(bu.categories, ',') AS cat;

------------------------------------------------------------------------------------------------------------------------------------------------
-- DIMENSION TABLES:
CREATE OR REPLACE VIEW Dim_Business AS
SELECT
    BUSINESS_ID,
    NAME AS BUSINESS_NAME,
    CITY,
    STATE
FROM TBL_YELPBUSINESSES;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Dim_City AS
SELECT DISTINCT CITY
FROM TBL_YELPBUSINESSES;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Dim_Category AS
SELECT DISTINCT TRIM(value) AS Category
FROM TBL_YELPBUSINESSES,
LATERAL SPLIT_TO_TABLE(CATEGORIES, ',');

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Dim_State AS
SELECT
    bu.state AS StateAbbr,
    CASE bu.state
        WHEN 'AB' THEN 'Alberta'
        WHEN 'AZ' THEN 'Arizona'
        WHEN 'CA' THEN 'California'
        WHEN 'CO' THEN 'Colorado'
        WHEN 'DE' THEN 'Delaware'
        WHEN 'FL' THEN 'Florida'
        WHEN 'HI' THEN 'Hawaii'
        WHEN 'ID' THEN 'Idaho'
        WHEN 'IL' THEN 'Illinois'
        WHEN 'IN' THEN 'Indiana'
        WHEN 'LA' THEN 'Louisiana'
        WHEN 'MA' THEN 'Massachusetts'
        WHEN 'MI' THEN 'Michigan'
        WHEN 'MO' THEN 'Missouri'
        WHEN 'MT' THEN 'Montana'
        WHEN 'NC' THEN 'North Carolina'
        WHEN 'NJ' THEN 'New Jersey'
        WHEN 'NV' THEN 'Nevada'
        WHEN 'PA' THEN 'Pennsylvania'
        WHEN 'SD' THEN 'South Dakota'
        WHEN 'TN' THEN 'Tennessee'
        WHEN 'TX' THEN 'Texas'
        WHEN 'UT' THEN 'Utah'
        WHEN 'VI' THEN 'Virgin Islands'
        WHEN 'VT' THEN 'Vermont'
        WHEN 'WA' THEN 'Washington'
        ELSE bu.state
    END AS StateName,

    -- Latitude
    CASE bu.state
        WHEN 'AB' THEN 53.9333
        WHEN 'AZ' THEN 34.0489
        WHEN 'CA' THEN 36.7783
        WHEN 'CO' THEN 39.5501
        WHEN 'DE' THEN 38.9108
        WHEN 'FL' THEN 27.6648
        WHEN 'HI' THEN 19.8968
        WHEN 'ID' THEN 44.0682
        WHEN 'IL' THEN 40.6331
        WHEN 'IN' THEN 40.2672
        WHEN 'LA' THEN 30.9843
        WHEN 'MA' THEN 42.4072
        WHEN 'MI' THEN 44.3148
        WHEN 'MO' THEN 37.9643
        WHEN 'MT' THEN 46.8797
        WHEN 'NC' THEN 35.7596
        WHEN 'NJ' THEN 40.0583
        WHEN 'NV' THEN 38.8026
        WHEN 'PA' THEN 41.2033
        WHEN 'SD' THEN 43.9695
        WHEN 'TN' THEN 35.5175
        WHEN 'TX' THEN 31.9686
        WHEN 'UT' THEN 39.3200
        WHEN 'VI' THEN 18.3358
        WHEN 'VT' THEN 44.5588
        WHEN 'WA' THEN 47.7511
        ELSE NULL
    END AS Latitude,

    -- Longitude
    CASE bu.state
        WHEN 'AB' THEN -116.5765
        WHEN 'AZ' THEN -111.0937
        WHEN 'CA' THEN -119.4179
        WHEN 'CO' THEN -105.7821
        WHEN 'DE' THEN -75.5277
        WHEN 'FL' THEN -81.5158
        WHEN 'HI' THEN -155.5828
        WHEN 'ID' THEN -114.7420
        WHEN 'IL' THEN -89.3985
        WHEN 'IN' THEN -86.1349
        WHEN 'LA' THEN -91.9623
        WHEN 'MA' THEN -71.3824
        WHEN 'MI' THEN -85.6024
        WHEN 'MO' THEN -91.8318
        WHEN 'MT' THEN -110.3626
        WHEN 'NC' THEN -79.0193
        WHEN 'NJ' THEN -74.4057
        WHEN 'NV' THEN -116.4194
        WHEN 'PA' THEN -77.1945
        WHEN 'SD' THEN -99.9018
        WHEN 'TN' THEN -86.5804
        WHEN 'TX' THEN -99.9018
        WHEN 'UT' THEN -111.0937
        WHEN 'VI' THEN -64.8963
        WHEN 'VT' THEN -72.5778
        WHEN 'WA' THEN -120.7401
        ELSE NULL
    END AS Longitude,

    AVG(rv.review_stars) AS AvgRating,
    COUNT(*) AS TotalReviews,
    CASE 
        WHEN AVG(rv.review_stars) < 3.0 THEN 'Low (0 - 3.0)'
        WHEN AVG(rv.review_stars) < 4.0 THEN 'Medium (3.0 - 4.0)'
        WHEN AVG(rv.review_stars) <= 5.0 THEN 'High (4.0 - 5.0)'
        ELSE 'Unknown'
    END AS RatingColorCategory

FROM tbl_yelpbusinesses bu
JOIN fact_yelpdedupedreviews rv
    ON bu.business_id = rv.business_id
GROUP BY bu.state;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE STATE_YEAR_CATEGORY_STATS AS
SELECT
    STATE,
    YEAR(REVIEW_DATE)           AS REVIEW_YEAR,
    CATEGORY,
    COUNT(*)                    AS TOTAL_REVIEWS,
    AVG(REVIEW_STARS)           AS AVG_RATING
FROM VW_YELP_REVIEWS_UNPIVOTED
GROUP BY STATE, YEAR(REVIEW_DATE), CATEGORY;

------------------------------------------------------------------------------------------------------------------------------------------------




