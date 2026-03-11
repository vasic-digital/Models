package models

import (
	"encoding/json"
	"time"
)

// MCPServer represents an MCP server configuration in the database
// Maps to the mcp_servers table from migration 003
type MCPServer struct {
	ID        string          `json:"id" db:"id"`
	Name      string          `json:"name" db:"name"`
	Type      string          `json:"type" db:"type"` // "local" or "remote"
	Command   *string         `json:"command,omitempty" db:"command"`
	URL       *string         `json:"url,omitempty" db:"url"`
	Enabled   bool            `json:"enabled" db:"enabled"`
	Tools     json.RawMessage `json:"tools" db:"tools"`
	LastSync  time.Time       `json:"last_sync" db:"last_sync"`
	CreatedAt time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt time.Time       `json:"updated_at" db:"updated_at"`
}

// LSPServer represents an LSP server configuration in the database
// Maps to the lsp_servers table from migration 003
type LSPServer struct {
	ID           string          `json:"id" db:"id"`
	Name         string          `json:"name" db:"name"`
	Language     string          `json:"language" db:"language"`
	Command      string          `json:"command" db:"command"`
	Enabled      bool            `json:"enabled" db:"enabled"`
	Workspace    string          `json:"workspace" db:"workspace"`
	Capabilities json.RawMessage `json:"capabilities" db:"capabilities"`
	LastSync     time.Time       `json:"last_sync" db:"last_sync"`
	CreatedAt    time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at" db:"updated_at"`
}

// ACPServer represents an ACP server configuration in the database
// Maps to the acp_servers table from migration 003
type ACPServer struct {
	ID        string          `json:"id" db:"id"`
	Name      string          `json:"name" db:"name"`
	Type      string          `json:"type" db:"type"` // "local" or "remote"
	URL       *string         `json:"url,omitempty" db:"url"`
	Enabled   bool            `json:"enabled" db:"enabled"`
	Tools     json.RawMessage `json:"tools" db:"tools"`
	LastSync  time.Time       `json:"last_sync" db:"last_sync"`
	CreatedAt time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt time.Time       `json:"updated_at" db:"updated_at"`
}

// EmbeddingConfig represents embedding configuration in the database
// Maps to the embedding_config table from migration 003
type EmbeddingConfig struct {
	ID          int       `json:"id" db:"id"`
	Provider    string    `json:"provider" db:"provider"`
	Model       string    `json:"model" db:"model"`
	Dimension   int       `json:"dimension" db:"dimension"`
	APIEndpoint *string   `json:"api_endpoint,omitempty" db:"api_endpoint"`
	APIKey      *string   `json:"-" db:"api_key"` // Hidden from JSON serialization
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// VectorDocument represents a document with vector embedding in the database
// Maps to the vector_documents table from migration 003
type VectorDocument struct {
	ID                string          `json:"id" db:"id"`
	Title             string          `json:"title" db:"title"`
	Content           string          `json:"content" db:"content"`
	Metadata          json.RawMessage `json:"metadata" db:"metadata"`
	EmbeddingID       *string         `json:"embedding_id,omitempty" db:"embedding_id"`
	Embedding         []float32       `json:"-" db:"embedding"` // Vector data, not JSON serialized
	EmbeddingProvider string          `json:"embedding_provider" db:"embedding_provider"`
	SearchVector      []float32       `json:"-" db:"search_vector"` // Vector data, not JSON serialized
	CreatedAt         time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt         time.Time       `json:"updated_at" db:"updated_at"`
}

// ProtocolCache represents cached protocol data in the database
// Maps to the protocol_cache table from migration 003
type ProtocolCache struct {
	CacheKey  string          `json:"cache_key" db:"cache_key"`
	CacheData json.RawMessage `json:"cache_data" db:"cache_data"`
	ExpiresAt time.Time       `json:"expires_at" db:"expires_at"`
	CreatedAt time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt time.Time       `json:"updated_at" db:"updated_at"`
}

// ProtocolMetrics represents protocol operation metrics in the database
// Maps to the protocol_metrics table from migration 003
type ProtocolMetrics struct {
	ID           int             `json:"id" db:"id"`
	ProtocolType string          `json:"protocol_type" db:"protocol_type"` // "mcp", "lsp", "acp", "embedding"
	ServerID     *string         `json:"server_id,omitempty" db:"server_id"`
	Operation    string          `json:"operation" db:"operation"`
	Status       string          `json:"status" db:"status"` // "success", "error", "timeout"
	DurationMs   *int            `json:"duration_ms,omitempty" db:"duration_ms"`
	ErrorMessage *string         `json:"error_message,omitempty" db:"error_message"`
	Metadata     json.RawMessage `json:"metadata" db:"metadata"`
	CreatedAt    time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at" db:"updated_at"`
}

// ProtocolType constants
const (
	ProtocolTypeMCP       = "mcp"
	ProtocolTypeLSP       = "lsp"
	ProtocolTypeACP       = "acp"
	ProtocolTypeEmbedding = "embedding"
)

// MetricsStatus constants
const (
	MetricsStatusSuccess = "success"
	MetricsStatusError   = "error"
	MetricsStatusTimeout = "timeout"
)

// ServerType constants
const (
	ServerTypeLocal  = "local"
	ServerTypeRemote = "remote"
)

// MCPTool represents a tool exposed by an MCP server
type MCPTool struct {
	Name        string          `json:"name"`
	Description string          `json:"description"`
	InputSchema json.RawMessage `json:"input_schema,omitempty"`
}

// LSPCapability represents a capability of an LSP server
type LSPCapability struct {
	Name     string `json:"name"`
	Enabled  bool   `json:"enabled"`
	Provider string `json:"provider,omitempty"`
}

// VectorSearchResult represents a result from vector similarity search
type VectorSearchResult struct {
	Document   *VectorDocument `json:"document"`
	Similarity float64         `json:"similarity"`
	Distance   float64         `json:"distance"`
}
