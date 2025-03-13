USE Chinook;

-- 1. View: Countries with the most invoices
CREATE OR REPLACE VIEW v_CountryInvoiceCounts AS
SELECT BillingCountry, COUNT(*) AS InvoiceCount
FROM Invoice
GROUP BY BillingCountry
ORDER BY InvoiceCount DESC;

SELECT * FROM v_CountryInvoiceCounts;


-- 2. View: Cities with the most valuable customer base
CREATE OR REPLACE VIEW v_CityCustomerValue AS
SELECT Customer.City, Customer.Country, SUM(Invoice.Total) AS TotalSpent
FROM Customer
JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
GROUP BY Customer.City, Customer.Country
ORDER BY TotalSpent DESC;

SELECT * FROM v_CityCustomerValue;

-- 3. View: Top spending customer in each country
CREATE OR REPLACE VIEW v_TopCustomerByCountry AS
WITH CustomerSpending AS (
    SELECT Customer.CustomerId, Customer.FirstName, Customer.LastName, Customer.Country, SUM(Invoice.Total) AS TotalSpent
    FROM Customer
    JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
    GROUP BY Customer.CustomerId, Customer.Country
),
RankedCustomers AS (
    SELECT *, RANK() OVER (PARTITION BY Country ORDER BY TotalSpent DESC) AS RankPosition
    FROM CustomerSpending
)
SELECT CustomerId, FirstName, LastName, Country, TotalSpent
FROM RankedCustomers
WHERE RankPosition = 1
ORDER BY TotalSpent DESC;

-- 4. View: Top 5 selling artists of the top-selling genre(s)
CREATE OR REPLACE VIEW v_TopArtistsInTopGenre AS
WITH GenreSales AS (
    SELECT Genre.GenreId, Genre.Name AS GenreName, COUNT(InvoiceLine.TrackId) AS TotalSales
    FROM InvoiceLine
    JOIN Track ON InvoiceLine.TrackId = Track.TrackId
    JOIN Genre ON Track.GenreId = Genre.GenreId
    GROUP BY Genre.GenreId
),
TopGenres AS (
    SELECT GenreId, GenreName
    FROM GenreSales
    WHERE TotalSales = (SELECT MAX(TotalSales) FROM GenreSales)
),
ArtistSales AS (
    SELECT Artist.ArtistId, Artist.Name AS ArtistName, Genre.GenreId, COUNT(InvoiceLine.TrackId) AS ArtistSales
    FROM InvoiceLine
    JOIN Track ON InvoiceLine.TrackId = Track.TrackId
    JOIN Album ON Track.AlbumId = Album.AlbumId
    JOIN Artist ON Album.ArtistId = Artist.ArtistId
    JOIN Genre ON Track.GenreId = Genre.GenreId
    WHERE Genre.GenreId IN (SELECT GenreId FROM TopGenres)
    GROUP BY Artist.ArtistId, Genre.GenreId
),
RankedArtists AS (
    SELECT *, RANK() OVER (PARTITION BY GenreId ORDER BY ArtistSales DESC) AS RankPosition
    FROM ArtistSales
)
SELECT ArtistId, ArtistName, GenreId, ArtistSales
FROM RankedArtists
WHERE RankPosition <= 5;

-- 5. Stored Procedure: Retrieve all orders for a given InvoiceId
DELIMITER //
CREATE PROCEDURE sp_GetCustomerOrders(IN p_InvoiceId INT)
BEGIN
    DECLARE v_CustomerId INT;
    
    -- Get the CustomerId for the given InvoiceId
    SELECT CustomerId INTO v_CustomerId FROM Invoice WHERE InvoiceId = p_InvoiceId;
    
    -- Retrieve all invoices and order items for that customer
    SELECT Invoice.InvoiceId, Invoice.InvoiceDate, Invoice.Total,
           InvoiceLine.TrackId, InvoiceLine.UnitPrice, InvoiceLine.Quantity
    FROM Invoice
    JOIN InvoiceLine ON Invoice.InvoiceId = InvoiceLine.InvoiceId
    WHERE Invoice.CustomerId = v_CustomerId
    ORDER BY Invoice.InvoiceDate DESC;
END //
DELIMITER ;

-- 6. Stored Procedure: Retrieve sales data from a given date range
DELIMITER //
CREATE PROCEDURE sp_GetSalesData(IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    SELECT InvoiceId, InvoiceDate, BillingCountry, Total
    FROM Invoice
    WHERE InvoiceDate BETWEEN p_StartDate AND p_EndDate
    ORDER BY InvoiceDate;
END //
DELIMITER ;

-- 7. Stored Function: Calculate average invoice amount for a given country
DELIMITER //
CREATE FUNCTION fn_AvgInvoiceAmount(p_Country VARCHAR(50)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avgAmount DECIMAL(10,2);
    SELECT AVG(Total) INTO avgAmount FROM Invoice WHERE BillingCountry = p_Country;
    RETURN avgAmount;
END //
DELIMITER ;

-- 8. Stored Function: Best-selling artist in a given genre
DELIMITER //
CREATE FUNCTION fn_TopSellingArtist(p_Genre VARCHAR(50)) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE topArtist VARCHAR(100);
    
    SELECT Artist.Name INTO topArtist
    FROM InvoiceLine
    JOIN Track ON InvoiceLine.TrackId = Track.TrackId
    JOIN Album ON Track.AlbumId = Album.AlbumId
    JOIN Artist ON Album.ArtistId = Artist.ArtistId
    JOIN Genre ON Track.GenreId = Genre.GenreId
    WHERE Genre.Name = p_Genre
    GROUP BY Artist.ArtistId
    ORDER BY COUNT(InvoiceLine.TrackId) DESC
    LIMIT 1;

    RETURN topArtist;
END //
DELIMITER ;

-- 9. Stored Function: Total amount a customer has spent
DELIMITER //
CREATE FUNCTION fn_TotalCustomerSpending(p_CustomerId INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalSpent DECIMAL(10,2);
    SELECT SUM(Total) INTO totalSpent FROM Invoice WHERE CustomerId = p_CustomerId;
    RETURN IFNULL(totalSpent, 0);
END //
DELIMITER ;

-- 10. Stored Function: Find the average song length for an album
DELIMITER //
CREATE FUNCTION fn_AvgSongLength(p_AlbumId INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avgLength DECIMAL(10,2);
    SELECT AVG(Milliseconds) / 60000 INTO avgLength FROM Track WHERE AlbumId = p_AlbumId;
    RETURN IFNULL(avgLength, 0);
END //
DELIMITER ;

-- 11. Stored Function: Most popular genre in a given country
DELIMITER //
CREATE FUNCTION fn_TopGenreByCountry(p_Country VARCHAR(50)) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE topGenre VARCHAR(50);
    
    SELECT Genre.Name INTO topGenre
    FROM Invoice
    JOIN InvoiceLine ON Invoice.InvoiceId = InvoiceLine.InvoiceId
    JOIN Track ON InvoiceLine.TrackId = Track.TrackId
    JOIN Genre ON Track.GenreId = Genre.GenreId
    WHERE Invoice.BillingCountry = p_Country
    GROUP BY Genre.GenreId
    ORDER BY COUNT(InvoiceLine.TrackId) DESC
    LIMIT 1;
    
    RETURN topGenre;
END //
DELIMITER ;