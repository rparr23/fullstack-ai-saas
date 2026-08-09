create extension if not exists pgcrypto;

create type public.workspace_role as enum ('owner','admin','member','viewer');
create type public.analysis_status as enum ('queued','running','succeeded','failed');

create table public.profiles (id uuid primary key references auth.users on delete cascade, full_name text, avatar_url text, created_at timestamptz not null default now());
create table public.workspaces (id uuid primary key default gen_random_uuid(), name text not null check (char_length(name) between 2 and 80), slug text not null unique, created_by uuid not null references public.profiles, created_at timestamptz not null default now());
create table public.workspace_members (workspace_id uuid references public.workspaces on delete cascade, user_id uuid references public.profiles on delete cascade, role public.workspace_role not null default 'member', created_at timestamptz not null default now(), primary key(workspace_id,user_id));
create table public.projects (id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces on delete cascade, name text not null, created_by uuid not null references public.profiles, created_at timestamptz not null default now());
create table public.feedback_items (id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces on delete cascade, project_id uuid not null references public.projects on delete cascade, external_ref text, source text not null check(source in ('interview','support','survey','review')), body text not null check(char_length(body) between 8 and 8000), customer_label text, metadata jsonb not null default '{}', occurred_at timestamptz not null default now(), created_at timestamptz not null default now());
create table public.analysis_runs (id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces on delete cascade, project_id uuid not null references public.projects on delete cascade, requested_by uuid not null references public.profiles, status public.analysis_status not null default 'queued', idempotency_key text not null, model text, prompt_version text not null default 'v1', input_items int not null default 0, input_tokens int, output_tokens int, latency_ms int, error_code text, created_at timestamptz not null default now(), completed_at timestamptz, unique(workspace_id,idempotency_key));
create table public.themes (id uuid primary key default gen_random_uuid(), analysis_run_id uuid not null references public.analysis_runs on delete cascade, title text not null, summary text not null, urgency text not null check(urgency in ('critical','high','medium','low')), trend text not null check(trend in ('rising','steady','falling')), recommendation text not null, rank int not null);
create table public.theme_evidence (theme_id uuid references public.themes on delete cascade, feedback_item_id uuid references public.feedback_items on delete cascade, rationale text, primary key(theme_id,feedback_item_id));
create table public.usage_events (id bigint generated always as identity primary key, workspace_id uuid not null references public.workspaces on delete cascade, user_id uuid references public.profiles on delete set null, analysis_run_id uuid references public.analysis_runs on delete set null, event_type text not null, units int not null check(units >= 0), input_tokens int, output_tokens int, created_at timestamptz not null default now());
create table public.subscriptions (workspace_id uuid primary key references public.workspaces on delete cascade, plan text not null default 'trial', status text not null default 'trialing', monthly_limit int not null default 100, current_period_end timestamptz, provider_customer_id text, provider_subscription_id text, updated_at timestamptz not null default now());
create table public.product_feedback (id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces on delete cascade, user_id uuid references public.profiles on delete set null, rating int check(rating between 1 and 5), message text check(char_length(message) <= 2000), created_at timestamptz not null default now());

create index feedback_project_date_idx on public.feedback_items(project_id, occurred_at desc);
create index analysis_workspace_date_idx on public.analysis_runs(workspace_id, created_at desc);
create index usage_workspace_date_idx on public.usage_events(workspace_id, created_at desc);

create or replace function public.is_workspace_member(target_workspace uuid) returns boolean language sql stable security definer set search_path='' as $$ select exists(select 1 from public.workspace_members where workspace_id=target_workspace and user_id=auth.uid()) $$;
create or replace function public.can_manage_workspace(target_workspace uuid) returns boolean language sql stable security definer set search_path='' as $$ select exists(select 1 from public.workspace_members where workspace_id=target_workspace and user_id=auth.uid() and role in ('owner','admin')) $$;

alter table public.profiles enable row level security; alter table public.workspaces enable row level security; alter table public.workspace_members enable row level security; alter table public.projects enable row level security; alter table public.feedback_items enable row level security; alter table public.analysis_runs enable row level security; alter table public.themes enable row level security; alter table public.theme_evidence enable row level security; alter table public.usage_events enable row level security; alter table public.subscriptions enable row level security; alter table public.product_feedback enable row level security;

create policy "read own profile" on public.profiles for select using(id=auth.uid());
create policy "read member workspaces" on public.workspaces for select using(public.is_workspace_member(id));
create policy "read memberships" on public.workspace_members for select using(public.is_workspace_member(workspace_id));
create policy "manage memberships" on public.workspace_members for all using(public.can_manage_workspace(workspace_id)) with check(public.can_manage_workspace(workspace_id));
create policy "read projects" on public.projects for select using(public.is_workspace_member(workspace_id));
create policy "write projects" on public.projects for all using(public.can_manage_workspace(workspace_id)) with check(public.can_manage_workspace(workspace_id));
create policy "read feedback" on public.feedback_items for select using(public.is_workspace_member(workspace_id));
create policy "write feedback" on public.feedback_items for all using(public.is_workspace_member(workspace_id)) with check(public.is_workspace_member(workspace_id));
create policy "read analyses" on public.analysis_runs for select using(public.is_workspace_member(workspace_id));
create policy "read themes" on public.themes for select using(exists(select 1 from public.analysis_runs r where r.id=analysis_run_id and public.is_workspace_member(r.workspace_id)));
create policy "read evidence" on public.theme_evidence for select using(exists(select 1 from public.themes t join public.analysis_runs r on r.id=t.analysis_run_id where t.id=theme_id and public.is_workspace_member(r.workspace_id)));
create policy "read usage" on public.usage_events for select using(public.is_workspace_member(workspace_id));
create policy "read subscription" on public.subscriptions for select using(public.is_workspace_member(workspace_id));
create policy "submit product feedback" on public.product_feedback for insert with check(user_id=auth.uid() and public.is_workspace_member(workspace_id));
