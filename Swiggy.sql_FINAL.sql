SELECT* FROM Swiggy.swiggy_50;

SET SQL_SAFE_UPDATES = 0; 

-- Change the NA in rating to 0 use case when clause

-- UPDATE swiggy_50 
-- SET Rating = case when Rating = "NA"
-- THEN 0 
-- ELSE Rating
-- end;

-- ALTER TABLE `swiggy_50` MODIFY `Rating` Double;

-- Find null values 
SELECT *
FROM swiggy_50
WHERE `Restaurant Name` IS NULL or 
`category` is null or 
`Rating` is null or 
`cost for two` is null or
`veg` is null or
`city` is null or
`Area` is null or 
`Locality` is null or
`Address` is null or
`Long Distance delivery` is null;

-- Replace the null values in locality with the area address. Both are almost similar
select Area, Locality, ifnull(Locality, Area)
from swiggy_50 
where Locality IS NULL;

Update swiggy_50
Set Locality = ifnull(Locality, Area)
where Locality IS NULL;

-- Replace the null values in Address with the area and city
select city,Area, Locality,Address, ifnull(Address, concat(Area,",",city))
from swiggy_50 
where Address IS NULL;

Update swiggy_50
Set Address = ifnull(Address, concat(Area,",",city))
where Address IS NULL;

-- Split the category into 2 columns category, sub category
Select 
Substring(Category, 1 , LOCATE(',', Category)-1) as Main_category, 
substring(category, Locate(',',category)+1, LENGTH(category)) AS subcategory
from swiggy_50;

Alter table swiggy_50
add Main_category char(255);

update swiggy_50
set Main_category = Substring(Category, 1 , LOCATE(',', Category)-1);

-- Add a column sub category
Alter table swiggy_50
add subcategory char(255);

update swiggy_50
set subcategory = substring(category, Locate(',',category)+1, LENGTH(category));

-- The above query gave few null in main category so do the below
-- Have to replace the null in main category with value in sub category

select Category,Main_category,subcategory,substring_index(subcategory,",",1)
from Swiggy.swiggy_50 
where Main_category = "";

Update swiggy_50
Set Main_category = substring_index(subcategory,",",1)
where Main_category = "";

-- Split the address to get the last part of address where we can know the city

select Address,substring_index(Address,",",-1)
from Swiggy.swiggy_50;


Alter table swiggy_50
add Split_address_city_state char (255);

Update swiggy_50
set Split_address_city_state = substring_index(Address,",",-1);

-- Change long distance delievry to yes / no
Select
case 
when `Long Distance Delivery` = 0 then "No"
when `Long Distance Delivery` = 1 then "Yes"
else "NA"
end
from swiggy_50;

ALTER TABLE swiggy_50 MODIFY `Long Distance Delivery` char(255);

Update swiggy_50
set `Long Distance Delivery` = CASE
when `Long Distance Delivery` = 0 then "No"
else "Yes"
end;


-- -- Change the Ratings to words like poor, avg, very good, excellent

-- Change the NA to median in Rating - Kaggle queries and solns
-- The 'rating' column seems to have more than 50% of the data as NaN. 
-- Since, 'rating' might is a crucial role in the analysis, 
-- I was thinking of finding out an algorithm to input the missing data. 

-- ans you can replace the missing values with the already existing values of the attribute
-- either median or any value of our choice or 
-- predicted value - for example you can use logistic regression to input missing values.

-- Inputing 50 percent of the values can skew the data what to do then
-- Perhaps you could try to create two variables:
-- use one variable with imputed values and then without them and see, 
-- which variable has better performance. 

ALTER TABLE `swiggy_50` MODIFY `Rating` TEXT;

-- Update swiggy_50
-- set `Rating` = replace(`Rating`, "-1","NA");

select Rating,
row_number() over (partition by Rating) as `Rank`
from swiggy_50;

set @rowindex := -1;

Select avg(Rating) as Median
from
(select @rowindex:=@rowindex +1 as rowindex,swiggy_50.Rating as Rating
from swiggy_50
order by swiggy_50.Rating) AS R
Where
R.rowindex IN (FLOOR(@rowindex / 2), CEIL(@rowindex / 2));

-- Now the median is 0 so you can assign 0 to NA values in rating
-- Rating_withNA has median 0 instead of NA
Alter table swiggy_50
add Rating_withNA char (255);

-- Replace NA with 0 as the median is 0

ALTER TABLE `swiggy_50` MODIFY `Rating` DECIMAL;

Update swiggy_50
set `Rating` = replace(`Rating`, "NA","0");

update swiggy_50
set Rating_withNA = case
when Rating >= "0"  and Rating <="2" then "Poor"
when Rating >= "2.5" and Rating <="3.5" then "Average"
when Rating >="4" and Rating <="4.5" then "Very good"
when Rating = "5" then "Excellent"
else "Not_Available"
end;

-- Keep NA values as such
-- Rating_words has not available as such
SELECT MAX(RATING)
FROM swiggy_50;

SELECT MIN(RATING)
FROM swiggy_50;

Alter table swiggy_50
add Rating_words char (255);

ALTER TABLE `swiggy_50` MODIFY `Rating` Decimal;

Update swiggy_50
set `Rating` = replace(`Rating`, "NA","-1");

update swiggy_50
set Rating_words = case
when Rating = "0"  and Rating <="2" then "Poor"
when Rating >= "2.5" and Rating <="3.5" then "Average"
when Rating >="4" and Rating <="4.5" then "Very good"
when Rating = "5" then "Excellent"
when Rating = "-1" then "Not_Available"
else Rating
end;

-- Change cost for two to cheap,Affordable,Budget friendly,High price,Very expensive

SELECT MIN(`cost for two`)
FROM swiggy_50;

SELECT Max(`cost for two`)
FROM swiggy_50;

SELECT avg(`cost for two`)
FROM swiggy_50;

select distinct(`cost for two`), count(`cost for two`) as C
-- row_number() over (partition by `cost for two`) as `Rank`
from swiggy_50
group by 1
order by C;

select `Restaurant Name`, `cost for two`
from swiggy_50
where `cost for two` <= 620;

Alter table swiggy_50
add Budget_type char (255);

Update swiggy_50
set Budget_type =
case
when `cost for two` <= 620 then "cheap cost_for_two<=620"
when `cost for two` <= 1240 then "Affordable cost_for_two<=1240"
when `cost for two` <= 1860 then "Budget friendly cost_for_two<=1860"
when `cost for two` <= 2480 then "High price cost_for_two<=2480"
when `cost for two` > 2481 then "very expensive cost_for_two>2481"
else `cost for two`
end;

-- Drop unnecessary columns
select * 
from swiggy_50;

Alter table swiggy_50
drop column Category,
drop column Split_address_city_state;

