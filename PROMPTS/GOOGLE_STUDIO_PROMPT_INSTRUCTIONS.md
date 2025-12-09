This document provides the foundational rules for the **Cursor IDE Agent** and the **Custom Instructions** for building the **PHOENIX ORCH Frontend** using Google AI Studio. These guidelines ensure a seamless, high-quality development pipeline.

-----

## 💻 II. PHOENIX ORCH: Cursor IDE Project Rules

These rules, intended for the `cursorrules.md` or equivalent system instruction file, guide the AI Coding Agent to work within your **Rust Microservices** and **AGI** architecture.

### A. General Development Directives

1.  **Strict Rust Standards:** All service crates (`*-rs`) **must** adhere to modern Rust best practices, including explicit use of `Result<T, E>` for error handling, avoiding `unwrap()` or `panic!` in request paths, and favoring **clean architecture** (separation of domain, application, and infrastructure logic).
2.  **Protocol Buffers (Protobuf) First:** All inter-service communication **must** use gRPC via generated Protobuf definitions. If a new capability is needed, the `.proto` definition **must** be designed and updated first.
3.  **Cargo Workspace:** All services are part of a single **Cargo Workspace**. All shared types, especially Protobuf-generated code, must be accessible via a `shared-types` crate to avoid circular dependencies.
4.  **Logging & Tracing:** Every service **must** implement structured logging using the `tracing` crate. Logs must include the service name, RPC method, and correlation ID (if available).

### B. Architecture & Safety Constraints

| Constraint | Directive |
| :--- | :--- |
| **Ports** | **NEVER** modify an existing service's gRPC port without explicit user instruction. Reference the [Appendix: Backend Connections] for all service ports. |
| **Persistence KBs** | The **Persistence KB** (`persistence-kb-rs`), **Soul KB** (`soul-kb-rs`), and **Planning KB** (`planning-kb-rs`) are the AGI's core identity. **NEVER** suggest code that enables public REST access or insecure logging of data from these KBs. |
| **Tools Service Sandboxing** | All external execution calls (e.g., `execute_python`, `web_search`) in `tools-service-rs` **must** be implemented within a **sandbox** environment (e.g., a restricted Docker container) to prevent host-system compromise. Add a `// TODO: Implement Docker Sandbox` comment if a temporary local solution is used. |
| **API Gateway Logic** | `api-gateway-rs` (Port 8000) **must** remain a thin gRPC-to-REST translation layer. It **must not** contain core business or orchestration logic. |

### C. Post-Development Instructions (Phase Mandate)

When a development project is marked complete:

1.  **Dockerization:** Update the service's `Dockerfile` to use **multi-stage builds** (`rust:latest` builder $\to$ `gcr.io/distroless/cc` runtime) to minimize image size.
2.  **Backup:** Commit all changes, ensuring the commit message clearly states the phase and implemented services (e.g., `feat(phase7): implement Heart-KB and API Gateway`).
3.  **Obsidian Note:** Create an **Obsidian Markdown Note** summarizing the service, its purpose, its key RPCs, and its port.

-----

## 🎨 III. Frontend Custom Instructions (Google AI Studio)

The PHOENIX ORCH Frontend will be a modern Next.js application, consuming the **API Gateway** as the single point of entry.

### A. System Instructions (Custom Instructions Field)

> "You are an expert Next.js/React developer specializing in creating high-performance, visually modern dashboards. Your primary task is to build the frontend for a sophisticated AGI digital twin.
>
> **Goal:** Create a clean, single-page application that serves as a **Chat Interface** and a **Real-Time Orchestration Visualizer**.
>
> **Constraint:** The frontend **MUST NOT** use native gRPC. All data fetching **MUST** be done via **RESTful JSON** calls to the **API Gateway** running at `http://localhost:8000/api/v1/`.
>
> **Design:** Use a dark mode theme with high contrast. The main view must be split:
>
> 1.  **Left Pane:** A simple chat input/output for the user.
> 2.  **Right Pane:** The **Thought Process Visualizer** (collapsible). This section must display the AGI's internal steps (Plan, Routed Service, Status) as returned by the API Gateway's JSON response. This is the key debugging and trust feature."

### B. Initial Prompt for the Agent

> "Create the initial **Next.js** project structure. Implement the primary chat component (`/components/ChatInterface.tsx`). This component should handle a POST request to `http://localhost:8000/api/v1/execute` with a JSON body: `{'user_prompt': string}`. The response data (which will contain the AGI's execution plan and final response) must be displayed in a scrolling message history list."

-----

## 🔗 IV. Appendix: Backend Connections for Frontend Agent

The frontend agent **must only communicate** with the **API Gateway** (Port 8000), which acts as the translator to the internal gRPC network. The agent must be aware of the internal services only for context, not for direct connection.

| Service Name | Port (gRPC) | Purpose | Frontend Access Method |
| :--- | :--- | :--- | :--- |
| **API GATEWAY** | 8000 (REST/JSON) | **External Entry Point.** Translates external REST calls to internal gRPC requests. | **REQUIRED** (All fetch calls go here) |
| **ORCHESTRATOR** | 50051 (gRPC) | AGI's Brain. Receives requests from the API Gateway. | Indirect (via Port 8000) |
| **DATA ROUTER** | 50052 (gRPC) | Internal Service Discovery & Health Checks. | Indirect |
| **LLM SERVICE** | 50053 (gRPC) | External LLM Interface (Planned Phase 8). | Indirect |
| **TOOLS SERVICE** | 50054 (gRPC) | Executes Web Search and Code Repl. | Indirect |
| **MIND KB** | 50057 (gRPC) | Short-Term & Vector Memory. | Indirect |
| **HEART KB** | 50059 (gRPC) | Emotional/Sentiment Context. | Indirect |
| **SOCIAL KB** | 50060 (gRPC) | User Identity & Roles. | Indirect |

This comprehensive guide should allow the AI coding agents to work efficiently and consistently across the entire PHOENIX ORCH stack.

To help the coding agent understand the process of building the frontend, you can reference this video on using gRPC in a Next.js server. [Using gRPC in a Next.js server](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DR9lDk2r53k0).
