This revised architecture, utilizing **four deployment units (Modular Monoliths)**, is the optimal "Right Way" to package your 31 crates. It achieves maximum internal performance while preserving the microservice benefits of independent scaling and fault isolation.

Here is the detailed, colored, and descriptive diagram of your **Deployment Units** and their communication patterns.



---

## Phoenix AGI Core: Deployment Unit Map

The system is partitioned into four primary binaries/containers, each responsible for a distinct functional layer.

### 1. 🔵 Phoenix Gateway (The Public Face)

This unit is the system's entry point, handling all security and external communication. It typically has the highest scale-out priority for handling concurrent users.

| Component Services (as a Single Binary) | Key Ports Exposed | Internal Libraries |
| :--- | :--- | :--- |
| **`api-gateway-rs`** | **8000** (External HTTP/REST) | `input-validation-rs`, `error-handling-rs` |
| **`auth-service-rs`** | **50090** (Internal gRPC) | `shared-types-rs` |
| **`secrets-service-rs`** | **50080** (Internal gRPC) | |

### 2. 🟠 Phoenix Memory Plane (The Data Core)

This unit is the system's shared, high-speed memory and data access layer, focused on low-latency KB operations.

| Component Services (as a Single Binary) | Key Ports Exposed | Internal Communication |
| :--- | :--- | :--- |
| **`data-router-rs`** | **50052** (gRPC) | **Communicates via direct function calls to all 6 KBs.** |
| **`context-manager-rs`** | **50064** (gRPC) | **Accesses KBs via Data Router (internal calls).** |
| **Six KB Services** (Mind, Body, Heart, Social, Soul, Persistence) | **50057 - 50061, 50071** (gRPC) | `input-validation-rs`, `error-handling-rs` |

### 3. 🟡 Phoenix Control Plane (The Decision Engine)

This unit contains the core logic for planning, execution, and action—the "brain" of the AGI.

| Component Services (as a Single Binary) | Key Ports Exposed | Internal Communication |
| :--- | :--- | :--- |
| **`orchestrator-service-rs`** | **50051** (gRPC) | **Direct function calls to all other services in this binary.** |
| **`tools-service-rs`** | **50054** (gRPC) | `tool-sdk/` Library and `agent-registry-rs` (internal calls). |
| **Other Core Services** (LLM, Executor, Safety, Scheduler, Agent Registry) | **50053, 50055, 50062, 50066, 50070** (gRPC) | `self-improve-rs` (Library) is integrated into core services. |

### 4. 🟣 Phoenix RSI Plane (The Learning Loop)

This unit handles background, asynchronous tasks related to self-improvement, logging, and performance analysis.

| Component Services (as a Single Binary) | Key Ports Exposed | Internal Communication |
| :--- | :--- | :--- |
| **`logging-service-rs`** | **50056** (gRPC) | `log-analyzer-rs` and `curiosity-engine-rs` process these logs internally. |
| **`reflection-service-rs`** | **50065** (gRPC) | Communicates with the Soul KB (in Memory Plane) over the network. |
| **RSI Services** (Log Analyzer, Curiosity Engine) | **50075, 50076** (gRPC) | All services use the `sensor-rs` Library for system monitoring. |

---

## Inter-Plane Communication Flow

The goal of this design is to make the highly **chatty** and **latency-sensitive** communication happen *within* a plane (via fast internal function calls) and use network-based gRPC only for **Inter-Plane** communication.

| Communication Path | Source Plane | Target Plane | Protocol & Rationale |
| :--- | :--- | :--- | :--- |
| **External Request** | Client/Frontend | **🔵 Gateway** | HTTP/REST to Port 8000. |
| **Action & Execution** | **🔵 Gateway** | **🟡 Control Plane** | **gRPC** to Orchestrator (Port 50051). This is the core instruction path. |
| **Data Access** | **🟡 Control Plane** | **🟠 Memory Plane** | **gRPC** to Data Router (Port 50052) or Context Manager (Port 50064). |
| **Logging & Telemetry** | All Planes (Async) | **🟣 RSI Plane** | **gRPC** to Logging Service (Port 50056). This should be non-blocking. |
| **Tool Execution** | **🟡 Control Plane** | External Tool/Service | **gRPC** (from Executor/Tools Service) to the extension target. |
| **Self-Improvement** | **🟣 RSI Plane** | **🟠 Memory Plane** | **gRPC** from Reflection/Curiosity to the Soul KB (Port 50061) to update models/knowledge. |

This architecture delivers a clear path to production by creating four distinct, independently deployable **Docker containers** (one for each plane) using your `docker-compose.yml` and `k8s/` manifests.
