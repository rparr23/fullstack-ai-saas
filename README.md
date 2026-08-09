# SignalDesk

SignalDesk is a full-stack AI SaaS that turns customer feedback into evidence-linked product themes and prioritized actions. It demonstrates the complete product loop—identity, tenant-aware data, AI orchestration, metering, team-ready access control, and deployment—not a notebook wrapped in a chat box.

> The repository defaults to deterministic demo mode, so reviewers can run the complete workflow without paid services. Production adapters and security boundaries are documented and isolated.

## Why this product

Product teams already have feedback; their problem is turning it into decisions people trust. SignalDesk groups feedback, explains what changed, cites the exact source records behind each claim, and creates an action queue. The evidence graph makes AI output reviewable rather than authoritative by default.

## Architecture

```text
React/Vite web  →  Express API  →  OpenAI structured analysis
      ↓                 ↓
Supabase Auth      Supabase Postgres + RLS
```

The web app never receives privileged keys. The API verifies identity and membership, validates payloads with shared Zod contracts, applies rate limits, meters usage, and persists structured results. See [architecture](docs/ARCHITECTURE.md), [database design](docs/DATABASE.md), [milestones](docs/MILESTONES.md), and [deployment plan](docs/DEPLOYMENT.md).

## Included product features

- User/workspace model ready for Supabase email authentication.
- Postgres schema with memberships, roles, RLS, analyses, evidence, usage, subscriptions, and in-app feedback.
- Evidence-first AI workflow with structured, validated responses.
- Responsive customer-intelligence dashboard and analysis flow.
- Append-only usage model and visible plan quota.
- Per-actor API rate limiting and consistent error envelopes.
- Mock billing state, admin-ready roles, team accounts, and feedback table.
- Health/readiness endpoints, container build, and CI quality gates.
- Deterministic demo provider for a no-credential reviewer experience.

## Quick start

Requirements: Node.js 22+ and pnpm 10+.

```bash
cp .env.example .env
pnpm install
pnpm dev
```

Open `http://localhost:5173`. Select **New analysis**, then **Run analysis**. The API runs on `http://localhost:8787`.

## Demo scenario

The seeded Atlas Labs workspace contains support, survey, review, and interview feedback. The analysis surfaces onboarding friction, demand for traceable evidence, and report sharing. Hover evidence references such as `FB-184` to inspect the source. Stop the API to see the frontend’s honest offline-demo fallback.

## Configuration

Copy `.env.example`; mock mode needs no credentials. Hosted environments should configure Supabase and OpenAI secrets only in their host secret stores. Never expose `SUPABASE_SERVICE_ROLE_KEY` or `OPENAI_API_KEY` in a `VITE_` variable.

The included API currently uses the deterministic provider. `docs/ARCHITECTURE.md` defines the production OpenAI adapter contract: bounded source context, JSON-schema output, Zod validation, citation verification, timeout, retry, and metering. This keeps the repository safe to evaluate while making the provider seam explicit.

## Database setup

Create a Supabase project and apply `supabase/migrations/202608080001_initial.sql` through the Supabase CLI or dashboard migration runner. The migration enables RLS on every exposed table and keeps generated analyses/usage server-written.

## Quality checks

```bash
pnpm typecheck
pnpm test
pnpm build
```

CI runs the same checks on pull requests and main. API tests cover health and malformed input; the shared schema prevents web/API response drift.

## Security and privacy

- Tenant access is membership-scoped and backed by RLS.
- Provider and service-role keys remain server-side.
- Payload size, feedback count, and feedback length are bounded.
- Raw feedback is excluded from structured logs.
- Generated claims are displayed with evidence, not as verified fact.

Before a public launch, add automated tenant-isolation tests, durable distributed rate limiting, account deletion/export jobs, a subprocessor notice, abuse monitoring, dependency scanning, and an external security review.

## Roadmap

1. Private beta: live Supabase sessions, production OpenAI adapter, telemetry, five design partners.
2. Team release: invitations, role UI, durable queue, billing provider, exports.
3. Intelligence layer: connectors, semantic deduplication, similarity search, scheduled digests.
4. Enterprise: SSO, retention controls, regional storage, audit export.

## Repository map

```text
apps/web             React product UI
apps/api             authorization and AI orchestration API
packages/contracts   shared runtime schemas and types
supabase/migrations  Postgres schema and RLS policies
docs                 architecture, data, milestones, deployment
```

## Limitations

Mock analysis is intentionally deterministic and is not a substitute for an evaluation-backed model provider. The starter rate limiter is process-local, billing is modeled rather than charged, email delivery is not configured, and the schema has not undergone a compliance review. Those boundaries are explicit so the project is credible about what is—and is not—production-ready.

## License

MIT
