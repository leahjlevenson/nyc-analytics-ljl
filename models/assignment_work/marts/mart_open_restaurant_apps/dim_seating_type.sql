-- Seating type dimension for open restaurant seating applications
WITH seating_types AS (
   SELECT DISTINCT
       seating_interest_sidewalk AS seating_interest,

       -- Convert sidewalk approval into a boolean
       CASE
           WHEN approved_for_sidewalk_seating IN ('Yes', 'YES', 'Y', 'True', 'TRUE', '1') THEN TRUE
           WHEN approved_for_sidewalk_seating IN ('No', 'NO', 'False', 'FALSE', '0') THEN FALSE
           ELSE FALSE
       END AS approved_for_sidewalk,

       -- Convert roadway approval into a boolean
       CASE
           WHEN approved_for_roadway_seating IN ('Yes', 'YES', 'Y', 'True', 'TRUE', '1') THEN TRUE
           WHEN approved_for_roadway_seating IN ('No', 'NO', 'False', 'FALSE', '0') THEN FALSE
           ELSE FALSE
       END AS approved_for_roadway

   FROM {{ ref('stg_nyc_open_restaurant_apps') }}
   WHERE seating_interest_sidewalk IS NOT NULL
),

seating_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'seating_interest',
           'approved_for_sidewalk',
           'approved_for_roadway'
       ]) }} AS seating_type_key,

       seating_interest,
       approved_for_sidewalk,
       approved_for_roadway

   FROM seating_types
)

SELECT *
FROM seating_dimension