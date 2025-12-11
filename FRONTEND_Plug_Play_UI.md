You want a **plug-and-play frontend extension** that snaps onto the AGI Core like a Lego brick, and a **document template** you can hand to a UI designer so they don’t have to guess how the brain works.

Let’s do two things:

1. A **process / outline**: how to go from AGI CORE → working UI extension → marketplace-ready.
2. A **“Frontend Extension Design Brief” template** you can reuse for every new UI extension and give straight to designers/devs.

---

## 1. Process / Outline: From AGI CORE to UI Frontend Extension

Assuming you already have:

* 30+ Rust crates → packaged into one or more binaries (monolith or planes)
* gRPC/HTTP APIs exposed via `api-gateway-rs`
* CLI in progress or planned (`phoenixctl`)

### Step 1 – Freeze the AGI Core “Frontend Surface”

You don’t need the whole AGI core spec; you just need the **“frontend surface”**:

* Which APIs are “public” to UI?

  * Orchestrator: chat, tasks, plan status
  * Memory: search, timeline, “what did I just learn?”
  * Playbook / RSI: “what strategies exist?”, “what did Phoenix learn today?”
  * Tools / Extensions: list tools, trigger tool actions

Deliverable: **“Core Frontend API Sheet”**:

* List of endpoints / RPCs + request/response shapes.
* Auth model (tokens, sessions).
* Error patterns (codes, messages).

This becomes a fixed section in the template.

---

### Step 2 – Decide What This Specific Extension *Is*

Each UI extension should answer:

* What domain? (Security, Finance, Personal Twin Dashboard, etc.)
* Who’s using it? (SOC analyst, CFO, End-user, Architect)
* What AGI entities does it visualize/drive?

  * Tasks? Tools? Memory? Playbook? All of the above?

Deliverable: **Extension Concept + Personas** (goes into the template).

---

### Step 3 – Map Extension Views → AGI Core APIs

For this extension:

* List the **screens / panels / widgets**:

  * e.g. “Phoenix Memory Explorer”, “Task Timeline”, “RSI Insights Panel”.
* For each view, map:

  * Which API endpoints it reads.
  * Which actions it triggers (chat, task start, tool runs).

This guarantees the designer doesn’t invent UI that requires impossible backend magic.

Deliverable: **View / API Matrix** in the template.

---

### Step 4 – Define Extension Integration Contract (Plugin Side)

For **plug-and-play wiring**, you want each frontend extension to expose:

* A **plugin manifest** (e.g. `phoenix-plugin.json`).
* One or more **entrypoints** (routes or components).
* A set of **required capabilities/scopes** (e.g. `tasks:read`, `memory:read`, `tools:invoke:security`).

Your PWA host (Phoenix Console) will:

* Read manifest.
* Register routes/panels.
* Enforce permissions using AGI Core’s auth/safety services.

Deliverable: **Plugin Manifest Spec + example** in the template.

---

### Step 5 – UX States, Errors, and Telemetry

The extension needs to:

* Render **loading / empty / error states** in a way that matches the rest of Phoenix.
* Surface key AGI signals:

  * Agent status (awake, degraded, recovering).
  * Memory hits / misses.
  * Safety denials (when safety-service says “nope”).

Deliverable: **States & Error Handling** and **Telemetry expectations** in the template.

---

### Step 6 – Build, Wire, and Test as a True Client

When the designer/dev builds the UI:

* They use only:

  * The **Core Frontend API Sheet**
  * The **Phoenix frontend SDK** (TS/Rust client, if you generate one)
* They **never** talk directly to internal AGI services—only through `api-gateway-rs`.

Test:

* Against local monolith (dev mode).
* Then against plane binaries (prod shape) with same API contracts.

---

### Step 7 – Prepare for Marketplace

To make it marketplace-ready:

* Ensure the extension:

  * Has a manifest with version, permissions, and compatibility (“Requires Phoenix UAAT ≥ vX.Y”).
  * Respects auth/permissions and doesn’t assume admin power.
  * Emits standard telemetry (for billing, adoption, errors).

Deliverable: **Marketplace Metadata** section in the template.

---

## 2. Reusable Template Doc for a UI Frontend Extension

Here’s a full **Markdown template** you can hand to a designer/dev.

You can treat it as:

> **“Phoenix UAAT Frontend Extension Design Brief”**

Fill in the `<TODO>` blocks for each specific extension. The **AGI CORE sections** can be mostly copy-pasted across all extensions.

---

````markdown
# 🔥 Phoenix UAAT – Frontend Extension Design Brief

> Extension Name: `<TODO: e.g. Phoenix Security Operations Console>`  
> Version: `v0.1-draft`  
> Owner: `<TODO: team / person>`  
> AGI Core Version Target: `UAAT Core vX.Y`

---

## 1. Purpose & Context

### 1.1 Extension Summary

**What this extension does (one paragraph):**

`<TODO: Describe domain & main value.>`

Example: “A Security Operations Console that visualizes incidents, threat memory, and Phoenix’s recommended response actions.”

### 1.2 Target Users & Personas

- **Primary user:** `<TODO: e.g. SOC Analyst, Engineering Manager, End-User>`
- **Secondary user(s):** `<TODO>`
- **Skill level:** `<TODO: e.g. technical, semi-technical, non-technical>`

What problems it solves for them:

- `<TODO: bullet 1>`
- `<TODO: bullet 2>`
- `<TODO: bullet 3>`

---

## 2. AGI CORE Integration Overview

> **This section is shared across all extensions and maintained by the AGI CORE team.**

### 2.1 Core Frontend API Surface

**Gateway Base URL (dev):**

- `http://localhost:8000` (monolith/planes behind this)

**Key API groups exposed to frontends:**

- **Orchestrator**
  - `POST /v1/chat` – send a message / task to the orchestrator
  - `GET /v1/tasks/{task_id}` – get task status & result
- **Memory**
  - `POST /v1/memory/search` – semantic search (mind-kb)
  - `GET /v1/memory/episodes?agent_id=...` – list recent episodes
- **Playbook / RSI**
  - `GET /v1/playbook/strategies` – list strategies
  - `GET /v1/rsi/insights?agent_id=...` – summarized insights from log-analyzer & curiosity
- **Tools / Extensions**
  - `GET /v1/tools` – available tools
  - `POST /v1/tools/execute` – invoke a tool

> **Note:** Frontend uses the Phoenix Client SDK (TypeScript) which wraps these APIs.

### 2.2 Auth & Permissions Model

- **Auth method:** `<TODO: JWT / session cookie / API token>`
- **Permission scopes available to frontends:**
  - `tasks:read`
  - `tasks:write`
  - `memory:read`
  - `playbook:read`
  - `tools:invoke`
  - `admin:*` (restricted)

Extensions request scopes in their manifest; the host app enforces them and passes tokens to the gateway.

---

## 3. Extension Scope & Boundaries

### 3.1 What This Extension Can Access

**This extension requires the following scopes:**

- `<TODO: e.g. tasks:read, tasks:write, memory:read, tools:invoke>`

**AGI entities it interacts with:**

- [ ] Orchestrator (chat/task)
- [ ] Memory (mind-kb / persistence-kb)
- [ ] Playbook / RSI
- [ ] Tools / External APIs
- [ ] Safety / Policy decisions

Describe **how** it uses them:

`<TODO: short narrative.>`

### 3.2 Out-of-Scope

To avoid scope creep, explicitly list what this extension **does not** do:

- `<TODO: e.g. no user management, no license management, no marketplace UI>`

---

## 4. UI Views & Components

### 4.1 Views

List each major screen/view.

**View 1 – `<TODO: e.g. Incident Overview>`**

- **Description:** `<TODO>`
- **Primary data sources (APIs):**
  - `<TODO: e.g. GET /v1/tasks?type=incident>`
  - `<TODO: e.g. GET /v1/memory/search>`
- **Key UI elements:**
  - `<TODO: e.g. incidents table, severity badges, Phoenix recommendation panel>`

**View 2 – `<TODO: e.g. Phoenix Insight Panel>`**

- **Description:** `<TODO>`
- **Primary data sources:**
  - `<TODO: GET /v1/rsi/insights>`
- **Key UI elements:**
  - `<TODO>`

*(Repeat for all views.)*

### 4.2 Shared Components

List reusable components and where they come from:

- **Phoenix Header / Navigation:** Provided by host app.
- **Phoenix Agent Status Widget:** Provided by host (`useAgentStatus()` hook).
- **Extension-specific widgets:** `<TODO: list + description>`

---

## 5. Interaction Flows

### 5.1 Primary Flow – “User takes action through Phoenix”

Example: “User selects an incident, Phoenix proposes plan, user approves, executor runs tools.”

Describe as steps:

1. `<TODO: User selects X in UI>`
2. `<TODO: UI calls /v1/tasks/{id}>`
3. `<TODO: UI displays Phoenix’s recommended actions>`
4. `<TODO: User clicks ‘Approve & Run’>`
5. `<TODO: UI calls /v1/tools/execute with payload>`
6. `<TODO: UI polls /v1/tasks/{task_id}>` and updates the UI.

Optionally add a small sequence diagram (Mermaid):

```mermaid
sequenceDiagram
    participant U as User
    participant FE as Frontend Extension
    participant GW as API Gateway
    participant OR as Orchestrator
    participant EX as Executor

    U->>FE: Approve Action Plan
    FE->>GW: POST /v1/tools/execute
    GW->>OR: ExecutePlan(...)
    OR->>EX: Run tools
    EX-->>OR: Results
    OR-->>GW: Updated Task Status
    FE->>GW: GET /v1/tasks/{id}
    GW-->>FE: Task status + result
    FE-->>U: Show completion status
````

### 5.2 Error / Edge Cases

For each primary flow, specify:

* What if AGI is **offline / degraded**?
* What if **safety-service** denies the action?
* What if the request **times out**?

Example:

* Safety denial: show an inline alert:

  * “Phoenix safety policies blocked this action. Reason: `<reason_from_API>`”

---

## 6. States, Loading, and Empty Views

For each view, define:

* **Loading state**
* **Empty state** (no data yet)
* **Error state**
* **Degraded state** (partial data)

Example structure:

**View: Incident Overview**

* Loading: `<TODO: skeleton table, spinner>`
* Empty: “No incidents match your filters.”
* Error: Show error banner with retry button.
* Degraded: If RSI data is missing, show incidents but hide Phoenix advice with a “Phoenix is still thinking…” message.

---

## 7. Visual & UX Guidelines

### 7.1 Styling & Theming

* **Primary theme:** Phoenix Fire / Ashen Guard (dark, neon, etc.)
* **Layout constraints:**

  * Must work in right-side “panel” layout AND full-screen route.
  * Responsive: `<TODO: min width / max width>`

### 7.2 Accessibility

* Text contrast: follow WCAG AA or better.
* Keyboard navigation: all actions reachable via keyboard.
* Screen reader labels for:

  * Critical actions (approve, reject, escalate).
  * Important indicators (severity, status).

---

## 8. Telemetry & Observability (Frontend Side)

What events should this extension emit back to the AGI/logging stack?

Examples:

* `ui.extension.loaded`
* `ui.extension.action_clicked`
* `ui.extension.error_displayed`
* `ui.extension.flow_completed`

For each event:

* **Name:** `<TODO>`
* **When fired:** `<TODO>`
* **Payload:** `<TODO: keys & types>`

These help `log-analyzer-rs` & `curiosity-engine-rs` understand how humans are using the UI.

---

## 9. Plug-and-Play Wiring (Plugin Manifest)

This is the formal contract with the host Phoenix Console.

### 9.1 Plugin Manifest

Sample manifest for this extension:

```json
{
  "id": "phoenix.<TODO-extension-id>",
  "name": "<TODO Friendly Name>",
  "version": "0.1.0",
  "description": "<TODO short description>",
  "entry": "/plugins/<TODO-id>/index.js",
  "routes": [
    {
      "path": "/extensions/<TODO-id>",
      "label": "<TODO Menu Label>",
      "icon": "<TODO Icon Name>",
      "requiresAuth": true
    }
  ],
  "scopes": [
    "tasks:read",
    "tasks:write",
    "memory:read",
    "tools:invoke"
  ],
  "compatibleCoreVersions": [
    ">=1.0.0"
  ]
}
```

### 9.2 Host App Integration

Host Phoenix Console will:

* Load the manifest from the **Marketplace / Extension Registry**.
* Verify:

  * Extension is licensed for this tenant.
  * Requested scopes are allowed for this user/org.
* Dynamically mount:

  * Routes in the main router.
  * Menu items in the sidebar or “Extensions” section.

No hard-coded wiring: all via manifest + SDK.

---

## 10. Implementation Notes for Developers

* **Recommended stack:** React + TypeScript (or `<TODO stack>`).
* **SDK:** `@phoenix/uaat-client`:

  * `useAgentStatus()`
  * `useTasks()`
  * `useMemorySearch()`
  * `usePlaybook()`
* **Testing targets:**

  * Local monolith (`phoenix-core-monolith`).
  * Plane binaries (`phoenix-control-plane`, `phoenix-memory-plane`, etc.) behind the same gateway.

---

## 11. Open Questions / TBD

* `<TODO: e.g. should this extension be visible to non-admin users?>`
* `<TODO: any extra metrics or logs needed?>`
* `<TODO: future version features?>`

```

---

That template is the thing you hand to a UI designer/dev.

You fill in the **AGI CORE parts once**, then each new extension gets its own copy with the **scope, views, flows, and plugin manifest** filled in. Over time, this becomes the contract that keeps your frontends from doing weird side quests your core was never designed for.
::contentReference[oaicite:0]{index=0}
```
