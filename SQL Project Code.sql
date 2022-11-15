-- Question 1:

SELECT f.rating, AVG(f.rental_duration) AS avg_rental_duration
FROM film f
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
GROUP BY 1
ORDER BY 2 DESC;




-- Question 2:

WITH rentals_top5perc AS (
	SELECT SUM(rentals_total) AS rentals_top5perc
	FROM (
		SELECT CONCAT(c.first_name, ' ', c.last_name) AS full_name, COUNT(*) AS rentals_total
		FROM customer c
		JOIN rental r
		ON r.customer_id = c.customer_id
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT (0.05 * (SELECT COUNT(*) FROM customer))) t1 ),

	rentals_total AS (
		SELECT COUNT(*) AS rentals_total
		FROM rental
	)

SELECT ROUND(r5.rentals_top5perc / rt.rentals_total * 100, 2) AS percentage_top5_rentals
FROM rentals_top5perc r5
JOIN rentals_total rt
ON TRUE;




-- Question 3:

WITH top5 AS (
  SELECT country, CASE WHEN TRUE THEN 'top5' END AS group
  FROM (
    SELECT co.country, COUNT(*)
    FROM customer cu
    JOIN address a
    ON a.address_id = cu.address_id
    JOIN city ci
    ON ci.city_id = a.city_id
    JOIN country co
    ON co.country_id = ci.country_id
    GROUP BY 1
    ORDER BY 2 DESC
  ) sub
  LIMIT 5 ),

  not_top5 AS (
    SELECT country, CASE WHEN TRUE THEN 'not top5' END AS group
    FROM (
      SELECT co.country, COUNT(*)
      FROM customer cu
      JOIN address a
      ON a.address_id = cu.address_id
      JOIN city ci
      ON ci.city_id = a.city_id
      JOIN country co
      ON co.country_id = ci.country_id
      GROUP BY 1
      ORDER BY 2 ) sub
    LIMIT ((
	     SELECT COUNT (DISTINCT co.country_id)
	     FROM customer cu
	     JOIN address a
	     ON a.address_id = cu.address_id
	     JOIN city ci
	     ON ci.city_id = a.city_id
	     JOIN country co
	     ON co.country_id = ci.country_id ) - 5 )
  ),

  avg_spend AS (
    SELECT co.country, AVG(p.amount) AS avg_amount
    FROM payment p
    JOIN customer cu
    ON cu.customer_id = p.customer_id
    JOIN address a
    ON a.address_id = cu.address_id
    JOIN city ci
    ON ci.city_id = a.city_id
    JOIN country co
    ON co.country_id = ci.country_id
    GROUP BY 1
    ORDER BY 1
  )

SELECT groups, AVG(avg_amount) AS average_spending_per_group
FROM (
  SELECT avg_spend.country, avg_spend.avg_amount, CONCAT(top5.group, not_top5.group) AS groups
  FROM avg_spend
  LEFT JOIN top5
  ON top5.country = avg_spend.country
  LEFT JOIN not_top5
  ON not_top5.country = avg_spend.country ) t
GROUP BY 1;




-- Question 4:

SELECT r.rental_date,
	p.amount,
	SUM(p.amount) OVER (PARTITION BY DATE_TRUNC('month', r.rental_date) ORDER BY r.rental_date) AS running_sum_per_month
FROM rental r
JOIN payment p
ON p.rental_id = r.rental_id
ORDER BY 1;
