/*--
Tasty Bytes is a fictitious, global food truck network, that is on a mission to serve unique food options with high
quality items in a safe, convenient and cost effective way. In order to drive forward on their mission, Tasty Bytes
is beginning to leverage the Snowflake Data Cloud.

Within this Worksheet, we will walk through the end to end process required to load a CSV file containing Menu specific data
that is currently hosted in Blob Storage.
--*/

-------------------------------------------------------------------------------------------
    -- Step 1: To start, let's set the Role and Warehouse context
        -- USE ROLE: https://docs.snowflake.com/en/sql-reference/sql/use-role
        -- USE WAREHOUSE: https://docs.snowflake.com/en/sql-reference/sql/use-warehouse
-------------------------------------------------------------------------------------------

/*-- 
    - To run a single query, place your cursor in the query editor and select the Run button (⌘-Return).
    - To run the entire worksheet, select 'Run All' from the dropdown next to the Run button (⌘-Shift-Return).
--*/

---> set the Role
USE ROLE accountadmin;

---> set the Warehouse
USE WAREHOUSE compute_wh;

-------------------------------------------------------------------------------------------
    -- Step 2: With context in place, let's now create a Database, Schema, and Table
        -- CREATE DATABASE: https://docs.snowflake.com/en/sql-reference/sql/create-database
        -- CREATE SCHEMA: https://docs.snowflake.com/en/sql-reference/sql/create-schema
        -- CREATE TABLE: https://docs.snowflake.com/en/sql-reference/sql/create-table
-------------------------------------------------------------------------------------------

---> create the Tasty Bytes Database
CREATE OR REPLACE DATABASE tasty_bytes_sample_data;

---> create the Raw POS (Point-of-Sale) Schema
CREATE OR REPLACE SCHEMA tasty_bytes_sample_data.raw_pos;

---> create the Raw Menu Table
CREATE OR REPLACE TABLE tasty_bytes_sample_data.raw_pos.kanakmenu
(
    menu_id NUMBER(19,0),
    menu_type_id NUMBER(38,0),
    menu_type VARCHAR(16777216),
    truck_brand_name VARCHAR(16777216),
    menu_item_id NUMBER(38,0),
    menu_item_name VARCHAR(16777216),
    item_category VARCHAR(16777216),
    item_subcategory VARCHAR(16777216),
    cost_of_goods_usd NUMBER(38,4),
    sale_price_usd NUMBER(38,4),
    menu_item_health_metrics_obj VARIANT
);

---> confirm the empty Menu table exists
SELECT * FROM tasty_bytes_sample_data.raw_pos.kanakmenu;

 
--Creating Storage Integration 
CREATE STORAGE INTEGRATION kanaksnowflake_integration_forS3
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::608464619233:role/kanaksnowflakerole'
  
  STORAGE_ALLOWED_LOCATIONS = ('*');
  --STORAGE_BLOCKED_LOCATIONS = ('s3://mybucket1/mypath1/sensitivedata/', 's3://mybucket2/mypath2/sensitivedata/');

  --retrieving snowflake account 
  DESC INTEGRATION kanaksnowflake_integration_forS3;
  
--creating role for integration
create role  kanaksnowflake_integration_forS3_role;

  --giving grant 
GRANT CREATE STAGE ON SCHEMA public TO ROLE kanaksnowflake_integration_forS3_role;
  
GRANT USAGE ON INTEGRATION kanaksnowflake_integration_forS3 TO ROLE kanaksnowflake_integration_forS3_role;

-------------------------------------------------------------------------------------------
    -- Step 3: To connect to the Blob Storage, let's create a Stage
        -- Creating an S3 Stage: https://docs.snowflake.com/en/user-guide/data-load-s3-create-stage
-------------------------------------------------------------------------------------------

---> create the Stage referencing the Blob location and CSV File Format
--CREATE OR REPLACE STAGE tasty_bytes_sample_data.public.blob_stage
--url = 's3://sfquickstarts/tastybytes/'
CREATE OR REPLACE STAGE tasty_bytes_sample_data.public.KANAK_STAGE
STORAGE_INTEGRATION = kanaksnowflake_integration_forS3
url= 's3://kanaktrybucket/try_S3bucket_withSnowflake'
file_format = (type = csv);

List @tasty_bytes_sample_data.public.KANAK_STAGE

---> query the Stage to find the Menu CSV file
--LIST @tasty_bytes_sample_data.public.blob_stage/raw_pos/menu/;
LIST @tasty_bytes_sample_data.public.kanak_stage/raw_pos/kanakmenu;



-------------------------------------------------------------------------------------------
    -- Step 4: Now let's Load the Menu CSV file from the Stage
        -- COPY INTO <table>: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
-------------------------------------------------------------------------------------------

---> copy the Menu file into the Menu table
COPY INTO tasty_bytes_sample_data.raw_pos.KANAKMENU
FROM @tasty_bytes_sample_data.public.KANAK_STAGE
ON_ERROR= 'CONTINUE';


(Select $1,$2,$3 from @tasty_bytes_sample_data.public.KANAK_STAGE);
file_format = (type = csv);
-------------------------------------------------------------------------------------------
    -- Step 5: Query the Menu table
        -- SELECT: https://docs.snowflake.com/en/sql-reference/sql/select
        -- TOP <n>: https://docs.snowflake.com/en/sql-reference/constructs/top_n
        -- FLATTEN: https://docs.snowflake.com/en/sql-reference/functions/flatten
-------------------------------------------------------------------------------------------

---> how many rows are in the table?
SELECT COUNT(*) AS row_count FROM tasty_bytes_sample_data.raw_pos.kanakmenu;

---> what do the top 10 rows look like?
SELECT TOP 10 * FROM tasty_bytes_sample_data.raw_pos.kanakmenu;

---> what menu items does the Freezing Point brand sell?
SELECT 
   menu_item_name
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE truck_brand_name = 'Freezing Point';

---> what is the profit on Mango Sticky Rice?
SELECT 
   menu_item_name,
   (sale_price_usd - cost_of_goods_usd) AS profit_usd
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE 1=1
AND truck_brand_name = 'Freezing Point'
AND menu_item_name = 'Mango Sticky Rice';

---> to finish, let's extract the Mango Sticky Rice ingredients from the semi-structured column
SELECT 
    m.menu_item_name,
    obj.value:"ingredients"::ARRAY AS ingredients
FROM tasty_bytes_sample_data.raw_pos.menu m,
    LATERAL FLATTEN (input => m.menu_item_health_metrics_obj:menu_item_health_metrics) obj
WHERE 1=1
AND truck_brand_name = 'Freezing Point'
AND menu_item_name = 'Mango Sticky Rice';