--!jinja
-- Event-driven dbt for the CUSTOMERS table only.
-- REQUIRED USING vars: env, db_name, dbt_project_object, wh, src_db, src_schema
-- OPTIONAL: extra_args  (e.g. " --select state:modified+ --state @some_stage/manifest")

CREATE STREAM IF NOT EXISTS {{db_name}}.{{env}}.STREAM_CUSTOMERS_{{env}}
  ON TABLE {{src_db}}.RAW.CUSTOMERS;

CREATE OR REPLACE PROCEDURE {{db_name}}.{{env}}.RUN_DBT_ON_CUSTOMERS_{{ env }}()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE v_args STRING;
BEGIN
  -- base args (you can add more with extra_args)
  v_args := 'build --select tag:src_customers+ --target {{ env }}{{ extra_args and " " ~ extra_args or "" }}';

  -- ARGS must be part of the dynamic statement; pass the string as-is to dbt
  EXECUTE IMMEDIATE
    'EXECUTE DBT PROJECT {{db_name}}.{{env}}.{{dbt_project_object}} ARGS = ''' || v_args || '''';

  RETURN 'Ran: ' || v_args;
END;
$$;

CREATE OR REPLACE ALERT {{db_name}}.{{env}}.ALERT_DBT_ON_CUSTOMERS_{{env}}
  WAREHOUSE = {{ wh }}
  SCHEDULE = '1 MINUTE'
IF (EXISTS (SELECT 1 FROM {{db_name}}.{{env}}.STREAM_CUSTOMERS_{{env}}))
THEN
  CALL {{db_name}}.{{env}}.RUN_DBT_ON_CUSTOMERS_{{ env }}();

ALTER ALERT {{db_name}}.{{env}}.A_DBT_ON_CUSTOMERS_{{ env }} RESUME;
