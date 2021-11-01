USE SwoopRun;

CREATE VIEW total_order_amount_view
AS
WITH C1 AS (
SELECT order_id,
  amount FROM
(SELECT OL.order_id,
        U.user_id,
       SUM((F.price * OL.quantity) *((100 - C.discount_percent)/100)) AS amount,
  RANK() OVER(ORDER BY O.order_time) AS OrderTimeRank-- *(100 - C.discount_percent))/100)
FROM food AS F
INNER JOIN order_line AS OL
ON F.food_id = OL.food_id
INNER JOIN orders AS O
ON OL.order_id = O.order_id
INNER JOIN users AS U
ON O.user_id = U.user_id
INNER JOIN coupons AS C
ON U.user_id = C.user_id
--WHERE C.is_used = 'Y'
WHERE C.is_used = 'N'
--AND U.user_id = 1
     AND CAST(O.order_time AS DATE) BETWEEN C.startdate AND C.expirydate
GROUP BY OL.order_id, U.user_id, O.order_time) AS Q
WHERE Q.OrderTimeRank = 1
),
C2 AS (
SELECT OL.order_id,
       SUM((F.price * OL.quantity)) AS amount
FROM food AS F
INNER JOIN order_line AS OL
ON F.food_id = OL.food_id
INNER JOIN orders AS O
ON OL.order_id = O.order_id
INNER JOIN users AS U
ON O.user_id = U.user_id
INNER JOIN coupons AS C
ON U.user_id = C.user_id
--and U.user_id = 1
GROUP BY OL.order_id, U.user_id
)
SELECT * FROM C1
UNION
SELECT * FROM C2
WHERE (order_id NOT IN (SELECT order_id FROM c1))
;




