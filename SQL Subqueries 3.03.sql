-- Lab | SQL - Lab 3.02.03
USE Sakila;
-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film_id
FROM FILM
WHERE title = 'Hunchback Impossible';
# Film_id=439

SELECT COUNT(*) AS copies_count
FROM INVENTORY
WHERE film_id = 439;
# We obtain 6 copies

#Here it is the with a substring. 
SELECT COUNT(*) AS copies_of_Hunchback_Impossible
FROM INVENTORY
WHERE film_id = (
  SELECT film_id
  FROM FILM
  WHERE title = 'Hunchback Impossible'
);

-- 2. List all films whose length is longer than the average of all the films.
SELECT *
FROM film
WHERE length > (
  SELECT AVG(length)
  FROM film
);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
# TABLE PATH = FILM film_id -> FILM_ACTOR actor_idS ->  ACTOR.

SELECT film_id
FROM film
WHERE title = 'Alone Trip';
#film_id (PK)= 17

SELECT actor_id
FROM film_actor 
WHERE film_id = 17;

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (3, 12, 13,82,100,160,167,187);

-- SUBQUERY. 
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
   SELECT actor_id
   FROM film_actor 
WHERE film_id = (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip')
   );

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

# I need the categoy name, but the table is not related directly to the film table. 
# I need go trough film_category table because is the conexion table one between film and category table. 

SELECT * FROM film_category;
SELECT * FROM category;

SELECT category_id
FROM category
WHERE name = 'Family';

SELECT film_id
FROM film_category
WHERE category_id = 8;

SELECT film_id, title
FROM film
WHERE film_id IN (SELECT film_id FROM film_category WHERE category_id = 8);


-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT *
FROM city;


SELECT country_id
FROM country
WHERE country = 'Canada';

SELECT address_id
FROM address
WHERE city_id IN ( 
 SELECT city_id
 FROM city 
 WHERE country_id = (
  SELECT country_id
  FROM country
  WHERE country = 'Canada'));

-- 5.WITH JOINS. 
# TABLE PATH COUNTRY -> CITY -> ADDRESS -> CUSTOMER ->
SELECT cu.first_name, cu.last_name, cu.email
FROM customer cu
JOIN address ad ON cu.address_id = ad.address_id
JOIN city ct ON ad.city_id = ct.city_id
JOIN country co ON ct.country_id = co.country_id
WHERE co.country_id = 20;

-- 6. Which are films started by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
#Finding the actor_id of the most prolific actor.

SELECT actor_id
FROM (
  SELECT actor_id, COUNT(*) AS film_count
  FROM film_actor
  GROUP BY actor_id
  ORDER BY film_count DESC
  LIMIT 1
) AS subquery;
#Actor_id: 107

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
      SELECT actor_id
      FROM(
         SELECT ACTOR_ID, COUNT(film_id)
         FROM film_actor
         GROUP BY actor_id
         ORDER BY COUNT(film_id) DESC
         LIMIT 1) sub1);
         
-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments.

SELECT customer_id
FROM (SELECT customer_id, SUM(amount)
	  FROM payment
      GROUP BY customer_id
      ORDER BY SUM(amount) DESC
      LIMIT 1) sub1;
-- customer id: 526 is the most profitable customer. 

-- 8. Customers who spent more than the average payments.
# I selected as well the email, in case we want to send them an email offering a bonus or a ofert. 

SELECT
  cu.customer_id,
  cu.first_name,
  cu.last_name,
  cu.email,
  SUM(py.amount) AS total_amount_spent
FROM
  customer cu
JOIN
  payment py ON cu.customer_id = py.customer_id
WHERE
  cu.customer_id IN (
    SELECT
      py.customer_id
    FROM
      payment py
    GROUP BY
      py.customer_id
    HAVING
      SUM(py.amount) > (
        SELECT
          AVG(amount)
        FROM
          payment
      )
  )
GROUP BY
  cu.customer_id, cu.first_name, cu.last_name, cu.email;
