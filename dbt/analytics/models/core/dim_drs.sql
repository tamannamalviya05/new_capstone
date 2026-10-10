{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'DRS_REVIEW_ID',
           incremental_stretagy = 'merge') }}

SELECT 
  MD5(TO_CHAR(DRS_REVIEW_ID)) AS DRS_SK,
  DRS_REVIEW_ID,
  DRS_REVIEWED_BY,
  DRS_ORIGINAL_DECISION,
  DRS_OUTCOME
FROM {{ ref ('stg_cricket_data') }}
WHERE DRS_REVIEW_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY DRS_REVIEW_ID ORDER BY _LOADED_AT DESC) = 1 