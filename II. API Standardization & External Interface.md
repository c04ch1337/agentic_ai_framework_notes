📐 II. API Standardization & External Interface
The AGI needs a single, unified interface for all input and output that can be universally replicated.

3. 🛡️ Unified Output & Security Schema
The API Gateway (api-gateway-rs, 8000) must strictly enforce a final output schema and handle all external security.

Final Implementation: Define a single, non-negotiable External Response Protobuf Schema used by the API Gateway. This schema must contain fields not just for the FinalAnswer, but also for the ExecutionPlan, RoutedService, and a PHOENIX_SESSION_ID.

Why it's necessary: This guarantees that whether the output is text, an image URL (from the Avatar Service), or a simple status, all external apps/users receive a predictable structure. The API Gateway must also handle all initial API Key/mTLS checks and rate limiting before traffic reaches the Orchestrator.

4. 🔗 The Agent Registry Finalization
The Agent Registry (agent-registry-rs) needs to transition from a configuration file reader to a dynamic, runtime control plane.

Final Implementation: The Registry must be upgraded to perform runtime capability verification. It should not just read agent_registry.toml, but actively ping the RED-TEAM-SHADOW agent at startup to confirm its reported capabilities are active and non-malicious before listing it as available to the Orchestrator.

Why it's necessary: This confirms the replicable core starts with a dynamic, self-verified list of agents, which is essential for customized replicas (where you might add or remove specialty agents).
