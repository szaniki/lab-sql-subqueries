USE Sakila;
-- 1. How many copies of the film Hunchback Impossible exist in the inventory system? 

SELECT * FROM inventory;
SELECT * FROM film;

SELECT film_id
FROM film
WHERE title = 'Hunchback Impossible';
SELECT COUNT(film_id)
FROM inventory
WHERE film_id = (SELECT film_id
FROM film
WHERE title = 'Hunchback Impossible');

-- 6 copies of Hunchback Impossible

-- 2. List all films whose length is longer than the average of all the films.
SELECT title, length
FROM sakila.film
WHERE length > (SELECT
AVG(length)
FROM sakila.film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id FROM film WHERE title = 'Alone Trip'
	)
);

-- 4. Sales have been lagging among young families. Identify all movies categorized as family films.

SELECT title AS Title
FROM sakila.film
WHERE film_id IN
(SELECT film_id
FROM sakila.film_category
WHERE category_id IN
(SELECT category_id
FROM sakila.category
WHERE name = 'Family'));

-- 5. Get name and email from customers from Canada using subqueries. 
-- Do the same with joins. Note that to create a join, you will have to identify the correct 
-- tables with their primary keys and foreign keys, that will help you get the relevant info.

SELECT CONCAT(first_name, ' ', last_name) AS Customer_Name, email
FROM sakila.customer
WHERE address_id
IN (SELECT address_id
FROM sakila.address
WHERE city_id
IN (SELECT city_id
FROM sakila.city
WHERE country_id
IN (SELECT country_id
FROM sakila.country
WHERE country = 'Canada')));

-- 6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT CONCAT(first_name, ' ', last_name) AS actor_name, film.title, film.release_year
FROM actor
INNER JOIN film_actor USING (actor_id)
INNER JOIN film USING (film_id)
WHERE actor_id = (SELECT actor_id
FROM actor
INNER JOIN film_actor USING (actor_id)
INNER JOIN film USING (film_id)
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC 
LIMIT 1)
ORDER BY release_year DESC;

-- Gina Degeneres is The Beast!

-- 7. Films rented by most profitable customer. 
-- Use the customer table and payment table to find the most profitable customer 
-- ie the customer that has made the largest sum of payments

SELECT film_id, title, rental_date, amount
FROM sakila.film
INNER JOIN inventory USING (film_id)
INNER JOIN rental USING (inventory_id)
INNER JOIN payment USING (rental_id)
WHERE rental.customer_id =
(SELECT  customer_id
FROM customer
INNER JOIN payment USING (customer_id)
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1)
ORDER BY rental_date DESC;


-- 8. Customers who spent more than the average payments.

SELECT customer_id, CONCAT(first_name, ' ', last_name) AS power_customers, SUM(amount) AS payment
FROM sakila.customer
INNER JOIN payment USING (customer_id)
GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(total_payment)
FROM
(SELECT customer_id, SUM(amount) total_payment
FROM payment
GROUP BY customer_id) t)
ORDER BY payment DESC;

