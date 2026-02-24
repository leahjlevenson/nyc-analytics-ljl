-- Clean and standardize NYC Open Restaurant Applications
-- One row per application

WITH source AS (
   SELECT * FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
   SELECT
       * EXCEPT (
           objectid,
           globalid,
           restaurant_name,
           legal_business_name,
           doing_business_as_dba,
           food_service_establishment,
           bulding_number,           
           street,
           borough,
           zip,
           business_address,
           time_of_submission,
           latitude,
           longitude,
           community_board,
           council_district,
           census_tract,
           bin,
           bbl,
           nta
       ),

       -- Identifiers
       CAST(objectid AS STRING) AS objectid,
       CAST(globalid AS STRING) AS globalid,

       -- Business names
       CAST(restaurant_name AS STRING) AS restaurant_name,
       CAST(legal_business_name AS STRING) AS legal_business_name,
       CAST(doing_business_as_dba AS STRING) AS doing_business_as_dba,

       CAST(food_service_establishment AS STRING) AS food_service_establishment,

       -- Address components
       CAST(bulding_number AS STRING) AS building_number,   
       CAST(street AS STRING) AS street,

       -- Standardized borough
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,

       -- Clean zip code
       CASE
           WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 9 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(zip AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(zip AS STRING)
           ELSE NULL
       END AS zip,

       CAST(business_address AS STRING) AS business_address,

       -- Dates
       CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,

       -- Geolocation
       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,

       -- Geography / metadata
       CAST(community_board AS STRING) AS community_board,
       CAST(council_district AS STRING) AS council_district,
       CAST(census_tract AS STRING) AS census_tract,
       CAST(bin AS STRING) AS bin,
       CAST(bbl AS STRING) AS bbl,
       CAST(nta AS STRING) AS nta,

       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   WHERE objectid IS NOT NULL
     AND restaurant_name IS NOT NULL
     AND borough IS NOT NULL
     AND time_of_submission IS NOT NULL

   QUALIFY ROW_NUMBER() OVER (PARTITION BY objectid ORDER BY time_of_submission DESC) = 1
)

SELECT * FROM cleaned