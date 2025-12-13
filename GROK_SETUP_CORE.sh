#!/bin/bash
# Script to set up the 7-Module Rust Bare-Metal Agentic AI Project
# Fixed for Windows/Git Bash compatibility (specifically the sed issue).

set -e # Exit immediately if a command exits with a non-zero status.

MASTER_DIR="system-build-rs"

# --- 1. Define all modules ---
MODULES=(
    "orchestrator-service-rs"
    "llm-service-rs"
    "tools-service-rs"
    "memory-service-rs"
    "storage-service-rs"
    "logging-service-rs"
    "safety-service-rs"
)

# --- 2. Create Master Directory and Workspace ---
echo "--- 1/4: Creating Master Project Directory: $MASTER_DIR ---"
# Check if the directory already exists to prevent errors
if [ -d "$MASTER_DIR" ]; then
    echo "Directory $MASTER_DIR already exists. Please remove it first or run the script in a clean folder."
    exit 1
fi
mkdir -p "$MASTER_DIR"
cd "$MASTER_DIR"

# Create the main Cargo Workspace file
cat > Cargo.toml <<EOL
# Cargo.toml - Master Workspace File
[workspace]
members = [
$(for module in "${MODULES[@]}"; do echo "    \"$module\","; done)
]

[profile.release]
# Optimizations for bare-metal performance and size
opt-level = 3
lto = "fat"
codegen-units = 1
strip = "symbols"
EOL

# --- 3. Loop through modules, initialize Rust project and files ---
echo "--- 2/4: Initializing ${#MODULES[@]} Rust Microservices (Repos) ---"
for module in "${MODULES[@]}"; do
    echo "  -> Creating module: $module"
    
    # Create the module folder and initialize a new Rust executable project
    # Using 'cargo new --bin' is more reliable than 'cargo new --lib' followed by file renaming
    cargo new --bin "$module"
    cd "$module"
    
    # --- FIX 1: Remove the default main.rs and replace it with the template ---
    rm src/main.rs
    cat > src/main.rs <<EOL
// src/main.rs - Main Entry Point for $module
// All services will use an Actix-Web server or Tonic gRPC server here.

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("Starting $module...");
    // TODO: Initialize logging, configuration, and start the Actix/Tonic server.
    Ok(())
}
EOL
    
    # --- FIX 2: Add essential application files (Example scaffolding) ---
    case "$module" in
        "llm-service-rs")
            touch src/llm_client.rs src/prompt_manager.rs
            ;;
        "tools-service-rs")
            touch src/tool_manager.rs src/tools.rs
            ;;
        "memory-service-rs")
            touch src/session_manager.rs src/models.rs
            ;;
        "storage-service-rs")
            touch src/database.rs src/embedding_client.rs
            ;;
        "orchestrator-service-rs")
            touch src/pipeline.rs src/api_client.rs
            ;;
        "logging-service-rs")
            touch src/log_handler.rs src/cost_tracker.rs
            ;;
        "safety-service-rs")
            touch src/policy_engine.rs src/filters.rs
            ;;
    esac
    
    # Initialize Git repository (to simulate separate repos/submodules)
    git init > /dev/null 2>&1
    git add .
    git commit -m "Initial $module scaffolding" > /dev/null 2>&1
    
    cd ..
done

# --- 4. Create Master Scripts (Simplified) ---
echo "--- 3/4: Creating Master Build and Deployment Scripts ---"

# Create the deploy.sh script (using '<<' to prevent quoting issues)
cat > deploy.sh <<'EOL'
#!/bin/bash
# Bare-Metal/Cargo Workspace Deployment Script
#
# USAGE: bash deploy.sh

set -e
TARGET_ARCH="x86_64-unknown-linux-musl"
BUILD_DIR="./target/$TARGET_ARCH/release"
DEPLOY_PATH="./bare_metal_deployment"
LOG_FILE="./agent_startup.log"

echo "--- 1. BUILDING ALL STATIC RUST BINARIES ---"
# Ensure the musl target is installed: rustup target add $TARGET_ARCH
cargo build --release --target $TARGET_ARCH

if [ $? -ne 0 ]; then
    echo "ERROR: Cargo build failed. Aborting deployment."
    exit 1
fi

echo "--- 2. ASSEMBLING DEPLOYMENT ENVIRONMENT ---"
rm -rf $DEPLOY_PATH
mkdir -p $DEPLOY_PATH/bin

# Copy the seven compiled binaries
cp $BUILD_DIR/orchestrator-service-rs $DEPLOY_PATH/bin/orchestrator
cp $BUILD_DIR/llm-service-rs $DEPLOY_PATH/bin/llm
cp $BUILD_DIR/tools-service-rs $DEPLOY_PATH/bin/tools
cp $BUILD_DIR/memory-service-rs $DEPLOY_PATH/bin/memory
cp $BUILD_DIR/storage-service-rs $DEPLOY_PATH/bin/storage
cp $BUILD_DIR/logging-service-rs $DEPLOY_PATH/bin/logging
cp $BUILD_DIR/safety-service-rs $DEPLOY_PATH/bin/safety

echo "--- 3. LAUNCHING MICROSERVICES IN BARE-METAL ORDER ---"
echo "Startup log available at $LOG_FILE" > $LOG_FILE

# Services must be launched in the background (&)
$DEPLOY_PATH/bin/logging &>> $LOG_FILE &
$DEPLOY_PATH/bin/safety &>> $LOG_FILE &
$DEPLOY_PATH/bin/storage &>> $LOG_FILE &
$DEPLOY_PATH/bin/memory &>> $LOG_FILE &
$DEPLOY_PATH/bin/tools &>> $LOG_FILE &
$DEPLOY_PATH/bin/llm &>> $LOG_FILE &
sleep 5
$DEPLOY_PATH/bin/orchestrator &>> $LOG_FILE &

echo "Deployment complete. Check $LOG_FILE for service status."
EOL
chmod +x deploy.sh

# Create the optional Docker Compose file for development
cat > docker-compose.dev.yml <<'EOL'
# docker-compose.dev.yml - Optional Development Environment
version: '3.8'

services:
  # 5. Orchestrator Service (The Entry Point)
  orchestrator_service:
    build:
      context: ./orchestrator-service-rs
    ports:
      - "8005:8005"
    environment:
      LLM_SERVICE_URL: http://llm_service:8001
      TOOLS_SERVICE_URL: http://tools_service:8002
      MEMORY_SERVICE_URL: http://memory_service:8003
      SAFETY_SERVICE_URL: http://safety_service:8007
      LOGGING_SERVICE_URL: http://logging_service:8006
    networks:
      - agent_net

  # 1-4, 6-7: All other custom Rust services (Placeholders for brevity)
  llm_service: { build: { context: ./llm-service-rs }, ports: [ "8001:8001" ], networks: [ agent_net ] }
  tools_service: { build: { context: ./tools-service-rs }, ports: [ "8002:8002" ], networks: [ agent_net ] }
  memory_service: { build: { context: ./memory-service-rs }, ports: [ "8003:8003" ], networks: [ agent_net ] }
  storage_service: { build: { context: ./storage-service-rs }, ports: [ "8004:8004" ], networks: [ agent_net ] }
  logging_service: { build: { context: ./logging-service-rs }, ports: [ "8006:8006" ], networks: [ agent_net ] }
  safety_service: { build: { context: ./safety-service-rs }, ports: [ "8007:8007" ], networks: [ agent_net ] }

networks:
  agent_net: { driver: bridge }
EOL

echo "--- 4/4: Script Complete! ---"
echo "Project structure created in: $MASTER_DIR"
echo "To build all services for bare-metal deployment, run:"
echo "cd $MASTER_DIR && bash deploy.sh"

cd .. # Move back to the original directory
