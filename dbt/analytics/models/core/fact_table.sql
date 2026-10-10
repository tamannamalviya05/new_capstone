{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'DELIVERY_ID',
           incremental_stretagy = 'merge') }}

SELECT
  s.DELIVERY_ID,
  s.DELIVERY_TIMESTAMP,
  s.INNINGS_NO,
  s.OVER_NO,
  s.BALL_IN_OVER,
  s.RUNS_OFF_BAT,
  s.EXTRA_RUNS,
  s.EXTRA_TYPE,
  s.TOTAL_RUNS,
  s.IS_WICKET,
  s.DISMISSAL_TYPE,
  s.BALL_SPEED_KMPH,
  s.NON_STRICKER_ID,
  s.SHOT_REGION,
  s.SHOT_TYPE,
  v.VENUE_SK,
  v.VENUE_ID,
  d.DATE_KEY,
  t.TEAM_SK,
  t.TEAM_ID,
  dr.DRS_REVIEW_SK,
  dr.DRS_REVIEW_ID,
  b.BATSMAN_SK,
  b.BATSMAN_ID
  bo.BOWLER_SK,
  bo.BOWLER_ID,
  m.MATCH_SK,
  m.MATCH_ID,
  c.CONTRACT_SK,
  c.CONTRACT_ID
FROM {{ ref ('stg_cricket_data') }} AS s
LEFT JOIN {{ ref ('dim_venue') }} AS v ON s.VENUE_ID = v.VENUE_ID
LEFT JOIN {{ ref ('dim_date') }} AS d ON TO_DATE(s.DELIVERY_TIMESTAMP) = d.DATE_DAY
LEFT JOIN {{ ref ('dim_team_details') }} AS t ON s.TEAM_ID = t.TEAM_ID
LEFT JOIN {{ ref ('dim_drs') }} AS dr ON s.DRS_REVIEW_ID = dr.DRS_REVIEW_ID
LEFT JOIN {{ ref ('dim_batsman') }} AS b ON s.BATSMAN_ID = b.BATSMAN_ID
LEFT JOIN {{ ref ('dim_bowler') }} AS bo ON s.BOWLER_ID = bo.BOWLER_ID
LEFT JOIN {{ ref ('dim_match_details') }} AS m ON s.MATCH_ID = m.MATCH_ID
LEFT JOIN {{ ref ('dim_contract') }} AS c ON s.CONTRACT_ID = c.CONTRACT_ID

WHERE DELIVERY_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY DELIVERY_ID ORDER BY _LOADED_AT DESC) = 1