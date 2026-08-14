-- =========================================================
-- DATA EXPLORATION
-- =========================================================

SELECT * FROM swiggy_data;

-- Row count
SELECT COUNT(*) AS Total_Menu_Records
FROM swiggy_data;


-- =========================================================
-- DATA CLEANING & VALIDATION
-- =========================================================

-- Null Values
SELECT
    SUM(State IS NULL) AS Null_State,
    SUM(City IS NULL) AS Null_City,
    SUM(Order_Date IS NULL) AS Null_Order_Date,
    SUM(Restaurant_Name IS NULL) AS Null_Restaurant,
    SUM(Category IS NULL) AS Null_Category,
    SUM(Dish_Name IS NULL) AS Null_Dish,
    SUM(Price_INR IS NULL) AS Null_Price,
    SUM(Rating IS NULL) AS Null_Rating,
    SUM(Rating_Count IS NULL) AS Null_Rating_Count
FROM swiggy_data;


-- Blank or Empty Strings
SELECT * 
FROM swiggy_data
WHERE 
State ='' OR Restaurant_Name = '' OR Location = '' OR Category = '' OR Dish_Name = '' ;


-- Duplicate Detection / Check
SELECT
    State, City, Order_Date, Restaurant_Name, Location,
    Category, Dish_Name, Price_INR, Rating, Rating_Count,
    COUNT(*) AS Duplicate_Rows
FROM swiggy_data
GROUP BY
    State, City, Order_Date, Restaurant_Name, Location,
    Category, Dish_Name, Price_INR, Rating, Rating_Count
HAVING COUNT(*) > 1
ORDER BY Duplicate_Rows DESC;


-- Delete Duplication
DELETE FROM swiggy_data
WHERE id IN ( 
    SELECT id
    FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY State, City, Order_Date, Restaurant_Name,
                                Location, Category, Dish_Name, Price_INR,
                                Rating, Rating_Count
                   ORDER BY id
               ) AS rn
        FROM swiggy_data
    ) AS temp
    WHERE rn > 1
);
   
   
-- =========================================================
-- DIMENSION TABLES
-- =========================================================

-- DATE TABLE
CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    Full_Date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter INT,
    Day INT,
    Week INT
);


-- dim_location
CREATE TABLE dim_location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    State VARCHAR(100),
    City VARCHAR(100),
    Location VARCHAR(200)
);


-- dim_restaurant
CREATE TABLE dim_restaurant (
    Restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    Restaurant_Name VARCHAR(200)
);


-- dim_category
CREATE TABLE dim_category (
    Category_id INT AUTO_INCREMENT PRIMARY KEY,
    Category VARCHAR(200)
);


-- dim_dish
CREATE TABLE dim_dish (
    dish_id INT AUTO_INCREMENT PRIMARY KEY,
    Dish_Name VARCHAR(200)
 );
 
-- =========================================================
-- FACT TABLE
-- =========================================================
 
 -- Grain:
-- One row represents one Swiggy menu-item listing
-- for a specific restaurant, dish, category,
-- location, and date.

CREATE TABLE fact_swiggy_menu (
    menu_item_id INT AUTO_INCREMENT PRIMARY KEY,

    date_id INT,
    Price_INR DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

SELECT * FROM fact_swiggy_menu;


-- =========================================================
-- DATA INSERTION
-- =========================================================

-- dim_date
INSERT INTO dim_date
    (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
    STR_TO_DATE(Order_Date, '%m/%d/%Y'),
    YEAR(STR_TO_DATE(Order_Date, '%m/%d/%Y')),
    MONTH(STR_TO_DATE(Order_Date, '%m/%d/%Y')),
    MONTHNAME(STR_TO_DATE(Order_Date, '%m/%d/%Y')),
    QUARTER(STR_TO_DATE(Order_Date, '%m/%d/%Y')),
    DAY(STR_TO_DATE(Order_Date, '%m/%d/%Y')),
    WEEK(STR_TO_DATE(Order_Date, '%m/%d/%Y'))
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

SELECT * FROM dim_date;


-- dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT
	State, 
    City,
    Location
FROM swiggy_data;

-- Verify dim_location
SELECT * FROM dim_location;


-- dim_restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT
	Restaurant_Name
FROM swiggy_data;

-- Verify dim_restaurant
SELECT * FROM dim_restaurant;


-- dim_category
INSERT INTO dim_category (Category)
SELECT DISTINCT
	Category
FROM swiggy_data;

-- Verify dim_category
SELECT * FROM dim_category;


-- dim_dish
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT
	Dish_Name
FROM swiggy_data;

-- Verify dim_dish
SELECT * FROM dim_dish;


-- fact_table
INSERT INTO fact_swiggy_menu
(
    date_id,
    Price_INR,
    Rating,
    Rating_Count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_Count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dish.dish_id
FROM swiggy_data s

JOIN dim_date dd
    ON dd.Full_Date = STR_TO_DATE(s.Order_Date, '%m/%d/%Y')

JOIN dim_location dl
    ON dl.State = s.State
    AND dl.City = s.City
    AND dl.Location = s.Location

JOIN dim_restaurant dr
    ON dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category dc
    ON dc.Category = s.Category

JOIN dim_dish dish
    ON dish.Dish_Name = s.Dish_Name;


-- Verify Fact Table
SELECT * FROM fact_swiggy_menu;


-- =========================================================
-- DATA VERIFICATION
-- =========================================================

-- Verify Fact Table with Dimension Tables
SELECT *
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
JOIN dim_location l
    ON f.location_id = l.location_id
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
JOIN dim_category c
    ON f.category_id = c.category_id
JOIN dim_dish di
    ON f.dish_id = di.dish_id;
    
    
-- =========================================================
-- CORE KPIs
-- =========================================================

-- Total Menu Records 
SELECT COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu;

-- Total_Restaurants
SELECT COUNT(DISTINCT restaurant_id) AS Total_Restaurants
FROM fact_swiggy_menu;

-- Total_Dishes
SELECT COUNT(DISTINCT dish_id) AS Total_Dishes
FROM fact_swiggy_menu;

-- Total_Locations
SELECT COUNT(DISTINCT location_id) AS Total_Locations
FROM fact_swiggy_menu;

-- Total_Categories
SELECT COUNT(DISTINCT category_id) AS Total_Categories
FROM fact_swiggy_menu;

-- Average_Menu_Price
SELECT ROUND(AVG(Price_INR), 2) AS Average_Menu_Price
FROM fact_swiggy_menu;


-- =========================================================
-- PRICE ANALYSIS
-- =========================================================

-- Overall Price Statistics
SELECT
    MIN(Price_INR) AS Minimum_Price,
    ROUND(AVG(Price_INR), 2) AS Average_Price,
    MAX(Price_INR) AS Maximum_Price
FROM fact_swiggy_menu;


-- Top Restaurants by Average Menu Price
SELECT
    r.Restaurant_Name,
    COUNT(*) AS Menu_Items,
    ROUND(AVG(f.Price_INR), 2) AS Average_Price
FROM fact_swiggy_menu f
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
GROUP BY r.Restaurant_Name
HAVING COUNT(*) >= 5
ORDER BY Average_Price DESC
LIMIT 10;


-- Average Price by Category
SELECT
    c.Category,
    COUNT(*) AS Menu_Items,
    ROUND(AVG(f.Price_INR), 2) AS Average_Price
FROM fact_swiggy_menu f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY c.Category
HAVING COUNT(*) >= 10
ORDER BY Average_Price DESC
LIMIT 20;


-- =========================================================
-- LOCATION-BASED ANALYSIS
-- =========================================================
 
-- Top 10 cities by menu records
SELECT
    l.City,
    COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.City
ORDER BY
    Total_Menu_Records DESC
LIMIT 10;


-- Top 10 cities by average menu price
SELECT
    l.City,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price
FROM fact_swiggy_menu f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.City
ORDER BY
    Average_Menu_Price DESC
LIMIT 10;


-- City-wise Restaurant Coverage and Rating Analysis
SELECT
    l.City,
    COUNT(DISTINCT f.restaurant_id) AS Total_Restaurants,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY l.City
ORDER BY Total_Restaurants DESC
LIMIT 20;


-- Average menu price by state
SELECT
    l.State,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price
FROM fact_swiggy_menu f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.State
ORDER BY
    Average_Menu_Price DESC
LIMIT 10;


-- State-wise Restaurant Coverage and Rating Analysis
SELECT
    l.State,
    COUNT(DISTINCT f.restaurant_id) AS Total_Restaurants,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.State
ORDER BY
    Total_Restaurants DESC
LIMIT 10;


-- =========================================================
-- FOOD & CATEGORY ANALYSIS
-- =========================================================

-- Top 10 restaurants by menu records
SELECT
    r.Restaurant_Name,
    COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu f
JOIN dim_restaurant r
    ON r.restaurant_id = f.restaurant_id
GROUP BY
    r.Restaurant_Name
ORDER BY
    Total_Menu_Records DESC
LIMIT 10;
 
 
 -- Restaurant Performance: Menu Size, Price and Rating
SELECT
    r.Restaurant_Name,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_restaurant r
    ON r.restaurant_id = f.restaurant_id
GROUP BY
    r.Restaurant_Name
HAVING SUM(f.Rating_Count) >= 100
ORDER BY
    Average_Rating DESC,
    Total_Ratings DESC
LIMIT 10;


-- Top Rated Restaurants with Sufficient Review Volume
SELECT
    r.Restaurant_Name,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price
FROM fact_swiggy_menu f
JOIN dim_restaurant r
    ON r.restaurant_id = f.restaurant_id
WHERE f.Rating IS NOT NULL
  AND f.Rating > 0
GROUP BY
    r.Restaurant_Name
HAVING SUM(f.Rating_Count) >= 100
ORDER BY
    Average_Rating DESC,
    Total_Ratings DESC
LIMIT 10;


-- Top categories by menu records
SELECT
    c.Category,
    COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY
    c.Category
ORDER BY
    Total_Menu_Records DESC;
    
    
-- Category Performance Analysis
SELECT
    c.Category,
    COUNT(DISTINCT f.restaurant_id) AS Total_Restaurants,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY
    c.Category
ORDER BY
    Total_Menu_Records DESC
LIMIT 20;


-- =========================================================
-- DISH ANALYSIS
-- =========================================================

-- Most Listed Dishes
SELECT
    d.Dish_Name,
    COUNT(*) AS Listing_Count
FROM fact_swiggy_menu f
JOIN dim_dish d
    ON f.dish_id = d.dish_id
GROUP BY
    d.Dish_Name
ORDER BY
    Listing_Count DESC;
    
    
-- TOP 10 Most Listed Dishes
SELECT
    d.Dish_Name,
    COUNT(*) AS Listing_Count
FROM fact_swiggy_menu f
JOIN dim_dish d
    ON f.dish_id = d.dish_id
GROUP BY
    d.Dish_Name
ORDER BY
    Listing_Count DESC
LIMIT 10;  


-- Top Rated Dishes with Sufficient Review Volume
SELECT
    d.Dish_Name,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings,
    COUNT(*) AS Listing_Count,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price
FROM fact_swiggy_menu f
JOIN dim_dish d
    ON f.dish_id = d.dish_id
WHERE f.Rating IS NOT NULL
  AND f.Rating > 0
GROUP BY
    d.Dish_Name
HAVING SUM(f.Rating_Count) >= 100
ORDER BY
    Average_Rating DESC,
    Total_Ratings DESC
LIMIT 20;


-- Rating Count Distribution (1-5)
SELECT
    Rating,
    COUNT(*) AS Number_of_Menu_Records
FROM fact_swiggy_menu
GROUP BY Rating
ORDER BY Rating;


-- =========================================================
-- DATE / TIME ANALYSIS
-- =========================================================

-- Monthly menu record trends
SELECT
    d.Year,
    d.Month,
    d.Month_Name,
    COUNT(*) AS Menu_Records
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY d.Year, d.Month, d.Month_Name
ORDER BY d.Year, d.Month;


-- Monthly Price and Rating Analysis
SELECT
    d.Year,
    d.Month,
    d.Month_Name,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.Year,
    d.Month,
    d.Month_Name
ORDER BY
    d.Year,
    d.Month;
    
        
-- Quarterly Menu Record Trends
SELECT
    d.Year,
    d.Quarter,
    COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.Year,
    d.Quarter
ORDER BY
    d.Year,
    d.Quarter;
    
    
-- Quarterly Price and Rating Analysis
SELECT
    d.Year,
    d.Quarter,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.Year,
    d.Quarter
ORDER BY
    d.Year,
    d.Quarter;
    

-- Menu Records by Day of Week
SELECT
    DAYNAME(d.Full_Date) AS Day_Name,
    COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    DAYOFWEEK(d.Full_Date),
    DAYNAME(d.Full_Date)
ORDER BY
    DAYOFWEEK(d.Full_Date);
    
    
-- Day-wise Price and Rating Analysis
SELECT
    DAYNAME(d.Full_Date) AS Day_Name,
    COUNT(*) AS Total_Menu_Records,
    ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    DAYOFWEEK(d.Full_Date),
    DAYNAME(d.Full_Date)
ORDER BY
    DAYOFWEEK(d.Full_Date);
    

-- =========================================================
-- ADVANCE SQL ANALYSIS
-- =========================================================
    
-- Restaurant Ranking by Average Rating
WITH restaurant_rating AS (
    SELECT
        r.Restaurant_Name,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    JOIN dim_restaurant r
        ON f.restaurant_id = r.restaurant_id
    WHERE f.Rating IS NOT NULL
      AND f.Rating > 0
    GROUP BY
        r.Restaurant_Name
    HAVING SUM(f.Rating_Count) >= 100
)
SELECT
    Restaurant_Name,
    Average_Rating,
    Total_Ratings,
    RANK() OVER (
        ORDER BY Average_Rating DESC, Total_Ratings DESC
    ) AS Restaurant_Rank
FROM restaurant_rating
ORDER BY Restaurant_Rank
LIMIT 20;


-- Dish Ranking by Average Rating
WITH dish_rating AS (
    SELECT
        d.Dish_Name,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    JOIN dim_dish d
        ON f.dish_id = d.dish_id
    WHERE f.Rating IS NOT NULL
      AND f.Rating > 0
    GROUP BY
        d.Dish_Name
    HAVING SUM(f.Rating_Count) >= 100
)
SELECT
    Dish_Name,
    Average_Rating,
    Total_Ratings,
    RANK() OVER (
        ORDER BY Average_Rating DESC, Total_Ratings DESC
    ) AS Dish_Rank
FROM dish_rating
ORDER BY Dish_Rank
LIMIT 20;


-- Category Ranking by Average Rating
WITH category_rating AS (
    SELECT
        c.Category,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    JOIN dim_category c
        ON f.category_id = c.category_id
    WHERE f.Rating IS NOT NULL
      AND f.Rating > 0
    GROUP BY
        c.Category
    HAVING SUM(f.Rating_Count) >= 100
)
SELECT
    Category,
    Average_Rating,
    Total_Ratings,
    RANK() OVER (
        ORDER BY Average_Rating DESC, Total_Ratings DESC
    ) AS Category_Rank
FROM category_rating
ORDER BY Category_Rank
LIMIT 20;


-- Price Range Performance Analysis
WITH price_range_data AS (
    SELECT
        CASE
            WHEN f.Price_INR < 100 THEN 'Under 100'
            WHEN f.Price_INR BETWEEN 100 AND 199 THEN '100 - 199'
            WHEN f.Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
            WHEN f.Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
            ELSE '500+'
        END AS Price_Range,
        COUNT(*) AS Total_Menu_Records,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    GROUP BY
        CASE
            WHEN f.Price_INR < 100 THEN 'Under 100'
            WHEN f.Price_INR BETWEEN 100 AND 199 THEN '100 - 199'
            WHEN f.Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
            WHEN f.Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
            ELSE '500+'
        END
)
SELECT
    Price_Range,
    Total_Menu_Records,
    Average_Rating,
    Total_Ratings,
    RANK() OVER (
        ORDER BY Average_Rating DESC
    ) AS Price_Range_Rank
FROM price_range_data
ORDER BY Price_Range_Rank;


-- City Ranking by Average Rating
WITH city_rating AS (
    SELECT
        l.City,
        COUNT(DISTINCT f.restaurant_id) AS Total_Restaurants,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    JOIN dim_location l
        ON f.location_id = l.location_id
    WHERE f.Rating IS NOT NULL
      AND f.Rating > 0
    GROUP BY
        l.City
    HAVING SUM(f.Rating_Count) >= 100
)
SELECT
    City,
    Total_Restaurants,
    Average_Rating,
    Total_Ratings,
    RANK() OVER (
        ORDER BY Average_Rating DESC, Total_Ratings DESC
    ) AS City_Rank
FROM city_rating
ORDER BY City_Rank
LIMIT 20;


-- State Ranking by Average Rating
WITH state_rating AS (
    SELECT
        l.State,
        COUNT(DISTINCT f.restaurant_id) AS Total_Restaurants,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    JOIN dim_location l
        ON f.location_id = l.location_id
    WHERE f.Rating IS NOT NULL
      AND f.Rating > 0
    GROUP BY
        l.State
    HAVING SUM(f.Rating_Count) >= 100
)
SELECT
    State,
    Total_Restaurants,
    Average_Rating,
    Total_Ratings,
    RANK() OVER (
        ORDER BY Average_Rating DESC, Total_Ratings DESC
    ) AS State_Rank
FROM state_rating
ORDER BY State_Rank
LIMIT 20;


-- Month-over-Month Menu Record Analysis
WITH monthly_data AS (
    SELECT
        d.Year,
        d.Month,
        d.Month_Name,
        COUNT(*) AS Total_Menu_Records
    FROM fact_swiggy_menu f
    JOIN dim_date d
        ON f.date_id = d.date_id
    GROUP BY
        d.Year,
        d.Month,
        d.Month_Name
),
monthly_comparison AS (
    SELECT
        Year,
        Month,
        Month_Name,
        Total_Menu_Records,
        LAG(Total_Menu_Records) OVER (
            ORDER BY Year, Month
        ) AS Previous_Month_Records
    FROM monthly_data
)
SELECT
    Year,
    Month,
    Month_Name,
    Total_Menu_Records,
    Previous_Month_Records,
    Total_Menu_Records - Previous_Month_Records AS Record_Change,
    ROUND(
        (Total_Menu_Records - Previous_Month_Records) * 100.0
        / NULLIF(Previous_Month_Records, 0),
        2
    ) AS MoM_Growth_Percent
FROM monthly_comparison
ORDER BY Year, Month;


-- Restaurant Performance by Price Range
WITH restaurant_price AS (
    SELECT
        r.Restaurant_Name,
        CASE
            WHEN AVG(f.Price_INR) < 100 THEN 'Under 100'
            WHEN AVG(f.Price_INR) BETWEEN 100 AND 199 THEN '100 - 199'
            WHEN AVG(f.Price_INR) BETWEEN 200 AND 299 THEN '200 - 299'
            WHEN AVG(f.Price_INR) BETWEEN 300 AND 499 THEN '300 - 499'
            ELSE '500+'
        END AS Price_Range,
        ROUND(AVG(f.Price_INR), 2) AS Average_Menu_Price,
        ROUND(AVG(f.Rating), 2) AS Average_Rating,
        SUM(f.Rating_Count) AS Total_Ratings
    FROM fact_swiggy_menu f
    JOIN dim_restaurant r
        ON f.restaurant_id = r.restaurant_id
    WHERE f.Price_INR IS NOT NULL
      AND f.Rating IS NOT NULL
    GROUP BY
        r.Restaurant_Name
    HAVING SUM(f.Rating_Count) >= 100
)
SELECT
    Price_Range,
    COUNT(*) AS Total_Restaurants,
    ROUND(AVG(Average_Menu_Price), 2) AS Avg_Restaurant_Price,
    ROUND(AVG(Average_Rating), 2) AS Avg_Restaurant_Rating,
    SUM(Total_Ratings) AS Total_Ratings
FROM restaurant_price
GROUP BY
    Price_Range
ORDER BY
    Avg_Restaurant_Rating DESC;
    

-- Menu Records by Price Range
SELECT
    CASE
        WHEN Price_INR < 100 THEN 'Under 100'
        WHEN Price_INR BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END AS Price_Range,
    COUNT(*) AS Total_Menu_Records
FROM fact_swiggy_menu
GROUP BY
    CASE
        WHEN Price_INR < 100 THEN 'Under 100'
        WHEN Price_INR BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END
ORDER BY
    Total_Menu_Records DESC;
    

-- Affordable & Well-Rated Restaurants
SELECT
    r.Restaurant_Name,
    ROUND(AVG(f.Price_INR), 2) AS Average_Price,
    ROUND(AVG(f.Rating), 2) AS Average_Rating,
    SUM(f.Rating_Count) AS Total_Ratings
FROM fact_swiggy_menu f
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
GROUP BY r.Restaurant_Name
HAVING AVG(f.Price_INR) <= 300
   AND AVG(f.Rating) >= 4.0
   AND SUM(f.Rating_Count) >= 50
ORDER BY Average_Rating DESC, Average_Price ASC;


-- =========================================================
-- BUSINESS INSIGHTS
-- =========================================================

-- 1. Restaurant Insights

-- Insight 1:
-- McDonald's has the highest menu-record presence with 13,528 records,
-- followed by KFC with 12,957 and Burger King with 7,115 records.
-- This indicates that these major QSR brands have the strongest
-- representation in the dataset.


-- 2. Location Insights

-- Insight 2:
-- Bengaluru has the highest menu-record volume with 20,072 records,
-- almost twice the volume of Mumbai (10,507), the second-highest city.
-- This indicates that Bengaluru has a particularly strong representation
-- in the dataset.


-- 3. Category & Dish Insights

-- Insight 3:
-- Several dishes achieved an average rating of 5.00, with Namakpara,
-- Pork American Chopsuey and Tender Coconut Ice Cream among the
-- highest-ranked dishes. However, their review volumes are relatively
-- small, ranging from 103 to 260 ratings, so the results should be
-- interpreted as high customer ratings rather than overall popularity.


-- Insight 4:
-- The highest-rated categories in the dataset achieve ratings
-- between 4.80 and 4.95. Set Menu (served With Rice,miso Soup)
-- ranks first with a 4.95 average rating and 246 total ratings.
-- Dairy Products has a slightly lower average rating of 4.81
-- but has a much higher review volume of 3,601 ratings, indicating
-- stronger rating coverage than the highest-ranked categories.


-- 4. Price & Rating Insights

-- Insight 5:
-- The ₹500+ price range has the highest average rating at 4.39,
-- followed by the Under ₹100 and ₹300–499 ranges at 4.35.
-- The Under ₹100 range has 26,796 menu records and the highest
-- review volume at 1,253,614 ratings, indicating strong representation
-- and customer engagement for lower-priced items.


-- 5. Time-based Insights

-- Insight 6:
-- January 2025 recorded the highest monthly menu-record volume
-- with 25,393 records, while February had the lowest with 23,292.
-- After the February decline, menu-record volume generally recovered,
-- reaching 25,227 records in August.


