select * from album;

--Q1: find senior employee.
select * from employee order by levels desc limit 1;

--Q2: which country have most invoice?

select count(*) as c, billing_country 
from invoice
group by billing_country order by c desc;

--Q3.Top three valuess offf total invoice

select total from invoice 
order by total desc limit 3;

--Q4.which city has the best customers? writee a qquery thet returnss 
--one city that has highest summ offf invoice totals returnn bothh the city namee
--andd summ offf alll invoice totals.

select sum(total) as invoice_total, billing_city from invoice
group by billing_city 
order by invoice_total desc;

----Q5.writee a qquery that returnns the person who has spent the most moneyy

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id 
group by customer.customer_id
order by total desc limit 1 ;

--Q6. writee queryy tp returnn the email,first_name, last_name andd genre offf alll rock 
--music listeners. returnn your list ordered alphabetically byy email staring withh A.

select customer.email, customer.first_name, customer.last_name 
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id =genre.genre_id
	where genre.name like 'Rock'
)
order by email;

--Q7.writee a qquery that returnss the artist namee andd total track countt oft the top 10
--rock bands.

select artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc 
limit 10;

--Q8.returnn alls thetrack namess that have a song lengthd longer than the average song 
--lengthf. returnn the namee andd miliseconds forr eachh track. ordeer byy the song lenght

select name,milliseconds 
from track
where milliseconds > (
	select avg(milliseconds) as average
	from track
)order by milliseconds desc;

--Q9. find how mch amount spent byeach customer onn artists. writee a uery toreturn cust namee , artstname
--andd totlspent.

with best_selling_artist as(
	select artist.artist_id as artist_id,
	       artist.name as artist_name,
	       sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--Q10.write a query that returns  each country along with the top genre. for countries where the maximum
--number of purchases is shared return all genres

with popular_genre as(
	select count(invoice_line.quantity) as purchases, 
	       customer.country, 
	       genre.name,
		   genre.genre_id,
	       Row_number() over(partition by customer.country order by count(invoice_line.quantity)desc)as rowno
	       from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id= invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select *from popular_genre where rowno<=1;

--Q11. write a query that determines the customer that has spent the most on music for
-- each country.

with recursive
	customer_with_country as(
	select customer.customer_id, first_name, last_name, billing_country,
	sum(total) as total_spending from invoice
	join customer on customer.customer_id= invoice.customer_id
	group by 1,2,3,4
	order by 1,5 desc),

	customer_max_spending as(
	select billing_country , max(total_spending) as max_spending
	from customer_with_country
	group by billing_country
	)

select cc.billing_country, cc.total_spending, cc.first_name,cc.last_name,cc.customer_id
from customer_with_country cc
join customer_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending= ms.max_spending
order by 1;
