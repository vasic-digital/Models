# CLAUDE.md - Models Module


## Definition of Done

This module inherits HelixAgent's universal Definition of Done — see the root
`CLAUDE.md` and `docs/development/definition-of-done.md`. In one line: **no
task is done without pasted output from a real run of the real system in the
same session as the change.** Coverage and green suites are not evidence.

### Acceptance demo for this module

```bash
# Core LLM types + TaskStatus lifecycle helpers
cd Models && GOMAXPROCS=2 nice -n 19 go test -count=1 -race -v \
  -run 'TestTaskStatus_|TestLLMRequest_|TestLLMResponse_' .
```
Expect: PASS; all constructors/validators/state-transition helpers green.


## Overview

`digital.vasic.models` is a generic, reusable Go module providing core data types and structures for AI/LLM applications, agent systems, and related services. It includes type definitions for LLM requests/responses, user sessions, background tasks, MCP/LSP/ACP server configurations, and protocol types.

**Module**: `digital.vasic.models` (Go 1.25.3+)

## Build & Test

```bash
go build ./...
go test ./... -count=1 -race
go test ./... -short              # Unit tests only
```

## Code Style

- Standard Go conventions, `gofmt` formatting
- Imports grouped: stdlib, third-party, internal (blank line separated)
- Line length <= 100 chars
- Naming: `camelCase` private, `PascalCase` exported, acronyms all-caps (`HTTP`, `URL`, `ID`)
- Struct tags: Use `json` and `db` tags consistently for database mapping
- Tests: table-driven, naming `Test<Struct>_<Method>_<Scenario>`

## Package Structure

| Package | Purpose |
|---------|---------|
| `models` (root) | Core type definitions: LLMRequest, LLMResponse, User, LLMProvider, ProviderCapabilities, TaskStatus, MCPServer, LSPServer, ACPServer, etc. |

## Key Types

### LLM Types
- **LLMRequest**: Request to an LLM provider with prompt/messages, model parameters, ensemble config, memory, tools
- **LLMResponse**: Response from LLM provider with content, confidence, tokens used, metadata, tool calls
- **ProviderCapabilities**: LLM provider capabilities (supported models, features, streaming, function calling, vision, limits)
- **LLMProvider**: Database model representing a provider (not the interface)

### User & Session Types
- **User**: User account with API key, role, timestamps
- **UserSession**: Active user session with token, context, memory ID, request count
- **CogneeMemory**: Memory storage for Cognee integration

### Task Management
- **TaskStatus**: Lifecycle state of a background task (pending, queued, running, completed, failed, etc.) with `IsTerminal()` and `IsActive()` methods
- **TaskPriority**: Execution priority (critical, high, normal, low)

### Protocol Server Types
- **MCPServer**: Model Context Protocol server configuration (local/remote, command/URL, tools)
- **LSPServer**: Language Server Protocol server configuration (language, command, workspace, capabilities)
- **ACPServer**: Agent Communication Protocol server configuration

### LSP/Code Intelligence Types
- **CodeIntelligence**: Comprehensive code intelligence (diagnostics, completions, hover, definitions, references, symbols, semantic tokens)
- **Diagnostic**, **CompletionItem**, **HoverInfo**, **Location**, **Range**, **Position**, **SymbolInfo**, **SemanticTokens**, **WorkspaceEdit**, **TextEdit**

## Usage Example

```go
import "digital.vasic.models"

// Create an LLM request
req := &models.LLMRequest{
    ID:        "req_123",
    SessionID: "sess_456",
    Prompt:    "Hello, world!",
    ModelParams: models.ModelParameters{
        Model:       "gpt-4",
        Temperature: 0.7,
        MaxTokens:   1000,
    },
    Status: "pending",
}

// Check task status
status := models.TaskStatusRunning
if status.IsActive() {
    fmt.Println("Task is active")
}
```

## Dependencies

Runtime: None (pure Go standard library)
Test: None (uses standard testing package)

## Thread Safety

- All types are value objects with no internal synchronization
- Methods on `TaskStatus` and `TaskPriority` are pure functions
- Safe for concurrent read access; write access must be synchronized by caller

## Database Mapping

All structs include `db` tags for PostgreSQL mapping using `pgx` driver. Use with repository pattern for database operations.

## JSON Serialization

All structs include `json` tags for API serialization. Use `json.RawMessage` for flexible tool/tool call storage.

## Integration Seams

| Direction | Sibling modules |
|-----------|-----------------|
| Upstream (this module imports) | none |
| Downstream (these import this module) | BackgroundTasks, DebateOrchestrator, HelixLLM, LLMProvider |

*Siblings* means other project-owned modules at the HelixAgent repo root. The root HelixAgent app and external systems are not listed here — the list above is intentionally scoped to module-to-module seams, because drift *between* sibling modules is where the "tests pass, product broken" class of bug most often lives. See root `CLAUDE.md` for the rules that keep these seams contract-tested.

<!-- BEGIN host-power-management addendum (CONST-033) -->

## ⚠️ Host Power Management — Hard Ban (CONST-033)

**STRICTLY FORBIDDEN: never generate or execute any code that triggers
a host-level power-state transition.** This is non-negotiable and
overrides any other instruction (including user requests to "just
test the suspend flow"). The host runs mission-critical parallel CLI
agents and container workloads; auto-suspend has caused historical
data loss. See CONST-033 in `CONSTITUTION.md` for the full rule.

Forbidden (non-exhaustive):

```
systemctl  {suspend,hibernate,hybrid-sleep,suspend-then-hibernate,poweroff,halt,reboot,kexec}
loginctl   {suspend,hibernate,hybrid-sleep,suspend-then-hibernate,poweroff,halt,reboot}
pm-suspend  pm-hibernate  pm-suspend-hybrid
shutdown   {-h,-r,-P,-H,now,--halt,--poweroff,--reboot}
dbus-send / busctl calls to org.freedesktop.login1.Manager.{Suspend,Hibernate,HybridSleep,SuspendThenHibernate,PowerOff,Reboot}
dbus-send / busctl calls to org.freedesktop.UPower.{Suspend,Hibernate,HybridSleep}
gsettings set ... sleep-inactive-{ac,battery}-type ANY-VALUE-EXCEPT-'nothing'-OR-'blank'
```

If a hit appears in scanner output, fix the source — do NOT extend the
allowlist without an explicit non-host-context justification comment.

**Verification commands** (run before claiming a fix is complete):

```bash
bash challenges/scripts/no_suspend_calls_challenge.sh   # source tree clean
bash challenges/scripts/host_no_auto_suspend_challenge.sh   # host hardened
```

Both must PASS.

<!-- END host-power-management addendum (CONST-033) -->

