#### **🍔 Swiggy SQL Data Analysis**





SQL-based analysis of Swiggy restaurant and menu data using MySQL.



###### **📌 Project Overview**



This project analyzes Swiggy menu data to generate business insights related to:



* Restaurant performance
* Menu and dish analysis
* Pricing
* Ratings and review volume
* Location-wise trends
* Restaurant categories
* Date and time trends



The project follows a complete SQL analysis workflow:



Data Quality Check → Duplicate Check → Data Modeling → KPI Analysis → Business Analysis → Advanced SQL





###### **🎯 Business Objectives**



The analysis focuses on:



* Validating data quality and identifying duplicate records
* Building a Star Schema for analytical reporting
* Calculating key business KPIs
* Analyzing restaurant and menu performance
* Comparing pricing and ratings across locations and categories
* Identifying popular dishes and categories
* Performing date and time analysis
* Applying advanced SQL techniques for ranking and comparison





###### **📊 Key KPIs**





|KPI|Value|
|-|-|
|Total Menu Records|197,403|
|Total Restaurants|984|
|Total Dishes|56,588|
|Total Locations|964|
|Total Categories|4,774|
|Average Menu Price|₹268.50|







###### **⭐ Data Model**



The project uses a **Star Schema** consisting of:



###### **Fact Table**



&#x20;   \*\*-\*\*fact\_swiggy\_menu



###### **Dimension Tables**



* dim\_date
* dim\_location
* dim\_restaurant
* dim\_category
* dim\_dish



**Fact Table Grain:**
One row represents one Swiggy menu-item listing for a specific restaurant, dish, category, location, and date.



###### **🔍 Analysis Performed**



###### **Data Quality**



* Record count validation
* NULL value checks
* Blank value checks
* Duplicate detection
* Duplicate handling



###### **Restaurant Analysis**



* Top restaurants by menu count
* Average restaurant pricing
* Restaurant ratings
* Review volume



###### **Location Analysis**



* State-wise analysis
* City-wise restaurant/menu presence
* Average pricing by location
* Rating patterns by location



###### **Category \& Dish Analysis**



* Most listed categories
* Most listed dishes
* Category pricing
* Dish pricing
* Rating and review analysis



###### **Date \& Time Analysis**



* Year-wise trends
* Month-wise trends
* Monthly growth
* Date/time patterns



###### **Advanced SQL**



* CTEs
* ROW\_NUMBER()
* RANK()
* LAG()
* Window Functions
* Top-N analysis
* Month-over-month comparison





###### **🛠️ SQL Skills Demonstrated**



* Data Cleaning
* Data Validation
* Joins
* Aggregations
* GROUP BY
* HAVING
* CTEs
* Window Functions
* Ranking
* Date/Time Analysis
* Star Schema / Dimensional Modeling
* KPI Analysis





###### **💡 Key Insights**



* McDonald's has the highest menu-record presence among the analyzed restaurants, followed by KFC and Burger King.
  
* Bengaluru has the highest menu-record presence among the analyzed cities, followed by Mumbai.
  
* Some dishes have very high average ratings but relatively low review volumes, showing why ratings should be considered together with review count.
  
* Pricing and rating patterns vary across restaurants, categories, and locations.





###### **📸 Project Screenshots**





1\. Data Quality Check



!\[Data Quality Check](Screenshot/01\_Data\_Quality\_Check.png)





2\. Duplicate Check



!\[Duplicate Check](Screenshot/02\_Duplicate\_Check.png)





3\. Data Model



!\[Data Model](Screenshot/03\_Data\_Model.png)





4\. Core KPIs



!\[Core KPIs](Screenshot/04\_Core\_KPIs.png)





5\. Location Analysis



!\[Location Analysis](Screenshot/05\_Location\_Analysis.png)





6\. Restaurant \& Category Analysis



!\[Restaurant \& Category Analysis](Screenshot/06\_Restaurant\_Category\_Analysis.png)





7\. Date \& Time Analysis



!\[Date \& Time Analysis](Screenshot/07\_Date\_Time\_Analysis.png)





8\. Advanced SQL Ranking



!\[Advanced SQL Ranking](Screenshot/08\_Advanced\_SQL\_Ranking.png)





###### **📂 Project Structure**



```text
Swiggy_SQL_Project/
│
├── Dataset/
│   ├── swiggy_data.csv
│   └── swiggy_data.sql
│
├── Screenshot/
│   ├── 01_Data_Quality_Check.png
│   ├── 02_Duplicate_Check.png
│   ├── 03_Data_Model.png
│   ├── 04_Core_KPIs.png
│   ├── 05_Location_Analysis.png
│   ├── 06_Restaurant_Category_Analysis.png
│   ├── 07_Date_Time_Analysis.png
│   └── 08_Advanced_SQL_Ranking.png
│
├── SQL_Queries/
│   └── swiggy_analysis.sql
│
├── Business_Requirements.docx
└── README.md
```





###### **📄 Project Files**



* Business Requirements: Business\_Requirements.docx
* Dataset: Dataset/
* SQL Queries: SQL\_Queries/swiggy\_analysis.sql
* Screenshots: Screenshot/





###### **🎓 Skills Demonstrated**



This project demonstrates practical experience in:



**SQL | MySQL | Data Cleaning | Data Modeling | Star Schema | KPI Analysis | Business Analysis | CTEs | Window Functions | Ranking | Time-Based Analysis**

