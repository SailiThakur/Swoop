USE SwoopRun;

SELECT * FROM  roles;
SELECT * FROM  users;
SELECT * FROM  user_roles;

SELECT * FROM  user_address;
UPDATE user_address SET is_primary='Y' WHERE user_id NOT IN (1,4,8,12,16,20,24,28,32,36,40,45);
UPDATE user_address SET is_primary='Y' WHERE addr_id IN (56,57,58,59,60,61,62,63,64,65,66,67);

SELECT * FROM  contact_details;
UPDATE contact_details SET is_primary='Y' WHERE phone_num IN ('519-642-8577','912-918-4639','615-648-5682','405-441-6386','756-680-8211',
'778-551-5219','777-536-8177','669-257-8665','617-368-5658','849-138-6364');
UPDATE contact_details SET is_primary='Y' WHERE user_id NOT IN (1,4,8,12,16,20,24,28,32,36);

SELECT * FROM  restaurant;
SELECT * FROM  restaurant_type;

SELECT * FROM  food;
UPDATE food SET is_vegan='Y' where food_id IN (2,3,4,11,12,13,14,15,16,20);

SELECT * FROM  orders;
SELECT * FROM  order_line;

SELECT * FROM  delivery;
UPDATE delivery SET delivery_status='DELIVERED' WHERE delivery_id < 38;
UPDATE delivery SET delivery_status='CANCELLED' WHERE delivery_id IN (2,6,9,21,32,38);
UPDATE delivery SET delivery_status='IN PROGRESS' WHERE delivery_id = 39;

SELECT * FROM  order_payment;

UPDATE order_payment SET payment_status='VALIDATING' WHERE order_id IN (
SELECT order_id from orders WHERE order_status='OPEN');

UPDATE order_payment SET payment_status='SUCCESS' WHERE order_id IN (
SELECT order_id from orders WHERE order_status='DELIVERED');

UPDATE order_payment SET payment_status='CANCELLED' WHERE order_id IN (
SELECT order_id from orders WHERE order_status='CANCELLED');

UPDATE order_payment SET payment_status='AWAITING' WHERE order_payment_id=76;
UPDATE order_payment SET payment_status='FAILED' WHERE order_payment_id IN (37,69);
UPDATE order_payment SET payment_status='REFUNDED' WHERE order_payment_id IN (34,70);


SELECT * FROM  payment_mode;

SELECT * FROM  card_payments;
UPDATE card_payments SET is_primary='Y' WHERE user_id NOT IN (1,10,20,50);


SELECT * FROM  mobile_payments;
UPDATE mobile_payments SET is_primary='Y' WHERE wallet_name='eCash';

SELECT * FROM  coupons;
UPDATE coupons SET startdate=CAST(DATEADD(DAY,-365,getdate()) as date) WHERE discount_id IN (2,6,12,24,40); 
UPDATE coupons SET startdate=CAST(DATEADD(DAY,-100,getdate()) as date) WHERE discount_id IN (5,10,15,20,30);
UPDATE coupons SET expirydate=CAST(DATEADD(DAY,100,getdate()) as date) WHERE discount_id IN (5,10,15,20,30);
UPDATE coupons SET expirydate=CAST(DATEADD(DAY,365,getdate()) as date) WHERE discount_id IN (4,8,12,16,35);
UPDATE coupons SET expirydate=CAST(DATEADD(DAY,-30,getdate()) as date),is_used='Y' WHERE discount_id IN (6,19,1,3,22,28,13);