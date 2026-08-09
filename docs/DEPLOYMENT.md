# Deployment plan

## Recommended topology

- Web: Vercel or Netlify static deployment from `apps/web`.
- API: Render, Fly.io, or Cloud Run from `apps/api/Dockerfile`.
- Data/auth: Supabase managed Postgres and Auth.
- AI: OpenAI Responses API from the server only.

## Environments

Use separate Supabase projects for preview/staging and production. CI runs typecheck, tests, builds, and migration linting. Production migrations run as an explicit release step before API rollout.

## Secrets

Set `SUPABASE_URL`, `SUPABASE_ANON_KEY` in the web host. Set `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `OPENAI_API_KEY`, and allowed origins only in the API host. Never commit real values or expose a service-role/provider key through a `VITE_` variable.

## Rollout

1. Apply migration and seed an internal workspace.
2. Deploy API; verify `/health` and `/ready`.
3. Deploy web against the API origin.
4. Run sign-up, analysis, usage, tenant-isolation, and deletion smoke tests.
5. Invite a small cohort, watch error/cost budgets, then expand gradually.

## Operations

Alert on failed analysis ratio, p95 latency, provider errors, quota rejections, and spend anomalies. Back up Postgres, test point-in-time recovery, pin model/prompt versions, and retain audit metadata without logging customer content.
