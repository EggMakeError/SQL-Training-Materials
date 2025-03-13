USE Chinook

-- 1. How many artists are in the database?
SELECT COUNT(*) AS ArtistCount FROM Artist;

-- 2. Create an alphabetized list of the artists.
SELECT Name FROM Artist ORDER BY Name;

-- 3. Show only the customers from Germany.
SELECT * FROM Customer WHERE Country = 'Germany';

-- 4. Get the full name, customer ID, and country of customers not in the US.
SELECT CustomerId, FirstName, LastName, Country FROM Customer WHERE Country <> 'USA';

-- 5. Find the track with the longest duration.
SELECT Name, Milliseconds FROM Track ORDER BY Milliseconds DESC LIMIT 1;

-- 6. Which tracks have 'love' in their title?
SELECT Name FROM Track WHERE Name LIKE '%love%';

-- 7. What is the difference in days between the earliest and latest invoice?
SELECT DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) AS DateDifference FROM Invoice;

-- 8. Which genres have more than 100 tracks?
SELECT Genre.Name, COUNT(Track.TrackId) AS TrackCount 
FROM Genre 
JOIN Track ON Genre.GenreId = Track.GenreId 
GROUP BY Genre.GenreId 
HAVING TrackCount > 100;

-- 9. Create a table showing countries alongside how many invoices there are per country.
SELECT BillingCountry, COUNT(*) AS InvoiceCount 
FROM Invoice 
GROUP BY BillingCountry;

-- 10. Find the name of the employee who has served the most customers.
SELECT e.FirstName, e.LastName, COUNT(c.CustomerId) AS CustomersServed 
FROM Employee e 
JOIN Customer c ON e.EmployeeId = c.SupportRepId 
GROUP BY e.EmployeeId 
ORDER BY CustomersServed DESC 
LIMIT 1;

-- 11. Which customers have a first name that starts with 'A' and is 5 letters long?
SELECT * FROM Customer WHERE FirstName LIKE 'A____';

-- 12. Find the total number of tracks in each playlist.
SELECT Playlist.Name, COUNT(PlaylistTrack.TrackId) AS TrackCount 
FROM Playlist 
JOIN PlaylistTrack ON Playlist.PlaylistId = PlaylistTrack.PlaylistId 
GROUP BY Playlist.PlaylistId;

-- 13. Find the artist that appears in the most playlists.
SELECT Artist.Name, COUNT(DISTINCT PlaylistTrack.PlaylistId) AS PlaylistCount 
FROM Artist 
JOIN Album ON Artist.ArtistId = Album.ArtistId 
JOIN Track ON Album.AlbumId = Track.AlbumId 
JOIN PlaylistTrack ON Track.TrackId = PlaylistTrack.TrackId 
GROUP BY Artist.ArtistId 
ORDER BY PlaylistCount DESC 
LIMIT 1;

-- 14. Find the genre with the most tracks.
SELECT Genre.Name, COUNT(Track.TrackId) AS TrackCount 
FROM Genre 
JOIN Track ON Genre.GenreId = Track.GenreId 
GROUP BY Genre.GenreId 
ORDER BY TrackCount DESC 
LIMIT 1;

-- 15. Which tracks have a composer whose name ends with 'Smith'?
SELECT Name, Composer FROM Track WHERE Composer LIKE '%Smith';

-- 16. Which artists have albums in the 'Rock' or 'Blues' genres?
SELECT DISTINCT Artist.Name 
FROM Artist 
JOIN Album ON Artist.ArtistId = Album.ArtistId 
JOIN Track ON Album.AlbumId = Track.AlbumId 
JOIN Genre ON Track.GenreId = Genre.GenreId 
WHERE Genre.Name IN ('Rock', 'Blues');

-- 17. Which tracks are in the 'Rock' or 'Blues' genre and have a name that is exactly 5 characters long?
SELECT Track.Name FROM Track 
JOIN Genre ON Track.GenreId = Genre.GenreId 
WHERE Genre.Name IN ('Rock', 'Blues') 
AND LENGTH(Track.Name) = 5;

-- 18. Classify customers as 'Local' if they are from Canada, 'Nearby' if they are from the USA, and 'International' otherwise.
SELECT CustomerId, FirstName, LastName, Country,
    CASE 
        WHEN Country = 'Canada' THEN 'Local' 
        WHEN Country = 'USA' THEN 'Nearby' 
        ELSE 'International' 
    END AS CustomerType 
FROM Customer;

-- 19. Find the total invoice amount for each customer.
SELECT Customer.CustomerId, Customer.FirstName, Customer.LastName, SUM(Invoice.Total) AS TotalSpent 
FROM Customer 
JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId 
GROUP BY Customer.CustomerId;

-- 20. Find the customer who has spent the most on music.
SELECT Customer.FirstName, Customer.LastName, SUM(Invoice.Total) AS TotalSpent 
FROM Customer 
JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId 
GROUP BY Customer.CustomerId 
ORDER BY TotalSpent DESC 
LIMIT 1;

-- 21. How many tracks were sold from each media type?
SELECT MediaType.Name, COUNT(InvoiceLine.TrackId) AS TracksSold 
FROM MediaType 
JOIN Track ON MediaType.MediaTypeId = Track.MediaTypeId 
JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId 
GROUP BY MediaType.MediaTypeId;

-- 22. Find the total sales per genre. Only include genres with sales between 100 and 500.
SELECT Genre.Name, SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS TotalSales 
FROM Genre 
JOIN Track ON Genre.GenreId = Track.GenreId 
JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId 
GROUP BY Genre.GenreId 
HAVING TotalSales BETWEEN 100 AND 500;

-- 23. Find the total number of tracks sold per artist. 
-- Add an extra column categorizing the artists into 'High', 'Medium', 'Low' based on the number of tracks sold.
-- High is more than 100, Low is less than 50.
SELECT Artist.Name, COUNT(InvoiceLine.TrackId) AS TracksSold, 
    CASE 
        WHEN COUNT(InvoiceLine.TrackId) > 100 THEN 'High' 
        WHEN COUNT(InvoiceLine.TrackId) < 50 THEN 'Low' 
        ELSE 'Medium' 
    END AS SalesCategory 
FROM Artist 
JOIN Album ON Artist.ArtistId = Album.ArtistId 
JOIN Track ON Album.AlbumId = Track.AlbumId 
JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId 
GROUP BY Artist.ArtistId;