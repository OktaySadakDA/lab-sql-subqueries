use sakila;

# How many copies of the film Hunchback Impossible exist in the inventory system?

select count(i.inventory_id) as inv , f.film_id,f.title
from inventory i
join film f 
on f.film_id=i.film_id
where i.film_id = (select film_id from film where title='Hunchback Impossible');

# List all films whose length is longer than the average of all the films.
select avg(length) as avg from film;

select title , length 
from film 
where length > (select avg(length) as avg from film)
order by length desc;

# Use subqueries to display all actors who appear in the film Alone Trip.

select a.actor_id,a.first_name,a.last_name,f.title
from actor a 
join film_actor fa
using (actor_id)
join film f
using(film_id)
where f.film_id =(select film_id from film where title='Alone Trip');

select first_name , last_name
from actor
where actor_id in (select actor_id from film_actor where film_id in (select film_id from film where title='Alone Trip'));

# Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select f.film_id,f.category_id,c.name,fil.title
from film_category f
join category c
using (category_id)
join film fil
using (film_id)
where c.name='Family';

select film_id,category_id
from film_category
where category_id in (select category_id from category where name in (select name from category where name ='Family'));

# Get name and email from customers from Canada using subqueries. Do the same with joins. 
# Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

select c.first_name,c.last_name,c.email,ct.country
from customer c
join address
using (address_id)
join city
using (city_id)
join country ct
using (country_id)
where country ='Canada';

select first_name,last_name,email
from customer
where address_id in (select address_id from address where city_id in 
( select city_id from city where country_id in 
(select country_id from country where country='Canada')));

# Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
# First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select actor_id
from film_actor 
group by actor_id 
order by count(film_id) desc limit 1; # Most prolific actor is the actor with the actor id 107

select* from film_actor where actor_id=107; # Actor 107 acted in 42 movies.

select film_id,title
from film 
join film_actor
using (film_id)
where actor_id in (select* from
(select actor_id
from film_actor 
group by actor_id 
order by count(film_id) desc limit 1) as act
); 

# Films rented by most profitable customer. 
# You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

select c.customer_id,c.first_name,c.last_name, sum(p.amount) 
from customer c
join payment p
using (customer_id)
group by customer_id
order by sum(p.amount) desc limit 1;

select customer_id from payment 
group by  customer_id
order by sum(payment.amount) desc limit 1;

select film_id,title
from film 
join inventory
using(film_id)
join rental
using (inventory_id)
where customer_id = 526;

select title,rental_rate from film 
where film_id in (select film_id from inventory
where inventory_id in (select inventory_id from rental
where customer_id = (select customer_id from payment 
group by  customer_id
order by sum(payment.amount) desc limit 1)));

# Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

with payment as (select customer_id, sum(amount) as total_amount
from payment
group by customer_id
order by sum(amount))
select customer_id,total_amount 
from payment
where total_amount > (select avg(total_amount) from payment)
order by customer_id;

########### The answer below belongs to Nicole

SELECT CONCAT('$', ' ', AVG(total_amount)) AS average_amount
FROM (SELECT customer_id, sum(amount) as total_amount
FROM payment
GROUP BY customer_id) AS subtable;

SELECT customer_id, CONCAT('$', ' ', sum(amount)) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING sum(amount) > (SELECT AVG(total_amount)
FROM (SELECT customer_id, sum(amount) as total_amount
FROM payment
GROUP BY customer_id) AS subtable)
ORDER BY total_amount_spent ASC;