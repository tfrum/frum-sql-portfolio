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

INTERT INTO merged_data_new
	SELECT *



-- FROM pragma_table_info('merged_data')
-- WHERE type <> 'TEXT';





