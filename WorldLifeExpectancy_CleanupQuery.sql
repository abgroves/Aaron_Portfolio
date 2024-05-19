# WORLD LIFE EXPECTANCY PROJECT (DATA CLEANING)

SELECT *
FROM world_life_expectancy
;

# Checking if any rows are duplicates, concatonating country and year
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year)) as countrydup
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

#Creating a row ID for the duplicate via partion, using query to identify duplicates
SELECT *
FROM (
    SELECT Row_ID, 
    CONCAT(Country, Year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as row_num
    FROM world_life_expectancy
    ) as row_table
WHERE row_num > 1
;

# Deleting the duplicates via the above queries
DELETE FROM world_life_expectancy 
WHERE 
    Row_ID IN (
    SELECT Row_ID
FROM (
    SELECT Row_ID, 
    CONCAT(Country, Year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as row_num
    FROM world_life_expectancy
    ) as row_table
WHERE row_num > 1
)
;

# Identifying rows with blank status fields
SELECT *
From world_life_expectancy
WHERE Status = ''
;

# Which fields should status be? Answer - Developed or Developing
SELECT DISTINCT(Status)
From world_life_expectancy
WHERE Status <> ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

#Fill the null status fields. Gives Error
UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
        FROM world_life_expectancy
        WHERE Status = 'Developing'
;

# Workaround - Join table to itself. Only updates Developed
UPDATE world_life_expectancy T1
JOIN world_life_expectancy T2
    ON T1.Country = T2.Country
SET T1.STATUS = 'Developing'
WHERE T1.Status = ''
AND T2.Status <> ''
AND T2.Status = 'Developing'
;

#Doing the same for Developed
UPDATE world_life_expectancy T1
JOIN world_life_expectancy T2
    ON T1.Country = T2.Country
SET T1.STATUS = 'Developed'
WHERE T1.Status = ''
AND T2.Status <> ''
AND T2.Status = 'Developed'
;

SELECT *
FROM world_life_expectancy
;

#Identifying blanks in world expectancy column. Need to use tilde key since no underscore
SELECT * 
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
;

#analyzing data, it makes sense to use average of prev. year and next year to fill empty fields
SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
;

#To populate blanks, joining table on itself like previously
SELECT t1.Country, t1.Year, t1.`Life expectancy`
, t2.Country, t2.Year, t2.`Life expectancy`
, t3.Country, t3.Year, t3.`Life expectancy`
,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
    ;
    
#update field using above query 
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

