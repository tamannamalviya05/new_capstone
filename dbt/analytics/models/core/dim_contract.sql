{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'CONTRACT_ID',
           incremental_strategy = 'merge') }}

SELECT 
  MD5(TO_CHAR(CONTRACT_ID)) AS CONTRACT_SK,
  CONTRACT_ID,
  CONTRACT_GRADE,
  CONTRACT_STATUS,
  ANNUAL_RETAINER_USD

FROM {{ref ('stg_cricket_data') }}
WHERE CONTRACT_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY CONTRACT_ID ORDER BY _LOADED_AT DESC) = 1