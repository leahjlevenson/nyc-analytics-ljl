WITH all_locations AS (

    -- MVC Crashes
    SELECT DISTINCT
        ST_GEOGPOINT(longitude, latitude) AS location_point,
        'MVC Crash' AS location_type,
        zip_code AS incident_zip,
        borough,
        latitude,
        longitude
    FROM {{ ref('stg_mvc_crashes') }}
    WHERE latitude IS NOT NULL AND longitude IS NOT NULL

    UNION DISTINCT

    -- Noise Complaints
    SELECT DISTINCT
        ST_GEOGPOINT(longitude, latitude) AS location_point,
        'Noise Complaint' AS location_type,
        incident_zip,
        borough,
        latitude,
        longitude
    FROM {{ ref('stg_nyc_noise_complaint') }}
    WHERE latitude IS NOT NULL AND longitude IS NOT NULL
),

location_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(["ST_AsText(location_point)"]) }} AS location_key,

        location_point AS location,   -- GEOGRAPHY column
        location_type,
        incident_zip,
        borough,
        latitude,
        longitude
    FROM all_locations
)

SELECT * FROM location_dimension