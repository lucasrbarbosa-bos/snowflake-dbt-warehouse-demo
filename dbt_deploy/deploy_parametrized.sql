--!jinja
-- Forward env/dbt parameters into the two deploy scripts stored in the Git repository clone.
-- REQUIRED USING vars:
--   env, db_name, dbt_project_object, wh, src_db, src_schema, daily_cron
-- OPTIONAL:
--   extra_args  (default: '')

-- Evented CUSTOMERS flow
EXECUTE IMMEDIATE FROM @snowflake_dbt_repo/branches/main/deploy/streams.sql
  USING (
    env              => '{{ env }}',
    db_name          => '{{ db_name }}',
    dbt_project_object => '{{ dbt_project_object }}',
    wh               => '{{ wh }}',
    src_db           => '{{ src_db }}',
    src_schema       => '{{ src_schema }}',
    extra_args       => '{{ extra_args | default("") }}'
  );

-- Daily schedule
EXECUTE IMMEDIATE FROM @snowflake_dbt_repo/branches/main/deploy/schedules.sql
  USING (
    env                => '{{ env }}',
    db_name            => '{{ db_name }}',
    dbt_project_object => '{{ dbt_project_object }}',
    wh                 => '{{ wh }}',
    daily_cron         => '{{ daily_cron }}',
    extra_args         => '{{ extra_args | default("") }}'
  );
