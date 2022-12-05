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


INSERT INTO RETAILER (R_MOBILE_NUM, R_NAME, R_USERNAME, R_ADDRESS,R_PASSWORD, R_EMAIL) 
            VALUES ('03218745530', 'ha', 'ha', 'ha','hatif1234', 'ha');
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
    INVENTORY_ID uuid,
    PRODUCT_ID SERIAL PRIMARY KEY,
    PRODUCT_NAME VARCHAR(50),
    PRODUCT_COUNT INTEGER,
    PRODUCT_DESCRIPTION VARCHAR(200),
    PRODUCT_TYPE VARCHAR(200)
);

ALTER TABLE PRODUCT ADD CONSTRAINT PRODUCTFK FOREIGN KEY(INVENTORY_ID) REFERENCES INVENTORY(INVENTORY_ID);





CREATE TABLE SENDER (
    S_ID SERIAL PRIMARY KEY,
    S_NAME VARCHAR(50),
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
    R_NAME VARCHAR(200) UNIQUE,
    R_MOBILE_NUM VARCHAR(200),
    R_ADDRESS VARCHAR(500),
    R_EMAIL VARCHAR(200)
);






--triggers
--password check in retailer

INSERT INTO RECIEVER (R_MOBILE_NUM, R_ADDRESS, R_EMAIL) VALUES ('030012345678', 'HAA', 'HATIF');
CREATE OR REPLACE FUNCTION CHECK_PASSWORD()
    RETURNS TRIGGER
    AS $$
    BEGIN 
        IF length(NEW.R_PASSWORD)<8 THEN
            RAISE NOTICE 'Password Length not sufficient!';
            RETURN NULL;
        ELSE 
            RETURN NEW;
        END IF;
        
    END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER check_pass 
    BEFORE INSERT OR UPDATE ON RETAILER
    FOR EACH ROW
    EXECUTE FUNCTION CHECK_PASSWORD();

--CHECK PHONE NUMBER LENGTH = 11 

CREATE OR REPLACE FUNCTION CHECK_PHONE()
    RETURNS TRIGGER
    AS $$
    BEGIN 
        IF length(NEW.R_MOBILE_NUM)<11 OR length(NEW.R_MOBILE_NUM)>11 THEN
            RAISE NOTICE 'Mobile no. not possible';
            RETURN NULL;
        ELSE 
            RETURN NEW;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_num 
    BEFORE INSERT OR UPDATE ON RETAILER
    FOR EACH ROW
    EXECUTE FUNCTION CHECK_PHONE();

--TRIGGER TO CHECK IF INVENTORY FULL
INSERT INTO INVENTORY (r_id, INVENTORY_COUNT, INVENTORY_DESCRIPTION, INVENTORY_MAX_COUNT, INVENTORY_TYPE)
VALUES ('0043d2b2-8eab-46cd-bc9c-5b467f04f461', 3, 'HAA', 2, 'HAA');
CREATE OR REPLACE FUNCTION product_function()
    returns trigger
    AS $$
    BEGIN 
        IF NEW.INVENTORY_COUNT<NEW.INVENTORY_MAX_COUNT THEN
            RETURN NEW;
        ELSE
            RAISE NOTICE 'INVENTORY FULL';
            RETURN NULL;
        end if;
    END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER CHECKPRODUCT
    BEFORE INSERT OR UPDATE 
    ON PRODUCT
    FOR EACH ROW
    EXECUTE PROCEDURE product_function();
CREATE OR REPLACE TRIGGER CHECKPRODUCT1
    BEFORE INSERT OR UPDATE 
    ON INVENTORY
    FOR EACH ROW
    EXECUTE PROCEDURE product_function();
CREATE OR REPLACE FUNCTION product_func()
    returns trigger
    AS $$
    BEGIN 
        IF NEW.INVENTORY_COUNT > 0 THEN
            RETURN NEW;
        ELSE
            RAISE NOTICE "INVENTORY COUNT CAN'T BE NEGATIVE";
            RETURN NULL;
        end if;
    END;
$$ LANGUAGE plpgsql;



