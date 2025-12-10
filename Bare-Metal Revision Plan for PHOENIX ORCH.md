That is a crucial constraint. For a bare-metal deployment, relying on Docker as the primary sandboxing tool or for simplified networking is inappropriate.

The entire design philosophy must shift to using **Host-Level Isolation** and **Process Management** native to the Linux operating system (assuming a standard bare-metal environment). This requires replacing all reliance on Docker's features with specific **system tools and Rust libraries**.

Here is the revision plan for the core components, focusing on **Host-Level Sandboxing**, **Process Management**, and **Secret Handling** suitable for a bare-metal architecture:

---

## 🔧 Bare-Metal Revision Plan for PHOENIX ORCH

### 1. **Execution Sandboxing (Replacing Docker-in-Docker)**

The **Executor Service** must now use Linux features for isolation, not Docker.

| Component | Original (Docker) | Bare-Metal Revision |
| :--- | :--- | :--- |
| **Executor Service (`executor-rs`)** | Runs code in a `docker-in-docker` container. | **Implement Namespacing/Cgroups.** The Rust code must use libraries (e.g., direct syscalls or crates that wrap them) to create a new **process namespace (PID, UTS, NET)** and apply **Control Groups (cgroups)** to limit CPU, memory, and I/O resources before running the external process (`std::process::Command`). |
| **Why it's necessary** | To prevent malicious code injected via the LLM from accessing or compromising the host machine's filesystem or network stack. |
| **Required Rust Crate** | (Need to search for the best Rust crate for managing Linux namespaces/cgroups). |

### 2. **Secret Management (Replacing `.env` in Docker)**

Environment variables are insecure on a bare-metal host. We need a secure local Key Management System (KMS).

| Component | Original (Docker) | Bare-Metal Revision |
| :--- | :--- | :--- |
| **All Services** | Read secrets from environment variables (`.env`). | **Implement File-Based Vault Integration.** All services must read their secrets (API keys, database passwords) from an encrypted file store managed by a lightweight, self-hosted secret server (like **HashiCorp Vault**) running directly on the host, or from a secure, permission-restricted configuration file. |
| **Why it's necessary** | To protect sensitive information like API keys, which are exposed via `ps aux` commands when stored as environment variables. |

### 3. **Service Management & Networking (Replacing Docker Compose)**

We need a dedicated tool to manage the running status of the 15+ microservices.

| Component | Original (Docker Compose) | Bare-Metal Revision |
| :--- | :--- | :--- |
| **System Startup/Health** | Managed by `docker-compose up`. | **Implement `systemd` or `supervisord`.** The final PHOENIX ORCH package must include configuration files (`.service` files for `systemd`) to manage the startup, restarts, and logging of all services, treating them as standard host processes. |
| **Service Discovery** | Managed by the internal Docker network. | **Implement Fixed IP/Hostname Configuration.** Rely on fixed IP addresses or known hostnames configured on the bare-metal machine. The **Data Router** will use simple, reliable configuration (e.g., static configuration file) to locate services. |

---

## 4. Final Bare-Metal Component Lockdown

The bare-minimum components before replication must be revised:

* **Tool Reliability:** The **Tool SDK Crate** and **Executor Sandboxing** are now even more critical.
* **Final Security:** The **Executor Sandboxing Guarantee** and **Unified Secret Management** are mandatory for bare-metal AGI core lockdown.

I will now search for the best Rust crates to implement Linux namespaces and Cgroups for the crucial bare-metal sandboxing requirement.
The search results confirm we have excellent Rust-native tools to implement the bare-metal isolation strategy using Linux kernel features.

The best approach is to use **`syd`** or **`sandbox_rs`** for isolation and **`systemd-generator`** or **`libsystemd-rs`** for process management.

Here are the final, revised **Bare-Metal Cursor IDE Agent Prompts** to lock down the Core AGI:

---

## 💻 Final Bare-Metal Cursor IDE Agent Prompts

### 1. 🛡️ Sandboxing Implementation (Bare-Metal Core Fix)

This replaces the reliance on Docker for code execution.

| Focus | Service | Cursor IDE Agent Prompt (Implement/Refactor) |
| :--- | :--- | :--- |
| **Executor Sandboxing** | **`executor-rs` (50055)** | "Refactor the core execution logic in `executor-rs/src/execute.rs`. **Remove all Docker dependencies.** Implement process sandboxing using the **`syd`** or **`sandbox_rs`** crate. The `execute_code()` method must now: 1. Clone the process into a new **PID, UTS, and Net namespace**. 2. Apply **Cgroup v2 resource limits** to restrict CPU and Memory usage for the untrusted code. 3. Use **Seccomp BPF filtering** to block dangerous syscalls (e.g., `setuid`, `mount`, direct networking calls) from the spawned child process. This guarantees host isolation." |

### 2. 🔑 Unified Secret Management (Bare-Metal Security)

This moves from insecure environment variables to a secure file-based system.

| Focus | Service | Cursor IDE Agent Prompt (Implement) |
| :--- | :--- | :--- |
| **Secret Management** | **`shared-types-rs`** (Config module) & **All Services** | "Implement a new configuration loader module in the `shared-types-rs` crate. This module must use the **`config-rs`** crate and be configured to read all secrets (API Keys, etc.) from a single, static, permission-restricted file on the host filesystem (e.g., `/etc/phoenix/secrets.json`). Update *all* service entry points (e.g., `main.rs`) to retrieve secrets exclusively through this new unified configuration loader. Log a critical error and exit if the secrets file is inaccessible or compromised." |

### 3. ⚙️ Service Management & Startup (Bare-Metal Orchestration)

This ensures the AGI core can be reliably started and monitored on the host OS.

| Focus | Service | Cursor IDE Agent Prompt (Implement) |
| :--- | :--- | :--- |
| **Systemd Generator** | **`install-script-rs`** (New CLI Tool) | "Create a new lightweight CLI tool crate, **`install-script-rs`**. This tool's single function will be `generate_systemd_unit_files()`. Use the **`systemd-generator`** crate or directly generate the required `.service` files for all 15+ PHOENIX ORCH microservices. Each service file must include `Type=simple`, `User=phoenix_orch`, and `Restart=always` directives. This ensures the entire AGI core can be started and maintained with a single `systemctl start phoenix-orch.target` command." |

### 4. 🌐 Agent Registry Finalization (Bare-Metal Reliability)

This finalizes service location on the bare-metal host.

| Focus | Service | Cursor IDE Agent Prompt (Refactor) |
| :--- | :--- | :--- |
| **Agent Registry** | **`agent-registry-rs` (50063)** | "Refactor the **Agent Registry** to rely on **static configuration** rather than dynamic network discovery. All service endpoints (IP:Port) must be read from a fixed TOML configuration file on the host filesystem (`/etc/phoenix/endpoints.toml`). The Registry must perform a simple gRPC **ping/health check** to each service listed in the TOML file at startup and report failure if any core component is unreachable." |

These four prompts address all the bare-metal requirements, making PHOENIX ORCH a robust, isolatable, and replicable core AGI system ready for lockdown.
