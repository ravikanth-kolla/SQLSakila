use sakila;
#* 1a. Display the first and last names of all actors from the table `actor`. 
select first_name, last_name from actor;

#* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
select concat(first_name, ' ', last_name) as 'Actor Name' from actor;

#* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 
#"Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from 
	actor 
where first_name = 'Joe';

#* 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like '%GEN%';

#* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%LI%' order by last_name, first_name ;

#* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country 
from 
	country 
where country in 
	('Afghanistan','Bangladesh','China');

#* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE `sakila`.`actor` 
	ADD COLUMN `middle_name` VARCHAR(45) NULL  DEFAULT NULL AFTER `first_name`;

#* 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE `sakila`.`actor` 
	CHANGE COLUMN `middle_name` `middle_name` BLOB NULL DEFAULT NULL ;

#* 3c. Now delete the `middle_name` column.
ALTER TABLE `sakila`.`actor` 
	DROP COLUMN `middle_name`;

#* 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as Num_Actors 
from 
	actor 
GROUP BY last_name;

#* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as Num_Actors 
	from actor  a 
GROUP BY last_name 
	having Num_Actors > 1;

#* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
#the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

update  actor 
	set first_name = 'HARPO' 
	where 
		(last_name = 'WILLIAMS' and first_name = 'GROUCHO');

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name 
#to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME 
#OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

update actor   
	set first_name = (
		case 
			when first_name = 'HARPO' then  'GROUCHO'
			else 'MUCHO GROUCHO'
		end)
	where actor_id = 172;

#* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 
#* Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
#(https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

#* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
#Use the tables `staff` and `address`:
select staff.first_name, staff.last_name, address.address 
from 
	staff 
	inner join address
		on staff.address_id = address.address_id;

#* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
# Use tables `staff` and `payment`. 
select s.staff_id,s.first_name,s.last_name,sum(amount) as Aug_2005_Collections 
from 
	staff s 
	INNER JOIN payment p 
		on p.staff_id=s.staff_id
	AND p.payment_date >= '2005-08-01' and p.payment_date <= '2005-08-31'
group by first_name,last_name;

#* 6c. List each film and the number of actors who are listed for that film.
# Use tables `film_actor` and `film`. Use inner join.
select f.film_id, f.title,count(actor_id) as Num_of_actors 
from 
	film f
	INNER JOIN film_actor fa
		on f.film_id = fa.film_id
GROUP BY title;


#* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(*) as Num_Copies from inventory where film_id in 
	(select film_id from film where title = 'Hunchback Impossible');


#* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
#List the customers alphabetically by last name:
select c.customer_id,c.first_name,c.last_name,sum(amount) as Total_Paid 
from 
	customer c 
	INNER JOIN payment p 
		on p.customer_id=c.customer_id
group by c.customer_id,first_name,last_name
order by 
	last_name;

#* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title from film where (title like 'K%' or title like 'Q%')
and language_id in(
SELECT language_id from language where name = 'English');

#* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name from actor where actor_id in (
	select actor_id from film_actor where film_id in(
		select film_id from film where title = 'Alone Trip'));


#* 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
#and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email 
from 
	customer 
	INNER JOIN address
		on customer.address_id = address.address_id
	INNER JOIN city
		on address.city_id = city.city_id
	INNER JOIN country
		on city.country_id = country.country_id
	AND country.country = 'CANADA';

#* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as famiy films.
select film_id, title from film where film_id in (
	select film_id from film_category where category_id in(
		select category_id from category where name = 'Family'));

#* 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) as Num_Rentals 
from 
	film f
	inner join inventory i
		on f.film_id = i.film_id
	inner join rental r
		on i.inventory_id = r.inventory_id
group by title
order by 
	count(r.rental_id) desc;

#* 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, sum(p.amount) as Revenue 
from 
	store st
	inner join staff sf
		on st.store_id = sf.store_id
	inner join payment p
		on sf.staff_id = p.staff_id
group by store_id
order by 
	sum(p.amount) desc;

#* 7g. Write a query to display for each store its store ID, city, and country.
select st.store_id, ci.city,co.country 
from 
	store st
	inner join address a
		on st.address_id = a.address_id
	inner join city ci
		on a.city_id = ci.city_id
	inner join country co
		on ci.country_id = co.country_id;

#* 7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select ca.name as Category_Name, sum(p.amount) as Revenue 
from 
	category ca
	inner join film_category fc
		on ca.category_id = fc.category_id
	inner join inventory i
		on fc.film_id = i.film_id
	inner join rental r
		on i.inventory_id = r.inventory_id
	inner join payment p
		on r.rental_id = p.rental_id
group by Category_Name
order by 
	Revenue desc limit 5;

#* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by
# gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, 
#you can substitute another query to create a view.
create view Top_5_Grossers as
	select ca.name as Category_Name, sum(p.amount) as Revenue 
	from 
		category ca
		inner join film_category fc
			on ca.category_id = fc.category_id
		inner join inventory i
			on fc.film_id = i.film_id
		inner join rental r
			on i.inventory_id = r.inventory_id
		inner join payment p
			on r.rental_id = p.rental_id
	group by Category_Name
	order by 
		Revenue desc limit 5;

#* 8b. How would you display the view that you created in 8a?
select * from Top_5_Grossers;

#* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop  view if exists Top_5_Grossers ;


