/* Single Table Operation: 
Lecture 1: SELECT, WHERE, AND, OR, ORDER BY, LIMIT */

-- 1. Top store for movie sales

SELECT store, manager
FROM sales_by_store
ORDER BY total_sales DESC
LIMIT 1

--2. Top 3 movie categories by sales

SELECT category
FROM sales_by_film_category
ORDER BY total_sales DESC
LIMIT 3

--3. Top 5 shortest movies

SELECT title
FROM film
ORDER BY length
LIMIT 5

-- 4. Staff without a profile image

SELECT first_name, last_name
FROM staff
WHERE picture IS NULL

--16. Staff who live in Woodridge

SELECT name
FROM staff_list
WHERE city = 'Woodridge'

--17. GROUCHO WILLIAMS’ actor_id

SELECT actor_id
FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'

/* Single Table Operation:
Lecture 2: COUNT, SUM, AVERAGE, MIN, MAX, GROUP BY, HAVING  */

--5. Monthly revenue

SELECT
    EXTRACT(YEAR FROM payment_ts) AS year,
    EXTRACT(MONTH FROM payment_ts) AS mon,
    SUM(amount) AS rev
FROM payment
GROUP BY year, mon
ORDER BY year, mon

--6. Daily revenue in June, 2020

SELECT
    DATE(payment_ts) AS dt,
    SUM(amount) AS sum
FROM payment
WHERE DATE(payment_ts) BETWEEN '2020-06-01' AND '2020-06-30'
GROUP BY dt
ORDER by dt

--7. Unique customers count by month  easy

SELECT
    EXTRACT(YEAR from return_ts) AS year,
    EXTRACT(MONTH from return_ts) AS mon,
    COUNT(DISTINCT customer_id) as uu_cnt
FROM rental
GROUP BY year, mon
ORDER BY year, mon


--8. Average customer spend by month

SELECT
    EXTRACT(YEAR from payment_ts) AS year,
    EXTRACT(MONTH from payment_ts) AS mon,
    SUM(amount)/COUNT(DISTINCT customer_id) AS avg_spend
FROM payment
GROUP BY year, mon
ORDER BY year, mon

--9. Number of high spend customers by month

WITH X AS (
    SELECT
        EXTRACT(YEAR from payment_ts) AS year,
        EXTRACT(MONTH from payment_ts) AS mon,
        customer_id,
        SUM(amount) AS amt
    FROM payment
    GROUP BY year, mon, customer_id
)

SELECT year, mon, COUNT(customer_id)
FROM X
WHERE amt > 20 
GROUP BY year, mon
ORDER BY year, mon

--10. Min and max spend

WITH X AS (
    SELECT 
        customer_id,
        SUM(amount) AS amt
    FROM payment
    WHERE DATE(payment_ts) BETWEEN '2020-06-01' AND '2020-06-30'
    GROUP BY customer_id
)
 
SELECT
    MIN(amt) AS min_spend,
    MAX(amt) AS max_spend
FROM X

--18. Top film category

SELECT 
    category_id,
    COUNT(*) AS film_cnt
FROM film_category 
GROUP BY category_id
ORDER BY film_cnt DESC
LIMIT 1

--19. Most productive actor

WITH X AS (
    SELECT
        actor_id,
        COUNT(*) AS film_cnt
    FROM film_actor 
    GROUP BY actor_id
    ORDER BY film_cnt DESC
    LIMIT 1
)

SELECT first_name, last_name
FROM actor A
WHERE A.actor_id
IN (
    SELECT actor_id
    FROM X
)

--20. Customer who spent the most 

WITH X AS (
    SELECT
        customer_id,
        SUM(amount) as total_amt
    FROM payment
    WHERE DATE(payment_ts) BETWEEN '2020-02-01' AND '2020-02-29'
    GROUP BY customer_id
    ORDER BY total_amt DESC
    LIMIT 1
)

SELECT first_name, last_name
FROM customer C
WHERE C.customer_id
IN (
    SELECT customer_id
    FROM X
)

--21. Customer who rented the most

WITH X AS (
    SELECT
        customer_id,
        COUNT(*) AS cnt
    FROM rental
    WHERE DATE(payment_ts) BETWEEN '2020-05-01' AND '2020-05-31'
    GROUP BY customer_id
    ORDER BY cnt DESC
    LIMIT 1
)

SELECT first_name, last_name
FROM customer C 
WHERE C.customer_id
IN (
    SELECT customer_id
    FROM X
)

--23. Average spend per customer in Feb 2020

WITH X AS (
    SELECT
        customer_id,
        SUM(amount) AS cust_spent
    FROM payment
    WHERE DATE(payment_ts) BETWEEN '2020-02-01' AND '2020-02-29'
    GROUP BY customer_id
)

SELECT AVG(cust_spent)
FROM X

/* Single Table Operation:
Lecture 3: IN, BETWEEN, LIKE, CASE WHEN*/

--11. Actors' last name

SELECT
    last_name,
    count(*)
FROM actor
WHERE last_name IN ('DAVIS', 'BRODY', 'ALLEN', 'BERRY')
GROUP BY last_name

--12. Actors' last name ending in 'EN' or 'RY'

SELECT
    last_name,
    COUNT(*)
FROM actor
WHERE last_name LIKE ('%EN')
OR last_name LIKE ('%RY')
GROUP BY last_name

--13. Actors' first name

SELECT
    CASE WHEN first_name LIKE 'A%' THEN 'a_actors'
         WHEN first_name LIKE 'B%' THEN 'b_actors'
         WHEN first_name LIKE 'C%' THEN 'c_actors'
         ELSE 'other_actors'
         END AS actor_category,
    COUNT(*)
FROM actor
GROUP BY actor_category


--14. Good days and bad days

WITH X AS (
    SELECT
        DATE(rental_ts) AS day,
        COUNT(*) AS cnt
    FROM rental
    WHERE DATE(payment_ts) BETWEEN '2020-05-01' AND '2020-05-31'
    GROUP BY day
)

SELECT
    SUM(CASE WHEN cnt > 100 THEN 1 ELSE 0
    END) AS good_days,

    31 - SUM(CASE WHEN cnt > 100 THEN 1 ELSE 0
    END) AS bad_days
FROM X

--15. Fast movie watchers vs slow watchers

WITH X AS (
    SELECT customer_id,
    AVG(EXTRACT(DAYS FROM (return_ts - rental_ts)) + 1) AS avg_days
    FROM rental
    WHERE return_ts IS NOT NULL
    GROUP BY customer_id
)

SELECT CASE WHEN avg_days <=5 THEN 'fast_watcher'
            WHEN avg_days > 5 THEN 'slow_watcher'
            ELSE NULL
            END AS watcher_category,
COUNT(*) AS count
FROM X
GROUP BY watcher_category

--22. Average cost per rental transaction

SELECT AVG(amount)
FROM payment
WHERE DATE(payment_ts) BETWEEN '2020-05-01' AND '2020-05-31'

--24. Films with more than 10 actors

WITH X AS(
    SELECT
        film_id,
        COUNT(*) AS cnt
    FROM film_actor
    GROUP BY film_id
    HAVING cnt >=10
)

SELECT title
FROM film
WHERE film_id
IN (
    SELECT film_id
    FROM X
)

--25. Shortest film

SELECT title
FROM film
ORDER BY length
LIMIT 1

--26. Second shortest film

WITH X AS (
    SELECT film_id
    FROM film
    ORDER BY length
    LIMIT 2
)

SELECT title
FROM film
WHERE film
IN (
    SELECT film_id
    FROM X
    ORDER BY length DESC
    LIMIT 1
)

--27. Film with largest cast

WITH X AS (
    SELECT
        film_id,
        COUNT(*) AS cnt
    FROM film_actor
    GROUP BY film_id
    ORDER BY cnt DESC
    LIMIT 1
)

SELECT title
FROM film
WHERE film_id
IN (
    SELECT film_id
    FROM X
)

--28. Film with the second largest cast

WITH X AS (
    SELECT
        film_id,
        COUNT(*) AS cnt
    FROM film_actor
    GROUP BY film_id
    ORDER BY cnt DESC
    LIMIT 2
)

SELECT title
FROM film
WHERE film_id
IN (
    SELECT film_id
    FROM X
    ORDER BY cnt ASC 
    LIMIT 1
)

--29. Second highest spend customer

WITH X AS (
    SELECT
        customer_id,
        SUM(amount) as amt
    FROM payment
    WHERE DATE(payment_ts) BETWEEN '2020-05-01' AND '2020-05-31'
    GROUP BY customer_id
    ORDER BY amt DESC
    LIMIT 2
)

SELECT first_name, last_name
FROM customer
WHERE customer_id
IN (
    SELECT customer_id
    FROM X
    ORDER BY amt ASC
    LIMIT 1
)

--30. Inactive customers in May

SELECT COUNT(*)
FROM customer
WHERE customer_id
NOT IN (
    SELECT customer_id
    FROM rental
    WHERE DATE(rental_ts) BETWEEN '2020-05-01' AND '2020-05-31'
)

--31. Movies that have not been returned

WITH X AS (
    SELECT DISTINCT film_id
    FROM inventory
    WHERE inventory_id
    IN (
        SELECT inventory_id
        FROM rental
        WHERE return_ts IS NULL
        )
)
SELECT title
FROM film
WHERE film_id
IN (
    SELECT film_id
    FROM X
)

--32. Unpopular movies

WITH X AS (
    SELECT DISTINCT film_id
    FROM inventory
    WHERE inventory_id
    IN (
        SELECT inventory_id
        FROM rental
        WHERE DATE(rental_ts) BETWEEN '2020-02-01' AND '2020-02-29'
    )
)

SELECT COUNT(*)
FROM film
WHERE film_id
NOT IN (
        SELECT film_id
        FROM X
)

--33. Returning customers

WITH X AS (
    SELECT DISTINCT customer_id
    FROM rental
    WHERE DATE(rental_ts) >= '2020-05-01'
    AND DATE(rental_ts) <= '2020-05-31' 
)

SELECT COUNT(DISTINCT customer_id)
FROM rental
WHERE DATE(rental_ts) >= '2020-06-01'
AND DATE(rental_ts) <= '2020-06-30'
AND customer_id
IN (
    SELECT customer_id
    FROM X
)

--34. Stocked up movies 

WITH X AS (
    SELECT film_id,
    COUNT(*)
    FROM inventory
    GROUP BY film_id
    HAVING COUNT(*) > 7
)

SELECT title 
FROM film
WHERE film_id
IN (
    SELECT film_id
    FROM X
)

--35. Film length report

SELECT
    CASE WHEN length < 60 THEN 'short'
         WHEN length >= 100 THEN 'long'
         WHEN length >=60 AND length <100 THEN 'medium'
         ELSE NULL
         END AS film_category,
    COUNT(*) AS count
FROM film
GROUP BY film_category

            