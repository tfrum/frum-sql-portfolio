/* While our new table, merged_data, isn't large that doesn't mean
   it can't be used to do interesting things. Let's ask some questions.*/
   
-- How much has the United States changed in 56 years?

EXPLAIN QUERY PLAN SELECT pop1960, pop2016
FROM merged_data
WHERE CountryCode = "USA";

-- Sadly our index didn't save us any time.

-- How many people have we added as a species?

SELECT SUM(pop1960)
FROM merged_data;

-- That's hard to read.

SELECT printf('%,d', SUM(pop1960))
as total_sum
FROM merged_data;

-- 30 Billion People in 1960 doesn't sound right. Let's look closer.

SELECT CountryCode, CountryName, pop1960
FROM merged_data
WHERE pop1960 > 1.0E9;

/* And so we've discovered that our dataset has some issues. Despite it being labeled as countries it
   it also includes non-country categories. We have two ways of handling this.
   First, I can fetch the ISO 3166-1 alpha-3 list of country codes and then just compare those.*/
   
DELETE FROM merged_data
WHERE CountryCode NOT IN (
	SELECT CountryCode FROM country_iso_codes
);

-- Now let's see what we've got.

SELECT printf('%,d', SUM(pop1960))
as total_sum
FROM merged_data;
