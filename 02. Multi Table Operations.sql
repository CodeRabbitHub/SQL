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

