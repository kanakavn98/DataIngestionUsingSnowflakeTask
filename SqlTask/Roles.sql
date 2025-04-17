use role accountadmin;

use schema "ECOMMERCE_DB"."ECOMMERCE_LIV";

create or replace role view_role;

grant usage on warehouse WORLDBANK_WAREHOUSE to role view_role;

grant usage on database ECOMMERCE_DB to role view_role;

grant usage on schema ECOMMERCE_LIV to role view_role;

grant select on "ECOMMERCE_DB"."ECOMMERCE_LIV"."SECURE_VW_AGGREGATED_ORDERS"  to role view_role;

grant select on "ECOMMERCE_DB"."ECOMMERCE_LIV"."URGENT_PRIORITY_ORDERS"  to role view_role;

grant select on "ECOMMERCE_DB"."ECOMMERCE_LIV"."VW_AGGREGATED_ORDERS"  to role view_role;

--creating user----

CREATE USER kanak PASSWORD='abc123' DEFAULT_ROLE = myrole DEFAULT_SECONDARY_ROLES = ('ALL') MUST_CHANGE_PASSWORD = TRUE;

grant role view_role to user kanak;

-- Test the GET_DDL using the new role created above  -----
show roles like '%admin%';
show users;

use role view_role;

use schema "ECOMMERCE_DB"."ECOMMERCE_LIV";

select * from SECURE_VW_AGGREGATED_ORDERS limit 20;

select get_ddl('view','URGENT_PRIORITY_ORDERS');
select get_ddl('view','SECURE_VW_AGGREGATED_ORDERS');-- we didnot get the output because it is secure views 