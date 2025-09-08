--YELP REVIEWS DATA ANALYSIS USING SQL:
SELECT *
FROM tbl_yelpreviews
LIMIT 10

SELECT *
FROM tbl_yelpbusinesses
LIMIT 10

---------------------------------------------------------------------------------------------------
--1) Number of businesses in each category:
WITH categorysplit AS(
SELECT business_id, TRIM(A.value) AS category
FROM tbl_yelpbusinesses,
    LATERAL SPLIT_TO_TABLE(categories, ',') A
)
SELECT category, COUNT(*) AS No_of_businesses
FROM categorysplit
GROUP BY category
ORDER BY No_of_businesses DESC

---------------------------------------------------------------------------------------------------
--2) Find the TOP 10 users who have reviewed the most businesses in the "Restaraunts" category:
SELECT re.user_id, COUNT(DISTINCT re.business_id) AS Count_of_businesses
FROM tbl_yelpreviews re
INNER JOIN tbl_yelpbusinesses bu
    USING(business_id)
WHERE bu.categories ILIKE '%restaurants%'
GROUP BY 1
ORDER BY Count_of_businesses DESC
LIMIT 10

---------------------------------------------------------------------------------------------------
--3) Find the most popular categories of businesses (Based on number of reviews):
WITH cte AS(
SELECT business_id, TRIM(A.value) AS category
FROM tbl_yelpbusinesses,
    LATERAL SPLIT_TO_TABLE(categories, ',') A
)
SELECT category, COUNT(*) AS No_of_reviews
FROM cte
INNER JOIN tbl_yelpreviews re
    ON cte.business_id = re.business_id
GROUP BY category
ORDER BY No_of_reviews DESC

---------------------------------------------------------------------------------------------------
--4) Find the TOP 3 Most recent reviews for each business:
WITH cte AS(
    SELECT re.*, bu.name,
        ROW_NUMBER() OVER(PARTITION BY re.business_id ORDER BY review_date DESC) AS rn
    FROM tbl_yelpreviews re
    INNER JOIN tbl_yelpbusinesses bu
        USING(business_id)
)
SELECT * 
FROM cte
WHERE rn<=3

---------------------------------------------------------------------------------------------------
--5) Find the month with highest number of reviews:
SELECT MONTH(review_date) AS review_month, COUNT(*) AS No_of_reviews
FROM tbl_yelpreviews
GROUP BY 1
ORDER BY 2 DESC

---------------------------------------------------------------------------------------------------
--6) Find the percentage of 5-star reviews for each business:
SELECT bu.business_id, bu.name, COUNT(*) AS Total_reviews,
    SUM(CASE WHEN re.review_stars=5 THEN 1 ELSE 0 END) AS Star5_reviews,
    Star5_reviews*100 / Total_reviews AS Percentage_5star
FROM tbl_yelpreviews re
INNER JOIN tbl_yelpbusinesses bu
    USING(business_id)
GROUP BY 1,2
ORDER BY Percentage_5star DESC

---------------------------------------------------------------------------------------------------
--7) Find the TOP 5 Most reviewed businesses in each city:
WITH cte AS(
SELECT bu.business_id, bu.name, bu.city, COUNT(*) AS Total_reviews
FROM tbl_yelpreviews re
INNER JOIN tbl_yelpbusinesses bu
    USING(business_id)
GROUP BY 1,2,3
)
SELECT *
FROM cte
QUALIFY ROW_NUMBER() OVER(PARTITION BY city ORDER BY Total_reviews DESC) <=5

---------------------------------------------------------------------------------------------------
--8) Find the average rating of businesses that have atleast 100 reviews:
SELECT bu.business_id, bu.name, COUNT(*) AS Total_reviews,
    AVG(review_stars) AS Avg_rating
FROM tbl_yelpreviews re
INNER JOIN tbl_yelpbusinesses bu
    USING(business_id)
GROUP BY 1,2
HAVING COUNT(*) >= 100
ORDER BY Total_reviews DESC

---------------------------------------------------------------------------------------------------
--9) List the TOP 10 users who have written the most reviews, along with the businesses they reviewed:
WITH cte AS(
SELECT re.user_id, COUNT(*) AS Total_reviews
FROM tbl_yelpreviews re
INNER JOIN tbl_yelpbusinesses bu
    USING(business_id)
GROUP BY 1
ORDER BY Total_reviews DESC
LIMIT 10
)
SELECT user_id, business_id
FROM tbl_yelpreviews
WHERE user_id IN (
    SELECT user_id FROM cte
)
GROUP BY 1,2
ORDER BY user_id

---------------------------------------------------------------------------------------------------
--10) Find TOP 10 businesses with highest Positive sentiment reviews:
SELECT re.business_id, bu.name, COUNT(*) AS Total_reviews
FROM tbl_yelpreviews re
INNER JOIN tbl_yelpbusinesses bu
    USING(business_id)
WHERE sentiments='Positive'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10

---------------------------------------------------------------------------------------------------