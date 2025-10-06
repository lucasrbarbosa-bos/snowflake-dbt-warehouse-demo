--!jinja
-- Forwards variables to both repo-hosted scripts.

EXECUTE IMMEDIATE FROM @{{ repo_name }}/branches/{{ branch }}/deploy/streams.sql
  USING (
    env                => '{{ env }}',
    db_name            => '{{ db_name }}',
    dbt_project_object => '{{ dbt_project_object }}',
    wh                 => '{{ wh }}',
    src_db             => '{{ src_db }}',
    src_schema         => '{{ src_schema }}',
    extra_args         => '{{ extra_args | default("") }}'
  );

EXECUTE IMMEDIATE FROM @{{ repo_name }}/branches/{{ branch }}/deploy/schedules.sql
  USING (
    env                => '{{ env }}',
    db_name            => '{{ db_name }}',
    dbt_project_object => '{{ dbt_project_object }}',
    wh                 => '{{ wh }}',
    daily_cron         => '{{ daily_cron }}',
    extra_args         => '{{ extra_args | default("") }}'
  );
