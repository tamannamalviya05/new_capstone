{{ config (schema = 'CORE',
            materialized = 'incremental',
            unique_key = 'BATSMAN_ID',
            incremental_strategy = 'merge') }}

SELECT 
  MD5(TO_CHAR(BATSMAN_ID)) AS BATSMAN_SK,
  BATSMAN_ID,
  BATSMAN_NAME,
  BATSMAN_DOB,
  BATSMAN_NATIONALITY,
  BATING_ROLE,
  BATSMAN_HAND,
  BATSMAN_EMAIL,
  BATSMAN_PHONE,
  BATSMAN_ICC_RATING

FROM {{ ref('stg_cricket_data') }}

WHERE BATSMAN_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY BATSMAN_ID ORDER BY _LOADED_AT DESC) = 1