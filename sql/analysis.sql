

--------------------------------------------------------------
-------------------------------------------------------------
--Are sales increasing or decreasing over time?

SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(total) AS revenue
FROM invoice
GROUP BY month
ORDER BY month;




--Which countries generate the most revenue?

SELECT billing_country, SUM(total) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;


----Which cities have the best customers?

SELECT billing_city, SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 5;

---Who are the best customers overall?

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

---Repeat vs one-time customers
SELECT 
    COUNT(*) FILTER (WHERE cnt = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE cnt > 1) AS repeat_customers
FROM (
    SELECT customer_id, COUNT(*) AS cnt
    FROM invoice
    GROUP BY customer_id
) sub;


-----Top customer per country
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spent,
        RANK() OVER (
            PARTITION BY i.billing_country
            ORDER BY SUM(i.total) DESC
        ) AS rank_num
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT *
FROM customer_spending
WHERE rank_num = 1;


----Revenue by genre
SELECT g.name, SUM(il.unit_price * il.quantity) AS revenue
FROM invoice_line il
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY revenue DESC;


----Most popular genre by country

WITH genre_purchases AS (
    SELECT 
        c.country,
        g.name AS genre,
        COUNT(il.quantity) AS purchases,
        RANK() OVER (
            PARTITION BY c.country
            ORDER BY COUNT(il.quantity) DESC
        ) AS rank_num
    FROM invoice_line il
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name
)
SELECT country, genre, purchases
FROM genre_purchases
WHERE rank_num = 1;


-----Genre diversity by country

SELECT billing_country, COUNT(DISTINCT genre_id) AS genre_diversity
FROM invoice
JOIN invoice_line USING (invoice_id)
JOIN track USING (track_id)
GROUP BY billing_country
ORDER BY genre_diversity DESC;



-----Most popular artists

SELECT ar.name AS artist_name, COUNT(il.quantity) AS purchases
FROM invoice_line il
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
GROUP BY ar.name
ORDER BY purchases DESC 
limit 10;


---Revenue concentration (Top 10 artists)
WITH artist_revenue AS (
    SELECT ar.name, SUM(il.unit_price * il.quantity) AS revenue
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN album al ON al.album_id = t.album_id
    JOIN artist ar ON ar.artist_id = al.artist_id
    GROUP BY ar.name
)
SELECT 
    SUM(revenue) FILTER (WHERE rank <= 10) * 100.0 / SUM(revenue) AS top10_percentage
FROM (
    SELECT *, RANK() OVER (ORDER BY revenue DESC) AS rank
    FROM artist_revenue
) r;

---Most popular songs
SELECT 
    ar.name   AS artist_name,
    t.name    AS song_name,
    al.title  AS album_name,
    COUNT(il.quantity) AS purchases
FROM invoice_line il
JOIN track t  ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN artist ar ON ar.artist_id = al.artist_id
GROUP BY ar.name, t.name, al.title
ORDER BY purchases DESC
LIMIT 3;

