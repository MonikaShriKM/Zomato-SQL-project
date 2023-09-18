
SHOW DATABASES;    --- shows all databases connected   
                   ---  shows Zomato database is connected
                   
 USE zomatoo;       --- using database zomato            
                 
SELECT * FROM tablename      -- viewing the table ,limiting number of rows displayed to 5
LIMIT 5;                 

RENAME TABLE tablename TO Restaurant_details;     --- renaming the table to restaurant_details

CREATE TABLE Country(
Country_Code INT PRIMARY KEY,
Country VARCHAR(100));                 --- creating a table named Country

INSERT  INTO Country VALUES            -- inserting values into the created table "Country"
(1,"India"),
(14,"Australia"),
(30,"Brazil"),
(37	,"Canada"),
(94	,"Indonesia"),
(148,"New Zealand"),
(162,"Phillipines"),
(166,"Qatar"),
(184,"Singapore"),
(189,"South Africa"),
(191,"Sri Lanka"),
(208,"Turkey"),
(214,"UAE"),
(215,"United Kingdom"),
(216,"United States");

/* Table named Country is created ,now table:Country should be joined with table:restaurant_details
For above to happen,the primary key of restairant_details table should be foreign key of parent table :Country */
--- INDEX---

SHOW INDEX FROM Country;
SHOW INDEX FROM restaurant_details;

--- When we look the index of restaurant_Details table ,there is no index so making restaurant_id as primary key

ALTER TABLE restaurant_details
ADD PRIMARY KEY (Restaurant_ID);

SHOW INDEX FROM restaurant_details; --- restaurant_id has become the primary key

 --- ADDING FOREIGN KEY---
ALTER TABLE restaurant_details
ADD CONSTRAINT FK_Countrycode
FOREIGN KEY (Country_Code) 
REFERENCES Country(Country_Code)
ON DELETE SET NULL;

/* here it show error Country_Cod is incompatible.Because here the country code column of resataurant_Details is VARCHAR(512),
Country code of Country is INT */

---- Error :incompatibility Country_Code in TABLE Country and in TABLE restaurant_details is not same

ALTER TABLE Country
MODIFY Country_Code VARCHAR(512);  --- To make it compatible we are changing the data type of Country_code of Coutry to VARCHAR(512)

SHOW INDEX FROM restaurant_details; --- PK: restaurant_id 
SHOW INDEX FROM Country;  --- PK: Country_Code

ALTER TABLE restaurant_details
ADD  CONSTRAINT FK_Countrycode FOREIGN KEY(Country_Code) REFERENCES country(Country_Code)
ON DELETE SET NULL;    --- Adding country code as Foreign key


SHOW INDEX FROM restaurant_details; --- Checking whether Country_code is added as Foreign key,it is added

SELECT DISTINCT c.Country_Code ,c.country
FROM Country as c
LEFT JOIN restaurant_details as r
ON c.Country_Code=r.Country_Code;    --- Joining the country table and restaurant_details table


--- Adding column Country to existing table restaurant_Details with help of foreign key

ALTER TABLE restaurant_details
ADD  COLUMN Country VARCHAR(100);

SELECT* FROM restaurant_details;    -- we have added colum country,but its values are null,so adding values to it using JOIN function

UPDATE restaurant_details
JOIN Country 
ON restaurant_details.Country_Code=country.Country_Code
SET restaurant_details.Country=country.Country;

SELECT* FROM restaurant_details; --- Column country is updated



--- CREATING VIEW ---
CREATE VIEW RESTAURANT_COUNT
AS
SELECT Country,CITY,COUNT(DISTINCT Restaurant_ID) as  no_of_restaurants
FROM Restaurant_details
GROUP BY Country,CITY
ORDER BY Country;

SELECT* FROM RESTAURANT_COUNT;
DROP VIEW RESTAURANT_COUNT;

---- ASKING QUERIES--- 


--- (1)WHICH COUNTRY HAS MAX NUMBER OF RESTAURANTS---
SELECT Country,SUM(no_of_restaurants)
FROM RESTAURANT_COUNT
GROUP BY Country
ORDER BY SUM(no_of_restaurants) desc
LIMIT 1;

--- (2)WHICH CITY HAS MAX NUMBER OF RESTAURANS --
SELECT City,SUM(no_of_restaurants)
FROM RESTAURANT_COUNT
GROUP BY city
ORDER BY SUM(no_of_restaurants) desc
LIMIT 1;


--- (3)LIST OUT ALL RESTAURANTS WITH Cuisine details IN INDIA ---
SELECT  Country,City,Restaurant_Name,Cuisines
FROM restaurant_details    
WHERE Country="India" ;


-- (4) When we look at restaurant names most are repeated so we look at count of each restaurant--
SELECT DISTINCT Restaurant_Name,COUNT(Restaurant_Name)
FROM restaurant_details
WHERE Country="India"
GROUP BY Restaurant_Name
ORDER BY COUNT(RESTAURANT_Name) desc; --- Cafe Coffee Day has more number of restaurants in India


/* (5)WHERE ALL Domino's Pizza is present */
SELECT Country,City,Restaurant_Name,Count(Restaurant_ID)
FROM restaurant_details
WHERE Restaurant_Name="Domino's Pizza"
GROUP BY Country,City;

-- (6)WHERE ALL American food is available in Noida
SELECT Country,City,Restaurant_Name,Cuisines
FROM restaurant_details
WHERE City="Noida" AND Cuisines LIKE "%American%";

--- (7) Which Restaurants in Coimbatore has the highest rating and votes
SELECT * FROM restaurant_details
WHERE EXISTS(
SELECT City,Restaurant_ID,Restaurant_Name,Aggregate_rating,Rating_text
WHERE City="Coimbatore" AND Aggregate_rating>4.5 AND Rating_text ="Excellent");

--- (8) WHICH Restaurants have table booking options in Singapore
SELECT Restaurant_Name,Address,Average_Cost_for_two
FROM restaurant_details
WHERE City="New Delhi" AND Table_booking="Yes";

--- (9) Which restaurants provide chinese cuisine in Coimbatore
SELECT Country,City,Restaurant_Name
FROM restaurant_Details
WHERE Country="India" 
AND City="Coimbatore" 
AND Cuisines LIKE "Chinese" ;


--- (10) List of restaurants with table booking options as yes grouped by city and country
SELECT Country,City,COUNT(DISTINCT Restaurant_ID),SUM(Table_booking="Yes"),SUM(Table_booking="No")
FROM restaurant_details
GROUP BY Country,City;

-- (11)List of restaurants with ONLINE DELIVERY  options as yes grouped by city and country
SELECT Country,City,COUNT(DISTINCT Restaurant_ID),SUM(Online_delivery="Yes"),SUM(Online_delivery="No")
FROM restaurant_details
GROUP BY Country,City;

--- (12) List of restaurants having indian food in United states
SELECT Country,City,Restaurant_ID,Restaurant_Name
FROM restaurant_details
WHERE Country="United States" AND Cuisines LIKE "%Indian%";

--- (13) CONCATENATION OF Avg cost for two and currency. 
SELECT CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(Currency,"(",-1),")",1)," ",Average_Cost_for_two) AS PRICE
FROM restaurant_details;

--- (14) LIST out all the currency 
SELECT DISTINCT Currency 
FROM restaurant_Details;

--- (15) Price in Indian Rupees
SELECT COUNT(DISTINCT Currency)
FROM restaurant_details;

ALTER TABLE restaurant_details ADD Price Decimal(10,5) ;

ALTER TABLE restaurant_details 
DROP  Price;


 CREATE TABLE Exchange_rate(
 Currency VARCHAR(512),
 erate decimal(7,3)
 );
 
 
 ALTER  TABLE Exchange_rate
 ADD Currency_symbol VARCHAR(50);

SELECT * FROM Exchange_rate;

DROP TABLE Exchange_rate;

UPDATE restaurant_details
SET Currency=SUBSTRING_INDEX(Currency,"(",1);

SELECT *FROM restaurant_details;

INSERT  INTO Exchange_rate VALUES ("Indian Rupees",1,"Rs")
,("Rand",4.8,"R")
,("Emirati Diram",22.6,"AED")
,("Sri Lankan Rupee",0.26,"LKR")
,("Turkish Lira",3.08,"TL")
,("Pounds",103.06,"EU")
,("Qatari Rial",22.8,"QR")
,("Botswana Pula",6.09,"P")
,("Brazilian Real",17.08,"R$")
,("NewZealand",0.02,"$")
,("Indonesian Rupiah",0.005,"IDR")
,("Dollar",83.4,"$");

SELECT * FROM Exchange_rate;

SHOW INDEX FROM Exchange_rate;

SELECT * FROM restaurant_details;


UPDATE restaurant_details AS r
JOIN Exchange_rate AS e ON r.Currency=e.Currency
SET r.Price =(r.Average_Cost_for_two*e.erate);

ALTER TABLE restaurant_details
RENAME COLUMN Price to Price_in_Rs;

-- (16)
SELECT DISTINCT Restaurant_Name,COUNT(Restaurant_Name)
FROM restaurant_details
GROUP BY Restaurant_Name
ORDER BY COUNT(Restaurant_Name) DESC;

SELECT DISTINCT Restaurant_Name,COUNT(Restaurant_Name)
FROM restaurant_details
GROUP BY Restaurant_Name
HAVING COUNT(Restaurant_Name)>50
ORDER BY COUNT(Restaurant_Name) DESC;