USE magist;


SELECT COUNT(*) AS orders_count FROM orders;

SELECT COUNT(order_item_id) AS all_items FROM order_items;
/* Are orders actually delivered ?
SELECT order_status:

    This specifies that we want to include the order_status column in the result.
    Each unique value in the order_status column will represent a group in the output.

COUNT(*):

    The COUNT(*) function counts the total number of rows in each group created by "GROUP BY".

AS order_count:

    This assigns an alias (order_count) to the result of "COUNT(*)".
    The alias is used to make the output column easier to understand in the results.

GROUP BY order_status:

    This groups the rows in the orders table by the order_status column.
    All rows with the same value in the order_status column are grouped together.
*/

SELECT order_status, COUNT(*) AS ordercount FROM orders GROUP BY order_status;
SELECT order_status, COUNT(order_approved_at) AS ordercount FROM orders GROUP BY order_status;

/* Is Magist having user growth ?

SELECT YEAR(order_purchase_timestamp) AS sale_year, MONTH(order_purchase_timestamp) AS sale_month:

    YEAR(order_purchase_timestamp): Extracts the year part from the order_purchase_timestamp column.
    MONTH(order_purchase_timestamp): Extracts the month part from the same column.

COUNT(order_approved_at) AS purchase_total:

    COUNT(order_approved_at):
        Counts all non-NULL values in the order_approved_at column for each group.
        represents the timestamp when an order was approved, since I wanted to exclude orders that were rejected for any reason (might actually not be necessary).

GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp):

    Groups the rows in the orders table by unique combinations of year and month from the order_purchase_timestamp column.
    Within each group (year-month), the aggregate functions (COUNT) are applied.

ORDER BY sale_year, sale_month:

    Sorts the results first by sale_year (ascending) and then by sale_month (also ascending).
    Ensures the output is displayed in chronological order.
    
*/

-- SELECT YEAR(order_purchase_timestamp) AS sale_year, MONTH(order_purchase_timestamp) AS sale_month, COUNT(order_id) AS purchase_total FROM orders GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp) ORDER BY sale_year, sale_month;

/* How many products are there on the products table ?

		There are actually multiple solutions for this depending on what we are looking for, if we just want to see the amount of products, then we can just count the number of distinct product id's with:

SELECT COUNT(DISTINCT product_id) AS product_amount FROM products;

	COUNT(DISTINCT product_id) lets us return that information.
    
		If we want to see how many distinct product categories there are, we can do that with:

SELECT COUNT(DISTINCT product_category_name) AS product_categories FROM products;

		which is just the same as before but with product categories.

		Personally, I am a fan of the third method of grouping product count by category which is technically, the next question already:
*/

-- SELECT COUNT(DISTINCT product_id) AS product_amount FROM products;
-- SELECT COUNT(DISTINCT product_category_name) AS product_categories FROM products;

/* Which are the categories with the most products ?

this query is only a little bit longer than the one for product amount:

SELECT product_category_name, COUNT(*) AS product_count FROM products GROUP BY product_category_name ORDER BY product_count DESC;

*/

-- SELECT product_category_name, COUNT(DISTINCT product_id) AS product_count FROM products GROUP BY product_category_name ORDER BY product_count DESC;

/* how many of the products were present in actual transactions ?
*/

-- SELECT COUNT(DISTINCT product_id) AS sold_products FROM order_items;

-- SELECT  MIN(product_weight_g) AS min_weight , MAX(product_weight_g) AS max_weight , product_category_name FROM products GROUP BY product_category_name ORDER BY product_category_name;

SELECT p.product_category_name AS category_name, MIN(oi.price) AS min_price, MAX(oi.price) AS max_price, AVG(oi.price) AS avg_price, COUNT(order_item_id) AS items_sold 
	FROM order_items oi 
		JOIN products p ON oi.product_id = p.product_id
			WHERE p.product_category_name LIKE '%tele%' OR p.product_category_name LIKE '%elet%' OR p.product_category_name LIKE '%audio%' OR p.product_category_name LIKE '%inform%' OR p.product_category_name LIKE 'pcs'
			GROUP BY p.product_category_name 
			ORDER BY items_sold DESC;

-- SELECT review_score, review_comment_message, YEAR(review_creation_date) AS review_year, MONTH(review_creation_date) AS review_month FROM order_reviews WHERE review_score < 3;

SELECT * FROM product_category_name_translation WHERE product_category_name_english LIKE '%tele%' OR product_category_name_english LIKE '%elect%' OR product_category_name_english LIKE '%audio%' OR product_category_name_english LIKE '%compu%' OR product_category_name_english LIKE 'pcs';

SELECT p.product_category_name AS category_name,t.product_category_name_english AS category_name_english, round(MIN(oi.price),2) AS min_price, round(MAX(oi.price),2) AS max_price, round(AVG(oi.price),2) AS avg_price , (COUNT(oi.order_item_id) / 112650 * 100) AS amount_sold_percentage,
	CASE WHEN (COUNT(oi.order_item_id) / 112650 * 100) > 4 THEN 'popular'
		ELSE 'not popular'
        END AS popularity
			FROM order_items oi 
				JOIN products p ON oi.product_id = p.product_id 
					JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
						WHERE t.product_category_name LIKE '%tele%' OR t.product_category_name LIKE '%elet%' OR t.product_category_name LIKE '%audio%' OR t.product_category_name LIKE '%inform%' OR t.product_category_name LIKE 'pcs'
							GROUP BY p.product_category_name, t.product_category_name_english 
								ORDER BY amount_sold_percentage DESC;

-- SELECT COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS months_total FROM orders;

-- SELECT COUNT(DISTINCT (seller_id)) AS total_sellers FROM sellers;

SELECT p.product_category_name AS category_ , round(SUM(price),2), COUNT(DISTINCT oi.seller_id) AS seller_category_amount
	FROM order_items oi
		JOIN products p ON oi.product_id = p.product_id
			WHERE p.product_category_name LIKE '%tele%' OR p.product_category_name LIKE '%elet%' OR p.product_category_name LIKE '%audio%' OR p.product_category_name LIKE '%inform%' OR p.product_category_name LIKE 'pcs'
            	GROUP BY p.product_category_name 
				ORDER BY seller_category_amount DESC;