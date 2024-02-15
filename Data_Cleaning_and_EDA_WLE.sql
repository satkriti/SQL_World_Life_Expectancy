SELECT * FROM World_Life_Expectancy.worldlifeexpectancy;

-- PART 1 Data Cleaning

SELECT * FROM worldlifeexpectancy;

SELECT Country, Year, CONCAT(Country," ",Year), COUNT(CONCAT(Country," ",Year))
FROM worldlifeexpectancy
GROUP BY Country, Year, CONCAT(Country," ",Year)
HAVING COUNT(CONCAT(Country," ",Year))>1;

SELECT *
	FROM (SELECT Row_ID, 
	CONCAT(Country,Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country,Year)) AS row_num
	FROM worldlifeexpectancy) AS tab_1
    WHERE row_num>1;
    
DELETE FROM worldlifeexpectancy
WHERE Row_ID IN (
	SELECT Row_ID FROM (
		SELECT Row_ID, 
		CONCAT(Country,Year), 
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country,Year)) AS row_num
		FROM worldlifeexpectancy
	)AS tab_1 
WHERE row_num>1
);

SELECT * FROM worldlifeexpectancy
WHERE Status = '';

SELECT DISTINCT(Status) 
FROM worldlifeexpectancy
WHERE Status <> '';

SELECT DISTINCT(Country)
FROM worldlifeexpectancy
WHERE Status = 'Developing';

UPDATE worldlifeexpectancy
SET Status ='Developing'
WHERE Country IN (SELECT DISTINCT(Country)
				FROM worldlifeexpectancy
				WHERE Status = 'Developing');
                
UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
ON t1.Country = t2.Country
SET t1.Status ='Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
ON t1.Country = t2.Country
SET t1.Status ='Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

SELECT * 
FROM worldlifeexpectancy
WHERE `Life expectancy` = '';

SELECT t1.Country, t1.Year, t1.`Life Expectancy`, 
t2.Country, t2.Year, t2.`Life Expectancy`, 
t3.Country, t3.Year, t3.`Life Expectancy`,
ROUND((t2.`Life Expectancy` + t3.`Life Expectancy`)/2,1)
FROM worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
ON t1.Country = t2.Country
AND  t1.Year = t2.Year-1
JOIN worldlifeexpectancy t3
ON t1.Country = t3.Country
AND  t1.Year = t3.Year+1
WHERE t1.`Life expectancy` = '';

UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
ON t1.Country = t2.Country
AND  t1.Year = t2.Year-1
JOIN worldlifeexpectancy t3
ON t1.Country = t3.Country
AND  t1.Year = t3.Year+1
SET t1.`Life Expectancy` = ROUND((t2.`Life Expectancy` + t3.`Life Expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

-- PART 2: EDA

SELECT Country, MAX(`Life expectancy`), MIN(`Life expectancy`) 
FROM worldlifeexpectancy
GROUP BY Country
HAVING MAX(`Life expectancy`) <>0 
AND MIN(`Life expectancy`) <> 0
ORDER BY Country DESC;



SELECT Country, MAX(`Life expectancy`), MIN(`Life expectancy`),
ROUND(MAX(`Life expectancy`)-MIN(`Life expectancy`) ,2) AS Life_Incr_15_Yrs
FROM worldlifeexpectancy
GROUP BY Country
HAVING MAX(`Life expectancy`) <>0 
AND MIN(`Life expectancy`) <> 0
ORDER BY Life_Incr_15_Yrs DESC;

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM worldlifeexpectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year ;

-- CORRELATION

SELECT Country,ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM worldlifeexpectancy
GROUP BY Country
HAVING Life_Exp> 0 AND GDP>0 
ORDER BY  GDP DESC;

SELECT 
SUM(CASE
	WHEN GDP >= 1520 THEN 1 
	ELSE 0
END) High_GDP_Count
FROM worldlifeexpectancy;

SELECT 
SUM(CASE WHEN GDP >= 1520 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1520 THEN `Life Expectancy` ELSE NULL END) Avg_Life_Expectancy1,
SUM(CASE WHEN GDP < 1520 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP < 1520 THEN `Life Expectancy` ELSE NULL END) Avg_Life_Expectancy2
FROM worldlifeexpectancy;

SELECT * FROM worldlifeexpectancy;

SELECT Status,  ROUND(AVG(`Life expectancy`),1) AS Life_Exp
FROM worldlifeexpectancy
GROUP BY Status;

SELECT Status,  COUNT(DISTINCT(Country)), ROUND(AVG(`Life expectancy`),1) AS Life_Exp
FROM worldlifeexpectancy
GROUP BY Status;

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM worldlifeexpectancy
GROUP BY Country
HAVING Life_Exp> 0 AND BMI>0 
ORDER BY BMI DESC;

-- ROLLING TOTAL
SELECT Country,
Year,
`Life Expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_total
FROM worldlifeexpectancy;
-- look population data set courty wise and do more eda DIY