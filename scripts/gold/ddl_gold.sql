/*
=================================================================================================================================
Gold Layer

-- Give new friendly names to each column using Snake Case
-- Create Primary Ley using Surrogate Key using query based using window function (row-number)
=================================================================================================================================
*/

CREATE VIEW gold.dim_customers AS
SELECT
  ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
  ci.cst_id AS customer_id,
  ci.cst_key AS customer_number,
  ci.cst_firstname AS first_name,
  ci.cst_lastname AS last_name,
  la.cntry AS country,
  ci.cst_marital_status AS marital_status,
CASE 
	WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
	ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
  ca.bdate AS birth_date,
  ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;

SELECT *
FROM gold.dim_customers;

/*
=================================================================================================================================
Gold Layer: Create product dimension
-- Group columns into logical groups
-- friendly names into columns
=================================================================================================================================
*/

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.prd_nm AS product_name,
	pi.prd_line AS product_line,
	pi.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pi.prd_cost AS product_cost,
	pi.prd_start_dt AS start_date
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pi.cat_id = pc.id
WHERE prd_end_dt IS NULL; -- Filter out all historical data

SELECT *
FROM gold.dim_products;

/*
=================================================================================================================================
Gold Layer: Create Sales Fact Table
-- Join Tables using Data LookUp using surrogate keys
-- 
=================================================================================================================================
*/

CREATE VIEW gold.fact_sales AS
SELECT
  sd.sls_ord_num AS order_number,
  pr.product_key, -- surrogate key from products dimension
  cu.customer_key, -- surrogate key from customers dimension
  sd.sls_order_dt AS order_date,
  sd.sls_ship_dt AS shipping_date,
  sd.sls_due_dt AS due_date,
  sd.sls_sales AS sales_amount,
  sd.sls_quantity AS quantity,
  sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;

SELECT *
FROM gold.fact_sales;
