Below is a **ready-to-paste Cursor IDE Agent Debug/Analyze prompt** tailored to your **PHOENIX ORCH Next.js Frontend Dashboard** spec. It assumes the goal is to **inspect an existing implementation** of that prompt (chat UI → `/api/v1/execute`, collapsible Thought Process showing Plan/Routed To/Payload, settings page for API key) and **fix bugs, architecture gaps, or security footguns**.

You can drop this into Cursor’s Agent chat as-is.

---

## Cursor Agent Debug/Analyze Prompt (Next.js Frontend Dashboard)

```text
You are a senior Next.js/TypeScript engineer and security-minded UI architect. 
Your job is to DEBUG, AUDIT, and IMPROVE an existing implementation of the PHOENIX ORCH Frontend Dashboard.

PROJECT CONTEXT
- Repo contains a Next.js frontend inside:
  frontend/
- This UI is a visual interface for the PHOENIX ORCH API Gateway.
- Primary chat endpoint target:
  POST http://localhost:8000/api/v1/execute
- The chat UI must:
  1) Send user messages to the endpoint.
  2) Render assistant responses.
  3) For each assistant message, show a collapsible “Thought Process” section that displays:
     - Plan
     - Routed To
     - Payload
  4) Provide a Settings page that configures an API Key for requests.

YOUR MISSION
Perform a full diagnostic and produce fixes directly in code.
Do not rewrite everything from scratch unless required.
Prefer minimal, high-quality patches.

WHAT TO DELIVER
1) A concise diagnosis of current issues.
2) A prioritized fix plan.
3) Actual code changes to resolve issues.
4) A short verification checklist and how to run it.

HARD REQUIREMENTS
- Keep the app simple and readable.
- Ensure the chat UX is stable and resilient.
- The collapsible Thought Process must work per-message.
- The API Key configuration must actually affect requests.
- Handle large responses safely (avoid UI lockups).
- Do not leak secrets into logs or error toasts.
- Avoid unsafe rendering (no raw HTML injection).

ASSUMPTIONS (IF NOT SPECIFIED IN CODE)
- Use modern Next.js with App Router if the project already uses it.
- Use TypeScript.
- Use fetch for HTTP calls.
- UI framework is whatever exists; if none, keep plain Tailwind or minimal CSS.
- If the user previously stored API keys in localStorage, keep it only if needed,
  but warn about limitations and implement the safest feasible pattern for a client-only app.

STEP-BY-STEP WORKFLOW
A) RECON & STRUCTURE CHECK
- Inspect the tree under frontend/.
- Identify Next.js version, router style (App Router vs Pages), state management approach, and styling.
- Find chat components, API utilities, and settings storage logic.

B) BUILD & RUN FAILURE TRIAGE
- Attempt to build and run the frontend.
- Fix any dependency, TypeScript, lint, or runtime errors blocking dev and prod builds.
- Ensure environment variables and config files are aligned with Next.js conventions.

C) API CONTRACT VALIDATION
- Locate the code that calls the gateway.
- Verify:
  - Method is POST.
  - URL matches http://localhost:8000/api/v1/execute (or appropriately configurable).
  - Headers include the API key when set.
  - Content-Type is correct.
  - Request body matches what the backend expects (infer from current code).
- If request/response types are missing, add types.

D) THOUGHT PROCESS UI VALIDATION
- Trace response handling and confirm metadata extraction.
- Ensure “Plan”, “Routed To”, and “Payload” render in a dedicated collapsible section per assistant turn.
- Fix state bugs:
  - Collapsible toggles must be independent per message.
  - Collapsible should default to closed unless UX clearly suggests otherwise.
- Add safe stringification and truncation for giant payloads.
  - Example: clamp displayed JSON length and add “Copy full JSON” button if appropriate.

E) SETTINGS PAGE & API KEY FLOW
- Verify Settings page exists and is routable.
- Ensure API key:
  - Can be set, updated, cleared.
  - Is validated for empty/whitespace.
  - Is used by the chat request pipeline.
- Implement a clean storage strategy:
  - For client-only: localStorage + in-memory cache with a small abstraction.
  - Avoid exposing it in console logs.
  - Provide a subtle warning in UI that client storage is not fully secure.

F) ERROR HANDLING & UX
- Add user-friendly errors for:
  - Network failure
  - Non-2xx responses
  - Unexpected response schema
- Ensure the UI:
  - Shows loading states.
  - Disables send button during request.
  - Prevents double-submits.
  - Keeps scroll pinned to latest messages.

G) PERFORMANCE & QUALITY
- Ensure no unnecessary re-renders in message lists.
- Memoize heavy metadata formatting.
- Avoid rendering huge JSON by default (collapsed + truncated preview).
- Confirm no hydration errors.

H) SECURITY PASS (FRONTEND-SCOPE)
- Confirm no dangerouslySetInnerHTML usage for assistant content.
- Sanitize any markdown renderer if present.
- Avoid storing API key in querystring.
- Ensure CORS or proxy strategy is consistent with dev usage.

IMPLEMENTATION RULES
- Make changes in small logical edits.
- Add or update:
  - A single API utility module (if missing).
  - Message types/interfaces.
  - A lightweight settings store.
- Keep code style consistent with existing patterns.
- Leave clear comments ONLY where needed.

OUTPUT FORMAT
1) “Findings” (bulleted list).
2) “Fix Plan” (ordered list).
3) Apply code changes.
4) “Verification” with exact commands and manual test steps.

START NOW
- Begin by listing the current file tree under frontend/.
- Identify the chat page/component and the settings page.
- Then proceed with the workflow above.
```

---

### Tiny optional add-on (if you want the agent to be extra surgical)

Paste this line at the top of the prompt:

```text
When you change code, show a brief before/after snippet for the most important files.
```

---

This prompt will push Cursor’s agent to behave like a disciplined forensic engineer: locate the implementation, prove what’s broken, then fix the minimum surface area while hardening your chat + metadata + settings flow.
