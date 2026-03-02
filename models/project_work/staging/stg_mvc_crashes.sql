-- Clean and standardize MVC crash data
-- One row per crash

WITH source AS (
    SELECT * FROM {{ source('raw', 'source_mvc_crash_data') }}
),

cleaned AS (
    SELECT
        -- Keep all columns except those we transform
        * EXCEPT (
            collision_id,
            crash_date,
            crash_time,
            borough,
            zip_code,
            latitude,
            longitude,
            on_street_name,
            off_street_name,
            cross_street_name
        ),

        -- Identifier
        CAST(collision_id AS STRING) AS crash_id,

        -- Date + time fields
        CAST(crash_date AS DATE) AS crash_date,
        CAST(crash_time AS STRING) AS crash_time, -- keep original hh:mm format

        -- Standardize borough the same way as your DOT model
        CASE
            WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
            ELSE 'UNKNOWN or CITYWIDE'
        END AS borough,

        -- Clean ZIP code (same rules as DOT model)
        CASE
            WHEN UPPER(TRIM(CAST(zip_code AS STRING))) IN ('N/A','NA') THEN NULL
            WHEN LENGTH(CAST(zip_code AS STRING)) = 5 THEN CAST(zip_code AS STRING)
            WHEN LENGTH(CAST(zip_code AS STRING)) = 9 THEN CAST(zip_code AS STRING)
            WHEN LENGTH(CAST(zip_code AS STRING)) = 10
                 AND REGEXP_CONTAINS(CAST(zip_code AS STRING), r'^\d{5}-\d{4}')
                 THEN CAST(zip_code AS STRING)
            ELSE NULL
        END AS zip_code,

        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude,

        CAST(on_street_name AS STRING) AS on_street_name,
        CAST(off_street_name AS STRING) AS off_street_name,
        CAST(cross_street_name AS STRING) AS cross_street_name,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE collision_id IS NOT NULL
      AND crash_date IS NOT NULL
      AND CAST(crash_date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 YEAR)
      AND borough IS NOT NULL

    -- Deduplicate
    QUALIFY ROW_NUMBER() OVER (PARTITION BY collision_id ORDER BY crash_date DESC, crash_time DESC) = 1
)

SELECT * FROM cleaned