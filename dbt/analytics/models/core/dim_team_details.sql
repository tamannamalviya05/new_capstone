{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'TEAM_ID',
           incremental_stretagy = 'merge') }}

WITH CTE AS (SELECT 
  BOWLING_TEAM_ID AS TEAM_ID,
  BOWLING_TEAM_NAME AS TEAM_NAME
FROM {{ ref('stg_cricket_data') }}
UNION ALL
SELECT
  BATTING_TEAM_ID AS TEAM_ID,
  BATTING_TEAM_NAME AS TEAM_NAME
FROM {{ ref('stg_cricket_data') }})

SELECT 
  MD5(TO_CHAR(TEAM_ID)) AS TEAM_SK,
  TEAM_ID,
  TEAM_NAME
FROM CTE

WHERE TEAM_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY TEAM_ID ORDER BY _LOADED_AT DESC) = 1