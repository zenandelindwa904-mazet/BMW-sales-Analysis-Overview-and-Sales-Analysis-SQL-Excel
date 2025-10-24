USE BMW_sales
GO

SELECT * FROM dbo.BMW_sales_data;

-- the total number of bmw vehicles sold between 2010 and 2024

SELECT year, COUNT(*) AS Vehicles_Sold
FROM BMW_sales_data 
WHERE Year BETWEEN 2010 AND 2024
GROUP BY Year
ORDER BY Year;

--calcutating the avg selling price across all years

SELECT Year, AVG(Price_USD) AS Avg_selling_price
FROM BMW_Sales_Data
GROUP BY Year
ORDER BY Year;

--showing the top 5 years with highest sales volume 
SELECT TOP 5 Year, SUM(Sales_Volume) AS Total_sales_volume
FROM BMW_Sales_Data
GROUP BY Year
ORDER BY Total_sales_volume DESC;

--showing bmw model with the highest sales overall
SELECT  model,SUM(Sales_Volume) AS Total_sales
FROM BMW_Sales_Data
GROUP BY model
ORDER BY Total_sales ,Model DESC;

-- the most common transmission and fuel type sold globally?

WITH RegionalTransmission AS (
    SELECT 
        Region, 
        Transmission, 
        SUM(Sales_Volume) AS Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY SUM(Sales_Volume) DESC) AS rn
    FROM dbo.BMW_Sales_Data
    GROUP BY Region, Transmission
)
SELECT Region, Transmission, Total_Sales
FROM RegionalTransmission
WHERE rn = 1;

WITH RegionalFuel AS (
    SELECT 
        Region, 
        Fuel_Type, 
        SUM(Sales_Volume) AS Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Region ORDER BY SUM(Sales_Volume) DESC) AS rn
    FROM BMW_Sales_Data
    GROUP BY Region, Fuel_Type
)
SELECT Region, Fuel_Type, Total_Sales
FROM RegionalFuel
WHERE rn = 1;

--2. pricing over the years
--showing the relationship between mileage KM and price USD and the total sales generated from them
SELECT 
   Mileage_KM,
    Price_USD,
    SUM(Sales_Volume) AS Total_Sales
FROM BMW_Sales_Data
GROUP BY Mileage_KM,Price_USD
ORDER BY Mileage_KM,Price_USD;
--showing how transmition type manual and automatic influence the price of a vehicle
SELECT 
    Transmission,
    ROUND(AVG(Price_USD), 2) AS Avg_Price_USD,
    MIN(Price_USD) AS Min_Price_USD,
    MAX(Price_USD) AS Max_Price_USD,
    SUM(Sales_Volume) AS Total_Sales
FROM BMW_Sales_Data
WHERE  Transmission IN ('AUTOMATIC', 'MANUAL')
GROUP BY Transmission
ORDER BY Avg_Price_USD DESC;
--3.comparing bmw sales across different regions 
--showing how sales volumes changed by region over time
SELECT
     Region,
     Year,
     SUM(Sales_Volume) AS Regional_sales
FROM  BMW_Sales_Data
GROUP BY Region,Year
ORDER BY Regional_sales DESC;
--trends and preference analysis
-- showing How has fuel type preference changed between 2010 and 2024

 WITH YearlySales AS (
    SELECT
        Year,
        Fuel_Type,
        SUM(Sales_Volume) AS Total_Sales
    FROM BMW_Sales_Data
    WHERE Year BETWEEN 2010 AND 2024
    GROUP BY Year, Fuel_Type
),
TotalByYear AS (
    SELECT
        Year,
        SUM(Total_Sales) AS Year_Total
    FROM YearlySales
    GROUP BY Year
)
SELECT
    y.Year,
    y.Fuel_Type,
    y.Total_Sales,
    ROUND(100.0 * y.Total_Sales / t.Year_Total, 2) AS Market_Share_Percentage
FROM YearlySales y
JOIN TotalByYear t ON y.Year = t.Year
ORDER BY y.Year ASC, Market_Share_Percentage DESC;
---showing model that gained popularity during the years with high sales increase
WITH ModelSales AS (
    SELECT 
        Model,
        Year,
        SUM(Sales_Volume) AS Total_Sales
    FROM BMW_Sales_Data
    GROUP BY Model, Year
),
ModelGrowth AS (
    SELECT
        Model,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (PARTITION BY Model ORDER BY Year) AS Prev_Year_Sales,
        (Total_Sales - LAG(Total_Sales) OVER (PARTITION BY Model ORDER BY Year)) AS Sales_Increase
    FROM ModelSales
)
SELECT TOP 1
    Model,
    Year,
    Sales_Increase
FROM ModelGrowth
WHERE Sales_Increase IS NOT NULL
ORDER BY Sales_Increase DESC;
--showing the year with most sales and high revenue generated
SELECT TOP 5
    Year,
    SUM(CAST(Price_USD AS BIGINT) * CAST(Sales_Volume AS BIGINT)) AS Total_Revenue
FROM BMW_Sales_Data
GROUP BY Year
ORDER BY Total_Revenue DESC;
--  showing Which models or fuel types show the strongest growth trend

WITH ModelSales AS (
    SELECT 
        Model,
        Fuel_Type,
        Year,
        SUM(Sales_Volume) AS Total_Sales
    FROM BMW_Sales_Data
    GROUP BY Model, Fuel_Type, Year
),
ModelGrowth AS (
    SELECT
        Model,
        Fuel_Type,
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (PARTITION BY Model ORDER BY Year) AS Prev_Year_Sales,
        Total_Sales - LAG(Total_Sales) OVER (PARTITION BY Model ORDER BY Year) AS Sales_Increase
    FROM ModelSales
)
SELECT TOP 5
    Model,
    Fuel_Type,
    Year,
    Sales_Increase
FROM ModelGrowth
WHERE Sales_Increase > 0
ORDER BY Sales_Increase DESC;








