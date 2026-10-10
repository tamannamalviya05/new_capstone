{{ config (schema = 'CORE',
            materialized = 'incremental',
            unique_key = 'BOWLER_ID',
            incremental_strategy = 'merge') }}

SELECT 
  MD5(TO_CHAR(BOWLER_ID)) AS BOWLER_SK,
  BOWLER_ID,
  BOWLER_NAME,
  BATSMAN_EMAIL AS BOWLER_EMAIL,
  BATSMAN_PHONE AS BOWLER_PHONE,
  BOWLER_NATIONALITY,
  BOWLER_STYLE,
  BOWLER_ICC_RATING

FROM {{ ref('stg_cricket_data') }}
WHERE BOWLER_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY BOWLER_ID ORDER BY _LOADED_AT DESC) = 1