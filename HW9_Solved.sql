use sakila;

#  1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name
FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
ALTER TABLE actor
ADD ActorName VARCHAR(30);

UPDATE actor 
SET ActorName = CONCAT(first_name, ' ', last_name);

SELECT * FROM actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT ActorName
FROM actor
WHERE first_name = 'Joe';

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT ActorName
FROM actor
WHERE last_name LIKE '%GEN%';

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT ActorName
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name , first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan' , 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB; # I think the difference btwn BLOB and VARCHAR is that BLOB is a pointer, while VARCHAR contains the actual values inline wth the table.

# Display table
SELECT* FROM actor;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP description;

# Dislplay table to confrm changes
SELECT * FROM actor;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY (last_name);

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY (last_name)
HAVING COUNT(last_name) > 1;

#  4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

SELECT * FROM actor
WHERE  last_name = 'WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
# Display all the entries with first name "Harper" to make sure we don't change the wrong thing
SELECT * FROM  actor
WHERE first_name = 'HARPO';

UPDATE actor
set first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
DESCRIBE address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM staff;
SELECT * FROM address;

SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a
USING (address_id);

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT * FROM staff;
SELECT * FROM payment;

SELECT s.first_name, s.last_name, SUM(p.amount) AS TotalSales
FROM staff s
JOIN payment p
USING (staff_id)
GROUP	BY (staff_id);

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * FROM film_actor;
SELECT * FROM film;

SELECT f.title, COUNT(fa.film_id) AS NumActors
FROM film f
JOIN film_actor fa
USING (film_id)
GROUP BY (film_id);

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT * FROM inventory;
SELECT * FROM film;

SELECT f.title, COUNT(i.film_id) AS NumInStock
FROM film f
JOIN  inventory i
USING (film_id)
WHERE title = 'Hunchback Impossible';

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT * FROM payment;
SELECT * FROM customer;

SELECT 	c.first_name, c.last_name, SUM(p.amount) AS TotalPaid
FROM customer c
JOIN payment p
USING (customer_id)
GROUP BY(customer_id)
ORDER BY(last_name);

#  7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT  * FROM film;
SELECT * FROM language;

SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND language_id IN 
	(
		select language_id
		from language
		where name = 'English'
	);
    
# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM actor;

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN
	(
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
	)
);

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT * FROM country;
SELECT* FROM city;
SELECT* FROM address;
SELECT * FROM customer;

CREATE VIEW CanCampaign AS
    SELECT c.first_name, c.last_name, c.email
    FROM customer c
            JOIN address 
            USING (address_id)
            JOIN city 
            USING (city_id)
            JOIN country 
            USING (country_id)
    WHERE country = 'Canada';

SELECT * FROM CanCampaign;

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film;

CREATE OR REPLACE VIEW FamFilms AS
	SELECT f.title, f.rating
    FROM film f
        JOIN film_category
        USING (film_id)
        JOIN category
        USING (category_id)
	WHERE name = 'Family';
    
SELECT * FROM FamFilms;

# 7e. Display the most frequently rented movies in descending order.
SELECT  * FROM rental;
SELECT * FROM inventory;
SELECT  * FROM film;

CREATE OR REPLACE VIEW MostRented AS
	SELECT f.title, COUNT(f.title) AS TimesRented
    FROM film f
		JOIN inventory
        USING(film_id)
        JOIN rental
        USING(inventory_id)
        GROUP BY(film_id)
        ORDER BY(TimesRented) DESC;
        
SELECT * FROM MostRented;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM payment;
SELECT * FROM customer;
SELECT * FROM store;

CREATE OR REPLACE VIEW StoreRevenue AS
	SELECT c.store_id, SUM(p.amount) AS Revenue
    FROM payment p
		JOIN customer c
        USING(customer_id)
        GROUP BY (store_id);

SELECT * FROM StoreRevenue;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;


CREATE OR REPLACE VIEW StoreInfo AS
	SELECT s.store_id, city.city, country.country
    FROM store s
		JOIN address
        USING (address_id)
        JOIN city
        USING (city_id)
        JOIN country
        USING (country_id);
        
SELECT * FROM StoreInfo;

# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film_category;
SELECT * FROM film;
SELECT * FROM category;

CREATE OR REPLACE VIEW TopFiveGenres AS
	SELECT cat.name, SUM(p.amount) AS GrossRevenue
    FROM payment p
		JOIN rental
        USING (rental_id)
        JOIN inventory
        USING (inventory_id)
        JOIN film
        USING (film_id)
        JOIN film_category
        USING (film_id)
        JOIN category cat
        USING(category_id)
        GROUP BY (cat.name)
        ORDER BY (GrossRevenue) DESC 
        LIMIT 5;

# * 8b. How would you display the view that you created in 8a?

SELECT * FROM TopFiveGenres;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW IF EXISTS TopFiveGenres;
        