/*
===============================================================================================================================================================================
Load Tables: Load information into tables (Source --> Bronze Layer)
===============================================================================================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze) ----> If we have a Script frequently Used, The advice is to create a stored procedure to automatize it. 
===============================================================================================================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================================================================================================================
Considerations:
	Due to MySQL Workbench permissions I'm not allowed to do BULK INSERT.
    To solve this and load all rows into tables I used the "MySQL for Excel" extension within Excel and then "Append Excel Data to Table."
    Therefore, the loading process doesn't include the stored procedure or the BULK INSERT, however, due to documentation purposes, 
    I'll add the script for the stored procedure that performs the Bulk Data Load, once issue with permissions is solved, I'll use it to automatize the process. 
===============================================================================================================================================================================
*/

USE bronze;

SELECT COUNT(*)
FROM crm_cust_info;

SELECT COUNT(*)
FROM crm_prd_info;

SELECT COUNT(*)
FROM crm_sales_details;

SELECT COUNT(*)
FROM erp_cust_az12;

SELECT COUNT(*)
FROM erp_loc_a101;

SELECT COUNT(*)
FROM erp_px_cat_g1v2;

DELIMITER $$
CREATE PROCEDURE bronze.load_bronze ()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SELECT '=======================================================================================';
			SELECT 'ERROR OCCURRED DURING LOADING BRONZE LAYER' AS msg;
			SELECT '=======================================================================================';        
        END;
        
			SELECT '=======================================================================================';
			SELECT 'Loading Bronze Layer' AS msg;
			SELECT '=======================================================================================';
			
			SELECT '---------------------------------------------------------------------------------------';
			SELECT 'Loading CRM Tables' AS msg;
			SELECT '---------------------------------------------------------------------------------------';
			
            SET @start_time = NOW();
			SELECT '>>Truncating Table: bronze.crm_cust_info' AS msg;
			TRUNCATE TABLE bronze.crm_cust_info;
			SELECT '>>Inserting Data Into: bronze.crm_cust_info' AS msg;
			LOAD DATA INFILE 'C:\Users\PC\Documents\Tutorials\SQL\Final Projects\source_crm\cust_info.csv'
			INTO TABLE bronze.crm_cust_info
			FIELDS TERMINATED BY ','
			LINES TERMINATED BY '\r\n'
			IGNORE 1 LINES;
            SET @end_time = NOW();
            SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds');


			SET @start_time = NOW();
            SELECT '>>Truncating Table: bronze.crm_prd_info' AS msg;
			TRUNCATE TABLE bronze.crm_prd_info;
            SELECT '>>Inserting Data Into: bronze.crm_prd_info' AS msg;
			LOAD DATA INFILE 'C:\Users\PC\Documents\Tutorials\SQL\Final Projects\source_crm\prd_info.csv'
			INTO TABLE bronze.crm_prd_info
			FIELDS TERMINATED BY ','
			LINES TERMINATED BY '\r\n'
			IGNORE 1 LINES;
			SET @end_time = NOW();
            SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds');

			SET @start_time = NOW();
            SELECT '>>Truncating Table: bronze.crm_sales_details' AS msg;
			TRUNCATE TABLE bronze.crm_sales_details;
            SELECT '>>Inserting Data Into: bronze.crm_sales_details' AS msg;
			LOAD DATA INFILE 'C:\Users\PC\Documents\Tutorials\SQL\Final Projects\source_crm\sales_details.csv'
			INTO TABLE bronze.crm_sales_details
			FIELDS TERMINATED BY ','
			LINES TERMINATED BY '\r\n'
			IGNORE 1 LINES;
			SET @end_time = NOW();
            SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds');

			SELECT '---------------------------------------------------------------------------------------';
			SELECT 'Loading ERP Tables' AS msg;
			SELECT '---------------------------------------------------------------------------------------';

			SET @start_time = NOW();
            SELECT '>>Truncating Table: bronze.erp_cust_az12' AS msg;
			TRUNCATE TABLE bronze.erp_cust_az12;
            SELECT '>>Inserting Data Into: bronze.erp_cust_az12' AS msg;
			LOAD DATA INFILE 'C:\Users\PC\Documents\Tutorials\SQL\Final Projects\source_erp\cust_az12.csv'
			INTO TABLE bronze.erp_cust_az12
			FIELDS TERMINATED BY ','
			LINES TERMINATED BY '\r\n'
			IGNORE 1 LINES;
			SET @end_time = NOW();
            SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds');

			SET @start_time = NOW();
            SELECT '>>Truncating Table: bronze.erp_loc_a101' AS msg;
			TRUNCATE TABLE bronze.erp_loc_a101;
            SELECT '>>Inserting Data Into: bronze.erp_loc_a101' AS msg;
			LOAD DATA INFILE 'C:\Users\PC\Documents\Tutorials\SQL\Final Projects\source_erp\loc_a101.csv'
			INTO TABLE bronze.erp_loc_a101
			FIELDS TERMINATED BY ','
			LINES TERMINATED BY '\r\n'
			IGNORE 1 LINES;
			SET @end_time = NOW();
            SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds');

			SET @start_time = NOW();
            SELECT '>>Truncating Table: bronze.erp_px_cat_g1v2' AS msg;
			TRUNCATE TABLE bronze.erp_px_cat_g1v2;
            SELECT '>>Inserting Data Into: bronze.erp_px_cat_g1v2' AS msg;
			LOAD DATA INFILE 'C:\Users\PC\Documents\Tutorials\SQL\Final Projects\source_erp\px_cat_g1v2.csv'
			INTO TABLE bronze.erp_px_cat_g1v2
			FIELDS TERMINATED BY ','
			LINES TERMINATED BY '\r\n'
			IGNORE 1 LINES;
			SET @end_time = NOW();
            SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds');            

END $$
DELIMITER ;
