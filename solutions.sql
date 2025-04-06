USE sakila;

SHOW tables;


/* 1 - How many copies of the film Hunchback Impossible exist in the inventory system? */
SELECT COUNT(*) AS total_copies
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE title = 'Hunchback Impossible';


/* 2 - List all films whose length is longer than the average of all the films. */
SELECT title, length FROM film
WHERE length > ( SELECT AVG(length) FROM film );


/* 3 - Use subqueries to display all actors who appear in the film Alone Trip. */
SELECT * FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id = (
		SELECT film_id 
        FROM film
        WHERE title = 'Alone Trip'
    )
);


/* 4 - Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films. */
SELECT f.film_id, title 
FROM film f
INNER JOIN film_category fc USING(film_id)
INNER JOIN category c USING(category_id)
WHERE c.name = 'Family';


/* 5 - Get name and email from customers from Canada using subqueries. 
Do the same with joins. 
Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information. */

-- using subqueries
SELECT first_name, last_name, email 
FROM customer
WHERE address_id IN (
	SELECT address_id
    FROM address
    WHERE city_id IN (
		SELECT city_id
        FROM city
        WHERE country_id = (
			SELECT country_id 
            FROM country
            WHERE country = 'Canada'
        )
    )
);

-- using joins
SELECT first_name, last_name, email 
FROM customer
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country = 'Canada';


/* 6 - Which are films starred by the most prolific actor? 
Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred. */

-- using a CTE
WITH most_prolific AS (
	SELECT actor_id, COUNT(*) AS total_movies
    FROM film_actor 
    GROUP BY actor_id
    ORDER BY total_movies DESC
    LIMIT 1
) 
SELECT film_id, title
FROM film_actor
JOIN film USING(film_id)
WHERE film_actor.actor_id = (SELECT actor_id FROM most_prolific) ;


-- using joins
SELECT f.film_id, f.title
FROM film f
JOIN film_actor fa USING(film_id)
WHERE fa.actor_id = (
	SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);



/* 7 - Films rented by most profitable customer. 
You can use the customer table and payment table to find the most profitable customer 
(ie the customer that has made the largest sum of payments) */

SELECT film_id, title 
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM inventory
	WHERE inventory_id IN (
		SELECT inventory_id
		FROM rental
		WHERE customer_id = (
			SELECT customer_id
			FROM payment
			GROUP BY customer_id
			ORDER BY SUM(amount) DESC
			LIMIT 1
		)
	)
);


/* 8 - Get the client_id and the total_amount_spent 
of those clients who spent more than the average of the total_amount spent by each client. */

SELECT customer_id, SUM(amount) AS spent
FROM customer
JOIN payment USING(customer_id)
GROUP BY customer_id
HAVING SUM(amount) > (
	SELECT AVG(total_amount)
	FROM (
		SELECT SUM(amount) AS total_amount
		FROM payment
		GROUP BY customer_id
	) AS avg_spent
);

