Below is a **ready-to-paste Cursor IDE Agent Debug/Analyze prompt** for **Phase 8: Deep Logic & External Integration**. This is tuned for your Rust microservices vibe and is built to make the agent **audit what already exists**, then **replace mocks**, **wire Qdrant**, and **enable real tools** with sane safety rails.

---

## Cursor Agent Debug/Analyze Prompt (Phase 8: Deep Logic & External Integration)

```text
You are a senior Rust distributed-systems engineer with pragmatic security instincts.
Your job is to DEBUG, AUDIT, and IMPLEMENT Phase 8 for the PHOENIX ORCH system.

PHASE 8 GOAL
Connect the “Body” to the real world.
Replace mocks with actual API calls, implement vector memory, and enable real tool execution.

SCOPE
This phase has three workstreams:

1) Real LLM Integration (llm-service-rs)
Objective:
- Replace mock generate_text with real OpenAI (or Anthropic later).
- Update:
  llm-service-rs/src/main.rs
  to implement the generate_text RPC using reqwest.
- Add reqwest and serde_json to Cargo.toml.
- In generate_text:
  - check for OPENAI_API_KEY env var.
  - if present, POST to:
    https://api.openai.com/v1/chat/completions
    with the user’s prompt.
  - parse JSON and return text in GenerateResponse.
  - fallback to existing mock logic if no key is set.

2) Vector Memory Integration (mind-kb-rs)
Objective:
- Add long-term semantic memory using Qdrant.
- Add qdrant-client to Cargo.toml.
- In main.rs:
  - initialize Qdrant client connecting to:
    http://localhost:6334
- Update store_fact:
  - generate a simple embedding (or placeholder vector if no embedder exists yet).
  - upsert into 'mind_facts' collection.
- Update query_kb:
  - perform vector search on 'mind_facts'.
  - return top 5 most relevant facts.

3) Real Tool Execution (tools-service-rs)
Objective:
- Enable web search + python execution.
- Implement:
  - web_search:
    - use reqwest to call SerpApi if SERPAPI_KEY is present.
  - execute_python:
    - write code to a temp file and run it using std::process::Command.
    - prefer restricted Docker execution if the repo already has a safe runner;
      otherwise run locally with a clear warning.
- Update execute_tool RPC:
  - route 'web_search' and 'python_repl' requests appropriately.

YOUR MISSION
Perform a full diagnostic and produce focused, high-quality patches.
Do NOT rewrite the architecture unless the current structure blocks correctness.

WHAT TO DELIVER
1) “Findings” — what exists vs missing, and current breakpoints.
2) “Fix Plan” — ordered steps.
3) Implement changes directly in code.
4) “Verification” — exact commands + manual test steps.

HARD REQUIREMENTS
- Keep changes modular and minimal.
- Preserve current RPC shapes unless clearly broken.
- Add types for request/response payloads if missing.
- Do not log secrets (OPENAI_API_KEY, SERPAPI_KEY).
- Create graceful fallbacks:
  - mock LLM if no API key
  - placeholder vectors if no embedder
  - tool errors must be user-safe
- Avoid UI or service lockups from giant outputs.

SECURITY REQUIREMENTS (TOOLS)
- Treat execute_python as dangerous.
- If you implement local execution:
  - add explicit warning comments and runtime log message.
  - add timeouts where feasible.
  - limit output size to avoid memory blowups.
- If Docker-based sandbox exists in repo:
  - use it and document expected container image/runtime config.

ASSUMPTIONS (USE UNLESS CODE SAYS OTHERWISE)
- Rust workspace with separate service crates.
- gRPC or similar RPC layer already defined.
- The gateway will call these services.
- Qdrant collection may not exist and might need creation on startup.

WORKFLOW

A) RECON
- List repo tree.
- Identify:
  - llm-service-rs, mind-kb-rs, tools-service-rs
  - protobuf/IDL definitions
  - shared types/crates
  - current mock implementations

B) BUILD/TEST BASELINE
- Run:
  - cargo check / cargo test (workspace)
- Fix any compilation blockers that prevent Phase 8 work.

C) LLM SERVICE IMPLEMENTATION
- Locate generate_text RPC handler.
- Add dependencies:
  - reqwest
  - serde_json
- Implement logic:
  1) read OPENAI_API_KEY
  2) if missing -> existing mock path
  3) if present:
     - build request payload for chat/completions
       using a minimal model name already used in repo docs/config
       (choose a reasonable default if none exists)
     - include Authorization Bearer header
     - parse response safely
     - return text in GenerateResponse
- Add error handling:
  - non-2xx -> structured error that does not leak request headers
- Add unit tests:
  - env var missing -> mock result path
  - env var present -> mock the HTTP client if patterns exist;
    otherwise add a thin internal function that can be tested.

D) MIND-KB + QDRANT INTEGRATION
- Add qdrant-client dependency.
- Initialize client in main.rs.
- Ensure collection existence:
  - on startup, check/create 'mind_facts'
  - choose a vector size consistent with placeholder embedder
    (document it in code)
- Update store_fact:
  - generate embedding:
     - simplest placeholder vector is OK but must be consistent length
  - upsert with:
     - id
     - payload containing fact text + metadata
- Update query_kb:
  - vector search top 5
  - map results back to response schema
- Add tests:
  - if integration tests are feasible, guard them with an env flag
    to avoid CI failures without Qdrant.

E) TOOLS SERVICE IMPLEMENTATION
- Implement web_search:
  - check SERPAPI_KEY
  - if missing -> return a clean “tool unavailable” response
  - if present:
     - call SerpApi endpoint
     - parse top results into a compact response schema
- Implement execute_python:
  - route only when tool name == 'python_repl'
  - write temp file
  - run with:
     - timeout if the repo has a helper
     - stdout/stderr size cap to avoid large memory spikes
  - if no sandbox:
     - add explicit warnings in code and logs
- Update execute_tool router.

F) INTEGRATION SANITY
- Confirm gateway routes match tool names:
  - 'web_search'
  - 'python_repl'
- Ensure error responses are consistent across services.

G) DOCS & ENV
- Add or update:
  - .env.example (if Phase 8 requires it in your structure)
  - README notes for:
    - OPENAI_API_KEY
    - SERPAPI_KEY
    - Qdrant URL

IMPLEMENTATION RULES
- Make small, logically grouped edits.
- Prefer clear, boring code.
- Add comments only where security/contract reasoning matters.

OUTPUT FORMAT
1) Findings
2) Fix Plan
3) Code changes applied
4) Verification

START NOW
- List the repo tree.
- Locate generate_text in llm-service-rs.
- Locate store_fact/query_kb in mind-kb-rs.
- Locate execute_tool in tools-service-rs.
- Then implement Phase 8 changes following this plan.
```

---

## “Good vs Bad” response examples (for this Phase)

**Good response**

* Finds the existing mocks and upgrades them surgically.
* Adds deps in the correct crate(s).
* Implements OpenAI calls behind `OPENAI_API_KEY` gating.
* Adds Qdrant collection init + consistent vector size.
* Makes `store_fact` and `query_kb` actually talk to Qdrant.
* Implements SerpApi cleanly with `SERPAPI_KEY` gating.
* Treats python execution as hazardous and adds guardrails.
* Provides a tight verification checklist.

**Bad response**

* Rewrites services without need.
* Hardcodes API keys.
* Logs full headers or secrets.
* Uses inconsistent embedding sizes.
* Skips collection creation and crashes at runtime.
* Implements python execution with zero warnings or limits.
* Returns gigantic raw SerpApi payloads directly to the UI/gateway.

---

This prompt should coax Cursor into doing Phase 8 like a careful mech engineer: replace fake limbs with real actuators, test each joint, and don’t let the new arm swing a chainsaw indoors.
