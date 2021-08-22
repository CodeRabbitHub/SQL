/*Window Functions: Lecture 1: AVG, MIN/MAX, SUM*/

--58. Percentage of revenue per movie

WITH X AS(
    SELECT I.film_id, SUM(P.amount) AS revenue
    FROM payment P 
    INNER JOIN rental R
    ON R.rental_id = P.rental_id
    INNER JOIN inventory I 
    ON I.inventory_id = R.inventory_id
    GROUP BY I.fim_id
)
 SELECT film_id, revenue*100/SUM(revenue) OVER() revenue_percentage
 FROM X
 ORDER BY film_id
 LIMIT 10

 --59. Percentage of revenue per movie by category 

WITH X AS(
    SELECT I.film_id, SUM(P.amount) AS revenue
    FROM payment P 
    INNER JOIN rental R
    ON R.rental_id = P.rental_id
    INNER JOIN inventory I 
    ON I.inventory_id = R.inventory_id
    GROUP BY I.fim_id
)
 SELECT 
    X.film_id,
    C.name AS category_name,
    revenue*100/SUM(revenue) OVER(PARTITION BY C.name) AS revenue_percentage
 FROM X
 INNER JOIN film_category FC
 ON FC.film_id = X.film_id
 INNER JOIN category C 
 ON C.category_id = FC.category_id
 ORDER BY film_id
 LIMIT 10

 --60. Movie rentals and average rentals in the same category

WITH X AS (
    SELECT film_id, COUNT(rental_id) AS rentals
    FROM rental R 
    INNER JOIN inventory I 
    ON R.inventory_id = I.inventory_id
    GROUP BY film_id
)
WITH Y AS (
SELECT  X.film_id,
        C.name AS category_name, 
        X.rentals,
        AVG(rentals) OVER(PARTITION BY C.name) AS avg_rentals_category
        FROM X 
        INNER JOIN film_category FC
        ON FC.film_id = FC.category_id
        INNER JOIN category C 
        ON C.category_id = FC.category_id
)
SELECT
    film_id,
    category_name,
    rentals,
    avg_rentals_category
FROM Y
WHERE film_id <= 10

--61. Customer spend vs average spend in the same store

WITH X AS(
    SELECT 
        P.customer_id, 
        MAX(C.store_id) AS store_id, 
        SUM(P.amount) as ltd_spend
    FROM payment P 
    INNER JOIN customer C 
    ON P.customer_id = C.customer_id
    GROUP BY P.customer_id
)
SELECT 
    customer_id, 
    store_id, 
    ltd_spend, 
    store_avg 
FROM (
    SELECT customer_id, 
    store_id, 
    ltd_spend, 
    AVG(ltd_spend) OVER(PARTITION BY store_id) AS store_avg
    FROM X) Y
WHERE Y.customer_id IN (1, 100, 101, 200, 201, 300, 301, 400, 401, 500)
ORDER BY Y.customer_id

--70. Cumulative spend

WITH X AS (
    SELECT 
        DATE(payment_ts) AS date, 
        customer_id, 
        SUM(amount) AS daily_spend
    FROM payment
    WHERE customer_id IN (1, 2, 3)
    GROUP BY DATE(payment_ts), customer_id
)
SELECT 
    date,
    customer_id,
    X.daily_spend,
    SUM(X.daily_spend) OVER(PARTITION BY customer_id ORDER BY date) AS cumulative_spend
FROM X

/*Window Functions: Lecture 2: ROW_NUMBER, RANK, DENSE_RANK*/

--62. Shortest film by category

WITH X AS (
    SELECT 
    F.film_id, 
    F.title, 
    F.length, 
    C.name AS category,
    ROW_NUMBER() OVER(PARTITION BY C.name ORDER BY F.length) row_num
FROM film F 
INNER JOIN film_category FC 
ON FC.film_id = F.film_id
INNER JOIN category C 
ON C.category_id =  FC.category_id
)
SELECT
    film_id,
    title,
    length,
    category,
    row_num
FROM X
WHERE row_num = 1

--63. Top 5 customers by store

WITH X AS (
    SELECT 
        C.customer_id,
        MAX(store_id) AS store_id,
        SUM(amount) revenue 
    FROM customer C
    INNER JOIN payment P
    ON P.customer_id = C.customer_id
    GROUP BY C.customer_id
)
SELECT * FROM  (
    SELECT 
        store_id, 
        customer_id,
        revenue,
        DENSE_RANK() OVER (PARTITION BY store_id ORDER BY revenue DESC) AS ranking
    FROM X) Y
WHERE ranking <=5

--64. Top 2 films by category

WITH X AS (
    SELECT
        F.film_id,
        MAX(C.name) AS category,
        SUM(P.amount) AS revenue
    FROM payment P
    INNER JOIN rental R 
    ON R.rental_id = P.rental_id
    INNER JOIN inventory I
    ON I.inventory_id = R.inventory_id
    INNER JOIN film F
    ON F.film_id = I.film_id
    INNER JOIN film_category FC
    ON FC.film_id = F.film_id
    INNER JOIN category C
    ON C.category_id = FC.category_id
    GROUP BY F.film_id
)
SELECT * FROM (
    SELECT
        category,
        FR.film_id,
        revenue,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY revenue DESC)
    FROM X
    INNER JOIN film_category FC
    ON FC.film_id = X.film_id
    INNER JOIN category C
    ON C.category_id = FC.category_id
) Y
WHERE row_num <=2

/*Window Functions: Lecture 3: NTILE */

--65. Movie revenue percentiles

WITH X AS (
    SELECT
        F.film_id, 
        SUM(P.amount) revenue,
        NTILE(100) OVER(ORDER BY SUM(P.amount)) AS percentile 
    FROM payment P 
    INNER JOIN rental R 
    ON R.rental_id = P.rental_id
    INNER JOIN inventory I 
    ON I.inventory_id = R.inventory_id
    INNER JOIN film F
    ON F.film_id = I.film_id
    GROUP BY F.film_id
)
SELECT
    film_id,
    revenue,
    percentile
    FROM X
    WHERE film_id IN (1,10,11,20,21,30)


--66. Movie percentiles by revenue by category

WITH x AS (
    SELECT
        F.film_id,
        MAX(C.name) AS category,
        SUM(P.amount) revenue
    FROM payment P
    INNER JOIN rental R
    ON R.rental_id = P.rental_id
    INNER JOIN inventory I
    ON I.inventory_id = R.inventory_id
    INNER JOIN film F
    ON F.film_id = I.film_id
    INNER JOIN film_category FC
    ON FC.film_id = F.film_id
    INNER JOIN category C
    ON C.category_id = FC.category_id
    GROUP BY F.film_id
)
SELECT
    category,
    film_id,
    revenue,
    percentile
    FROM (
        SELECT
        category,
        X.film_id,
        revenue,
        NTILE(100) OVER(PARTITION BY category ORDER BY revenue) percentile
    FROM X
    INNER JOIN film_category FC
    ON FC.film_id = X.film_id
    INNER JOIN category C
    ON C.category_id = FC.category_id
    ) Y
WHERE film_id <=20
ORDER BY category, revenue

--67. Quartile by number of rentals

WITH X AS (
    SELECT
        F.film_id,
        COUNT(*) AS num_rentals,
        NTILE(4) OVER(ORDER BY COUNT(*)) AS quartile
        FROM rental R
        INNER JOIN inventory I
        ON I.inventory_id = R.inventory_id
        INNER JOIN film F
        ON F.film_id = I.film_id
        GROUP BY F.film_id
)
SELECT *
FROM X
WHERE film_id IN (1,10,11,20,21,30)

--68. Spend difference between first and second rentals

SELECT 
    customer_id,
    prev_amount - current_amount AS delta
    FROM (
        SELECT
            customer_id,
            payment_ts,
            amount as current_amount,
            LAG(amount, 1) OVER(PARTITION BY customer_id ORDER BY payment_ts ) AS prev_amount,
            ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_ts) AS payment_idx
        FROM payment
        WHERE customer_id IN (1,2,3,4,5,6,7,8,9,10)
        ) X
    WHERE payment_idx = 2;

--69. Number of happy customers

WITH customer_rental_date AS (
    SELECT
        customer_id,
        DATE(rental_ts) AS rental_date
        FROM rental
        WHERE DATE(rental_ts) >= '2020-05-24'
        AND DATE(rental_ts) <= '2020-05-31'
        GROUP BY customer_id, DATE(rental_ts)
),
customer_rental_date_diff AS (
    SELECT
        customer_id,
        rental_date AS current_rental_date,
        LAG( rental_date, 1) OVER(PARTITION BY customer_id ORDER BY rental_date) AS prev_rental_date
        FROM customer_rental_date
)

SELECT COUNT(*) 
FROM (
    SELECT
    customer_id,
    MIN(current_rental_date - prev_rental_date)
    FROM customer_rental_date_diff
    GROUP BY customer_id
    HAVING MIN(current_rental_date - prev_rental_date) = 1
) X
