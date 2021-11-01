SELECT * FROM restaurant;
SELECT * FROM orders;

SELECT R.restaurant_name as restaurant_name,
	RANK() OVER( ORDER BY COUNT(O.order_id) DESC ) AS RestaurantRank
FROM restaurant AS R
INNER JOIN orders AS O
ON R.restaurant_id = O.restaurant_id
WHERE O.order_status = 'DELIVERED'
GROUP BY R.restaurant_name
HAVING COUNT(O.order_id) > 1
ORDER BY COUNT(O.order_id) DESC;




WITH food_rank AS
( SELECT C.state_province,
OH.order_date,
C.customer_name,
RANK() OVER( PARTITION BY C.state_province ORDER BY OH.order_date DESC ) AS StateRank
FROM customer AS C
INNER JOIN order_header AS OH
ON C.customer_id = OH.customer_id
)


WITH customer_rank AS
( SELECT C.state_province,
OH.order_date,
C.customer_name,
RANK() OVER( PARTITION BY C.state_province ORDER BY OH.order_date DESC ) AS StateRank
FROM customer AS C
INNER JOIN order_header AS OH
ON C.customer_id = OH.customer_id
)





WITH delivery_agent_rank AS
( SELECT C.state_province,
OH.order_date,
C.customer_name,
RANK() OVER( PARTITION BY C.state_province ORDER BY OH.order_date DESC ) AS StateRank
FROM customer AS C
INNER JOIN order_header AS OH
ON C.customer_id = OH.customer_id
)




