/* In this project I'm going to process
   and reorganize three tables of demographic data
   sourced from Kaggle. The code is SQLite and the project
   is being done in DB Browser.
   
   I've included the unmodified CSV files.*/

/* We'll need to combine them all according to a common key.
   But first I need to inspect and reorganize my data.
   about what data I'll I use from this database.*/
   
SELECT *
FROM country_population, fertility_rate, life_expectancy;

/* We have a problem before we combine these tables. 
   They share a *lot* of keys since the data is organized by year.
   
   Another issue is that some of those decimal places are extremely long.
   I should truncate those, but I'll do that later.*/

/* We'll do some cleaning. We don't need these indicator columns since 
   we can know that in other ways. Unfortunately SQLite isn't concise here.*/

ALTER TABLE country_population
DROP COLUMN IndicatorName;

ALTER TABLE country_population
DROP COLUMN IndicatorCode;

ALTER TABLE fertility_rate
DROP COLUMN IndicatorName;

ALTER TABLE fertility_rate
DROP COLUMN IndicatorCode;

ALTER TABLE life_expectancy
DROP COLUMN IndicatorName;

ALTER TABLE life_expectancy
DROP COLUMN IndicatorCode;

/* At this point I would normally turn to a python script to automate this.
   Instead let's just limit the scope a bit to a couple of years. Our first and last.*/
   
ALTER TABLE country_population
RENAME COLUMN "2016" TO pop2016;

ALTER TABLE country_population
RENAME COLUMN "1960" TO pop1960;

ALTER TABLE fertility_rate
RENAME COLUMN "2016" TO fert2016;

ALTER TABLE fertility_rate
RENAME COLUMN "1960" TO fert1960;

ALTER TABLE life_expectancy
RENAME COLUMN "2016" TO life2016;

ALTER TABLE life_expectancy
RENAME COLUMN "1960" TO life1960;

-- Now let's merge these tables together.

/* If I weren't using SQLite I would do this differently. This is another opportunity to use Python
   to automate the query for a larger database. */

-- I want to make a table to merge the data into. 
CREATE TABLE merged_data (
  CountryName TEXT,
  CountryCode TEXT,
  pop1960 REAL,
  pop2016 REAL,
  fert1960 REAL,
  fert2016 REAL,
  life1960 REAL,
  life2016 REAL
);

-- Now let's fill this table with data.

INSERT INTO merged_data
SELECT  c.CountryName, c.CountryCode,
        p.pop1960, p.pop2016,
        f.fert1960, f.fert2016,
        l.life1960, l.life2016
FROM country_population p
INNER JOIN fertility_rate f ON p.CountryCode = f.CountryCode AND p.CountryName = f.CountryName
INNER JOIN life_expectancy l ON p.CountryCode = l.CountryCode AND p.CountryName = l.CountryName
INNER JOIN (
  SELECT DISTINCT CountryCode, CountryName
  FROM country_population
) c ON p.CountryCode = c.CountryCode AND p.CountryName = c.CountryName;

-- So did that work?


-- It did! But now I want to do something about these decimal points.

/* I could manually do this, or generate a large query, or use python.
   However I want to move a little out of my comfort zone here. */
   
SELECT group_concat('UPDATE merged_data SET "' || name || '" = ROUND("' || name || '", 3); ', '') 
FROM pragma_table_info('merged_data');

/* This is another place where SQLite has some limitations. AFAIK you can't assign the statement that 
   was just generated to a variable to execute automatically here. */
   
/* The resulting code from that statement:   
   UPDATE merged_data SET "CountryName" = ROUND("CountryName", 3);
   UPDATE merged_data SET "CountryCode" = ROUND("CountryCode", 3);
   UPDATE merged_data SET "pop1960" = ROUND("pop1960", 3);
   UPDATE merged_data SET "pop2016" = ROUND("pop2016", 3);
   UPDATE merged_data SET "fert1960" = ROUND("fert1960", 3);
   UPDATE merged_data SET "fert2016" = ROUND("fert2016", 3);
   UPDATE merged_data SET "life1960" = ROUND("life1960", 3);
   UPDATE merged_data SET "life2016" = ROUND("life2016", 3); 
   
   So why did I comment that? Well, it'll ruin our table, that's why! I can't round a string!
   This is another limitation of SQLite.*/

SELECT group_concat('UPDATE merged_data SET "' || name || '" = ROUND("' || name || '", 3); ', '') 
FROM pragma_table_info('merged_data')
WHERE type <> 'TEXT';

-- That's better. We get this as our concatenated statement:
UPDATE merged_data SET "pop1960" = ROUND("pop1960", 3); 
UPDATE merged_data SET "pop2016" = ROUND("pop2016", 3); 
UPDATE merged_data SET "fert1960" = ROUND("fert1960", 3); 
UPDATE merged_data SET "fert2016" = ROUND("fert2016", 3); 
UPDATE merged_data SET "life1960" = ROUND("life1960", 3); 
UPDATE merged_data SET "life2016" = ROUND("life2016", 3); 
   
SELECT *
FROM merged_data;

-- That worked perfectly!


