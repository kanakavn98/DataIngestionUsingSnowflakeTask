----Working on Snowflaske Project---------
---Creating the warehouse---
CREATE OR ALTER WAREHOUSE WorldBank_WareHouse
  WAREHOUSE_TYPE = 'STANDARD'
  WAREHOUSE_SIZE = 'XSMALL' 
  MIN_CLUSTER_COUNT = 1 
  AUTO_SUSPEND = 5
  AUTO_RESUME = TRUE 
  INITIALLY_SUSPENDED = FALSE 
  COMMENT = 'This warehouse is built for a practical purpose'
  ENABLE_QUERY_ACCELERATION =  FALSE 


SHOW SCHEMAS;



---How to keep track of consumption----

Select * from snowflake.account_usage.warehouse_metering_history limit 10;

Select * from snowflake.account_usage.query_history limit 10;

-----CReating Database-----------
    
CREATE DATABASE SNOWFLAKE_SAMPLE_DATA FROM SHARE SFC_SAMPLES.SAMPLE_DATA;
     
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE sysadmin;
     
use role sysadmin ; 

create database if not exists ecommerce_db;

create schema if not exists ecommerce_liv;

use schema ecommerce_db.ecommerce_liv;

use warehouse WORLDBANK_WAREHOUSE;



create or replace table LINEITEM cluster by (L_SHIPDATE) as select * from "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."LINEITEM" limit 2000000;
     
create or replace table ORDERS as select * from "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."ORDERS" limit 2000000;