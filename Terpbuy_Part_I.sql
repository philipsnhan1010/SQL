/*1. How many rows of data are stored for each table in the database? List the name of each table followed by the number of rows it has */
SELECT TABLE_NAME AS 'Table Name', TABLE_ROWS AS 'Number of Rows in Table'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'terpbuy';
/* MINH LAP NHAN 06/09/2022 */

/*2. Which products are considered high-priced products? A high-priced product has a price exceeding $100.00. List the names and prices of the high-priced products.*/
SELECT p.product_name AS 'Product Name', CONCAT('$', p.product_price) AS 'Product Price'
FROM product p
WHERE p.product_price > 100
ORDER BY p.product_price DESC;
/* MINH LAP NHAN 06/09/2022 */

/*3. List all orders placed by customers in the state of Florida. Note: The state abbreviation for Florida is 'FL'. 
Include the customers’ first names, last names, city, and segment, along with the order ID and order date.*/
SELECT c.first_name AS 'Customer First Name', c.last_name AS 'Customer Last Name', c.city AS City, c.segment AS Segment, 
	   o.order_id AS 'Order ID', o.order_date AS 'Order Date'
FROM orders o
	INNER JOIN customer c on o.customer_Id = c.customer_id
WHERE c.state = 'FL'
ORDER BY o.order_date DESC;
/* MINH LAP NHAN 06/09/2022 */

/*4. List all products that fall in one of the following categories: 'Computers', 'Toys', 'Tennis  & Racquet'. Include the products’ names, category, department, and price.*/
SELECT p.product_name AS 'Product Name', c.category_name AS 'Product Category', d.department_name AS 'Department', 
CONCAT('$',p.product_price) AS 'Product Price'
FROM product p
	INNER JOIN category c ON p.category_id = c.category_id
    INNER JOIN department d ON p.department_id = d.department_id
WHERE c.category_name IN ('Computers', 'Toys', 'Tennis & Racquet');
/* MINH LAP NHAN 06/09/2022 */

/*5. TerpBuy is considering reducing its product offerings. Which products have not yet been sold? Include the name, category, and department for each such product.*/
SELECT p.product_name AS 'Product Name', c.category_name AS 'Product Category', d.department_name AS 'Department'
FROM product p
	INNER JOIN category c ON p.category_id = c.category_id
    INNER JOIN department d ON p.department_id = d.department_id
WHERE p.product_id NOT IN (SELECT DISTINCT ol.product_id FROM order_line ol);
/* MINH LAP NHAN 06/09/2022 */

/*6. List the names of all cities from where orders are shipped. Also, for such cities, find the number of orders for which shipping was delayed. 
Sort the list of cities in order from the highest to the least number of shipping orders.*/
SELECT 	o.order_city AS 'Order City', 
		COUNT(o.order_id) AS 'Total Completed Orders',
		(
			SELECT count(lo.order_id) 
			FROM orders lo 
			WHERE lo.order_status='COMPLETE' 
				AND lo.order_city=o.order_city 
                AND lo.actual_shipping_days > lo.scheduled_shipping_days
		) AS 'Total Completed Orders Transit Delay',
		(
			SELECT count(lo.order_id) 
			FROM orders lo 
			WHERE lo.order_status IN ('ON_HOLD','PAYMENT_REVIEW','PENDING_PAYMENT') 
				AND lo.order_city=o.order_city 
		) AS 'Total Incomplete Delayed Orders'
FROM orders o
WHERE o.order_status = 'COMPLETE'
GROUP BY o.order_city
ORDER BY COUNT(o.order_id) DESC;
/* MINH LAP NHAN 06/09/2022 */

/*7. How many customers are there in each segment? Show the most popular segment at the top of the result. Incorporate a column alias in the result.*/
SELECT c.segment AS 'Customer Segment',  COUNT(c.customer_id) AS 'Customers Per Segment'
FROM customer c
GROUP BY c.segment
ORDER BY COUNT(c.customer_id) DESC;
/* MINH LAP NHAN 06/09/2022 */

/*8. How many orders were placed in the first quarter of 2021? Note: A quarter consists of three months. 
Incorporate a column alias in the result. You can refer to the documentation on date functions provided here.*/
SELECT CONCAT(year(o.order_date),' First Quarter') AS 'Quarterly Results', COUNT(o.order_id) AS 'Total Orders'
FROM orders o
WHERE YEAR(o.order_date) = 2021 AND MONTH(o.order_date) IN (1, 2, 3);
/* MINH LAP NHAN 06/09/2022 */

/*9. List in alphabetical order all states supporting multiple customer segments. */
SELECT c.state AS 'State'
FROM customer c
GROUP BY c.state
HAVING COUNT(DISTINCT c.segment) >= 2
ORDER BY c.state;
/* MINH LAP NHAN 06/09/2022 */

/*10. To help the commercial sales department with its marketing, find all customers in the corporate segment who have not placed any orders. 
Include each customers’ first name, last name, street, city, state, and zip code. Sort the results by the last name first and then by the first name. */
SELECT c.first_name AS 'Customer First Name', c.last_name AS 'Customer Last Name', 
	   c.street AS 'Street Address', c.city AS 'City', c.state AS 'State', c.zipcode AS 'Zip Code'
FROM customer c
WHERE c.segment = 'CORPORATE'
	AND c.customer_id NOT IN (SELECT o.customer_Id FROM orders o)
ORDER BY c.last_name, c.first_name;
/* MINH LAP NHAN 06/09/2022 */

/*11. There has been a recall of the product Nike Mens Free 5.0+ Running Shoe. TerpBuy would have to offer a discount coupon to all customers who purchased this product. 
Find all orders that included this product as a part of the purchase. For all such orders, list the customers’ first names, last names, street, state, zip code, and order date. 
Each customer can be offered only one discount coupon. Hence, do not list the same customer more than once. */
SELECT DISTINCT c.first_name AS 'Customer First Name', c.last_name AS 'Customer Last Name', 
	c.street AS 'Street Address', c.city AS 'City', c.state AS 'State', c.zipcode AS 'Zip Code',
	MAX(o.order_date) OVER(PARTITION BY c.first_name, c.last_name) AS 'Most Recent Order Date'
FROM orders o
	INNER JOIN order_line ol ON o.order_id = ol.order_id
    INNER JOIN customer c ON o.customer_Id = c.customer_id
WHERE ol.product_id = (SELECT product_id FROM product WHERE product_name = 'Nike Mens Free 5.0+ Running Shoe')
ORDER BY c.last_name, c.first_name;
/* MINH LAP NHAN 06/09/2022 */

/*12. Premium customers are those customers who have placed orders with order amounts greater than the average order amount. 
For each customer, find the first and last names, and the order amount for all orders that exceeded the average order amount. */
SELECT c.first_name AS 'Premium Customer First Name', c.last_name AS 'Premium Customer Last Name', 
	   SUM(ol.total_price) AS 'High Value Orders',
	   c.customer_id,o.order_id
FROM orders o
	INNER JOIN order_line ol ON o.order_id=ol.order_id
	INNER JOIN customer c ON o.customer_id=c.customer_id
GROUP BY o.order_id
HAVING SUM(ol.total_price)> (SELECT ROUND((SUM(ol2.total_price)/COUNT(DISTINCT o2.order_id)),2) 
							 FROM orders o2 
								INNER JOIN order_line ol2 ON o2.order_id=ol2.order_id
							)
ORDER BY c.last_name, c.first_name;
/* MINH LAP NHAN 06/09/2022 */