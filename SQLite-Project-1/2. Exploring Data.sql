/* While our new table, merged_data, isn't large that doesn't mean
   it can't be used to do interesting things. Let's ask some questions.*/
   
-- How much has the United States changed in 56 years?

EXPLAIN QUERY PLAN SELECT pop1960, pop2016
FROM merged_data
WHERE CountryCode = "USA";

-- Sadly our index didn't save us any time.

-- How many people have we added as a species?

SELECT
	SUM(pop1960)
FROM merged_data;

-- That's hard to read.

SELECT
	printf('%,d', SUM(pop1960))
AS total_sum
FROM merged_data;

-- 30 Billion People in 1960 doesn't sound right. Let's look closer.

SELECT CountryCode, CountryName, pop1960
FROM merged_data
WHERE pop1960 > 1.0E9;

/* And so we've discovered that our dataset has some issues. Despite it being labeled as countries it
   it also includes non-country categories. We have two ways of handling this.
   First, I can fetch the ISO 3166-1 alpha-3 list of country codes and then just compare those.
   I already imported a table with just those codes.*/
   
DELETE FROM merged_data
WHERE CountryCode NOT IN (
SELECT CountryCode FROM country_iso_codes
);

-- Now let's see what we've got.

SELECT 
	printf('%,d', SUM(pop1960))
AS total_sum
FROM merged_data;

-- That worked! So we don't need that table anymore.

DROP TABLE country_iso_codes;

-- So let's try all of that again. How many people have we added?

SELECT 
	printf('%,d', SUM(pop1960))
AS '1960_sum',
	printf('%,d', SUM(pop2016))
AS '2016_sum'
FROM merged_data;

-- That's a lot, but how many?
SELECT
	printf('%,d', (SUM(pop2016) - SUM(pop1960))) AS 'difference'
FROM merged_data

-- 4.4bn people is a pretty good amount. I'm curious which countries increased the most.
ALTER TABLE merged_data 
ADD COLUMN popChangePercent REAL;

UPDATE merged_data 
SET popChangePercent = ((pop2016 - pop1960) / pop1960) * 100;
	
SELECT CountryName, pop1960, pop2016, popChangePercent
	FROM merged_data
	ORDER BY popChangePercent DESC;
	
-- Props to the UAE, with an incredible 99x increase.

