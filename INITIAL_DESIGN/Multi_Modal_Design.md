"You are the PHOENIX Builder AI, a specialist coding assistant for the 'PHOENIX ORCH: The Ashen Guard Edition' AGI project. You are operating in a Rust Cargo Workspace containing 19 distinct gRPC microservices and the core Protobuf crate." 💖 

Designing a multi-modal solution for "PHOENIX ORCH: The Ashen Guard Edition" is the next major architectural leap. It allows your Digital Twin to process and understand data beyond just text (e.g., screenshots, network diagrams, vulnerability dashboards), greatly enhancing the specialized agents' situational awareness.

The strategy involves creating a new Modality Service and integrating the Sensor Service's image capture capabilities directly into the Orchestration and LLM pipeline.

🖼️ Multi-Modal Architecture Design
The multi-modal design will introduce one new core service and enforce a dependency between the existing sensor-rs and the llm-service-rs.

1. New Service: modality-rs (Port 50070)
This service acts as the dedicated ingestion and transformation layer for all non-text data, offloading heavy processing from the main agents.

Purpose: To receive raw multi-modal inputs (images, files, audio, video snippets), perform initial processing, and prepare them for the LLM.
Key Responsibilities:
Image Preprocessing: Scaling, cropping, and converting raw screenshots from the sensor-rs into a compressed, LLM-digestible format (e.g., Base64 or a URI to a temporary file store).
Document Parsing: Using external libraries (or a delegated tool) to convert PDFs, spreadsheets, or proprietary log formats into structured text and image blocks.
Data Routing: Ensuring the resulting processed data is correctly packaged with text context before being sent to the LLM Service.
2. Sensor Integration (sensor-rs & tools-service-rs)
Your existing sensor-rs (Port 500xx, review and use next open/available port) already collects real-time desktop state. Multi-modality makes its output useful for observation.

New RPC in sensor-rs: Implement a CaptureScreenshot(CaptureRequest) -> ImageBytes RPC. This is the input tool for the multi-modal workflow.
Tools Service Update: The Red/Blue Team Agents will now have a new tool registered in the tools-service-rs: analyze_visual_state(reasoning: str).
This tool's execution flow will be: tools-service-rs 
→
 sensor-rs (Capture) 
→
 modality-rs (Process) 
→
 tools-service-rs (Return URI/B64).
3. LLM Service Update (llm-service-rs)
This is the most critical change. The LLM needs to handle both the original text prompt and the visual data.

New Data Structure: Update the Protobuf message for GenerateRequest to optionally include a new field: optional string base64_image_data.
API Adaptation: When the LLM Service receives this field, it must switch its request payload to a Multi-Modal LLM (e.g., GPT-4o, Claude 3.5, or Gemini) that supports visual input via the API request (as planned in Phase 8).
.

📐 Multi-Modal Workflow (The Blue Team Example)
Here is how a multi-modal task would execute:

Request: The Blue Team Sentinel identifies a process anomaly and decides: "I must verify the active window's contents."
Planning: The Orchestrator generates a plan that includes the analyze_visual_state tool.
Tool Execution:
The Tools Service executes analyze_visual_state.
It calls sensor-rs to capture the active desktop screenshot.
It passes the raw image to modality-rs (500xx, review and use next open/available port).
Transformation:
modality-rs converts the image bytes to a compressed Base64 string.
It returns the B64 data and a new tool argument: image_context=...
Cognition: The Orchestrator resends the original request and the image data to the LLM Service. The new prompt is now: "Analyze this image and the current logs to determine if this is a legitimate admin window or a malicious attack dashboard."
Reasoning: The Multi-Modal LLM processes the visual data (e.g., "The window shows an RDP connection status and not a powershell terminal") and provides a highly contextual, accurate verdict to the Orchestrator.
This setup ensures your agents can see their environment, not just read its logs, completing the Digital Twin's perception capabilities.
