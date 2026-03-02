{{ config(materialized="table") }}

WITH src AS (
    SELECT *
    FROM {{ ref('stg_mvc_crashes') }}
),

keys AS (
    SELECT
        crash_id AS collision_id,

        -- Date FK
        {{ dbt_utils.generate_surrogate_key(['crash_date']) }} AS date_key,

        -- Time FK (parsed timestamp)
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M',
            CONCAT(CAST(crash_date AS STRING), ' ', crash_time)
        ) AS full_ts,

        {{ dbt_utils.generate_surrogate_key([
            "PARSE_TIMESTAMP('%Y-%m-%d %H:%M', CONCAT(CAST(crash_date AS STRING),' ', crash_time))"
        ]) }} AS time_key,

        -- Location FK
        {{ dbt_utils.generate_surrogate_key(['ST_AsText(ST_GEOGPOINT(longitude, latitude))']) }} AS location_key,

        contributing_factor_vehicle_1,
        contributing_factor_vehicle_2,
        contributing_factor_vehicle_3,
        contributing_factor_vehicle_4,
        contributing_factor_vehicle_5
    FROM src
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['collision_id']) }} AS mvc_collision_key,
    collision_id,
    date_key,
    time_key,
    location_key,
    contributing_factor_vehicle_1,
    contributing_factor_vehicle_2,
    contributing_factor_vehicle_3,
    contributing_factor_vehicle_4,
    contributing_factor_vehicle_5
FROM keys