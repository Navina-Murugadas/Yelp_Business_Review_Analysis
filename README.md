# 📊 Yelp Business & Reviews Analytics

### End-to-End Data Analytics Project | Python · Amazon S3 · Snowflake (Snowflake Schema) · SQL · Power BI · DAX

---

## 🚀 Project Overview  
This project delivers a **complete analytics pipeline** for Yelp’s open dataset (≈7M reviews, 2005–2022), designed to uncover business insights across **categories, geographies, and time**.  

Raw JSON data was ingested, processed, stored, and transformed into a **Snowflake schema** with SQL transformations and a Python UDF for sentiment analysis. The final outputs were interactive **Power BI dashboards**, providing insights into:  
- Review volume and rating trends  
- Sentiment distribution across categories and cities  
- State-wise business performance  
- Seasonal & time-based review behaviors  

🔎 **Why this matters:** The project simulates a real-world **data engineering + BI analytics workflow**, combining **ETL, cloud storage, data warehousing, sentiment analysis, and visualization** into one end-to-end solution.

---

## 📂 Tech Stack & Tools
- **Python** – ETL processing, data cleaning, and S3 upload  
- **Amazon S3** – Cloud storage for raw JSON files  
- **Snowflake Data Warehouse** – Normalized **Snowflake schema design**, SQL transformations, performance tuning  
- **Python UDF in Snowflake** – Sentiment analysis using `TextBlob`  
- **SQL** – Data exploration, validation, KPI calculations  
- **Power BI + DAX** – Interactive dashboards & advanced analytics  

---

## 🏗️ Data Pipeline Architecture
![Yelp_Pipeline](https://github.com/user-attachments/assets/c07a4c02-0d04-4e2d-b237-e80dc512ebe7)

**Flow:**  
Raw Yelp JSON → Python ETL → Amazon S3 → Snowflake DWH (Snowflake Schema + UDF Sentiment) → SQL Validation & Analysis → Power BI Dashboards  

---

## 🗄️ Data Model (Snowflake Schema)
<img width="1455" height="732" alt="Yelp Model View" src="https://github.com/user-attachments/assets/20168e1a-a816-481e-b774-9225560b9fa3" />

The schema follows a **Snowflake design** with normalized dimensions and a bridge table:  

- **Fact Tables**
  - `Fact_YelpDedupedReviews` → review-level data (stars, sentiments, date, user, business)  
  - `Fact_CategorySummary` → aggregated category & sentiment stats  
  - `Fact_CityCategoryReviews` → city × category review metrics  
  - `Fact_Words_By_City_Category` → word frequency for word clouds  

- **Dimension Tables**
  - `Dim_Business` (business attributes)  
  - `Dim_Category` (unique categories)  
  - `Dim_City` (city details)  
  - `Dim_State` (state details with lat/long for maps)  
  - `Dim_Calendar` (date intelligence)  
  - `Dim_Year` (year-level)  

- **Bridge Table**
  - `Bridge_BusinessCategory` → resolves many-to-many between businesses and categories  

---

## 🧠 Sentiment Analysis (Python UDF in Snowflake)
```sql
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

---
✅ Applied on 6.99M reviews to classify Positive / Neutral / Negative sentiment.
