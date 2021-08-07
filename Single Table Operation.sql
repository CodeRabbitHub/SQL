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
    FROM payemnt
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