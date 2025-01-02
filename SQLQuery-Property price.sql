Select * from untidy_combined_toronto_property_data

-- Clean data:

SELECT bedrooms,
       CASE 
           WHEN CHARINDEX('+', bedrooms) > 0 
           THEN LEFT(bedrooms, CHARINDEX('+', bedrooms) - 1)
           ELSE bedrooms
       END AS cleaned_bedrooms
FROM untidy_combined_toronto_property_data

--add a new column:
ALTER TABLE untidy_combined_toronto_property_data
ADD cleaned_bedrooms VARCHAR(255); 

UPDATE untidy_combined_toronto_property_data
SET cleaned_bedrooms = CASE 
    WHEN CHARINDEX('+', bedrooms) > 0 
    THEN LEFT(bedrooms, CHARINDEX('+', bedrooms) - 1)
    ELSE bedrooms
END;

SELECT bedrooms, cleaned_bedrooms
FROM untidy_combined_toronto_property_data;



--Change the price to million and integer:


SELECT *
FROM untidy_combined_toronto_property_data
WHERE ISNUMERIC(price) = 0 AND price IS NOT NULL;

-- Remove Rows with Non-Numerical Values

DELETE FROM untidy_combined_toronto_property_data
WHERE ISNUMERIC(price) = 0;

-- Clean the numbers with commas:

UPDATE untidy_combined_toronto_property_data
SET price = REPLACE(price, ',', '')
WHERE price LIKE '%,%';

Select CAST(price as float) from untidy_combined_toronto_property_data



-- Drop rows with null values

DELETE FROM untidy_combined_toronto_property_data
WHERE price IS NULL OR bedrooms IS NULL;

--Analysing:


Select price, region, cleaned_bedrooms from untidy_combined_toronto_property_data 
where price>1000000

Select price, cleaned_bedrooms, region from untidy_combined_toronto_property_data 
where region ='Ajax, ON'
order by cast(price as float) DESC

-- Average price by region
SELECT region, 
       AVG(cast(price as int)) AS average_price
FROM untidy_combined_toronto_property_data
GROUP BY region
ORDER BY average_price DESC;

-- Price Per Bedroom

SELECT address, 
       region, 
       price, 
       cleaned_bedrooms, 
       cast(price as int) / cast(cleaned_bedrooms as int) AS price_per_bedroom
FROM untidy_combined_toronto_property_data
WHERE cleaned_bedrooms > 0
ORDER BY price_per_bedroom DESC;


-- Most Expensive Properties in Each Region
SELECT region, 
       address, 
       price
FROM (
    SELECT region, 
           address, 
           price, 
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY price DESC) AS rank
    FROM untidy_combined_toronto_property_data
) ranked
WHERE rank <= 3
ORDER BY region, rank;

