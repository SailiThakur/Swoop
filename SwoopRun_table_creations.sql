use master;
drop database SwoopRun;

CREATE DATABASE SwoopRun;
USE SwoopRun;

DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS user_address;
DROP TABLE IF EXISTS contact_details;
DROP TABLE IF EXISTS restaurant;
DROP TABLE IF EXISTS restaurant_type;
DROP TABLE IF EXISTS food;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS order_payment;
DROP TABLE IF EXISTS payment_mode;
DROP TABLE IF EXISTS card_payments;
DROP TABLE IF EXISTS mobile_payments;
DROP TABLE IF EXISTS coupons;



CREATE TABLE roles	(
						role_id INT IDENTITY(1,1) NOT NULL,
						role_name VARCHAR(20),
						description VARCHAR (100),
					CONSTRAINT roles_role_id_pk PRIMARY KEY ( role_id )
					)
;

CREATE TABLE users	( 
						user_id INT IDENTITY(1,1) NOT NULL,
						first_name VARCHAR (25) NOT NULL,
						last_name VARCHAR (25) NOT NULL,
						email VARCHAR (100),
					CONSTRAINT users_user_id_pk PRIMARY KEY ( user_id )
					)
;

CREATE TABLE user_roles	(
							user_id INT NOT NULL,
							role_id INT NOT NULL,
						CONSTRAINT user_roles_uid_rid_pk PRIMARY KEY ( user_id , role_id ),
						CONSTRAINT user_roles_uid_fk FOREIGN KEY ( user_id ) REFERENCES users ( user_id ),
						CONSTRAINT user_roles_rid_fk FOREIGN KEY ( role_id ) REFERENCES roles ( role_id )
						)
;

CREATE TABLE contact_details	(
									user_id INT NOT NULL,
									phone_num VARCHAR(12) NOT NULL,
									is_primary CHAR(1) DEFAULT('N') NOT NULL,
								CONSTRAINT contact_details_uid_phone_num_pk PRIMARY KEY ( user_id , phone_num ),
								CONSTRAINT contact_details_user_id_fk FOREIGN KEY ( user_id ) REFERENCES users ( user_id )
								)
;

ALTER TABLE contact_details
	ADD CONSTRAINT chck_contact_details_is_primary CHECK (is_primary IN ( 'N' , 'Y' )
	)
; 
CREATE TABLE user_address	(
								addr_id INT IDENTITY(1,1) NOT NULL,
								user_id INT NOT NULL,
								street_addr VARCHAR(200),
								city VARCHAR(100),
								state CHAR(2),
								zip_code INT NOT NULL,
								latitude NUMERIC(10,8) DEFAULT NULL,
								longitude NUMERIC(11,8) DEFAULT NULL,
								is_primary CHAR(1) DEFAULT('N') NOT NULL,
							CONSTRAINT user_address_addr_id_pk PRIMARY KEY ( addr_id ),
							CONSTRAINT user_address_user_id_fk FOREIGN KEY ( user_id ) REFERENCES users ( user_id )
							)
;

ALTER TABLE user_address 
	ADD CONSTRAINT chck_user_addr_zip_code CHECK ( zip_code LIKE REPLICATE('[0-9]' , 5 ) 
	)
;
ALTER TABLE user_address
	ADD CONSTRAINT chck_user_addr_is_primary CHECK (is_primary IN ( 'N' , 'Y' )
	)
; 


CREATE TABLE restaurant	(
							restaurant_id INT IDENTITY(1,1) NOT NULL,
							restaurant_name VARCHAR(50),
							street_addr VARCHAR(200),
							city VARCHAR(100),
							state CHAR(2),
							zip_code INT,
							contact_number CHAR(12),
							opening_time TIME,
							closing_time TIME,
							latitude NUMERIC(10,8) NOT NULL,
							longitude NUMERIC(11,8) NOT NULL,
						CONSTRAINT restaurant_res_id_pk PRIMARY KEY ( restaurant_id )
						)
;
ALTER TABLE restaurant 
	ADD CONSTRAINT chck_restaurant_zip_code CHECK ( zip_code LIKE REPLICATE('[0-9]' , 5 ) 
	)
; 

CREATE TABLE restaurant_type	(
									restaurant_id INT NOT NULL,
									cuisine VARCHAR(100) NOT NULL,
								CONSTRAINT restaurant_type_resid_cuistype_pk PRIMARY KEY ( restaurant_id , cuisine ),
								CONSTRAINT restaurant_type_res_id_fk FOREIGN KEY ( restaurant_id ) REFERENCES restaurant ( restaurant_id )
								)
;

CREATE TABLE food	(
						food_id INT IDENTITY(1,1) NOT NULL,
						restaurant_id INT NOT NULL,
						food_name VARCHAR(50) NOT NULL,
						is_vegan CHAR(1) DEFAULT('N') NOT NULL,
						price NUMERIC(8,2) NOT NULL,
						food_description VARCHAR(200),
					CONSTRAINT food_food_id_pk PRIMARY KEY ( food_id ),
					CONSTRAINT food_restau_id_fk FOREIGN KEY ( restaurant_id ) REFERENCES restaurant ( restaurant_id )
					)
;
ALTER TABLE food
	ADD CONSTRAINT chck_food_is_vegan CHECK (is_vegan IN ( 'N' , 'Y' )
	)
; 


CREATE TABLE orders	(
						order_id INT IDENTITY(1,1) NOT NULL,
						user_id INT NOT NULL,
						restaurant_id INT NOT NULL,
						order_time DATETIME,
						special_instructions VARCHAR(200), 
						order_status VARCHAR(20) DEFAULT('OPEN') NOT NULL,
					CONSTRAINT orders_order_id_pk PRIMARY KEY ( order_id ),
					CONSTRAINT orders_user_id FOREIGN KEY ( user_id ) REFERENCES users ( user_id ),
					CONSTRAINT orders_rest_id_fk FOREIGN KEY ( restaurant_id ) REFERENCES restaurant ( restaurant_id )
					)
;

ALTER TABLE orders 
	ADD CONSTRAINT chck_orders_order_status CHECK (order_status IN ('OPEN', 'IN PROGRESS','DELIVERED','CANCELLED')
	)
;


CREATE TABLE order_line	(
							order_line_id INT IDENTITY(1,1) NOT NULL,
							order_id INT NOT NULL,
							food_id INT NOT NULL,
							quantity SMALLINT NOT NULL,
						CONSTRAINT order_line_order_line_id_pk PRIMARY KEY ( order_line_id ),
						CONSTRAINT order_line_order_id_fk FOREIGN KEY ( order_id ) REFERENCES orders ( order_id ),
						CONSTRAINT order_line_food_id_fk FOREIGN KEY ( food_id ) REFERENCES food ( food_id )
						)
;

CREATE TABLE delivery	(
							delivery_id INT IDENTITY(1,1) NOT NULL,
							order_id INT NOT NULL,
							delivery_agent_id INT NOT NULL,
							delivery_status VARCHAR(20) DEFAULT('OPEN') NOT NULL,
							first_mile DECIMAL (4,2),
							last_mile DECIMAL (4,2),
						CONSTRAINT delivery_delivery_id_pk PRIMARY KEY ( delivery_id ),
						CONSTRAINT delivery_order_id_fk FOREIGN KEY ( order_id ) REFERENCES orders ( order_id ),
						CONSTRAINT delivery_userid_fk FOREIGN KEY ( delivery_agent_id ) REFERENCES users ( user_id )
						)
;
ALTER TABLE delivery 
	ADD CONSTRAINT chck_delivery_del_status CHECK ( delivery_status IN ('OPEN', 'IN PROGRESS','DELIVERED','CANCELLED')
	)
;


CREATE TABLE payment_mode	( 
								payment_mode_id INT IDENTITY(1,1) NOT NULL,
								user_id INT NOT NULL,
							CONSTRAINT payment_mode_payment_mode_id_pk PRIMARY KEY ( payment_mode_id , user_id ),
							CONSTRAINT payment_mode_user_id_fk FOREIGN KEY ( user_id ) REFERENCES users ( user_id )
							)
;

CREATE TABLE card_payments	(
								payment_mode_id INT NOT NULL,
								user_id INT NOT NULL,
								card_num CHAR(16) NOT NULL, 
								expiry_month CHAR(2) NOT NULL,
								expiry_year CHAR(2) NOT NULL,
								is_primary CHAR(1) DEFAULT('N') NOT NULL,
							CONSTRAINT card_payments_payment_mode_id_pk PRIMARY KEY ( payment_mode_id ),
							CONSTRAINT card_payments_payment_mode_id_fk FOREIGN KEY ( payment_mode_id, user_id ) REFERENCES payment_mode ( payment_mode_id,user_id )
							)
;

ALTER TABLE card_payments 
	ADD CONSTRAINT chck_card_payments_card_num CHECK ( card_num LIKE REPLICATE('[0-9]',16 )
	)
;
ALTER TABLE card_payments 
	ADD CONSTRAINT  chck_card_payments_exmnth CHECK ( expiry_month LIKE REPLICATE('[0-9]',2 )
	)
;
ALTER TABLE card_payments 
	ADD CONSTRAINT  chck_card_payments_exyr CHECK ( expiry_year LIKE REPLICATE('[0-9]',2 )
	)
;
ALTER TABLE card_payments
	ADD CONSTRAINT chck_card_payments_is_primary CHECK (is_primary IN ( 'N' , 'Y' )
	)
;
 
CREATE TABLE mobile_payments	(
									payment_mode_id INT NOT NULL,
									user_id INT NOT NULL,
									wallet_name VARCHAR(10) NOT NULL,
									wallet_number VARCHAR(100) NOT NULL,
									balance NUMERIC(8,2) NOT NULL,
									is_primary CHAR(1) DEFAULT('N') NOT NULL,
								CONSTRAINT mobile_payments_payment_mode_id_pk PRIMARY KEY ( payment_mode_id ),
								CONSTRAINT mobile_payments_payment_mode_id_fk FOREIGN KEY ( payment_mode_id, user_id ) REFERENCES payment_mode ( payment_mode_id, user_id )
								)
;
ALTER TABLE mobile_payments
	ADD CONSTRAINT chck_mobile_payments_is_primary CHECK ( is_primary IN ( 'N' , 'Y' )
	)
;

CREATE TABLE order_payment	(
								order_payment_id INT IDENTITY(1,1) NOT NULL,
								user_id INT NOT NULL,
								order_id INT NOT NULL,
								amount NUMERIC(8,2) DEFAULT(0) NOT NULL,
								payment_status VARCHAR (10) DEFAULT('AWAITING') NOT NULL,
								payment_mode_id INT NOT NULL,
							CONSTRAINT order_payment_order_payment_id_pk PRIMARY KEY ( order_payment_id ),
							CONSTRAINT order_payment_order_id_fk FOREIGN KEY ( order_id ) REFERENCES orders ( order_id ),
							CONSTRAINT order_payment_payment_mode_id_fk FOREIGN KEY ( payment_mode_id, user_id ) REFERENCES payment_mode ( payment_mode_id, user_id )
							)
;

ALTER TABLE order_payment
	ADD CONSTRAINT  chck_order_payment_status CHECK (payment_status IN ('AWAITING', 'VALIDATING' , 'SUCCESS' , 'FAILED' , 'REFUNDED' , 'CANCELLED' )
	)
;



CREATE TABLE coupons	(
							discount_id INT IDENTITY(1,1) NOT NULL,
							user_id INT NOT NULL,
							codenum VARCHAR(100) NOT NULL,
							discount_percent NUMERIC(4,2) NOT NULL,
							startdate date NOT NULL,
							expirydate date NOT NULL,
							is_used CHAR(1) DEFAULT('N') NOT NULL,
						CONSTRAINT coupons_dscnt_user_pk PRIMARY KEY ( discount_id , user_id ),
						CONSTRAINT coupons_user_id_fk FOREIGN KEY ( user_id ) REFERENCES users ( user_id )
						)
;

ALTER TABLE coupons
	ADD CONSTRAINT  chck_coupons_is_used CHECK (is_used IN ( 'N' , 'Y' )
	)
;
