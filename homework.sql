--Clint Goodman
--clint.goodman@gmail.com

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
ALTER TABLE sakila.actor ADD COLUMN Actor_Name VARCHAR(100);
UPDATE sakila.actor SET Actor_Name = CONCAT(first_name,' ',last_name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM sakila.actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM sakila.actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM sakila.actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE sakila.actor ADD COLUMN middle_name VARCHAR(100) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE sakila.actor MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE sakila.actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name ln, COUNT(*) FROM sakila.actor GROUP BY ln;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name ln, COUNT(*) FROM sakila.actor GROUP BY ln HAVING COUNT(ln) > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's
-- yoga teacher. Write a query to fix the record.
UPDATE sakila.actor SET first_name='HARPO' WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO,
-- as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER!
-- (Hint: update the record using a unique identifier.)
UPDATE sakila.actor SET
	first_name = IF(first_name="GROUCHO", "MUCHO GROUCHO", first_name),
    first_name = IF(first_name="HARPO", "GROUCHO",first_name)
WHERE actor_id IN (SELECT actor_id FROM (SELECT actor_id FROM actor WHERE last_name = "WILLIAMS" and first_name IN ("HARPO", "GROUCHO", "MUCHO GROUCHO")) TempTbl);
-- NOTE: The WHERE statement is querying for the actor_id in a newly created table (outer SELECT statement in WHERE clause) that is populated using the inner SELECT statement.
-- Given the data we are working with this should return one value only.  IT was created under the assumption that I don't have access to the actor_id field but I do know the 
-- last_name and the possible first_name values (multiple options) because I was made aware of the erroneous update in the earlier question.

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE actor;
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address , address.address2 FROM staff INNER JOIN
	address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) FROM staff INNER JOIN
	payment ON staff.staff_id = payment.staff_id GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title , COUNT(film_actor.actor_id) actorCount FROM film INNER JOIN
	film_actor ON film.film_id = film_actor.film_id GROUP BY film.title;  

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) AS  'Number of Copies' FROM inventory WHERE film_id IN (SELECT film_id FROM film WHERE title="Hunchback Impossible");

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.last_name, customer.first_name, SUM(payment.amount) as 'Total Paid' FROM customer INNER JOIN payment
	ON customer.customer_id = payment.customer_id GROUP BY customer.customer_id ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title from film WHERE title IN
	(SELECT title FROM film WHERE (title LIKE "K%" OR title LIKE "Q%") AND language_id IN
		(SELECT language_id FROM language WHERE name = 'English'));

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN 
	(SELECT actor_id FROM film_actor WHERE film_id IN
		(SELECT film_id FROM film WHERE title ='Alone Trip')
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer INNER JOIN (address, city, country) ON 
	(customer.address_id = address.address_id AND address.city_id = city.city_id AND city.country_id = country.country_id AND 
		country.country = 'Canada');

-- OPTION 2 
SELECT first_name, last_name, email FROM customer WHERE address_id IN 
	(SELECT address_id FROM address WHERE city_id IN
		(SELECT city_id FROM city WHERE country_id IN
			(SELECT country_id FROM country WHERE country = 'Canada')
		)
	)
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.  EXTRA: A recent 'mishap' forced the owner to QC the Rating for films
-- categorized as 'Family.'  The Rating field was added to verify that the store's definition of 'family friendly'
-- resembles society's.
SELECT film.title, film.rating, category.name FROM film INNER JOIN (film_category, category) ON 
	(film.film_id = film_category.film_id AND film_category.category_id = category.category_id AND category.name = 'Family');

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) AS Rental_Count FROM film, rental WHERE film_id IN 
	(SELECT film_id FROM inventory WHERE inventory.inventory_id = rental.inventory_id) GROUP BY film.title ORDER BY Rental_Count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, CONCAT("$", SUM(payment.amount)) AS 'Total Sales' FROM store  INNER JOIN (staff, payment) ON
	(payment.staff_id = staff.staff_id AND staff.store_id = store.store_id) GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country FROM store INNER JOIN (city, country, address) ON
	(store.address_id = address.address_id AND address.city_id = city.city_id AND city.country_id = country.country_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables:
-- category, film_category, inventory, payment, and rental.)
SELECT category.name, (CONCAT("$", sum(payment.amount))) AS Total_Sales FROM category INNER JOIN (film_category, payment, 
	inventory, rental) ON(payment.rental_id = rental.rental_id AND rental.inventory_id = inventory.inventory_id AND 
	film_category.film_id = inventory.film_id AND film_category.category_id = category.category_id) GROUP BY category.name 
	ORDER BY Total_Sales DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to 
-- create a view.
CREATE VIEW Top5_Genres AS SELECT category.name, (CONCAT("$", sum(payment.amount))) AS Total_Sales FROM category INNER JOIN (film_category, payment, 
	inventory, rental) ON(payment.rental_id = rental.rental_id AND rental.inventory_id = inventory.inventory_id AND 
	film_category.film_id = inventory.film_id AND film_category.category_id = category.category_id) GROUP BY category.name 
	ORDER BY Total_Sales DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * From Top5_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top5_Genres;
