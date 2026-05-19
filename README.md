# Models Module

`digital.vasic.models` is a generic, reusable Go module providing core data types and structures for AI/LLM applications, agent systems, and related services.

## Features

- **LLM Types**: `LLMRequest`, `LLMResponse`, `ProviderCapabilities`, `ModelLimits`
- **User & Session**: `User`, `UserSession`, `CogneeMemory`
- **Task Management**: `TaskStatus` (with `IsTerminal()` and `IsActive()` methods), `TaskPriority`
- **Protocol Servers**: `MCPServer`, `LSPServer`, `ACPServer`
- **LSP/Code Intelligence**: `CodeIntelligence`, `Diagnostic`, `CompletionItem`, `HoverInfo`, `Location`, `Range`, `Position`, `SymbolInfo`, `SemanticTokens`, `WorkspaceEdit`, `TextEdit`
- **Zero Dependencies**: Pure Go standard library, no external runtime dependencies
- **Dual Serialization**: All types include both `json` and `db` tags for API and database mapping
- **Thread-Safe**: Value objects with no shared mutable state

## Installation

```bash
go get digital.vasic/models
```

## Quick Start

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

// Use task status helpers
status := models.TaskStatusRunning
if status.IsActive() {
    fmt.Println("Task is active")
}

// Create a background task status
taskStatus := models.TaskStatusPending
if !taskStatus.IsTerminal() {
    fmt.Println("Task can still be processed")
}
```

## Type Categories

### LLM Request/Response
- `LLMRequest`: Complete LLM request with prompt/messages, model parameters, ensemble config, memory, tools
- `LLMResponse`: LLM response with content, confidence, tokens used, metadata, tool calls
- `ProviderCapabilities`: LLM provider capabilities (supported models, features, streaming, function calling, vision)
- `ModelLimits`: Operational limits (max tokens, input/output length, concurrent requests)

### User Management
- `User`: User account with API key, role, timestamps
- `UserSession`: Active user session with token, context, memory ID
- `CogneeMemory`: Memory storage for Cognee integration

### Task Management
- `TaskStatus`: Lifecycle state (`pending`, `queued`, `running`, `completed`, `failed`, `stuck`, `cancelled`, `dead_letter`) with helper methods
- `TaskPriority`: Execution priority (`critical`, `high`, `normal`, `low`)

### Protocol Servers
- `MCPServer`: Model Context Protocol server configuration
- `LSPServer`: Language Server Protocol server configuration
- `ACPServer`: Agent Communication Protocol server configuration

### Code Intelligence (LSP)
- `CodeIntelligence`: Comprehensive code intelligence container
- `Diagnostic`: Diagnostic message with range, severity, code, source, message
- `CompletionItem`: Code completion item with label, kind, detail, documentation
- `HoverInfo`: Hover information with content and language
- `Location`: File location with URI and range
- `Range`: Text range with start/end positions
- `Position`: Line and character position
- `SymbolInfo`: Symbol information with name, kind, location, container
- `SemanticTokens`: Semantic token data array
- `WorkspaceEdit`: Workspace edit with file changes
- `TextEdit`: Text edit with range and new text

## Database Mapping

All structs include `db` tags for PostgreSQL mapping using `pgx` driver:

```go
type User struct {
    ID           string    `json:"id" db:"id"`
    Username     string    `json:"username" db:"username"`
    Email        string    `json:"email" db:"email"`
    PasswordHash string    `json:"-" db:"password_hash"`
    APIKey       string    `json:"api_key" db:"api_key"`
    // ...
}
```

## JSON Serialization

All structs include `json` tags for API serialization:

```go
type LLMResponse struct {
    ID             string                 `json:"id" db:"id"`
    RequestID      string                 `json:"request_id" db:"request_id"`
    ProviderID     string                 `json:"provider_id" db:"provider_id"`
    Content        string                 `json:"content" db:"content"`
    Confidence     float64                `json:"confidence" db:"confidence"`
    // ...
}
```

## Development

### Building and Testing

```bash
# Build
go build ./...

# Run all tests
go test ./...

# Run tests with race detection
go test ./... -race

# Format code
gofmt -w .

# Vet code
go vet ./...
```

### Adding New Types

1. Add the type definition to `types.go` (for core types) or `protocol_types.go` (for protocol types)
2. Include appropriate `json` and `db` tags
3. Add test cases in `types_test.go` or separate test file
4. Update documentation in `README.md` and `CLAUDE.md`

## Anti-bluff guarantees (round-268)

This module ships an anti-bluff posture per Article XI §11.9 and
CONST-035 / CONST-050(B). Every test and every Challenge under this
repository MUST carry positive runtime evidence; metadata-only,
grep-only, or absence-of-error PASS counts are categorically
forbidden.

> Verbatim 2026-05-19 operator mandate: "all existing tests and
> Challenges do work in anti-bluff manner - they MUST confirm that
> all tested codebase really works as expected! We had been in
> position that all tests do execute with success and all
> Challenges as well, but in reality the most of the features does
> not work and can't be used! This MUST NOT be the case and
> execution of tests and Challenges MUST guarantee the quality, the
> completition and full usability by end users of the product!"

### Deep documentation (round-268 deliverables)

- **`docs/test-coverage.md`** — symbol → exerciser ledger covering
  every exported symbol of `digital.vasic.models`
  (`types.go`, `protocol_types.go`, `background_task.go`).
- **`challenges/runner/main.go`** — 8-section runtime exerciser
  that drives the public surface end-to-end across 5 locales:
  en (Latin), sr (Cyrillic), ja (Japanese), ar (Arabic, RTL),
  zh-CN (Han). The fixture lives at
  `tests/fixtures/models/payloads.json` — no prompt, task name,
  username, tool description, diagnostic message, completion label,
  or MCP command is hardcoded in the runner source.
- **`challenges/scripts/models_describe_challenge.sh`** —
  paired-mutation wrapper. Clean-mode exit 0 proves runner +
  ledger + fixture + README all converge; `--anti-bluff-mutate`
  exit 99 proves the wrapper actually catches ledger-vs-source
  drift when a known mutation (rename `TaskStatus` ->
  `TaskStatus_MUTATED` in a tmp ledger copy) is planted.

### Sections exercised in the round-268 runner

1. `TaskStatus.IsTerminal` / `IsActive` truth-table walk +
   `TaskPriority.Weight` inversion + 14 string-constant audits.
2. `NewBackgroundTask` defaults + 7 transition helpers
   (`CanRetry`, `CanPause`, `CanCancel`, `CanResume`, `Duration`,
   `IsOverdue`, `HasStaleHeartbeat`) per locale.
3. `LLMRequest` / `LLMResponse` / `Message` / `Tool` / `ToolCall` /
   `User` / `UserSession` / `CogneeMemory` JSON round-trip per
   locale; `User.PasswordHash` json:"-" leak guard.
4. `MCPServer` / `LSPServer` / `ACPServer` per-locale round-trip
   + `ProtocolType*` + `ServerType*` constant audits.
5. `ProtocolMetrics` × 3 status variants (success / error /
   timeout) per locale + `MetricsStatus*` constant audits.
6. `CodeIntelligence` + `Diagnostic` + `CompletionItem` +
   `HoverInfo` + `Range` + `Position` + `SymbolInfo` +
   `SemanticTokens` + `WorkspaceEdit` + `TextEdit` per locale.
7. `TaskExecutionHistory` / `DeadLetterTask` / `WebhookDelivery` /
   `TaskLogEntry` / `TaskProgressUpdate` / `TaskError` lifecycle
   payloads per locale + `TaskEvent*` constant audit (9 entries).
8. `ProviderCapabilities` + `ModelLimits` + `LLMProvider` (with
   `APIKey` json:"-" leak guard + `Models.dev` pointer fields) +
   `EnsembleConfig` + `VectorDocument` (with `Embedding []float32`
   json:"-" leak guard) per locale.

### Invocation

```bash
# Unit suite (with race detector)
GOMAXPROCS=2 nice -n 19 go test -count=1 -race ./...

# Challenge runner (real Models surface, 5 locales)
go run ./challenges/runner/ -fixtures tests/fixtures/models/payloads.json

# Paired-mutation gate (clean mode)
bash challenges/scripts/models_describe_challenge.sh

# Paired-mutation gate (mutate mode — MUST exit 99)
bash challenges/scripts/models_describe_challenge.sh --anti-bluff-mutate
```

## License

This module is part of the HelixAgent / HelixCode project family.
See root project for license details.

## Contributing

See `AGENTS.md` for agent coordination guidelines and `CLAUDE.md`
for AI assistant instructions.