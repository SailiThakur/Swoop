/* Stored Procedures */
 
 --SPROC for Adding User
 EXEC AddUser_proc 'Jerry','Seinfeld','jerry_seinfeld@swoop.com',2,'881-334-6584','300 W 7200 S Avia A321','Salt Lake City','UT',

CREATE or ALTER PROCEDURE AddUser_proc
@first_name VARCHAR(25) ,
@last_name VARCHAR(25) ,
@email VARCHAR(100) ,
@role_id INT,
@phone_num INT,
@street_address VARCHAR (200),
@city VARCHAR(100),
@state CHAR(2),
@zip_code VARCHAR(50),
@latitude DECIMAL(10,8),
@longitude DECIMAL(11,8),
@card_num INT ,
@expiry_year SMALLINT,
@expiry_month SMALLINT,
@wallet_name VARCHAR(10),
@wallet_number VARCHAR(100),
@balance NUMERIC(8,2)

AS 
BEGIN

DECLARE @str_useradded varchar(100)
DECLARE @str_useraddedwopayemt varchar(100)
DECLARE @str_useraddedwompayemt varchar(100)
SET @str_useradded='User was added Successfully'
SET @str_useraddedwopayemt='User was added Successfully without Card Payment info'
SET @str_useraddedwompayemt='User was added Successfully without Mobile Wallet Payment info'

DECLARE @user_id INT,
		@payment_mode_id INT;

    
BEGIN TRANSACTION;
    INSERT INTO users (first_name,last_name,email)
    VALUES (@first_name,@last_name,@email);
    SET @user_id = SCOPE_IDENTITY();

    INSERT INTO user_roles (user_id,role_id)
    VALUES(@user_id,@role_id);

    INSERT INTO contact_details(user_id,phone_num)
    VALUES(@user_id,@phone_num);

    INSERT INTO user_address(user_id,street_addr,city,state,zip_code,latitude,longitude)
    VALUES(@user_id,@street_address,@city ,@State,@zip_code,@latitude,@longitude);

    IF @card_num is NULL or @card_num ='' and @expiry_year is NULL or @expiry_year = '' and @expiry_month is NULL or @expiry_month =''
        BEGIN
            Print @str_useraddedwopayemt
        END
    ELSE
        BEGIN
            INSERT INTO payment_mode (user_id) 
            VALUES(@user_id);
			SET @payment_mode_id = SCOPE_IDENTITY();

			INSERT INTO card_payments (payment_mode_id,user_id,card_num,expiry_month,expiry_year)
			VALUES(@payment_mode_id,@user_id,@card_num,@expiry_month,@expiry_year);

            PRINT @str_useradded

        END

	IF @wallet_name is NULL or @wallet_name ='' and @wallet_number is NULL or @wallet_number = '' and @balance is NULL or @balance =''
        BEGIN
            Print @str_useraddedwompayemt
        END
    ELSE
        BEGIN
            INSERT INTO payment_mode (user_id) 
            VALUES(@user_id);
			SET @payment_mode_id = SCOPE_IDENTITY();

			INSERT INTO mobile_payments (payment_mode_id,user_id,wallet_name,wallet_number,balance)
			VALUES(@payment_mode_id,@user_id,@wallet_name,@wallet_number,@balance);

            PRINT @str_useradded

        END
COMMIT
END;

--SPROC For Adding Restaurants

CREATE or ALTER PROCEDURE AddRestaurants

@name VARCHAR (50),
@street_addr VARCHAR (200),
@city VARCHAR (100),
@state CHAR(2),
@postal_code VARCHAR (50),
@contact_number CHAR(10),
@opening_time TIME(7),
@closing_time TIME(7),
@latitude DECIMAL (10,8),
@longitude DECIMAL (11,8),
@cuisine_type VARCHAR (100)
 
AS 
BEGIN

DECLARE @str_restaurantadded varchar(100)
SET @str_restaurantadded='User was added successfully'

DECLARE @restaurant_id INT; 

BEGIN TRANSACTION;
    INSERT INTO restaurant(name,street_addr,city,state,postal_code,contact_number,opening_time,closing_time,latitude,longitude)
    VALUES (@name,@street_addr,@city,@state,@postal_code,@contact_number,@opening_time,@closing_time,@latitude,@longitude);
    SET @restaurant_id = SCOPE_IDENTITY();

    INSERT INTO restaurant_type (restaurant_id,cuisine_type)
    VALUES(@restaurant_id,@cuisine_type);

    
COMMIT
END;


--SPROC For Placing orders

CREATE or ALTER PROCEDURE Placeorders
@user_id INT,
@restaurant_id INT,
@food_id INT,
@quantity SMALLINT,
@order_time TIME(7),
@note VARCHAR(200),
@order_status VARCHAR(200),
@payment_status VARCHAR(10)


 
AS 
BEGIN

DECLARE @order_id INT;
DECLARE @price INT;
DECLARE @amount DECIMAL(6,2);
DECLARE @user_payment_mode_id INT;
DECLARE @str_orderplaced varchar(100);
DECLARE @str_paymentinfomissing varchar(100);


SET @str_orderplaced='Order placed successfully'
SET @str_paymentinfomissing='User did not setup billing info'


BEGIN TRANSACTION;

    IF EXISTS (SELECT user_payment_mode_id FROM user_payment_mode 
                WHERE user_id = @user_id
                ) 
                    BEGIN 
                        INSERT INTO orders(user_id,restaurant_id,order_time,note,order_status)
                        VALUES (@user_id,@restaurant_id,@order_time,@note,@order_status);
                        SET @order_id = SCOPE_IDENTITY();

                        INSERT INTO order_line(order_id,quantity,food_id)
                        VALUES(@order_id,@quantity,@food_id);

                        SET @price= @price ( SELECT price FROM food 
                                             WHERE food_id = @food_id                               
                                            )
                        SET @amount = @price * @quantity

                        SET @user_payment_mode_id= @user_payment_mode_id (SELECT user_payment_mode_id FROM user_payment_mode 
                                            WHERE user_id = @user_id                                
                                            )


                        INSERT INTO order_payment(order_id,amount,payment_status,user_payment_mode_id)
                        VALUES(@order_id,@amount,'P',@user_payment_mode_id);

                        PRINT @str_orderplaced
                    END
    ELSE
                    BEGIN
                        PRINT @str_paymentinfomissing                       
                    END
    
COMMIT
END;


CREATE or ALTER PROCEDURE Placeorders
@user_id INT,
@restaurant_id INT,
@food_id INT,
@quantity SMALLINT,
@order_time TIME(7),
@note VARCHAR(200),
@payment_status VARCHAR(10)

AS 
BEGIN

DECLARE @order_id INT;
DECLARE @price INT;
DECLARE @amount NUMERIC(8,2);
DECLARE @payment_mode_id INT;
DECLARE @str_orderplaced varchar(100);
DECLARE @str_paymentinfomissing varchar(100);


SET @str_orderplaced='Order Placed Successfully'
SET @str_paymentinfomissing='User does not have a valid Payment mode'


BEGIN TRANSACTION;

    IF EXISTS (SELECT payment_mode_id FROM payment_mode 
                WHERE user_id = @user_id
                ) 
                    BEGIN 
                        INSERT INTO orders(user_id,restaurant_id,order_time,special_instructions)
                        VALUES (@user_id,@restaurant_id,@order_time,@note);
                        SET @order_id = SCOPE_IDENTITY();

                        INSERT INTO order_line(order_id,food_id,quantity)
                        VALUES(@order_id,@food_id,@quantity);

                        PRINT @str_orderplaced
                    END
    ELSE
                    BEGIN
                        PRINT @str_paymentinfomissing                       
                    END
    
COMMIT
END;
