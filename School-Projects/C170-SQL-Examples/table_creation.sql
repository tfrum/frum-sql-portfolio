/* 
	We need to create the following tables:
	COFFEE_SHOP
	EMPLOYEE
	COFFEE
	SUPPLIER
	
	Of these only COFFEE_SHOP and SUPPLIER lack foreign keys.
	We should make those first. 
*/

CREATE TABLE COFFEE_SHOP (
	shop_id   INTEGER PRIMARY KEY,
	shop_name VARCHAR(50),
	city      VARCHAR(50),
	state     CHAR(2)
	);
	
CREATE TABLE SUPPLIER (
	supplier_id         INTEGER PRIMARY KEY,
	company_name        VARCHAR(50),
	country	            VARCHAR(30),
	sales_contact_name	VARCHAR(60),
	email	            VARCHAR(50)  NOT NULL
	);
	
CREATE TABLE EMPLOYEE (
	employee_id INTEGER PRIMARY KEY,
	first_name  VARCHAR(30),
	last_name   VARCHAR(30),
	hire_date   DATE,
	job_title   VARCHAR(30),
	shop_id     INTEGER,     
	FOREIGN KEY (shop_id) REFERENCES COFFEE_SHOP(shop_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
	);
	
CREATE TABLE COFFEE (
	coffee_id       INTEGER PRIMARY KEY,
	shop_id         INTEGER,
	supplier_id     INTEGER,
	coffee_name     VARCHAR(30),
	price_per_pound NUMERIC(5,2),
	FOREIGN KEY (shop_id) REFERENCES COFFEE_SHOP(shop_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	FOREIGN KEY (supplier_id) REFERENCES SUPPLIER(supplier_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
	);
	
	
/*
	Now we need to populate these tables with some data.
	We'll do it in the same order that we create tables with so that we can
	be sure we have valid foreign key values.
*/

INSERT INTO COFFEE_SHOP
VALUES (1, 'Beans Talk', 'Detroit', 'MI'),
	   (2, 'Bean Water Co', 'Cleveland', 'OH'),
	   (3, 'DIY Brew', 'Anchorage', 'AL');

INSERT INTO SUPPLIER
VALUES (1, 'Jus Beans', 'Ecuador', 'Pierre Stofelopolus', 'getbeans@jusbeans.com'),
	   (2, 'WeGetUBeanz', 'Ecuador', 'Tim Timberland', 'tim1967@geocities.com'),
	   (3, 'Untraceable Beans Inc', 'North Korea', 'Dennis Rodman', 'dennisthamenace@nba.com');

INSERT INTO EMPLOYEE
VALUES (1, 'Joe', 'Schmoe', '2020-01-01', 'Bean Master II', 1),
	   (2, 'Lillian', 'Duwop', '2020-02-02', 'Bean Water Artist', 2),
	   (3, 'Arthur', 'Bearington', '1981-01-04', 'Bean Referee', 3);

INSERT INTO COFFEE
VALUES (1, 2, 3, 'Boastful Roast', 152.00),
	   (2, 3, 1, 'Volatile Vanilla', 40.02),
	   (3, 1, 2, 'Generic Coffee #12', 12.98);
	   
	   
/*
	Now we want to create a view of these tables.
	Here are the conditions:
		Provide the SQL code you wrote to create your view. 
		The view should show all of the information from the 
		“Employee” table but concatenate each employee’s first
		and last name, formatted with a space between the first 
		and last name, into a new attribute called employee_full_name.


*/

CREATE VIEW EMPLOYEE_INFO_VIEW AS
SELECT 
	employee_id,
	first_name || ' ' || last_name AS employee_full_name,
	hire_date,
	job_title
FROM EMPLOYEE;


/*
	Now we want to create an index on the COFFEE(coffee_name) attribute
*/

CREATE UNIQUE INDEX idx_coffee
ON COFFEE(coffee_name);

/* 
	Now here is a select statement, I guess.
*/


