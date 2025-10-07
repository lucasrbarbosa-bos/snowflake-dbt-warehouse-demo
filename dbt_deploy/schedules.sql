--!jinja
-- One daily scheduled dbt build for a single environment.
-- REQUIRED USING vars: env, db_name, dbt_project_object, wh, daily_cron
-- OPTIONAL: extra_args  (e.g. " --select state:modified+ --state @some_stage/manifest")

CREATE OR REPLACE TASK {{ db_name }}.{{ env }}.T_DBT_DAILY_{{ env }}
  WAREHOUSE = {{ wh }}
  SCHEDULE = '{{ daily_cron }}'
AS
  -- Option A: full project build
  EXECUTE DBT PROJECT {{ db_name }}.{{ env }}.{{ dbt_project_object }}
    ARGS = 'build --target {{ lowerenv }}{{ extra_args and " " ~ extra_args or "" }}';

  -- Option B: rely solely on the stream for customers
  -- EXECUTE DBT PROJECT {{ db_name }}.{{ env }}.{{ dbt_project_object }}
  --   ARGS = 'build --select -tag:src_customers --target {{ env }}{{ extra_args and " " ~ extra_args or "" }}';

ALTER TASK {{ db_name }}.{{ env }}.T_DBT_DAILY_{{ env }} RESUME;
