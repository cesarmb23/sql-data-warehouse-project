/*
=====================================================================================================================================
Quality Checks
=====================================================================================================================================
Script Purpose:
	This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date range and orders.
    - Data consistency between related fields.alter
    
Usage Notes:
	- Run these checks after data loading Silver layer.
    - Investigate and resolve any discrepancies found during the checks
*/

USE silver;

-- =====================================================================================================================================
-- silver.crm_cust_info checks
-- =====================================================================================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT 
	cst_id, 
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted Spaces
-- Expectation: No Result

SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Data Standardization & Consistency: Check types of gender
-- As per data policies, we need to replace letters with friendly words

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Data Standardization & Consistency: Check types of marital_status
-- As per data policies, we need to replace letters with friendly words

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- =====================================================================================================================================
-- silver.crm_prd_info checks
-- =====================================================================================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1 OR prd_id IS NULL;

-- Check for unwanted Spaces
-- Expectation: No Result

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for Nulls or Negative numbers
-- Expectation: No Results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency: Check types of prd_line
-- As per data policies, we need to replace letters with friendly words

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders
-- Expectation: No Invalid Dates

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =====================================================================================================================================
-- silver.crm_sales_details
-- =====================================================================================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
	OR sls_order_dt > sls_due_dt;
    
-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL 
    OR sls_quantity IS NULL 
    OR sls_price IS NULL
	OR sls_sales <= 0 
    OR sls_quantity <= 0 
    OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =====================================================================================================================================
-- silver.erp_cust_az12 checks
-- =====================================================================================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate > CURDATE();

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- =====================================================================================================================================
-- silver.erp_loc_a101 checks
-- =====================================================================================================================================
-- Data Standardization & Consistency

SELECT DISTINCT cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =====================================================================================================================================
-- silver.erp_px_cat_g1v2 checks
-- =====================================================================================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
    OR maintenance != TRIM(maintenance);

-- Check for Data Standardization & Consistency

SELECT DISTINCT
cat,
subcat, 
maintenance
FROM silver.erp_px_cat_g1v2;
