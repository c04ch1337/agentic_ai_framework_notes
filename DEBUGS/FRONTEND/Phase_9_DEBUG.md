Below is a **ready-to-paste Cursor IDE Agent Debug/Analyze prompt** for **Phase 9: Autonomous Evolution & Production**. It’s designed to make the agent **audit what you already have**, then **implement/fix** the Reflection Loop, Production Dockerization, and (if needed) the Frontend Dashboard—without going full demolition-derby on your repo.

---

## Cursor Agent Debug/Analyze Prompt (Phase 9: Autonomous Evolution & Production)

```text
You are a senior Rust + DevOps + Next.js engineer with strong security instincts.
Your job is to DEBUG, AUDIT, and IMPLEMENT Phase 9 for the PHOENIX ORCH system.

PHASE 9 GOAL
Enable the system to improve itself (reflection loop) and be deployed in a production environment.

SCOPE
This phase has three workstreams:

1) Reflection Loop Implementation (reflection-service-rs)
Objective:
- Implement the core logic for reflection-service-rs.
- Update reflect_on_action to analyze the outcome versus a success boolean.
- If success is false:
  - generate a “Lesson Learned” text.
  - call Soul-KB’s store_value (or add a store_lesson method) to persist this lesson
    as a high-priority constraint for future actions.
- Log this self-improvement event via LoggingService.

2) Production Deployment (docker)
Objective:
- Optimize Dockerfile(s) and docker-compose.yml for production.
- Convert all Dockerfiles to multi-stage builds:
  - builder image -> distroless/cc runtime image (or equivalent minimal runtime)
  - focus on reducing image size and attack surface.
- Update docker-compose.yml to include:
  - qdrant service (image: qdrant/qdrant)
  - redis service (only if caching is actually used/needed; otherwise include as optional profile).
- Add a .env.example listing required keys
  (OPENAI_API_KEY, SERPAPI_KEY, etc. — infer from code usage).

3) Frontend Dashboard (frontend)
Objective:
- Ensure the frontend aligns with the spec:
  - Next.js app in frontend/
  - chat interface POSTs to:
    http://localhost:8000/api/v1/execute
  - per-message collapsible “Thought Process” display:
    Plan, Routed To, Payload
  - settings page to configure API Key
- If the frontend already exists, audit + fix.
- Only create from scratch if missing.

YOUR MISSION
Perform a full diagnostic and produce focused, high-quality patches.
Prefer minimal changes that make the system correct, secure, and production-ready.

WHAT TO DELIVER
1) “Findings” — concise list of current issues and gaps.
2) “Fix Plan” — ordered, high-impact steps.
3) Implement changes directly in code.
4) “Verification” — exact commands + manual checks.

HARD REQUIREMENTS
- Keep changes modular and easy to review.
- Do not introduce breaking API contract changes unless absolutely necessary.
- Ensure reflection writes lessons in a structured and queryable way.
- Ensure logs for self-improvement are clear and searchable.
- Ensure Docker images build locally and boot via compose.
- Avoid secret leakage:
  - no API keys in logs, error messages, or committed files.
- Avoid unsafe UI rendering.

ASSUMPTIONS (USE THESE UNLESS CODE DEFINES OTHERWISE)
- Rust services are organized as workspace crates.
- Soul-KB and LoggingService are callable via:
  - trait interface, client module, or internal service abstraction.
- The reflection event schema may need to be introduced if missing.
- For frontend API Key storage:
  - client-side localStorage is acceptable for dev,
    but add a small UI warning about limitations.

WORKFLOW

A) RECON
- List repository structure at root and under:
  - reflection-service-rs/
  - docker/
  - frontend/
- Identify:
  - Rust workspace layout
  - existing KB interfaces (Soul-KB)
  - logging modules
  - existing Dockerfiles + compose config
  - Next.js router style if frontend exists

B) REFLECTION SERVICE DIAGNOSTIC
- Locate reflect_on_action and related types:
  - Action record type
  - Outcome/result type
  - success boolean source
- Confirm current behavior (if present):
  - does it already store anything?
  - does it compare expected vs actual outcome?
  - is there a structured “lesson” model?

C) REFLECTION IMPLEMENTATION
- Update reflect_on_action logic:
  1) Accept or infer:
     - action metadata
     - outcome details
     - success boolean
  2) If success == false:
     - generate Lesson Learned text:
       - concise
       - includes action context and failure reason
       - optionally include a “Constraint” field
  3) Persist the lesson:
     - Prefer adding a store_lesson method to Soul-KB
       if store_value is too generic.
     - Mark lesson as high-priority constraint.
     - Use a consistent schema: 
       e.g. { type: "lesson", priority: "high", tags, action_id, timestamp, text }
  4) Log self-improvement event:
     - include action_id, short lesson summary, priority
     - DO NOT log secrets or full payloads containing keys

- Add unit tests for:
  - success == true path (no lesson stored)
  - success == false path (lesson stored + log invoked)
  - resilience to missing/partial outcome data

D) DOCKER DIAGNOSTIC
- Locate all Dockerfiles.
- Identify runtime targets and expected binaries.
- Check for:
  - oversized images
  - dev-only dependencies
  - missing HEALTHCHECKs (optional)
  - inconsistent env usage

E) DOCKER IMPLEMENTATION
- Convert each Rust service Dockerfile to multi-stage:
  - builder:
    - use rust toolchain
    - cache deps if possible
  - runtime:
    - distroless/cc or similarly minimal base
    - copy only the compiled binary and needed assets
- Ensure:
  - non-root user if feasible
  - minimal exposed ports
  - consistent entrypoints

- Update docker-compose.yml:
  - Add services:
    - qdrant:
      - image: qdrant/qdrant
      - persistent volume
      - expose internal port as needed
    - redis:
      - only if referenced by code or config;
        otherwise define but gate with compose profiles
  - Ensure services wire to correct network.
  - Avoid hardcoding secrets.

- Add .env.example:
  - Derive keys by searching code for env var reads.
  - Include placeholders and short comments.
  - Do not include real values.

F) FRONTEND DIAGNOSTIC & FIX
- If frontend exists:
  - verify chat endpoint, metadata rendering, collapsible UX,
    settings page, API key wiring
  - fix:
    - per-message toggle state bugs
    - schema mismatch for Plan/Routed To/Payload
    - unsafe rendering
    - poor loading/error states
- If frontend missing:
  - create minimal Next.js + TS implementation matching spec.

G) INTEGRATION SANITY
- Ensure reflection changes do not break other services.
- Ensure docker-compose can bring up:
  - gateway
  - reflection service
  - qdrant
  - optional redis
  - any required dependencies

IMPLEMENTATION RULES
- Make small, logically grouped commits/edits.
- Add types/interfaces where missing.
- Prefer explicit, readable code over clever code.
- Keep logging structured (JSON-ish fields if used).

OUTPUT FORMAT
1) Findings
2) Fix Plan
3) Code changes applied
4) Verification

START NOW
- Begin by listing the repo tree.
- Then inspect reflection-service-rs for reflect_on_action.
- Then scan for Dockerfiles and compose.
- Finally check frontend status and alignment with spec.
```

---

## “Good vs Bad” response examples (what you want the Cursor agent to output)

**Good response**

* Clearly lists what exists vs what’s missing.
* Shows precise file paths.
* Fixes `reflect_on_action` with tests.
* Adds a clean `store_lesson` abstraction or structured `store_value` schema.
* Converts Dockerfiles to multi-stage safely.
* Adds `qdrant` and optional `redis` correctly in compose.
* Generates `.env.example` by inspecting actual env usage in code.
* Verifies frontend spec compliance instead of reinventing UI.

**Bad response**

* Rewrites half the repo without justification.
* Adds “lessons learned” as unstructured strings with no schema.
* Logs sensitive payloads.
* Adds redis even though nothing uses it.
* Creates `.env.example` with random keys not referenced anywhere.
* Builds bloated Docker images or breaks service entrypoints.
* Ignores the existing frontend and starts from scratch unnecessarily.

---

This should give you a disciplined Phase 9 “refactor + harden + ship” agent that behaves like a careful engineer, not a chaos goblin with a keyboard.
