{{ config(materialized="table") }}

WITH base AS (
    SELECT
        crash_id AS collision_id,

        number_of_persons_injured,
        number_of_persons_killed,

        number_of_pedestrians_injured,
        number_of_pedestrians_killed,

        number_of_cyclist_injured,
        number_of_cyclist_killed,

        number_of_motorist_injured,
        number_of_motorist_killed
    FROM {{ ref('stg_mvc_crashes') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['collision_id']) }} AS mvc_injuries_key,
    *
FROM base