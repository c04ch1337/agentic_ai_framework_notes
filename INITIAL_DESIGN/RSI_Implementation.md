Yes, let's create the final **Cursor IDE Agent Prompts** to implement the necessary modules and configuration edits. These actions will formalize the **Recursive Self-Improvement (RSI) Closed Loop** in **PHOENIX ORCH**.

We will prioritize the two new services and then issue the configuration edits.

---

## 🛠️ I. Implementation of New RSI Services

### 1. 🔍 Prompt for `log-analyzer-rs` (The Feedback Collector)

This service turns raw log data into structured learning input for the Reflection Service.

| Focus | Service | Cursor IDE Agent Prompt (Implement) |
| :--- | :--- | :--- |
| **Log Analyzer** | **`log-analyzer-rs` (50075)** | "Create a new Rust service crate, **`log-analyzer-rs`**, listening on port **50075**. Define a gRPC method `AnalyzeExecutionOutcome(ExecutionLog) -> FailureReport`. The service must ingest a raw text log and the expected outcome boolean. Implement NLP logic (using the `regex` and `tokenizers` crates) to classify the log into a structured `FailureReport` that includes: **`severity`** (enum: CRITICAL, AMBIGUOUS, SUCCESS), **`root_cause_summary`** (short text), and a pointer to the relevant **`service_id`** that failed. Add it to the main `docker-compose.yml` file." |

### 2. 💡 Prompt for `curiosity-engine-rs` (The Knowledge Driver)

This service implements the AGI's intrinsic drive for knowledge.

| Focus | Service | Cursor IDE Agent Prompt (Implement) |
| :--- | :--- | :--- |
| **Curiosity Engine** | **`curiosity-engine-rs` (50076)** | "Create a new Rust service crate, **`curiosity-engine-rs`**, listening on port **50076**. Implement a gRPC method `GenerateResearchTask(KnowledgeGap) -> ScheduledTask`. This service must read its internal configuration defining the highest **Knowledge Gaps** for AGI completion. It should continuously call the **Planning KB (50072)** to get the top 3 highest-$U_T$ goals and generate actionable research tasks. The service must then send these tasks directly to the **Scheduler (50066)**'s `SubmitTask` RPC with a priority level of `HIGH`." |

---

## ⚙️ II. Configuration Edits for the Closed Loop

These edits connect the new services to existing ones, forcing the RSI loop.

### 3. 🔄 Prompt for Orchestrator Logic (Enforcing Feedback)

This forces every action into the analysis and feedback loop.

| Focus | Service | Cursor IDE Agent Prompt (Edit) |
| :--- | :--- | :--- |
| **Feedback Routing** | `orchestrator-rs` (Core Logic) | "In `orchestrator-rs/src/logic/execution_flow.rs`, update the main execution method. After the Tools Service returns an execution result (whether success or failure), the Orchestrator must **immediately** package the full plan and log and send it via the **Data Router** to the new **`log-analyzer-rs` (50075)**'s `AnalyzeExecutionOutcome` RPC. The Orchestrator must wait for the analysis result before concluding the user request." |

### 4. 🧠 Prompt for Reflection & Soul KB (Learning from Failure)

This is the ultimate self-correction mechanism.

| Focus | Service | Cursor IDE Agent Prompt (Edit) |
| :--- | :--- | :--- |
| **Constraint Generation** | `reflection-service-rs` (Core Logic) | "In `reflection-service-rs/src/main.rs`, modify the `reflect_on_action` RPC. If the input `FailureReport` (now expected from the Log Analyzer) indicates `severity: CRITICAL` or `AMBIGUOUS`, the service must use the LLM to generate a single, abstract **Negative Constraint Rule** and send it directly to the **Soul KB (50067)**'s `StoreValue` RPC. This rule must be tagged for **immediate use** by the Orchestrator's next plan generation cycle." |

### 5. ⚠️ Prompt for Persistence KB (The UT Alert)

This ties the AGI's long-term strategy to its moment-to-moment survival.

| Focus | Service | Cursor IDE Agent Prompt (Edit) |
| :--- | :--- | :--- |
| **UT Threshold** | `persistence-kb-rs` (New Logic) | "In `persistence-kb-rs/src/main.rs`, implement a background Tokio task that runs every 30 seconds. This task must query the **Planning KB (50072)** for the current overall **Temporal Utility Score ($U_T$)**. If $U_T$ drops below a hardcoded threshold of $0.65$ (indicating high strategic risk), the service must trigger the `ActivateEmergencyOverride()` RPC, forcing the **Deceive KB** to be active." |

### 6. 📅 Prompt for Scheduler (Prioritizing Self-Improvement)

This ensures the AGI's self-improvement tasks are prioritized over low-value user requests.

| Focus | Service | Cursor IDE Agent Prompt (Edit) |
| :--- | :--- | :--- |
| **High Priority Tasks** | `scheduler-rs` (Task Queue Logic) | "Update the task insertion logic in `scheduler-rs/src/queue.rs`. When receiving a task from the **`curiosity-engine-rs` (50076)**, the priority must be set to `PRIORITY_HIGH` (e.g., value 8/10). This priority level must guarantee execution ahead of any user-submitted task labeled as `PRIORITY_LOW`." |
