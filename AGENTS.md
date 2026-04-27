# AGENTS.md - Models Module

## Module Overview

`digital.vasic.models` is a generic, reusable Go module providing core data types and structures for AI/LLM applications, agent systems, and related services. It includes type definitions for LLM requests/responses, user sessions, background tasks, MCP/LSP/ACP server configurations, and protocol types. The module has zero external runtime dependencies beyond Go standard library.

**Module path**: `digital.vasic.models`
**Go version**: 1.25.3+
**Dependencies**: None (standard library only)

## Package Responsibilities

| Package | Path | Responsibility |
|---------|------|----------------|
| `models` | `./` | Core type definitions: LLMRequest, LLMResponse, User, LLMProvider, ProviderCapabilities, TaskStatus, MCPServer, LSPServer, ACPServer, CodeIntelligence, and all related LSP types. This is the only package with no internal dependencies. |

## Dependency Graph

```
models (self-contained)
```

The module is a single package with no internal dependencies. All types are value objects with no external dependencies.

## Key Files

| File | Purpose |
|------|---------|
| `types.go` | Primary type definitions: User, LLMProvider, LLMRequest, LLMResponse, Message, ModelParameters, EnsembleConfig, UserSession, CogneeMemory, MemorySource, ProviderCapabilities, ModelLimits, and all LSP types (CodeIntelligence, Diagnostic, CompletionItem, etc.) |
| `protocol_types.go` | Protocol server types: MCPServer, LSPServer, ACPServer |
| `background_task.go` | Task management types: TaskStatus, TaskPriority with methods |
| `types_test.go` | Test utilities and helper functions |
| `background_task_test.go` | Task status tests |
| `go.mod` | Module definition and dependencies |
| `CLAUDE.md` | AI coding assistant instructions |
| `README.md` | User-facing documentation with quick start |

## Agent Coordination Guide

### Division of Work

When multiple agents work on this module simultaneously, divide work by type categories:

1. **Core LLM Types Agent** -- Owns LLMRequest, LLMResponse, ProviderCapabilities, ModelLimits, Message, ModelParameters, EnsembleConfig. Changes to these types affect many downstream systems.
2. **User & Session Agent** -- Owns User, UserSession, CogneeMemory, MemorySource.
3. **Task Management Agent** -- Owns TaskStatus, TaskPriority with their methods.
4. **Protocol Server Agent** -- Owns MCPServer, LSPServer, ACPServer.
5. **LSP/Code Intelligence Agent** -- Owns CodeIntelligence, Diagnostic, CompletionItem, HoverInfo, Location, Range, Position, SymbolInfo, SemanticTokens, WorkspaceEdit, TextEdit.

### Coordination Rules

- **LLMRequest/LLMResponse changes** require coordination with all agents using these types. These are foundational types used throughout the system.
- **TaskStatus/TaskPriority changes** affect task management systems. Coordinate with agents working on background processing.
- **Protocol server type changes** affect MCP/LSP/ACP integration points.
- **LSP type changes** affect code intelligence systems.

### Safe Parallel Changes

These changes can be made simultaneously without coordination:
- Adding new fields to existing structs (if they don't break serialization)
- Adding new helper methods to existing types
- Adding new types that don't affect existing types
- Updating documentation
- Adding new test cases

### Changes Requiring Coordination

- Removing or renaming existing fields (breaks JSON/database serialization)
- Changing field types (breaks compatibility)
- Modifying method signatures on TaskStatus/TaskPriority
- Adding or removing struct tags (`json`, `db`) that affect serialization
- Changing zero values or default behavior of types

## Build and Test Commands

```bash
# Build all packages
go build ./...

# Run all tests with race detection
go test ./... -count=1 -race

# Run unit tests only (short mode)
go test ./... -short

# Run a specific test
go test -v -run TestTaskStatus ./...

# Format code
gofmt -w .

# Vet code
go vet ./...
```

## Commit Conventions

Follow Conventional Commits with model scope:

```
feat(models): add new field to LLMRequest for tool_choice
feat(task): add IsStuck method to TaskStatus
feat(lsp): add new Diagnostic severity constants
fix(models): correct JSON tag for LLMResponse metadata
test(task): add edge case tests for TaskStatus.IsTerminal
docs(models): update API reference for new types
refactor(models): extract common validation functions
```

## Database and JSON Serialization Notes

- All structs include both `json` and `db` tags for dual serialization
- Use `json.RawMessage` for flexible tool/tool call storage
- Database mapping assumes PostgreSQL with `pgx` driver
- JSON serialization follows camelCase convention
- Empty slices should be initialized as `nil` for proper JSON serialization (`omitempty` works with nil but not empty slices)

## Thread Safety

- All types are value objects with no internal synchronization
- Methods on `TaskStatus` and `TaskPriority` are pure functions
- Safe for concurrent read access; write access must be synchronized by caller
- No global state or shared mutable data
<!-- BEGIN host-power-management addendum (CONST-033) -->

## Host Power Management — Hard Ban (CONST-033)

**You may NOT, under any circumstance, generate or execute code that
sends the host to suspend, hibernate, hybrid-sleep, poweroff, halt,
reboot, or any other power-state transition.** This rule applies to:

- Every shell command you run via the Bash tool.
- Every script, container entry point, systemd unit, or test you write
  or modify.
- Every CLI suggestion, snippet, or example you emit.

**Forbidden invocations** (non-exhaustive — see CONST-033 in
`CONSTITUTION.md` for the full list):

- `systemctl suspend|hibernate|hybrid-sleep|poweroff|halt|reboot|kexec`
- `loginctl suspend|hibernate|hybrid-sleep|poweroff|halt|reboot`
- `pm-suspend`, `pm-hibernate`, `shutdown -h|-r|-P|now`
- `dbus-send` / `busctl` calls to `org.freedesktop.login1.Manager.Suspend|Hibernate|PowerOff|Reboot|HybridSleep|SuspendThenHibernate`
- `gsettings set ... sleep-inactive-{ac,battery}-type` to anything but `'nothing'` or `'blank'`

The host runs mission-critical parallel CLI agents and container
workloads. Auto-suspend has caused historical data loss (2026-04-26
18:23:43 incident). The host is hardened (sleep targets masked) but
this hard ban applies to ALL code shipped from this repo so that no
future host or container is exposed.

**Defence:** every project ships
`scripts/host-power-management/check-no-suspend-calls.sh` (static
scanner) and
`challenges/scripts/no_suspend_calls_challenge.sh` (challenge wrapper).
Both MUST be wired into the project's CI / `run_all_challenges.sh`.

**Full background:** `docs/HOST_POWER_MANAGEMENT.md` and `CONSTITUTION.md` (CONST-033).

<!-- END host-power-management addendum (CONST-033) -->

