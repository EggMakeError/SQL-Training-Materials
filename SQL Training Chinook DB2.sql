USE Chinook;

-- 1. Rank the customers by total sales
WITH customer_sales AS (
    SELECT CustomerId, SUM(Total) AS total_spent
    FROM invoice
    GROUP BY CustomerId
)
SELECT CustomerId, total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS rank_standard,
       ROW_NUMBER() OVER (ORDER BY total_spent DESC, CustomerId ASC) AS rank_no_ties
FROM customer_sales;

-- 2. Select only the top 10 ranked customers from the previous question
WITH customer_sales AS (
    SELECT CustomerId, SUM(Total) AS total_spent
    FROM invoice
    GROUP BY CustomerId
)
SELECT CustomerId, total_spent
FROM (
    SELECT CustomerId, total_spent, 
           RANK() OVER (ORDER BY total_spent DESC) AS sales_rank
    FROM customer_sales
) ranked_customers
WHERE sales_rank <= 10;

-- 3. Rank albums based on the total number of tracks sold.
WITH album_sales AS (
    SELECT album.AlbumId, album.Title, COUNT(invoiceline.TrackId) AS tracks_sold
    FROM invoiceline
    JOIN track ON invoiceline.TrackId = track.TrackId
    JOIN album ON track.AlbumId = album.AlbumId
    GROUP BY album.AlbumId, album.Title
)
SELECT AlbumId, Title, tracks_sold,
       RANK() OVER (ORDER BY tracks_sold DESC) AS album_rank
FROM album_sales;

-- 4. Do music preferences vary by country? What are the top 3 genres for each country?
WITH genre_sales_by_country AS (
    SELECT BillingCountry AS country, genre.Name AS genre, COUNT(invoiceline.TrackId) AS tracks_sold
    FROM invoice
    JOIN invoiceline USING (InvoiceId)
    JOIN track USING (TrackId)
    JOIN genre USING (GenreId)
    GROUP BY BillingCountry, genre.Name
),
ranked_genres AS (
    SELECT *, 
           RANK() OVER (PARTITION BY country ORDER BY tracks_sold DESC) AS rank_value
    FROM genre_sales_by_country
)
SELECT country, genre, tracks_sold
FROM ranked_genres
WHERE rank_value <= 3
ORDER BY country, rank_value;

-- 5. In which countries is Blues the least popular genre?
WITH genre_sales AS (
    SELECT BillingCountry AS country, genre.Name AS genre, COUNT(invoiceline.TrackId) AS tracks_sold
    FROM invoice
    JOIN invoiceline USING (InvoiceId)
    JOIN track USING (TrackId)
    JOIN genre USING (GenreId)
    WHERE genre.Name = 'Blues'
    GROUP BY BillingCountry, genre.Name
)
SELECT country, tracks_sold
FROM genre_sales
ORDER BY tracks_sold ASC
LIMIT 5; -- Shows the least popular countries for Blues

-- 6. Has there been year-on-year growth? By how much have sales increased per year?
WITH yearly_sales AS (
    SELECT YEAR(InvoiceDate) AS sales_year, SUM(Total) AS total_sales
    FROM invoice
    GROUP BY sales_year
)
SELECT sales_year, total_sales, 
       LAG(total_sales) OVER (ORDER BY sales_year) AS previous_year_sales,
       total_sales - LAG(total_sales) OVER (ORDER BY sales_year) AS sales_growth,
       ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY sales_year)) / LAG(total_sales) OVER (ORDER BY sales_year), 2) AS growth_percentage
FROM yearly_sales;

-- 7. How do the sales vary month-to-month as a percentage?
WITH monthly_sales AS (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month, SUM(Total) AS total_sales
    FROM invoice
    GROUP BY sales_month
)
SELECT sales_month, total_sales, 
       LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
       ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY sales_month)) / LAG(total_sales) OVER (ORDER BY sales_month), 2) AS growth_percentage
FROM monthly_sales;

-- 8. What is the monthly sales growth, categorized by increase or decrease?
WITH monthly_sales AS (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month, SUM(Total) AS total_sales
    FROM invoice
    GROUP BY sales_month
)
SELECT sales_month, total_sales, 
       CASE 
           WHEN total_sales > LAG(total_sales) OVER (ORDER BY sales_month) THEN 'Increase'
           WHEN total_sales < LAG(total_sales) OVER (ORDER BY sales_month) THEN 'Decrease'
           ELSE 'No Change'
       END AS sales_trend
FROM monthly_sales;

-- 9. How many months in the data showed an increase in sales compared to the previous month?
WITH monthly_sales AS (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month, SUM(Total) AS total_sales
    FROM invoice
    GROUP BY sales_month
)
SELECT COUNT(*) AS months_with_growth
FROM (
    SELECT total_sales, 
           LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_sales
) sales_comparison
WHERE total_sales > previous_month_sales;

-- 10. As a percentage of all months in the dataset, how many months showed an increase in sales?
WITH monthly_sales AS (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month, SUM(Total) AS total_sales
    FROM invoice
    GROUP BY sales_month
)
SELECT ROUND(
    100.0 * COUNT(*) / (SELECT COUNT(*) FROM monthly_sales), 2
) AS growth_percentage
FROM (
    SELECT total_sales, 
           LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_sales
) sales_comparison
WHERE total_sales > previous_month_sales;

-- 11. How have purchases of rock music changed quarterly? Show the quarterly change in tracks sold.
WITH rock_quarterly_sales AS (
    SELECT CONCAT(YEAR(InvoiceDate), '-Q', QUARTER(InvoiceDate)) AS sales_quarter, COUNT(invoiceline.TrackId) AS rock_tracks_sold
    FROM invoice
    JOIN invoiceline USING (InvoiceId)
    JOIN track USING (TrackId)
    JOIN genre USING (GenreId)
    WHERE genre.Name = 'Rock'
    GROUP BY sales_quarter
)
SELECT sales_quarter, rock_tracks_sold, 
       rock_tracks_sold - LAG(rock_tracks_sold) OVER (ORDER BY sales_quarter) AS quarterly_change
FROM rock_quarterly_sales;

-- 12. Determine the average time between purchases for each customer.
WITH purchase_intervals AS (
    SELECT CustomerId, InvoiceDate, 
           LAG(InvoiceDate) OVER (PARTITION BY CustomerId ORDER BY InvoiceDate) AS previous_purchase
    FROM invoice
)
SELECT CustomerId, 
       ROUND(AVG(TIMESTAMPDIFF(DAY, previous_purchase, InvoiceDate)), 2) AS avg_days_between_purchases
FROM purchase_intervals
WHERE previous_purchase IS NOT NULL
GROUP BY CustomerId;