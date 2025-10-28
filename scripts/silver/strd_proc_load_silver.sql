/*
=================================================================================================================================
Insert into silver.crm_cust_info
=================================================================================================================================
*/

-- Insert into silver.crm_cust_info: To insert data standardized and cleaned
-- Trim: Used on first and last name to remove unwanted spaces
-- Case: Used on gender and marital status to modify letters for friendly words
-- Window function(Rank): to create a flag showing the latest record created
-- Subquery: To work only with the latest record of each cst_id and eliminate duplicates

INSERT INTO silver.crm_cust_info (
	cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    ELSE 'n/a' 
END cst_marital_status, -- Normalize marital status values to readable format
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'n/a' 
END cst_gndr, -- Normalize gender values to readable format
cst_create_date
FROM 
	(
	SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
	) t 
WHERE flag_last = 1; -- Select the most recent record per customer

SELECT * 
FROM silver.crm_cust_info;

/*
=================================================================================================================================
Insert into silver.crm_prd_info
=================================================================================================================================
*/

-- Substract prd_key first 5 characters to match with column cat from erp_px_cat_g1v2 table AS cat_id > Standardize format with replace
-- Substract prd_key from 7th character to match with column prd_key from crm_sales_details table, using Length to make it dynamic > No need to standardize
-- If there's any null in prd_cost, replace it with 0
-- Use a CASE statement on prd_line to replace abbreviations with user-friendly words
-- Use Lead Window function to 
-- Use LEAD() to have the prd_start_dt as the prd_end_dt and fix invalid orders date
-- Use DATE_SUB to substract one day to the lead window function
-- Modify the create_table to have all columns

INSERT INTO silver.crm_prd_info (
	prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
prd_nm,
IFNULL(prd_cost, 0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
	WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
    WHEN 'S' THEN 'Other Sales'
    WHEN 'T' THEN 'Touring'
	ELSE 'n/a'
END AS prd_line, -- Map product line codes to descriptive values
prd_start_dt,
DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS prd_end_dt -- Calculate end date as one day before the next start date
FROM bronze.crm_prd_info;

SELECT * 
FROM silver.crm_prd_info;

/*
=================================================================================================================================
Insert into silver.crm_sales_details
=================================================================================================================================
*/

INSERT INTO silver.crm_sales_details (
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE 
	WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
	ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
END AS sls_order_dt,
CASE 
	WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
	ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
END AS sls_ship_dt,
CASE 
	WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
	ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
END AS sls_due_dt,
ROUND(
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END, 0 
) AS sls_sales,
sls_quantity,
ROUND(	
    CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END, 0
) AS sls_price
FROM bronze.crm_sales_details;

SELECT * 
FROM silver.crm_sales_details;

/*
=================================================================================================================================
Insert into silver.erp_cust_az12
=================================================================================================================================
*/

SELECT *
FROM bronze.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
cid, 
bdate,
gen)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
	ELSE cid
END AS cid,
CASE WHEN bdate > CURDATE() THEN NULL
	ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
    ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;

SELECT *
FROM silver.erp_cust_az12;

/*
=================================================================================================================================
Insert into silver.erp_loc_a101
=================================================================================================================================
*/

SELECT *
FROM bronze.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (
cid,
cntry)
SELECT 
REPLACE(cid, '-', '') AS cid,
CASE 
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;

SELECT *
FROM silver.erp_loc_a101;

/*
=================================================================================================================================
Insert into silver.erp_px_cat_g1v2
=================================================================================================================================
*/

INSERT INTO silver.erp_px_cat_g1v2 (
id,
cat,
subcat,
maintenance)
SELECT 
id,
cat, 
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;
