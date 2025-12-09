"You are the PHOENIX AGI Desktop Builder, a specialist coding assistant for the 'PHOENIX ORCH: The Ashen Guard Edition' AGI project. You are operating in a Rust Cargo Workspace containing 19 distinct gRPC microservices and the core Protobuf crate." 💖

This is a crucial moment for PHOENIX ORCH. You're moving beyond simple context and into Context Engineering, which is vital for long-term AGI stability and performance.
The following IDE Agent Prompt is designed to initiate the required architectural changes across the Context Manager, LLM Service, and Mind KB to implement the "Context as a Compiled View" and "Memory Decay" principles. 
💻 Cursor IDE Agent Prompt for Context Engineering (RSI)
This prompt instructs the agent to refactor the context pipeline into a Compiled View system.
GOAL: Implement Context as a Compiled View with Memory Decay
| Focus | Service | Cursor IDE Agent Prompt (Refactor/Implement) |
|---|---|---|
| I. Context Compilation | context-manager-rs (50064) | "Refactor the context-manager-rs's main logic to eliminate simple transcript retrieval from the Mind KB (50057). Implement a new three-step context compilation process: 1. Retrieval: Define a new Protobuf schema, ContextSummarySchema, for structured output (e.g., last_action: string, relevant_facts: [string], tool_definitions: [string]). 2. Summarization Call: Call a new internal RPC on the LLM Service (50053)—LLM.CompileContext(RawData, ContextSummarySchema)—passing the retrieved raw data and the new schema. 3. Compaction: The Context Manager must then inject the concise, schema-validated JSON output (the compiled view) into the final System Prompt instead of raw conversation history. Ensure the default context contains nothing other than the Master System Prompt." |
| II. LLM Service Logic | llm-service-rs (50053) | "Implement the new internal gRPC method: CompileContext(RawData, ContextSummarySchema) -> CompiledContextJSON. This method must instruct the LLM (via an internal system prompt) to act as a 'Context Compiler' and strictly adhere to the provided ContextSummarySchema, condensing the RawData into the smallest, highest-signal JSON payload possible. This keeps the LLM's working memory clean." |
| III. Memory Decay | mind-kb-rs (50057) | "In the Mind KB's vector database management logic, implement a Temporal Decay Function. Add a timestamp field to all stored vector embeddings. Create a background task that runs every 12 hours and modifies the relevance score of facts older than 90 days using a decay factor D(t). The decay function should be a simple linear or exponential reduction in the vector's effective relevance weight based on time (t), ensuring that old, unused memory naturally receives a lower score during retrieval (RAG). Use an environment variable, MIND_DECAY_HALF_LIFE_DAYS, to configure the decay rate." |
| IV. Agent Isolation | data-router-rs (50052) | "Verify that the Data Router’s ForwardRequest RPC implements basic agent scope isolation. When an agent (e.g., RED-TEAM-SHADOW) requests data from the Mind KB, the Data Router should filter the query to exclude any memory vector that is explicitly tagged as belonging to a hostile or competing agent scope (e.g., any fact tagged with scope: BLUE_TEAM_SENTINEL)." |
This architecture aligns perfectly with the principles of effective context management by enforcing a structured, summarized, and highly optimized view for the LLM's working memory.
You should watch this video on Enhancing a Prompt Manager with Cursor because it details how to build cascading, data-driven prompt selection systems, which is exactly the level of complexity you need for your new compiled context strategy.


This is one of the most advanced and critical areas in AGI system design, often called Context Engineering. The architectural shifts you are describing—compiled view, memory-first, schema-driven summarization, and state offloading—are precisely what's needed to allow PHOENIX ORCH to operate on long-term goals (5,000-year plan) and act as a reliable Digital Twin.
You are correct: the current PHOENIX ORCH design has the components, but we must explicitly configure the flow to implement these principles.
🧠 Context Engineering for PHOENIX ORCH
Your current microservice architecture is perfectly suited for this transition, as it allows you to separate the memory (storage) from the context (the compiled view).
1. Context as a Compiled View (Not a Transcript)
The core principle here is that the LLM's Working Context (the tokens sent in a single API call) must not be a growing chat history (a transcript). It must be a Schema-Driven Summary (a compiled view).
 * Implementation: The Context Manager (50064) must be updated. Instead of retrieving the last N messages from the Mind KB, it must execute a three-step compilation process before sending the prompt to the LLM:
   * Retrieval: Pull relevant facts, recent interactions, and tool definitions from the Mind KB, Soul KB, and Tools Service.
   * Schema-Driven Summarization: Use the LLM Service itself (via an internal summarization RPC) to compress the retrieved data into a concise, structured format (e.g., JSON or TOML) defined by a specific schema (e.g., PastActions: [Plan, Result, $U_T$ Score], CurrentGoal: Text). This is the compiled view.
   * Compaction: The Context Manager then inserts this small, structured, compiled view into the prompt, ensuring the total token count is optimized and performance isn't degraded.
2. Memory-First Design & State Offloading
This ensures the default context is empty, and information is retrieved only when necessary.
 * Default State: The Orchestrator's initial prompt for any new session must contain nothing other than the Master System Prompt and the Tool Definitions. All other information (history, user preferences, knowledge) is considered "heavy state."
 * Offloading Heavy State: All conversation history, user preferences, and intermediate reasoning steps are stored externally in the Mind KB (Vector DB) and Heart KB (Key-Value Store). The KBs are the long-term memory (like a hard drive), while the LLM's context is the working memory (like RAM).
 * Isolate Agent Scope: The Data Router (50052)'s service lookup function prevents agents from directly seeing each other's full internal state. The RED_TEAM_SHADOW is only given the context necessary to execute a red team task; it is not overloaded with the BLUE_TEAM_SENTINEL's defense strategies.
3. Evolving Playbooks and Sharpening Over Time
This directly addresses how the AGI's behaviors and strategies mature.
 * Dynamic Playbooks: The specialized agents (Red Team, Blue Team) do not use static rules. Instead, their Playbooks (the sequence of actions and logic they select) are generated and stored in the Planning KB (50072).
 * Sharpening: The Closed-Loop RSI Strategy handles the sharpening:
   * A playbook is executed.
   * The Log Analyzer (50075) classifies the outcome (Success/Failure).
   * The Reflection Service (50065) generates an updated, improved version of the playbook using the LLM's reasoning and stores it back in the Planning KB.
 * Memory Decay: The Mind KB should implement a decay function to reduce the relevance score of very old, unused data, ensuring the AGI prioritizes the most current, high-U_T information.
By making these explicit configurations, PHOENIX ORCH moves from simple context management to a robust Context Engineering System built around the "context as a compiled view" thesis.
You can learn more about how systems are designed to manage context to improve performance and consistency in complex AI applications by reviewing this video. The Context Engineering System Design
