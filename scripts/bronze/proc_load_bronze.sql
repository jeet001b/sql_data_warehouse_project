/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
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
===============================================================================
*/
-- inserting data
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
	BEGIN TRY
	DECLARE @start_time DATETIME, @end_time DATETIME;
    PRINT '===============================================';
    PRINT 'Loading Bronze Layer';
    PRINT '===============================================';

    PRINT '-----------------------------------------------';
    PRINT 'Loading CRM Tables';
    PRINT '-----------------------------------------------';
    -- CRM Customer Information
    PRINT '>> Truncating Table: bronze.crm_cust_info';
    SET @start_time = GETDATE()
    TRUNCATE TABLE bronze.crm_cust_info;
    
    PRINT '>> Inserting Data Into: bronze.crm_cust_info';
    BULK INSERT bronze.crm_cust_info
    FROM '/data/datasets/source_crm/cust_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '-------------------'
	
	
	
	SET @start_time = GETDATE()
    PRINT '>> Truncating Table: bronze.crm_prd_info';
    PRINT '>> Inserting Data Into: bronze.crm_prd_info';
    -- CRM Product Information
    TRUNCATE TABLE bronze.crm_prd_info;
    
    BULK INSERT bronze.crm_prd_info
    FROM '/data/datasets/source_crm/prd_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
  	SET @end_time = GETDATE()
  	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '-------------------'
  	
  	SET @start_time = GETDATE()
    PRINT '>> Truncating Table: bronze.crm_sales_details';
    PRINT '>> Inserting Data Into: bronze.crm_sales_details';
    -- CRM Sales Information
    TRUNCATE TABLE bronze.crm_sales_details;

    BULK INSERT bronze.crm_sales_details
    FROM '/data/datasets/source_crm/sales_details.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
	SET @end_time = GETDATE()
   PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '-------------------'
 	
    PRINT '-----------------------------------------------';
    PRINT 'Loading ERP Tables';
    PRINT '-----------------------------------------------';
    PRINT '>> Truncating Table: bronze.erp_cust_az12';
    PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
    
    SET @start_time = GETDATE()
    -- ERP Customer Information
    TRUNCATE TABLE bronze.erp_cust_az12;

    BULK INSERT bronze.erp_cust_az12
    FROM '/data/datasets/source_erp/CUST_AZ12.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE()
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '-------------------'

	PRINT '>> Truncating Table: bronze.erp_loc_a101';
    PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
    -- ERP Location Information
	SET @start_time = GETDATE()
    TRUNCATE TABLE bronze.erp_loc_a101;

    BULK INSERT bronze.erp_loc_a101
    FROM '/data/datasets/source_erp/LOC_A101.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE()
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '-------------------'

	PRINT '>> Truncating Table: bronze.erp_cat_g1v2';
    PRINT '>> Inserting Data Into: bronze.erp_cat_g1v2';
	SET @start_time = GETDATE()
    -- ERP Product Category Information
    TRUNCATE TABLE bronze.erp_cat_g1v2;

    BULK INSERT bronze.erp_cat_g1v2
    FROM '/data/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE()
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'
	PRINT '-------------------'
    END TRY
    BEGIN CATCH
    PRINT '===============================================';
     PRINT 'Error Message' + ERROR_MESSAGE();
     PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
    PRINT '===============================================';
    END CATCH
END;

EXEC bronze.load_bronze;
