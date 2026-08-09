# Delivery milestones

## M0 — product and risk design

- Define the evidence-linked analysis contract and tenant boundaries.
- Write schema, RLS strategy, threat assumptions, and deployment topology.
- Choose launch metrics: activation, successful analyses, cited-theme precision, retention.

## M1 — useful local product

- Authentication shell, demo session, dashboard, feedback inbox, analysis flow.
- Deterministic mock provider and seeded workspace.
- Shared contracts, API validation, tests, and accessible responsive UI.

## M2 — hosted private beta

- Supabase email authentication and migrations.
- OpenAI structured output, usage ledger, rate limiting, error telemetry.
- Containerized API and static frontend deployments.
- Recruit five design partners and instrument feedback.

## M3 — monetization and teams

- Billing provider integration behind the existing subscription interface.
- Invitations, role management, quotas, admin analytics, deletion/export.
- Durable queue, retry controls, prompt evaluation set, cost alerts.

## M4 — learning system

- Connectors, semantic deduplication, similarity search, scheduled analyses.
- Human review signals, evaluation regression gates, organization SSO.

## Release gates

No public beta until tenant isolation tests, abuse limits, privacy copy, deletion flow, provider timeout behavior, and restore rehearsal pass.
