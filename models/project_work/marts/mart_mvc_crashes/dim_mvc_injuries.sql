{{ config(materialized="table") }}

WITH base AS (
    SELECT
        crash_id AS collision_id,
        persons_injured     AS number_of_persons_injured,
        persons_killed      AS number_of_persons_killed,
        pedestrians_injured AS number_of_pedestrians_injured,
        pedestrians_killed  AS number_of_pedestrians_killed,
        cyclists_injured    AS number_of_cyclist_injured,
        cyclists_killed     AS number_of_cyclist_killed,
        motorists_injured   AS number_of_motorist_injured,
        motorists_killed    AS number_of_motorist_killed
    FROM {{ ref('stg_mvc_crashes') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['collision_id']) }} AS mvc_injuries_key,
    *
FROM base