FROM apache/airflow:2.10.5

USER root

RUN apt-get update \
    && apt-get install -y \
        curl \
        gnupg2 \
        apt-transport-https \
        ca-certificates \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

RUN pip install --no-cache-dir \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.10.5/constraints-3.12.txt" \
    apache-airflow-providers-microsoft-mssql==4.0.0

RUN pip install --no-cache-dir \
    dbt-core==1.11.11 \
    dbt-snowflake==1.11.6

RUN pip install --no-cache-dir pandas