-- 1. Who is the senior most employee based on job title?

select * 
from employee
order by levels desc
limit 1


 -- Which countries have the most Invoices?

 select billing_country, count(*) as count_of_invoice
 from invoice
 group by billing_country
 order by count_of_invoice desc
 limit 1

 -- What are top 3 values of total invoice? 

 select total as top_values 
 from invoice
 order by top_values desc
 limit 3

--  Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals

select billing_city , sum(total) as sum_total 
from invoice
group by billing_city
order by sum_total desc
limit 1

-- Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money 

select c.customer_id,c.first_name, c.last_name , sum(total) as total_spending 
from customer as c 
join invoice as i 
on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1

--  Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A

select DISTINCT c.email ,c.first_name , c.last_name 
from track as t 
join 
	(select  * 
	from genre
	where name = 'Rock') as rock 
	on t.genre_id = rock.genre_id
join invoice_line as i on t.track_id = i.track_id
join invoice on invoice.invoice_id = i.invoice_id
join customer as c on c.customer_id = invoice.customer_id
order by c.email

--  Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands

select art.artist_id , art.name , count(tr.track_id) as track_count
from track as tr 
join album as al on tr.album_id = al.album_id
join artist as art on al.artist_id = art.artist_id
join (select * from genre where name = 'Rock') as gn on tr.genre_id = gn.genre_id
group by art.artist_id
order by track_count desc
limit 10

--  Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first

select name, milliseconds 
from track
where milliseconds > (
	select avg(milliseconds) as avg_len
	from track)
order by milliseconds desc

--  Find how much amount spent by each customer on artists? Write a query to return 
-- customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


-- Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how 
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS row_num 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE row_num <= 1
