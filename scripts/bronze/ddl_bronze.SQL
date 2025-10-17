/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

DROP SCHEMA IF EXISTS bronze;
CREATE SCHEMA bronze;

DROP SCHEMA IF EXISTS silver;
CREATE SCHEMA silver;

DROP SCHEMA IF EXISTS gold;
CREATE SCHEMA gold;

USE bronze;

DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key VARCHAR(20),
	cst_firstname VARCHAR(20),
	cst_lastname VARCHAR(20),
	cst_marital_status VARCHAR(10),
	cst_gndr VARCHAR(10),
	cst_create_date DATE
);

DROP TABLE IF EXISTS crm_prd_info;
CREATE TABLE crm_prd_info (
	prd_id INT,
	prd_key VARCHAR(20),
	prd_nm VARCHAR(35),
	prd_cost INT,
	prd_line VARCHAR(10),
	prd_start_dt DATE,
	prd_end_dt DATE
);

DROP TABLE IF EXISTS crm_sales_details;
CREATE TABLE crm_sales_details (
	sls_ord_num VARCHAR(20),
	sls_prd_key VARCHAR(20),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

DROP TABLE IF EXISTS erp_cust_az12;
CREATE TABLE erp_cust_az12 (
	cid VARCHAR(20),
	bdate DATE,
	gen VARCHAR(10)
);

DROP TABLE IF EXISTS erp_loc_a101;
CREATE TABLE erp_loc_a101 (
	cid VARCHAR(20),
    cntry VARCHAR(20)
);

DROP TABLE IF EXISTS erp_px_cat_g1v2;
CREATE TABLE erp_px_cat_g1v2 (
	id VARCHAR(10),
	cat VARCHAR(20),
	subcat VARCHAR(20),
	maintenance VARCHAR (10)
);
