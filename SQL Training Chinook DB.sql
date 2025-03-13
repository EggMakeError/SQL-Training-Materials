USE chinook;

-- Create temporary table for customer total spending
CREATE TEMPORARY TABLE temp_customer_spending AS
SELECT CustomerId, SUM(total) AS total_spent
FROM invoice
GROUP BY CustomerId;

-- Create temporary table for genre track counts
CREATE TEMPORARY TABLE temp_genre_track_counts AS
SELECT genre.GenreId, genre.Name AS genre, COUNT(track.TrackId) AS track_count
FROM track
JOIN genre ON track.GenreId = genre.GenreId
GROUP BY genre.GenreId;

-- 1. What is the difference in minutes between the total length of 'Rock' tracks and 'Jazz' tracks?
SELECT 
    ABS(
        (SUM(CASE WHEN genre.Name = 'Rock' THEN track.Milliseconds ELSE 0 END) -
         SUM(CASE WHEN genre.Name = 'Jazz' THEN track.Milliseconds ELSE 0 END)
        ) / 60000
    ) AS length_difference
FROM track
JOIN genre ON track.GenreId = genre.GenreId;

-- 2. How many tracks have a length greater than the average track length?
SELECT COUNT(*) AS track_count
FROM track
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM track);

-- 3. What is the percentage of tracks sold per genre?
SELECT genre, 
       ROUND(COUNT(invoiceline.TrackId) * 100.0 / (SELECT COUNT(*) FROM invoiceline), 2) AS percentage_sold
FROM invoiceline
JOIN track ON invoiceline.TrackId = track.TrackId
JOIN temp_genre_track_counts ON track.GenreId = temp_genre_track_counts.GenreId
GROUP BY genre
ORDER BY percentage_sold DESC;

-- 4. Can you check that the column of percentages adds up to 100%?
SELECT SUM(percentage_sold) AS total_percentage
FROM (
    SELECT ROUND(COUNT(invoiceline.TrackId) * 100.0 / (SELECT COUNT(*) FROM invoiceline), 2) AS percentage_sold
    FROM invoiceline
    JOIN track ON invoiceline.TrackId = track.TrackId
    JOIN temp_genre_track_counts USING (GenreId)
    GROUP BY genre
) subquery;


-- 5. What is the difference between the highest number of tracks in a genre and the lowest?
SELECT MAX(track_count) - MIN(track_count) AS genre_track_difference
FROM temp_genre_track_counts;

-- 6. What is the average value of Chinook customers (total spending)?
SELECT ROUND(AVG(total_spent), 2) AS avg_customer_spending
FROM temp_customer_spending;

-- 8. What is the maximum spent by a customer in each genre?
SELECT genre, 
       MAX(total_spent) AS max_spent
FROM (
    SELECT genre.GenreId, invoice.CustomerId, SUM(invoiceline.UnitPrice * invoiceline.Quantity) AS total_spent
    FROM invoiceline
    JOIN track ON invoiceline.TrackId = track.TrackId
    JOIN genre ON track.GenreId = genre.GenreId
    JOIN invoice ON invoiceline.InvoiceId = invoice.InvoiceId
    GROUP BY genre.GenreId, invoice.CustomerId
) AS customer_genre_spending
JOIN temp_genre_track_counts ON customer_genre_spending.GenreId = temp_genre_track_counts.GenreId
GROUP BY genre
ORDER BY max_spent DESC;

-- 9. What percentage of customers who made a purchase in 2022 returned to make additional purchases in subsequent years?
WITH first_purchases AS (
    SELECT CustomerId, MIN(YEAR(InvoiceDate)) AS first_year
    FROM invoice
    GROUP BY CustomerId
),
returned_customers AS (
    SELECT DISTINCT i.CustomerId
    FROM invoice i
    JOIN first_purchases f ON i.CustomerId = f.CustomerId
    WHERE f.first_year = 2022 AND YEAR(i.InvoiceDate) > 2022
)
SELECT ROUND(COUNT(returned_customers.CustomerId) * 100.0 / 
       (SELECT COUNT(*) FROM first_purchases WHERE first_year = 2022), 2) 
       AS returning_customer_percentage
FROM returned_customers;

-- 10. Which genre is each employee most successful at selling? Most successful is greatest amount of tracks sold.
WITH sales_by_employee AS (
    SELECT employee.EmployeeId, genre.Name AS genre, COUNT(invoiceline.TrackId) AS track_count
    FROM employee
    LEFT JOIN customer ON employee.EmployeeId = customer.SupportRepId
    LEFT JOIN invoice ON customer.CustomerId = invoice.CustomerId
    LEFT JOIN invoiceline ON invoice.InvoiceId = invoiceline.InvoiceId
    LEFT JOIN track ON invoiceline.TrackId = track.TrackId
    LEFT JOIN genre ON track.GenreId = genre.GenreId
    GROUP BY employee.EmployeeId, genre.Name
),
ranked_sales AS (
    SELECT *, 
           RANK() OVER (PARTITION BY EmployeeId ORDER BY track_count DESC) AS rank_value
    FROM sales_by_employee
)
SELECT EmployeeId, genre, track_count
FROM ranked_sales
WHERE rank_value = 1
ORDER BY EmployeeId;

-- 11. How many customers made a second purchase the month after their first purchase?
WITH first_purchases AS (
    SELECT CustomerId, MIN(DATE(InvoiceDate)) AS first_purchase_date
    FROM invoice
    GROUP BY CustomerId
),
second_purchases AS (
    SELECT DISTINCT i.CustomerId
    FROM invoice i
    JOIN first_purchases f ON i.CustomerId = f.CustomerId
    WHERE DATE(i.InvoiceDate) BETWEEN DATE_ADD(f.first_purchase_date, INTERVAL 1 MONTH) 
                                   AND DATE_ADD(f.first_purchase_date, INTERVAL 2 MONTH)
)
SELECT COUNT(*) AS customers_with_second_purchase
FROM second_purchases;