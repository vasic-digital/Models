# Models Schema Reference

## Core Data Types

### User
| Field | Type | JSON | DB | Description |
|-------|------|------|----|-------------|
| ID | string | `id` | `id` | Unique user identifier |
| Username | string | `username` | `username` | Display name |
| Email | string | `email` | `email` | Email address |
| PasswordHash | string | `-` (hidden) | `password_hash` | Bcrypt hash |
| APIKey | string | `api_key` | `api_key` | API authentication key |
| Role | string | `role` | `role` | User role (admin, user) |
| CreatedAt | time.Time | `created_at` | `created_at` | Creation timestamp |
| UpdatedAt | time.Time | `updated_at` | `updated_at` | Last update timestamp |

### LLMProvider
| Field | Type | JSON | Description |
|-------|------|------|-------------|
| ID | string | `id` | Provider identifier |
| Name | string | `name` | Display name |
| Type | string | `type` | Provider type (openai, claude, etc.) |
| APIKey | string | `-` (hidden) | API key (never serialized) |
| BaseURL | string | `base_url` | Provider API endpoint |
| Model | string | `model` | Default model |
| Weight | float64 | `weight` | Ensemble voting weight |
| Enabled | bool | `enabled` | Active status |
| HealthStatus | string | `health_status` | Current health |
| ResponseTime | int64 | `response_time` | Avg response ms |

### LLMRequest
| Field | Type | Description |
|-------|------|-------------|
| ID | string | Request identifier |
| SessionID | string | Session context |
| UserID | string | Requesting user |
| Prompt | string | Text prompt |
| Messages | []Message | Chat messages |
| ModelParams | ModelParameters | Temperature, max tokens, etc. |
| EnsembleConfig | *EnsembleConfig | Multi-provider config |
| Tools | []Tool | Available tools (OpenAI format) |
| ToolChoice | interface{} | Tool selection strategy |

### LLMResponse
| Field | Type | Description |
|-------|------|-------------|
| ID | string | Response identifier |
| Content | string | Generated text |
| Provider | string | Responding provider |
| Model | string | Model used |
| TokensUsed | TokenUsage | Input/output token counts |
| FinishReason | string | Completion reason |

## Protocol Types

See `protocol_types.go` for MCP, ACP, LSP, and streaming types.

## Background Task Types

See `background_task.go` for task queue data models.
