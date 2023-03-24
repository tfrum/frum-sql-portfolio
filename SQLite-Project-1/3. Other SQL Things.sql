/* Our tables have some issues if we want to use them to do research. 
   While we don't need a primary key here given the nature of the data 
   we should probably have one, still.*/
  
PRAGMA table_info(merged_data);

/* We don't have a primary key. Unfortunately setting one is kind of messy in SQLite.
   So if this were a really big dataset I'd want to brute force this a little. Perhaps like this:*/
   
SELECT group_concat('	' || name || ' REAL' , ',' || char(10))
FROM pragma_table_info('merged_data')
WHERE type <> 'TEXT';

-- That did a *lot* of work for me even given how small this dataset is.

/*	pop1960 REAL,
	pop2016 REAL,
	fert1960 REAL,
	fert2016 REAL,
	life1960 REAL,
	life2016 REAL,
	popChangePercent REAL */
	
-- Now I want to create the new table with that time saver.

CREATE TABLE merged_data_new (
	CountryName TEXT,
	CountryCode TEXT PRIMARY KEY,
	pop1960 REAL,
	pop2016 REAL,
	fert1960 REAL,
	fert2016 REAL,
	life1960 REAL,
	life2016 REAL,
	popChangePercent REAL
);

-- Now I can fill the new table with data.

INSERT INTO merged_data_new
SELECT *
FROM merged_data;

SELECT * FROM merged_data_new;

-- And we have a primary key now, right?
PRAGMA table_info(merged_data_new);

-- We do!
DROP TABLE merged_data;
ALTER TABLE merged_data_new RENAME TO merged_data;

/* Now, it might have been good to do something like make 
   CountryCode and CountryName a composite key. However, country codes are 
   by-definition unique and we don't get a lot of new countries!*/
   








