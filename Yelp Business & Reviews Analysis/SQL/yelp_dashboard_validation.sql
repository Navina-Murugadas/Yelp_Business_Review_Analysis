--YELP BUSINESS REVIEWS - POWERBI DASHBOARD CALCULATIONS:
-- KPI Metrics
SELECT 
    COUNT(*) AS total_reviews,
    ROUND(AVG(review_stars), 2) AS avg_rating,
    ROUND(100.0 * SUM(CASE WHEN sentiments = 'Positive' THEN 1 ELSE 0 END) / COUNT(*), 2) AS positive_percent,
    ROUND(100.0 * SUM(CASE WHEN sentiments = 'Negative' THEN 1 ELSE 0 END) / COUNT(*), 2) AS negative_percent,
    ROUND(100.0 * SUM(CASE WHEN sentiments = 'Neutral' THEN 1 ELSE 0 END) / COUNT(*), 2) AS negative_percent
FROM tbl_yelpreviews;

-----------------------------------------------------------------------------------
-- Number of categories:
SELECT COUNT(DISTINCT TRIM(value)) AS total_unique_categories
FROM (
    SELECT value
    FROM tbl_yelpbusinesses,
         LATERAL SPLIT_TO_TABLE(categories, ',')
) AS sub;

-----------------------------------------------------------------------------------
-- Top 10 Categories by Reviews:
SELECT 
    TRIM(cat.value) AS category,
    COUNT(*) AS reviews
FROM tbl_yelpbusinesses bu
JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') cat
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
--WHERE re.sentiments = 'Positive'
GROUP BY category
ORDER BY reviews DESC
LIMIT 10;

-----------------------------------------------------------------------------------
-- Top 10 Cities by Reviews:
SELECT 
    city,
    COUNT(*) AS reviews
FROM tbl_yelpbusinesses bu
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
--WHERE re.sentiments = 'Positive'
GROUP BY city
ORDER BY reviews DESC
LIMIT 10;

-----------------------------------------------------------------------------------
-- Top Categories by Average Ratings:
SELECT 
    TRIM(cat.value) AS category,
    COUNT(*) AS total_reviews,
    ROUND(AVG(re.review_stars), 2) AS avg_rating
FROM tbl_yelpbusinesses bu
JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') cat
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
GROUP BY category
HAVING COUNT(*) >= 10000
AND avg_rating > 4
ORDER BY avg_rating DESC

-----------------------------------------------------------------------------------
-- STATE INSIGHTS:
SELECT 
    state,
    COUNT(*) AS reviews
FROM tbl_yelpbusinesses bu
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
GROUP BY state
ORDER BY reviews ASC
LIMIT 1;

SELECT 
    state,
    ROUND(AVG(re.review_stars), 2) AS avg_rating
FROM tbl_yelpbusinesses bu
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
GROUP BY state
ORDER BY avg_rating DESC
LIMIT 1;

-----------------------------------------------------------------------------------
-- CATEGORY INSIGHTS:
SELECT 
    TRIM(cat.value) AS category,
    COUNT(*) AS reviews
FROM tbl_yelpbusinesses bu
JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') cat
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
GROUP BY category
ORDER BY reviews DESC
LIMIT 1;

SELECT 
    TRIM(cat.value) AS category,
    ROUND(AVG(re.review_stars), 2) AS avg_rating
FROM tbl_yelpbusinesses bu
JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') cat
JOIN tbl_yelpreviews re ON re.business_id = bu.business_id
GROUP BY category
ORDER BY avg_rating ASC
LIMIT 1;

-----------------------------------------------------------------------------------
-- MAP TOP/BOTTOM CATEGORIES:
WITH Stats AS (
    SELECT
        STATE,
        CATEGORY,
        COUNT(*) AS TOTAL_REVIEWS,
        AVG(REVIEW_STARS) AS AVG_RATING
    FROM VW_YELP_REVIEWS_UNPIVOTED
    GROUP BY STATE, CATEGORY
),
Ranked AS (
    SELECT
        STATE,
        CATEGORY,
        TOTAL_REVIEWS,
        AVG_RATING,
        RANK() OVER (
            PARTITION BY STATE
            ORDER BY 
                AVG_RATING DESC, 
                TOTAL_REVIEWS DESC, 
                CATEGORY ASC
        ) AS TopRank,
        RANK() OVER (
            PARTITION BY STATE
            ORDER BY 
                AVG_RATING ASC, 
                TOTAL_REVIEWS ASC, 
                CATEGORY ASC
        ) AS BottomRank
    FROM Stats
)
SELECT
    STATE,
    MAX(CASE WHEN TopRank = 1 THEN CATEGORY END) AS TopCategory,
    MAX(CASE WHEN BottomRank = 1 THEN CATEGORY END) AS BottomCategory
FROM Ranked
GROUP BY STATE
ORDER BY STATE;
-----------------------------------------------------------------------------------
WHERE YEAR(REVIEW_DATE) IN (2022)
WHERE YEAR(REVIEW_DATE) BETWEEN 2020 AND 2022
WHERE YEAR(REVIEW_DATE) IN (2015, 2018, 2022)

-----------------------------------------------------------------------------------
-- TOP N CITIES BY CATEGORY (TABLE):
WITH base AS (
    SELECT 
        r.business_id,
        b.city,
        TRIM(cat.value::string) AS category,
        r.review_stars,
        r.sentiments
    FROM tbl_yelpreviews r
    JOIN tbl_yelpbusinesses b 
        ON r.business_id = b.business_id
    , LATERAL SPLIT_TO_TABLE(b.categories, ',') cat
),
agg AS (
    SELECT
        city,
        category,
        COUNT(*) AS total_reviews,
        AVG(review_stars) AS avg_rating,
        COUNT_IF(sentiments = 'Positive') AS positive_reviews,
        COUNT_IF(sentiments = 'Negative') AS negative_reviews,
        COUNT_IF(sentiments = 'Neutral') AS neutral_reviews
    FROM base
    -- optional slicer mimic
    -- WHERE category = 'Restaurants'      -- replace with desired category filter
      --AND review_stars BETWEEN 3 AND 5  -- mimic average rating slicer
    GROUP BY city, category
)
SELECT *
FROM agg
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY category
    ORDER BY total_reviews DESC, avg_rating DESC
) <= 30;

-----------------------------------------------------------------------------------
-- TOP N CATEGORIES BY CITY (BAR CHART):
WITH FilteredReviews AS (
    SELECT
        b.city,
        TRIM(cat.value) AS category,
        r.review_stars
    FROM tbl_yelpreviews r
    JOIN tbl_yelpbusinesses b 
        ON r.business_id = b.business_id,
        TABLE(SPLIT_TO_TABLE(b.categories, ',')) cat
    WHERE b.city = 'Berry Hill'
      AND r.review_stars BETWEEN 3 AND 5
)
SELECT
    category,
    COUNT(*) AS total_reviews
FROM FilteredReviews
GROUP BY category
ORDER BY total_reviews DESC
LIMIT 30;

-----------------------------------------------------------------------------------
-- Business-level average rating bins
CREATE OR REPLACE VIEW vw_BusinessRatingBins AS
WITH BusinessAvg AS (
    SELECT
        fr.BUSINESS_ID,
        AVG(fr.REVIEW_STARS) AS avg_rating
    FROM FACT_YELPDEDUPEDREVIEWS fr
    GROUP BY fr.BUSINESS_ID
)
SELECT
    b.BUSINESS_ID,
    b.BUSINESS_NAME,
    b.CITY,
    b.STATE,
    ROUND(avg_rating, 2) AS avg_rating,
    CASE 
        WHEN avg_rating < 1 THEN '0 - 1'
        WHEN avg_rating < 2 THEN '1 - 2'
        WHEN avg_rating < 3 THEN '2 - 3'
        WHEN avg_rating < 4 THEN '3 - 4'
        WHEN avg_rating <= 5 THEN '4 - 5'
        ELSE 'Unknown'
    END AS rating_bin
FROM BusinessAvg ba
JOIN Dim_Business b
    ON ba.BUSINESS_ID = b.BUSINESS_ID;

SELECT * FROM vw_BusinessRatingBins

-----------------------------------------------------------------------------------
-- Count of businesses by average rating bins
SELECT 
    RATING_BIN,
    COUNT(*) AS business_count
FROM (
    SELECT
        fr.BUSINESS_ID,
        ROUND(AVG(fr.REVIEW_STARS), 2) AS avg_rating,
        CASE 
            WHEN AVG(fr.REVIEW_STARS) >= 1   AND AVG(fr.REVIEW_STARS) < 1.5 THEN '1 - 1.5'
            WHEN AVG(fr.REVIEW_STARS) >= 1.5 AND AVG(fr.REVIEW_STARS) < 2   THEN '1.5 - 2'
            WHEN AVG(fr.REVIEW_STARS) >= 2   AND AVG(fr.REVIEW_STARS) < 2.5 THEN '2 - 2.5'
            WHEN AVG(fr.REVIEW_STARS) >= 2.5 AND AVG(fr.REVIEW_STARS) < 3   THEN '2.5 - 3'
            WHEN AVG(fr.REVIEW_STARS) >= 3   AND AVG(fr.REVIEW_STARS) < 3.5 THEN '3 - 3.5'
            WHEN AVG(fr.REVIEW_STARS) >= 3.5 AND AVG(fr.REVIEW_STARS) < 4   THEN '3.5 - 4'
            WHEN AVG(fr.REVIEW_STARS) >= 4   AND AVG(fr.REVIEW_STARS) < 4.5 THEN '4 - 4.5'
            WHEN AVG(fr.REVIEW_STARS) >= 4.5 AND AVG(fr.REVIEW_STARS) <= 5  THEN '4.5 - 5'
            ELSE 'Unknown'
        END AS RATING_BIN
    FROM FACT_YELPDEDUPEDREVIEWS fr
    GROUP BY fr.BUSINESS_ID
)
GROUP BY RATING_BIN
ORDER BY RATING_BIN;










