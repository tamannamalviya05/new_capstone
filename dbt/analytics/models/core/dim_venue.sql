{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'VENUE_ID',
           incremental_stretagy = 'merge') }}

SELECT 
 MD5(TO_CHAR(VENUE_ID)) AS VENUE_SK,
 VENUE_ID,
 VENUE_NAME,
 VENUE_CITY,
 VENUE_COUNTRY
FROM {{ ref('stg_cricket_data') }}
WHERE VENUE_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY VENUE_ID ORDER BY _LOADED_AT DESC) = 1