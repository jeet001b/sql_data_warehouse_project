/*==============================================================================
  OBJECTIVE:
  ------------------------------------------------------------------------------
  This script creates the Gold Layer views in the data warehouse.

  The Gold Layer is designed for reporting and business analytics. It transforms
  the cleaned Silver Layer data into a dimensional model (Star Schema) by
  creating:

  1. Customer Dimension (dim_customers)
     - Stores customer information with a surrogate key.
     - Combines customer, location, and demographic data.

  2. Product Dimension (dim_products)
     - Stores current product information with a surrogate key.
     - Combines product and category details.

  3. Sales Fact Table (fact_sales)
     - Stores sales transactions.
     - Links customers and products using surrogate keys.
     - Provides measures such as sales amount, quantity, and price.

  These views are intended for dashboards, BI reporting, and analytical queries.
==============================================================================*/


/*==============================================================================
  CUSTOMER DIMENSION
  Purpose:
  Creates a customer dimension by combining customer information,
  demographic data, and location details.
==============================================================================*/
CREATE VIEW gold.dim_customers AS

SELECT

    -- Generate surrogate key for each customer
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,

    -- Business key
    ci.cst_id AS customer_id,

    -- Customer number from CRM
    ci.cst_key AS customer_number,

    -- Customer personal details
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,

    -- Customer country
    la.cntry AS country,

    -- Marital status
    ci.cst_marital_status AS marital_status,

    -- Use CRM gender if available,
    -- otherwise use ERP gender,
    -- if both are unavailable return 'n/a'
    CASE
        WHEN ci.cst_gndr != 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    -- Date of birth
    ca.bdate AS birthdate,

    -- Customer creation date
    ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;



/*==============================================================================
  PRODUCT DIMENSION
  Purpose:
  Creates a product dimension by combining product information
  with category information.
  Only active/current products are included.
==============================================================================*/
CREATE VIEW gold.dim_products AS

SELECT

    -- Generate surrogate key for each product
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    -- Business key
    pn.prd_id AS product_id,

    -- Product number
    pn.prd_key AS product_number,

    -- Product name
    pn.prd_nm AS product_name,

    -- Category ID
    pn.cat_id AS category_id,

    -- Category details
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,

    -- Product cost
    pn.prd_cost AS cost,

    -- Product line
    pn.prd_line AS product_line,

    -- Product start date
    pn.prd_start_dt AS start_date

FROM silver.crm_prd_info pn

LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

-- Keep only current active products
WHERE prd_end_dt IS NULL;



/*==============================================================================
  SALES FACT TABLE
  Purpose:
  Creates the sales fact table by joining sales transactions
  with customer and product dimensions.

  This table stores measurable business metrics and references
  dimension tables through surrogate keys.
==============================================================================*/
CREATE VIEW gold.fact_sales AS

SELECT

    -- Sales order number
    sd.sls_ord_num AS order_number,

    -- Product surrogate key
    pr.product_key,

    -- Customer surrogate key
    cu.customer_key,

    -- Important dates
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,

    -- Business measures
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS sales_price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
