--!jinja
-- This file MUST reference repo files via the repo path, not relative paths.
-- Required -D variables (from the workflow): repo_name, branch,
-- env, db_name, dbt_project_object, wh, src_db, src_schema, daily_cron
-- Optional: extra_args

EXECUTE IMMEDIATE FROM 'dbt_deploy/streams.sql'
  USING (
    env                => '{{ env }}',
    db_name            => '{{ db_name }}',
    dbt_project_object => '{{ dbt_project_object }}',
    wh                 => '{{ wh }}',
    src_db             => '{{ src_db }}',
    src_schema         => '{{ src_schema }}',
    extra_args         => '{{ extra_args | default("") }}'
  );

EXECUTE IMMEDIATE FROM 'dbt_deploy/schedules.sql'
  USING (
    env                => '{{ env }}',
    db_name            => '{{ db_name }}',
    dbt_project_object => '{{ dbt_project_object }}',
    wh                 => '{{ wh }}',
    daily_cron         => '{{ daily_cron }}',
    extra_args         => '{{ extra_args | default("") }}'
  );
