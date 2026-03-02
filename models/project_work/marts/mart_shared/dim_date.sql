WITH all_dates AS (

    -- From MVC crashes
    SELECT DISTINCT crash_date AS full_date
    FROM {{ ref('stg_mvc_crashes') }}
    WHERE crash_date IS NOT NULL

    UNION DISTINCT

    -- From Noise Complaints
    SELECT DISTINCT CAST(created_date AS DATE) AS full_date
    FROM {{ ref('stg_nyc_noise_complaint') }}
    WHERE created_date IS NOT NULL
),

date_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key(['full_date']) }} AS date_key,

       full_date,
       EXTRACT(YEAR FROM full_date) AS year,
       EXTRACT(MONTH FROM full_date) AS month,
       EXTRACT(DAY FROM full_date) AS day,
       EXTRACT(DAYOFWEEK FROM full_date) AS weekday

   FROM all_dates
)

SELECT * FROM date_dimension