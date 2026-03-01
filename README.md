# 📊 Yelp Business Reviews Analysis
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
```
✅ Applied on 6.99M reviews to classify Positive / Neutral / Negative sentiment.

---
## 📊 Dashboards & Insights  

### 1️⃣ Executive Summary  
- **6.99M reviews**, **150K businesses**, **1,311 categories** across **1,237 cities & 26 states**  
- **94.5% Positive Sentiment**, **Avg Rating: 3.75⭐**  
- Key Finding → **High review volume ≠ High rating** (Restaurants dominate reviews, but niche categories like *Historical Tours* rank higher)  

---

### 2️⃣ Overview Dashboard  
- Top **categories & cities by review volume**  
- **High-volume categories** with best ratings (*e.g., Historical Tours, Food Stands*)  
- **Word Cloud (100K+ mentions)** → What customers talk about most  

---

### 3️⃣ State Insights  
- State-wise **review & sentiment distribution**  
- **Highest reviewed state:** Pennsylvania (*1.6M reviews*)  
- **Highest rated state:** Montana (*5.0⭐*)  
- **Lowest rated state:** Massachusetts (*1.3⭐*)  

---

### 4️⃣ City Insights  
- Which **categories drive reviews** in each city  
- **Top cities** by sentiment distribution  
- **Heatmap (City × Category):** Compare ratings across **10 cities × 10 categories**  

---

### 5️⃣ Time & Location Insights  
- **Yearly trend (2005–2022):** steady growth until 2020 dip, then **+11.5% rebound in 2021**  
- **Monthly YOY comparisons:** Florida in March saw peak review volume  
- **Seasonal review behavior** across states  

---

## 🚀 Live Dashboard  

🔗 [**Click here to explore the interactive Power BI Dashboard**](https://app.powerbi.com/view?r=eyJrIjoiMGM3YTg3MjEtODE3Mi00ODBlLTkxY2ItOTI1ZDA3ZjAzOGY5IiwidCI6IjQ5MWIwYjZiLTA1NDAtNDJjZi1iZTJmLWE2NjZlNWFiMjIxOCJ9&pageName=dca2e2cb0157702568d7)

*(Best viewed on desktop for full interactivity)*  

---

## 🔑 Key Learnings & Impact  
- **Data Engineering:** Built ETL pipeline using *Python + Amazon S3 + Snowflake*  
- **Data Warehousing:** Designed **Snowflake schema** with bridge table for many-to-many relationships  
- **Analytics:** Applied **sentiment analysis at scale** on millions of records  
- **BI Visualization:** Delivered **executive-level dashboards** for business strategy insights  
- **Validation:** Cross-checked results with **SQL + Power BI** to ensure accuracy  

---

## 📌 Use Cases  
- **Business Teams →** Identify underperforming but high-volume categories  
- **Marketing →** Track sentiment drivers by city or season  
- **Strategy →** Prioritize improvements in low-rated states/categories  
- **Analytics Hiring Portfolio →** Demonstrates end-to-end ownership of a real-world data project  

---

## 📸 Dashboard Preview 
### 🖼️ Cover Page
![Yelp Business Reviews Analysis_page-0001](https://github.com/user-attachments/assets/35d2995f-45e3-43a2-bfe8-90d81f687f06)
### 📊 Summary Dashboard
![Yelp Business Reviews Analysis_page-0002](https://github.com/user-attachments/assets/776f2283-2287-4ea8-8690-819c904bf0b6)
### 📌 Overview Dashboard
![Yelp Business Reviews Analysis_page-0003](https://github.com/user-attachments/assets/3207c71d-5a70-4bef-b1a0-686544b00019)
### 🗺️ State Insights
![Yelp Business Reviews Analysis_page-0004](https://github.com/user-attachments/assets/848c7032-6858-4ad5-8c11-227c45dae9c5)
### 🏙️ City & Category Insights
![Yelp Business Reviews Analysis_page-0005](https://github.com/user-attachments/assets/6ab19089-8396-4e3e-a4d2-6b0be6eaac8d)
### 🌍 Time & Location Insights
![Yelp Business Reviews Analysis_page-0006](https://github.com/user-attachments/assets/2eeca497-fa53-481c-976a-0457386709aa)

---

### 🔍 Tooltips
![Yelp Business Reviews Analysis_page-0007](https://github.com/user-attachments/assets/cdf14948-0068-442f-9e2b-e9dd63936aba)
![Yelp Business Reviews Analysis_page-0008](https://github.com/user-attachments/assets/5b018dde-3c54-4086-b692-597dd677aea8)
![Yelp Business Reviews Analysis_page-0009](https://github.com/user-attachments/assets/6a8b1fe4-20a6-41c1-88ec-c403c090af7c)
![Yelp Business Reviews Analysis_page-0010](https://github.com/user-attachments/assets/db17e6dd-2901-4367-84ec-fa59a11e4abd)

---

## 👩‍💻 Author  
**Navina M** | *Data Analyst Portfolio Project*  
📧 [navina.mk7@gmail.com](mailto:navina.mk7@gmail.com) | 💼 [LinkedIn](https://www.linkedin.com/in/navina-m/) | 🌐 [Portfolio Website](https://navina-murugadas.github.io/Portfolio/)


