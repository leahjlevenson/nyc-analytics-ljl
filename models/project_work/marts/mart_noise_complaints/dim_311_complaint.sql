{{ config(materialized="table") }}

WITH src AS (
    SELECT
        request_id AS unique_key,
        complaint_type,
        agency
    FROM {{ ref('stg_nyc_noise_complaint') }}
),

joined AS (
    SELECT
        s.unique_key,
        s.complaint_type,
        a.agency_key
    FROM src s
    LEFT JOIN {{ ref('dim_311_agency') }} a
        ON s.agency = a.agency
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['unique_key']) }} AS complaint_key,
    unique_key,
    agency_key,
    complaint_type
FROM joined