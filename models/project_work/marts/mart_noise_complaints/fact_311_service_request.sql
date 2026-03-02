{{ config(materialized="table") }}

WITH src AS (
    SELECT *
    FROM {{ ref('stg_nyc_noise_complaint') }}
),

keys AS (
    SELECT
        request_id AS unique_key,

        -- FK to dim_date
        {{ dbt_utils.generate_surrogate_key(["CAST(created_date AS DATE)"]) }} AS date_key,

        -- FK to dim_time
        {{ dbt_utils.generate_surrogate_key(['created_date']) }} AS time_key,

        -- FK to dim_location
        {{ dbt_utils.generate_surrogate_key(['ST_AsText(ST_GEOGPOINT(longitude, latitude))']) }} AS location_key,

        descriptor
    FROM src
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['unique_key']) }} AS request_key,
    unique_key,
    date_key,
    time_key,
    location_key,
    descriptor
FROM keys