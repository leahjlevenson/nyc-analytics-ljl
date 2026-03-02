WITH all_locations_raw AS (

    -- MVC Crashes
    SELECT
        ST_GEOGPOINT(longitude, latitude) AS location_point,
        'MVC Crash' AS location_type,
        zip_code AS incident_zip,
        borough,
        latitude,
        longitude
    FROM {{ ref('stg_mvc_crashes') }}
    WHERE latitude IS NOT NULL AND longitude IS NOT NULL

    UNION ALL

    -- Noise Complaints
    SELECT
        ST_GEOGPOINT(longitude, latitude) AS location_point,
        'Noise Complaint' AS location_type,
        incident_zip,
        borough,
        latitude,
        longitude
    FROM {{ ref('stg_nyc_noise_complaint') }}
    WHERE latitude IS NOT NULL AND longitude IS NOT NULL
),

-- Convert GEOGRAPHY→string and dedupe using ROW_NUMBER()
deduped AS (
    SELECT
        ST_AsText(location_point) AS location_wkt,   -- WKT text for hashing + dedup
        location_point,
        location_type,
        incident_zip,
        borough,
        latitude,
        longitude,

        ROW_NUMBER() OVER (
            PARTITION BY ST_AsText(location_point)
            ORDER BY location_type  -- arbitrary, stable ordering
        ) AS rn

    FROM all_locations_raw
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['location_wkt']) }} AS location_key,

    location_point AS location,
    location_type,
    incident_zip,
    borough,
    latitude,
    longitude

FROM deduped
WHERE rn = 1