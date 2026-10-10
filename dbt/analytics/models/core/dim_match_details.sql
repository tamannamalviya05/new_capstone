{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'MATCH_ID',
           incremental_strategy = 'merge')}}

SELECT 
  MD5(TO_CHAR(MATCH_ID)) AS MATCH_SK,
  MATCH_ID,
  MATCH_FORMAT,
  TOURNAMENT_NAME,
  SEASON,
  MATCH_STAGE,
  TOSS_DECISION
FROM {{ ref('stg_cricket_data') }}
WHERE MATCH_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY MATCH_ID ORDER BY _LOADED_AT DESC) = 1