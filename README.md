# ❄️ snowflake-dbt-warehouse-demo

This repository is a **Snowflake-focused** dbt starter, **based on** the classic jaffle shop project but adapted to:
- develop locally or in the Snowflake Workspace,
- deploy to **Snowflake DBT PROJECTS** via the **Snowflake CLI** (`snow dbt deploy`),
- use **split DEV/PROD** schemas and warehouses,
- optionally lint SQL with **SQLFluff** and enforce hygiene via **pre-commit**.

> If you’re familiar with jaffle shop: think of this as the same modeling patterns, just opinionated for **Snowflake + CI/CD**.

# Table of contents

1. [What you get](#what-you-get)
2. [Prerequisites](#prerequisites)
3. [Quick start](#quick-start)
4. [Local development](#local-development)
5. [CI/CD on GitHub Actions](#cicd-on-github-actions)
6. [Linting (optional)](#linting-optional)
7. [Project layout](#project-layout)
8. [Notes & acknowledgements](#notes--acknowledgements)

---

## What you get

- **dbt models** and tests adapted for Snowflake
- **DEV / PROD** targets:
  - Database: `dbt_projects`
  - Schemas: `dev` and `prod`
  - Warehouses: `ANALYST_WH_DEV` and `ANALYST_WH_PROD`
- **Snowflake CLI** deployment to DBT PROJECT objects (e.g., `dbt_projects.dev.jaffle_shop_test` → adjust as you like)
- Example **GitHub Actions** workflow for PR→DEV and main→PROD
- Optional **pre-commit** hooks (YAML hygiene, whitespace, Ruff) + **SQLFluff** (dbt templater, Snowflake dialect)

---

## Prerequisites

- Snowflake account + role with permissions to create objects in `dbt_projects` and run compute on the listed warehouses.
- Python 3.11+.
- For CI/CD: GitHub repository with the workflow in `.github/workflows/`.

---

## Quick start

Follow the steps under the following guideline under the medium article.

- create a virtualenv and install dev tools
```
python -m venv .venv
```
```
- Windows: .venv\Scripts\Activate.ps1 | mac/linux: source .venv/bin/activate
```
```
pip install -r requirements.txt
```
Create a local dbt profile at ~/.dbt/profiles.yml (keep creds off-repo). Pick one:
```
A) SSO (recommended for MFA/Duo)

snowflake_dbt_warehouse_demo:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <acct_locator>
      user: <you>
      authenticator: externalbrowser
      role: SYSADMIN
      warehouse: ANALYST_WH_DEV
      database: dbt_projects
      schema: dev
      client_session_keep_alive: true
      client_store_temporary_credential: true
```

```
B) Key-pair (no prompts)

snowflake_dbt_warehouse_demo:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <acct_locator>
      user: <you>
      private_key_path: "/path/to/sf_key.p8"
      private_key_passphrase: "{{ env_var('PRIVATE_KEY_PASSPHRASE','') }}"
      role: SYSADMIN
      warehouse: ANALYST_WH_DEV
      database: dbt_projects
      schema: dev
      client_session_keep_alive: true

```
Then:

## install dbt packages for this project (creates ./dbt_packages)
```bash
dbt deps
```
- optional: compile locally
```bash
dbt compile --target dev
```
- build locally (adjust as needed)
```bash
dbt build --select state:modified+ --target dev
```

The root profiles.yml in this repo is intentionally credential-free for Snowflake Workspace & CI deploys. Your local credentials live in ~/.dbt/profiles.yml.

## Local development

Use the profile above and standard dbt commands (dbt run, dbt test, dbt build).

If Duo prompts too often with SSO, ensure:

```
authenticator: externalbrowser
client_store_temporary_credential: true
client_session_keep_alive: true
```

## CI/CD on GitHub Actions

We ship a workflow that:
- On PRs to main: runs dbt deps and deploys to DEV via snow dbt deploy.
- On push to main: deploys to PROD.

Secrets to add in GitHub → Settings → Secrets and variables:

- SNOWFLAKE_ACCOUNT
- SNOWFLAKE_USER
- SNOWFLAKE_PRIVATE_KEY_PEM (PKCS#8 PEM, full contents)
- PRIVATE_KEY_PASSPHRASE (if your key is encrypted)

The workflow uses key-pair auth with:

--authenticator SNOWFLAKE_JWT --private-key-path <temp file written from secret>


By default it deploys to objects like:

- DEV: dbt_projects.dev.jaffle_shop_test
- PROD: dbt_projects.prod.jaffle_shop_test

Rename those in .github/workflows/*.yml to match your conventions.

## Linting and pre-commit(optional)

We include a .pre-commit-config.yaml and .sqlfluff:

- pre-commit hooks:

check-yaml, end-of-file-fixer, trailing-whitespace, requirements-txt-fixer

- ruff + ruff-format (Python hygiene if you add Snowpark/models)

SQLFluff with dbt templater and Snowflake dialect (uses your local ~/.dbt profile)

Enable locally:
```
pre-commit install
pre-commit install --hook-type pre-push   # so dbt/compile or extra checks can run on push
pre-commit run --all-files                # one-time cleanup; stage & commit its fixes
```

Don’t want local hooks? Skip installing them. CI deployment does not depend on pre-commit.

## Project Layout

```
snowflake-dbt-warehouse-demo
├─ models/                 # staging & marts (Snowflake-friendly SQL/Jinja)
├─ macros/                 # shared macros
├─ seeds/                  # optional small CSVs (not for heavy loading)
├─ dbt_project.yml
├─ packages.yml            # dbt packages (installed into ./dbt_packages)
├─ .sqlfluff               # SQLFluff config (dbt templater, snowflake dialect)
└─ .github/workflows/      # GitHub Actions (Snowflake CLI deploy)
```

### Schemas & warehouses used by default:

- Database: dbt_projects
- Schemas: dev, prod
- Warehouses: ANALYST_WH_DEV, ANALYST_WH_PROD

- Adjust in dbt_project.yml, the root profiles.yml (for Workspace/Deploy), and the workflow if needed.

## Notes & acknowledgements

This repo is based on the dbt Labs jaffle shop example, refactored to emphasize Snowflake + CI/CD patterns.
For larger data or different source systems, swap seeds/S3 loaders for your real ingestion process. dbt is not a loader.

Use service roles & least-privilege in PROD.

Happy building! ❄️
