/*Multi-Table Operation: Lecture 1: INNER JOIN */

--36. Actors from film 'AFRICAN EGG'

SELECT A.first_name, A.last_name
FROM film F
INNER JOIN film_actor FA
ON FA.film_id = F.film_id
INNER JOIN actor A
ON A.actor_id = FA.actor_id
WHERE F.title = 'AFRICAN EGG'

--37. Most popular movie category

SELECT C.name 
FROM film_category FC 
INNER JOIN category C 
ON C.category_id = FC.category_id 
GROUP BY C.name 
ORDER BY COUNT(*) DESC
LIMIT 1

--38. Most popular movie category (name and id)

SELECT C.category_id, MAX(C.name) 
FROM film_category FC 
INNER JOIN category C 
ON C.category_id = FC.category_id 
GROUP BY C.category_id 
ORDER BY COUNT(*) DESC
LIMIT 1

--NOTE: The SELECT statement has MAX(C.name)

--39. Most productive actor with inner join

SELECT
    A.actor_id,
    MAX(A.first_name) AS first_name,
    MAX(A.last_name) AS last_name
FROM actor A 
INNER JOIN film_actor FA 
ON A.actor_id = FA.actor_id
GROUP BY A.actor_id
ORDER BY COUNT(*) DESC
LIMIT 1

--40. Top 5 most rented movie in June 2020

SELECT 
    F.film_id, 
    MAX(F.title)
FROM rental R 
INNER JOIN inventory I 
ON R.rental_id = I.rental_id
INNER JOIN film F 
ON F.film_id = I.film_id
WHERE DATE(R.rental_ts) BETWEEN '2020-06-01' AND '2020-06-30'
GROUP BY F.film_id
ORDER BY COUNT(*) DESC
LIMIT 5

--48. Movie and TV actors

SELECT 
    M.actor_id, 
    M.first_name, 
    M.last_name
FROM actor_movie M 
INNER JOIN actor_tv T 
on T.actor_id = M.actor_id

--49. Top 3 money making movie categories

SELECT 
    C.name AS name 
    SUM(P.amount) AS revenue
FROM payment P 
INNER JOIN rental R 
ON R.customer_id = P.customer_id
INNER JOIN inventory I 
ON I.inventory_id = R.inventory_id
INNER JOIN film F 
ON I.film_id = F.film_id
INNER JOIN film_category FC
ON F.film_id = FC.film_id
INNER JOIN category C 
ON FC.category_id = C.category_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3

--50. Top 5 cities for movie rentals

SELECT CT.city SUM(P.amount) AS sum 
FROM payemnt P 
INNER JOIN customer C 
ON C.customer_id = P.customer_id
INNER JOIN address A 
ON A.address_id = C.address_id
INNER JOIN city CT 
ON CT.city_id = A.city_id
WHERE DATE(payment_ts) BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY CT.city
ORDER BY sum DESC
LIMIT 5

/*Multi-Table Operation: Lecture 2: OUTER JOINS*/

--41. Productive actors vs less-productive actors

WITH X AS (
        SELECT
        A.actor_id,
        CASE WHEN COUNT(DISTINCT FA.film_id) >= 30 THEN 'productive'
             ELSE 'less productive'
        END AS actor_category
        FROM actor A
        LEFT JOIN film_actor FA
        ON FA.actor_id = A.actor_id
        GROUP BY A.actor_id
)
SELECT actor_category, COUNT(*)
FROM X
GROUP BY actor_category

--42. Films that are in stock vs not in stock

WITH X AS(
        SELECT F.film_id,
        MAX(CASE WHEN I.inventory_id NOT NULL THEN 'in stock'
             ELSE 'not in stock'
        END) AS in_stock
        FROM film F
        LEFT JOIN inventory I 
        ON F.film_id = I.inventory_id
        GROUP BY F.film_id
)
SELECT in_stock, COUNT(*)
FROM X
GROUP BY in_stock


--43. Customers who rented vs. those who did not

SELECT have_rented, COUNT(*)
FROM (
    SELECT C.customer_id,
        CASE WHEN R.customer_id IS NOT NULL THEN 'rented'
             ELSE 'never-rented'
        END AS have_rented
        FROM customer
        LEFT JOIN (
            SELECT DISTINCT customer_id
            FROM rental
            WHERE DATE(rental_ts) BETWEEN '2020-05-01' AND '2020-05-31'
                ) R 
        ON R.customer_id = C.customer_id
 ) X
GROUP BY have_rented

--44. In-demand vs not-in-demand movies

SELECT demand_category, COUNT(*)
FROM (
    SELECT
        F.film_id,
        CASE WHEN COUNT(R.rental_id)>1 THEN 'in-demand'
             ELSE 'not-in-demand'
        FROM film F
        LEFT JOIN inventory I
        ON F.film_id = I.film_id
        LEFT JOIN (
            SELECT inventory_id, rental_id
            FROM rental
            WHERE DATE(rental_ts) BETWEEN '2020-05-01' AND '2020-05-31'
        ) R 
        ON R.inventory_id = I.inventory_id
        GROUP BY F.film_id
    ) X
GROUP BY demand_category

--45. Movie inventory optimization

SELECT COUNT(inventory_id )
FROM inventory I
INNER JOIN (
        SELECT F.film_id
        FROM film F
        LEFT JOIN (
            SELECT DISTINCT I.film_id
            FROM inventory I
            INNER JOIN (
                SELECT inventory_id, rental_id
                FROM rental
                WHERE DATE(rental_ts) >= '2020-05-01'
                AND DATE(rental_ts) <= '2020-05-31'
                ) R
                ON I.inventory_id = R.inventory_id
        ) X ON X.film_id = F.film_id
        WHERE X.film_id IS NULL
)Y
ON Y.film_id = I.film_id;

--51. Movie only actor 

SELECT M.first_name, M.last_name
FROM actor_movie M
LEFT JOIN actor_tv T
ON M.actor_id = T.actor_id
WHERE T.actor_id is NULL

--52. Movies cast by movie only actors

SELECT film_id,
FROM film F 
LEFT JOIN(
    SELECT DISTINCT FA.film_id
    FROM film_actor FA
    INNER JOIN actor_tv T
    ON T.actor_id = FA.actor_id
)X
ON F.film_id = X.film_id
WHERE X.film_id IS NULL

--53. Movie groups by rental income

SELECT film_group, COUNT(*)
FROM (SELECT 
        F.film_id,
        CASE WHEN SUM(P.amount) >=100 THEN 'high'
             WHEN SUM(P.amount) >=20 THEN 'medium'
             ELSE 'low'
        END AS film_group
      FROM film
      LEFT JOIN inventory I
      ON I.film_id = F.film_id
      LEFT JOIN rental R 
      ON R.inventory_id = I.inventory_id
      LEFT JOIN payment P
      ON P.rental_id = R.rental_id
      GROUP BY F.film_id
)X
GROUP BY film_group

--54. Customer groups by movie rental spend 

SELECT customer_group, COUNT(*)
FROM (
    SELECT
    C.customer_id,
    CASE WHEN SUM(P.amount)>=150 THEN 'high'
         WHEN SUM(P.amount)>=100 THEN 'medium'
         ELSE 'low' END customer_group
    FROM customer C
    LEFT JOIN payment P
    ON P.customer_id = C. customer_id
    GROUP BY C.customer_id
)X
GROUP BY customer_group

--55. Busy days and slow days

SELECT date_category, COUNT(*)
FROM (
    SELECT 
        D.date,
        CASE WHEN (*) >= 100 THEN 'busy'
             ELSE 'slow'
        END AS date_category
        FROM dates D
        LEFT JOIN (
            SEELCT * FROM RENTAL
        ) R
        ON D.date = DATE(R.rental_ts)
        WHERE D.date >= '2020-05-01'
        AND D.date <= '2020-05-31'
        GROUP BY D.date
) X
GROUP BY date_category

--56. Total number of actors

SELECT COUNT(DISTINCT actor_id)
FROM (
    SELECT COALESCE(T.actor_id, M.actor_id) AS actor_id
    FROM actor_tv T
    FULL OUTER JOIN actor_movie M 
    ON M.actor_id = T.actor_id
) X




