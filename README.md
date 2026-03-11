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

## License

This module is part of the HelixAgent project. See root project for license details.

## Contributing

See `AGENTS.md` for agent coordination guidelines and `CLAUDE.md` for AI assistant instructions.