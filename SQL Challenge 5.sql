CREATE TABLE pubs (
pub_id INT PRIMARY KEY,
pub_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50)
);

CREATE TABLE beverages (
beverage_id INT PRIMARY KEY,
beverage_name VARCHAR(50),
category VARCHAR(50),
alcohol_content FLOAT,
price_per_unit DECIMAL(8, 2)
);

CREATE TABLE pubsales (
sale_id INT PRIMARY KEY,
pub_id INT,
beverage_id INT,
quantity INT,
transaction_date DATE,
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id),
FOREIGN KEY (beverage_id) REFERENCES beverages(beverage_id)
);

CREATE TABLE ratings ( rating_id INT PRIMARY KEY, 
pub_id INT, 
customer_name VARCHAR(50), 
rating FLOAT, 
review TEXT, 
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id) )
;

INSERT INTO pubs (pub_id, pub_name, city, state, country)
VALUES
(1, 'The Red Lion', 'London', 'England', 'United Kingdom'),
(2, 'The Dubliner', 'Dublin', 'Dublin', 'Ireland'),
(3, 'The Cheers Bar', 'Boston', 'Massachusetts', 'United States'),
(4, 'La Cerveceria', 'Barcelona', 'Catalonia', 'Spain');

INSERT INTO beverages (beverage_id, beverage_name, category, alcohol_content, price_per_unit)
VALUES
(1, 'Guinness', 'Beer', 4.2, 5.99),
(2, 'Jameson', 'Whiskey', 40.0, 29.99),
(3, 'Mojito', 'Cocktail', 12.0, 8.99),
(4, 'Chardonnay', 'Wine', 13.5, 12.99),
(5, 'IPA', 'Beer', 6.8, 4.99),
(6, 'Tequila', 'Spirit', 38.0, 24.99);

INSERT INTO pubsales (sale_id, pub_id, beverage_id, quantity, transaction_date)
VALUES
(1, 1, 1, 10, '2023-05-01'),
(2, 1, 2, 5, '2023-05-01'),
(3, 2, 1, 8, '2023-05-01'),
(4, 3, 3, 12, '2023-05-02'),
(5, 4, 4, 3, '2023-05-02'),
(6, 4, 6, 6, '2023-05-03'),
(7, 2, 3, 6, '2023-05-03'),
(8, 3, 1, 15, '2023-05-03'),
(9, 3, 4, 7, '2023-05-03'),
(10, 4, 1, 10, '2023-05-04'),
(11, 1, 3, 5, '2023-05-06'),
(12, 2, 2, 3, '2023-05-09'),
(13, 2, 5, 9, '2023-05-09'),
(14, 3, 6, 4, '2023-05-09'),
(15, 4, 3, 7, '2023-05-09'),
(16, 4, 4, 2, '2023-05-09'),
(17, 1, 4, 6, '2023-05-11'),
(18, 1, 6, 8, '2023-05-11'),
(19, 2, 1, 12, '2023-05-12'),
(20, 3, 5, 5, '2023-05-13');

INSERT INTO ratings (rating_id, pub_id, customer_name, rating, review)
VALUES
(1, 1, 'John Smith', 4.5, 'Great pub with a wide selection of beers.'),
(2, 1, 'Emma Johnson', 4.8, 'Excellent service and cozy atmosphere.'),
(3, 2, 'Michael Brown', 4.2, 'Authentic atmosphere and great beers.'),
(4, 3, 'Sophia Davis', 4.6, 'The cocktails were amazing! Will definitely come back.'),
(5, 4, 'Oliver Wilson', 4.9, 'The wine selection here is outstanding.'),
(6, 4, 'Isabella Moore', 4.3, 'Had a great time trying different spirits.'),
(7, 1, 'Sophia Davis', 4.7, 'Loved the pub food! Great ambiance.'),
(8, 2, 'Ethan Johnson', 4.5, 'A good place to hang out with friends.'),
(9, 2, 'Olivia Taylor', 4.1, 'The whiskey tasting experience was fantastic.'),
(10, 3, 'William Miller', 4.4, 'Friendly staff and live music on weekends.');

# 1. How many pubs are located in each country?
SELECT Country, COUNT(pub_id) as Pubs
FROM pubs
GROUP BY country
ORDER BY country;

# 2. What is the total sales amount for each pub, including the beverage price and quantity sold?
WITH PUBSALES AS(
	SELECT p.pub_name, 
           s.beverage_id, 
           b.beverage_name,
           s.quantity, 
           b.price_per_unit, 
		   (s.quantity * b.price_per_unit) AS Beverage_Revenue
	FROM pubsales s
	INNER JOIN beverages b USING(beverage_id)
    INNER JOIN pubs p USING(pub_id)
	ORDER BY p.pub_name)
SELECT pub_name AS Pub, beverage_name AS Beverage, quantity AS Quatity, price_per_unit AS Price, Beverage_Revenue,
SUM(Beverage_Revenue) OVER(PARTITION BY pub_name) AS Total_Sales
FROM PUBSALES;

# 3. Which pub has the highest average rating?
SELECT pb.pub_name as Pub, ROUND(AVG(ra.rating),2) AS AVGrating
FROM pubs pb
JOIN ratings ra
ON pb.pub_id = ra.pub_id
GROUP BY pb.pub_name
ORDER BY ROUND(AVG(ra.rating)) DESC
LIMIT 1;

# 4. What are the top 5 beverages by sales quantity across all pubs?
SELECT bg.beverage_name as Beverage, bg.price_per_unit as Beverage_Price, SUM(ps.Quantity) as Quantity_Sold, bg.price_per_unit*SUM(ps.Quantity) as Total_Sales
FROM beverages bg
JOIN pubsales ps
ON bg.beverage_id = ps.beverage_id
GROUP BY bg.beverage_name
ORDER BY SUM(ps.Quantity) DESC
LIMIT 5;

# 5. How many sales transactions occurred on each date?
SELECT transaction_date as Date, COUNT(sale_id) as Sale_Transactions
FROM pubsales
GROUP BY transaction_date
ORDER BY transaction_date;

# 6. Find the name of someone that had cocktails and which pub they had it in.
SELECT ra.customer_name as Customer, pb.pub_name as Pub
FROM ratings ra
JOIN pubs pb
ON pb.pub_id = ra.pub_id
WHERE review like "%COCKTAILS%";

# 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?
SELECT Category, ROUND(AVG(price_per_unit),2) as Average_Price
FROM beverages
WHERE category NOT IN ('Spirit')
GROUP BY category
ORDER BY AVG(price_per_unit) DESC;

# 8. Which pubs have a rating higher than the average rating of all pubs?
SELECT pb.pub_name AS Pub, ROUND(AVG(ra.rating),2) as Rating
FROM ratings ra 
INNER JOIN pubs pb
ON pb.pub_id = ra.pub_id
WHERE ra.rating > (SELECT ROUND(AVG(Rating),2) as Average 
				   from ratings)
GROUP BY pb.pub_name
ORDER BY ROUND(AVG(ra.rating),2) DESC;

select p.pub_name, round(avg(r.rating),1) as rating
from ratings r
inner join pubs p using(pub_id)
where r.rating > (select round(avg(rating),1) as average_rating
					from ratings)
group by 1 order by 2 desc;

# 9. What is the running total of sales amount for each pub, ordered by the transaction date?
#SELECT transaction_date as Date, pb.pub_name, Quantity, SUM(Quantity) OVER(order by transaction_date) AS RunningTotal
#FROM pubs pb
#JOIN pubsales ps
#ON pb.pub_id = ps.pub_id
#ORDER BY transaction_date

# 9. What is the running total of sales amount for each pub, ordered by the transaction date?
SELECT transaction_date as Date, pb.pub_name as Pub, bg.price_per_unit*ps.Quantity as Total_Sales, 
SUM(bg.price_per_unit*ps.Quantity) OVER(partition by pub_name order by transaction_date) AS RunningTotal
FROM pubs pb
JOIN pubsales ps
ON pb.pub_id = ps.pub_id
JOIN beverages bg
ON ps.beverage_id = bg.beverage_id
ORDER BY pb.pub_name;

# 10. For each country, what is the average price per unit of beverages in each category, 
# and what is the overall average price per unit of beverages across all categories?
WITH COUNTRY AS (
	SELECT pb.country as Country, 
    bg.Category, 
    ROUND(AVG(bg.price_per_unit),2) as AveragePrice
	FROM pubsales ps
	INNER JOIN pubs pb USING(pub_id)
	INNER JOIN beverages bg USING(beverage_id)
	GROUP BY pb.country, bg.Category)
SELECT *, ROUND(AVG(AveragePrice) over(partition by Country),2) as OverallAveragePrice
FROM COUNTRY
ORDER BY COUNTRY;

# 11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?
WITH TOTALSALES AS (
	SELECT pb.pub_name, bg.category, 
		   SUM(ps.quantity*bg.price_per_unit) as TotalSales
	FROM pubsales ps
	INNER JOIN beverages bg USING(beverage_id)
	INNER JOIN pubs pb USING(pub_id)
	GROUP BY pb.pub_name, bg.category),
OVERALLTOTALSALES AS (
SELECT *, SUM(TotalSales) OVER(PARTITION BY pub_name) AS Overall_Total_Sales FROM TOTALSALES)
SELECT pub_name AS Pub, Category, 
	CONCAT(ROUND((TotalSales*100/Overall_Total_Sales),2)," %") AS Percentage_Contribution, Overall_Total_Sales
FROM OVERALLTOTALSALES;