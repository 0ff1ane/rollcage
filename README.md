# RollCage

A WIP (soft)port of https://gitlab.com/glitchtip/glitchtip-backend
to try a new architecture and learn Rust.
Not planned to be a SaaS product

* GlitchTip is an open source, Sentry API compatible error tracking platform

  
## Planned Architecture

<img width="1067" height="623" alt="Screenshot 2026-03-26 at 22 15 41" src="https://github.com/user-attachments/assets/f644d015-8aa8-41d3-9964-c1b5fd66fb6a" />

### ClickHouse

Use ClickHouse for most of the heavy lifting
* Grouping by project_id, release, environment
* Use materialized views to group issues by group_name/search_vector with SummingMergeTree and AggregatingMergeTree(issue_count, uniq_releases, uniq_environment)
* Use materialized views to populate 5min, 1hour, 12hour issues

### Kafka + Rust

Since the majority of traffic hits the DSN endpoint, 
we use Rust and Kafka to optimize the handling and parsing of Sentry Events


## Implementation Phases

### Phase 1

Simple POC in Elixir/Phonenix

* CRUD for users, organizations, teams, projects, uptime monitors
* Basic token based auth
* Uptime monitors using DynamicSupervisor
* Basic Sentry event handler/parser for a simple javascript(or python) payloads
* Add ecto_ch to save data into ClickHouse
* Svelte Frontend for signup, login, add/edit/view organizations/teams/projects
* Script to send events to a valid DSN endpoint
* Svelte Frontend to view issues and issue groups with filters(releases, tags, environments)


### Phase 2

Implement a basic

[rust-http-listener] <---> [Kafka] <---> [rust-event-handlers] <---> [ClickHouse DB]

event driven service to handle events and envelopes

* Keep it simple, handle only one type of event(js or python)
* Check for valid DSN from Elixir backend with caching on Rust side
* Rust service is not responsible for managing schema/migrations

### Phase 3

* Implement charts/dashboards with polling for updates
* Handle more event types


## Differences with GlitchTip

* This is just an experimental port, parity is not planned
* Table schema may not follow glitchtip, some tables like organizations_ext are merged with organizations
* Other tables may be optimized away on the Postgres side or handled by ClickHouse
