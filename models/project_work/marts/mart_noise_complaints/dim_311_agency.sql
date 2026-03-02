{{ config(materialized="table") }}

WITH base AS (
    SELECT DISTINCT
        agency,
        agency_name
    FROM {{ ref('stg_nyc_noise_complaint') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['agency']) }} AS agency_key,
    agency,
    agency_name
FROM base