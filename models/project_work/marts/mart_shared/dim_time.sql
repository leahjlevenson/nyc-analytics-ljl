WITH all_times AS (

    -- From MVC crashes: construct timestamp from separate date + time
    SELECT DISTINCT
        TIMESTAMP(CONCAT(CAST(crash_date AS STRING), ' ', crash_time)) AS full_timestamp
    FROM {{ ref('stg_mvc_crashes') }}
    WHERE crash_date IS NOT NULL AND crash_time IS NOT NULL

    UNION DISTINCT

    -- From Noise Complaints (already timestamp)
    SELECT DISTINCT created_date AS full_timestamp
    FROM {{ ref('stg_nyc_noise_complaint') }}
    WHERE created_date IS NOT NULL
),

time_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['full_timestamp']) }} AS time_key,
        full_timestamp AS created_date,

        EXTRACT(HOUR FROM full_timestamp) AS hour,
        EXTRACT(MINUTE FROM full_timestamp) AS minute,
        EXTRACT(SECOND FROM full_timestamp) AS second

    FROM all_times
)

SELECT * FROM time_dimension