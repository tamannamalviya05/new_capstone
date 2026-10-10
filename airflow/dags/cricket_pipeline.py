from airflow import DAG
from pathlib import Path
from datetime import datetime
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook


RAW_TABLE = "PROJECT_DB.RAW.RAW_CRICKET_DATA"
CONN_ID = "snowflake_conn"
STAGE = "PROJECT_DB.RAW.PROJECT_STAGE"
FILE_FORMAT = "PROJECT_DB.RAW.CSV_FORMAT"
DATA_DIR = "/opt/airflow/data"

DBT_DIR = "/opt/airflow/dbt/analytics"
DBT_PROFILES = "/home/airflow/.dbt"

def load_csv_to_raw():
    files = sorted(Path(DATA_DIR).glob("*.csv"))
    if not files:
        print("No CSV file found")

    hook = SnowflakeHook(snowflake_conn_id = CONN_ID)
    conn = hook.get_conn()
    cursor = conn.cursor()

    try:
        for file in files:
            cursor.execute(f""" PUT 'file://{file}'
                                @{STAGE}
                                AUTO_COMPRESS = FALSE
                                OVERWRITE = FALSE""")
            cursor.execute(f"""COPY INTO {RAW_TABLE}
                               FROM @{STAGE}
                               FILE_FORMAT = (FORMAT_NAME = '{FILE_FORMAT}')
                               MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
                               INCLUDE_METADATA = (
                               _SOURCE_FILE = METADATA$FILENAME,
                               _LOADED_AT = METADATA$START_SCAN_TIME)
                               PATTERN = '.*[.]csv'
                               ON_ERROR = 'ABORT_STATEMENT'
                               FORCE = FALSE""")

            for result in cursor.fetchall(): 
                print(result)

    finally:
        cursor.close()
        conn.close

with DAG(
    dag_id = "cricket_pipeline",
    schedule = None,
    start_date = datetime(2026, 1, 1),
    catchup = False
) as dag:

    load_raw_data = PythonOperator(
        task_id = "load_csv_to_raw",
        python_callable = load_csv_to_raw
    )

    raw_to_staging = BashOperator(
        task_id = "raw_to_staging",
        bash_command = "cd /opt/airflow/dbt/analytics && dbt build --project-dir /opt/airflow/dbt/analytics --profiles-dir /home/airflow/.dbt --select path:models/staging",
    )

    staging_to_core = BashOperator(
        task_id = "raw_to_staging",
        bash_command = "cd /opt/airflow/dbt/analytics && dbt build --project-dir /opt/airflow/dbt/analytics --profiles-dir /home/airflow/.dbt --select path:models/core",
    )

    load_raw_data >> raw_to_staging >> staging_to_core