CREATE DATABASE IVMS_DB;

-- create extension if not exists "uuid-ossp"
CREATE TABLE ADMIN (
    ADMIN_ID uuid PRIMARY KEY DEFAULT
    uuid_generate_v4(),
    ADMIN_USERNAME VARCHAR(255) not null,
    ADMIN_NAME VARCHAR(255) not null,
    ADMIN_EMAIL VARCHAR(255) not null,
    ADMIN_PASSWORD VARCHAR (255) not null
);


CREATE TABLE RETAILER(
    R_ID uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    R_MOBILE_NUM VARCHAR(200),
    R_NAME VARCHAR(200),
    R_USERNAME VARCHAR(200),
    R_PASSWORD VARCHAR(200),
    R_ADDRESS VARCHAR(500),
    R_EMAIL VARCHAR(500),
    R_APPROVAL_STATUS VARCHAR(20) DEFAULT 'FALSE'
);

CREATE VIEW RETAILER_ACCESSES AS
SELECT RETAILER.R_ID,R_NAME,R_APPROVAL_STATUS,INVENTORY.INVENTORY_ID
FROM RETAILER JOIN INVENTORY ON RETAILER.R_ID=INVENTORY.R_ID;

CREATE TABLE NOTIFICATIONS(
    N_ID uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    REFERRER_ID uuid  NOT NULL,
    string VARCHAR(500) NOT NULL,
    type INTEGER NOT NULL
);
------------------------
-- USE PL/SQL FOR IDS
------------------------
-- LOGIC TO HANDLE COUNT 
CREATE TABLE INVENTORY(
    INVENTORY_ID uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    R_ID uuid,
    INVENTORY_COUNT INTEGER DEFAULT 0,
    INVENTORY_TYPE VARCHAR(20),
    INVENTORY_DESCRIPTION VARCHAR(200),
    INVENTORY_MAX_COUNT INTEGER
);


ALTER TABLE RETAILER ADD CONSTRAINT retailerFK FOREIGN KEY(INVENTORY_ID) REFERENCES INVENTORY(INVENTORY_ID);

CREATE TABLE PRODUCT(
    INVENTORY_ID uuid FOREIGN KEY REFERENCES INVENTORY(INVENTORY_ID),
    PRODUCT_ID SERIAL PRIMARY KEY,
    PRODUCT_NAME VARCHAR(50),
    PRODUCT_COUNT INTEGER,
    PRODUCT_DESCRIPTION VARCHAR(200)
);

CREATE FUNCTION product_function()
    returns trigger language PLPGSQL
    AS $$
    BEGIN 
        IF INVENTORY_COUNT<INVENTORY_MAX_COUNT THEN
            INSERT INTO PRODUCT (INVENTORY_ID, PRODUCT_NAME, PRODUCT_COUNT)
            VALUES (OLD.INVENTORY_ID, OLD.PRODUCT_NAME, OLD.PRODUCT_COUNT);
        ELSE
            RAISE NOTICE 'INVENTORY FULL';
        end if;
    END;
    $$
CREATE TRIGGER CHECKPRODUCT
    BEFORE UPDATE 
    ON PRODUCT
    FOR EACH ROW
    EXECUTE PROCEDURE product_function();

CREATE TABLE SENDER (
    S_ID SERIAL PRIMARY KEY,
    S_MOBILE_NUM VARCHAR(200),
    S_ADDRESS VARCHAR(500),
    S_EMAIL VARCHAR(200)
);
CREATE TABLE INBOUND(
	INBOUND_ID INTEGER SERIAL PRIMARY KEY,
	SENDER_ID INTEGER FOREIGN KEY REFERENCES SENDER(S_ID),
	Approval_Status BOOLEAN DEFAULT 'False',
	Inventory_ID REFERENCES FOREIGN KEY INVENTORY(Inventory_ID)
	PRODUCT_COUNT NUMBER,
	PRODUCT_NAME VARCHAR(200)
	PRODUCT_DESCRIPTION VARCHAR(200)
);
CREATE TABLE OUTBOUND(
	OUTBOUND_ID SERIAL PRIMARY KEY,
	Inventory_ID References FORIEGN KEY INVENTORY(INVENTORY_ID),
	PRODUCT_ID REFERENCES FORIEGN KEY PRODUCT(PRODUCT_ID),
	PRODUCT_COUNT NUMBER,
	RECIEVER_ID REFERENCES FORIEGN KEY RECIEVER(RECIEVER_ID)
);
CREATE TABLE RECIEVER (
    R_ID SERIAL PRIMARY KEY,
    R_MOBILE_NUM VARCHAR(200),
    R_ADDRESS VARCHAR(500),
    R_EMAIL VARCHAR(200)
);











-- CREATE TABLE PURCHASING(
--     PURCHASING_ID SERIAL PRIMARY KEY,
--     CUSTOMER_ID NUM FOREIGN KEY REFRENCES CUSTOMER(C_ID),
--     PURCHASE_DESCRIPTION VARCHAR(300),
--     PURCHASE_AMOUNT DOUBLE, 
--     PURCHASE_DESC VARCAR(500)
-- );

-- CREATE TABLE STOCK (
--     INVENTORY_ID uuid,
--     STOCK_ID uuid PRIMARY KEY,
--     STOCK_ITEMS VARCHAR(500),
--     STOCK_NUMBER INTEGER, 
--     
--     STOCK_DESC VARCHAR(500)
-- );
-- ALTER TABLE STOCK ADD CONSTRAINT stockFK FOREIGN KEY(INVENTORY_ID) REFERENCES INVENTORY(INVENTORY_ID);





