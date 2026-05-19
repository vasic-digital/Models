#!/usr/bin/env bash
# models_describe_challenge.sh
#
# Round-268 paired-mutation deep-doc challenge for digital.vasic.models.
#
# Validates that:
#   1. The deep-doc ledger (docs/test-coverage.md) lists every exported
#      symbol from types.go, protocol_types.go, and background_task.go.
#   2. The multi-locale fixture
#      (tests/fixtures/models/payloads.json) parses and contains at
#      least 3 locales.
#   3. The multi-locale runner (challenges/runner/main.go) builds and
#      runs, byte-preserving non-ASCII payloads through real models
#      package surface across NewBackgroundTask, TaskStatus/Priority
#      helpers, LLMRequest/Response/Message/Tool/User/UserSession/
#      CogneeMemory JSON round-trips, MCP/LSP/ACP server round-trips,
#      ProtocolMetrics, CodeIntelligence + Diagnostic +
#      CompletionItem + WorkspaceEdit/TextEdit, lifecycle payloads,
#      and ProviderCapabilities/LLMProvider/EnsembleConfig/VectorDoc.
#   4. The README enumerates the round-268 anti-bluff guarantees.
#
# Paired-mutation invariant (CONST-035 + CONST-050(B)):
#   With --anti-bluff-mutate the script plants a deliberate symbol-rename
#   mutation in a tmp copy of the ledger (TaskStatus ->
#   TaskStatus_MUTATED), reruns validation, and asserts the gate
#   FAILS with exit 99. This proves the gate actually catches
#   ledger-vs-source drift instead of rubber-stamping it.
#
# Exit codes:
#   0  — gate PASS on clean tree
#   1  — gate FAIL on clean tree (real failure to fix)
#   99 — paired-mutation correctly detected (good — proves anti-bluff)
#   2  — usage / environment error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

MUTATE=0
for arg in "$@"; do
    case "$arg" in
        --anti-bluff-mutate) MUTATE=1 ;;
        --help|-h)
            sed -n '1,32p' "$0"
            exit 0
            ;;
        *)
            echo "unknown argument: $arg" >&2
            exit 2
            ;;
    esac
done

PASS=0
FAIL=0
TOTAL=0

pass() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); echo "  FAIL: $1"; }

LEDGER="${MODULE_DIR}/docs/test-coverage.md"
FIXTURE="${MODULE_DIR}/tests/fixtures/models/payloads.json"
RUNNER="${MODULE_DIR}/challenges/runner/main.go"
README="${MODULE_DIR}/README.md"

LEDGER_WORK="${LEDGER}"
TMP_LEDGER=""
if [ "${MUTATE}" -eq 1 ]; then
    TMP_LEDGER="$(mktemp)"
    cp "${LEDGER}" "${TMP_LEDGER}"
    # Plant a rename so the symbol no longer matches what the source declares.
    sed -i 's/TaskStatus/TaskStatus_MUTATED/g' "${TMP_LEDGER}"
    LEDGER_WORK="${TMP_LEDGER}"
    echo "=== Models Describe Challenge (anti-bluff-mutate mode) ==="
else
    echo "=== Models Describe Challenge (clean mode) ==="
fi
echo ""

# Section 1: ledger presence and freshness
echo "Section 1: docs/test-coverage.md ledger"
if [ ! -f "${LEDGER_WORK}" ]; then
    fail "ledger missing at ${LEDGER_WORK}"
else
    pass "ledger present"
    if grep -q "round-268" "${LEDGER_WORK}"; then
        pass "ledger marked round-268"
    else
        fail "ledger missing round-268 marker"
    fi
    if grep -q "execution of tests and Challenges MUST guarantee" "${LEDGER_WORK}"; then
        pass "ledger carries Article XI §11.9 mandate"
    else
        fail "ledger missing Article XI §11.9 mandate"
    fi
fi

# Section 2: every exported package symbol appears in ledger.
echo ""
echo "Section 2: structural symbol cross-reference"

EXPECTED_SYMBOLS=(
    # background_task.go
    "TaskStatus" "TaskStatusPending" "TaskStatusQueued" "TaskStatusRunning"
    "TaskStatusPaused" "TaskStatusCompleted" "TaskStatusFailed" "TaskStatusStuck"
    "TaskStatusCancelled" "TaskStatusDeadLetter"
    "TaskPriority" "TaskPriorityCritical" "TaskPriorityHigh" "TaskPriorityNormal"
    "TaskPriorityLow" "TaskPriorityBackground"
    "BackgroundTask" "TaskConfig" "DefaultTaskConfig" "NotificationConfig"
    "WebhookConfig" "SSEConfig" "WSConfig" "ResourceSnapshot"
    "TaskExecutionHistory" "DeadLetterTask" "WebhookDelivery" "TaskError"
    "TaskLogEntry" "TaskProgressUpdate" "NewBackgroundTask"
    "CanRetry" "CanPause" "CanCancel" "CanResume" "Duration" "IsOverdue"
    "HasStaleHeartbeat" "IsTerminal" "IsActive" "Weight"
    "TaskEventCreated" "TaskEventStarted" "TaskEventCompleted" "TaskEventFailed"
    # types.go
    "User" "LLMProvider" "LLMRequest" "Tool" "ToolFunction" "LLMResponse"
    "ToolCall" "ToolCallFunction" "Message" "ModelParameters" "EnsembleConfig"
    "UserSession" "CogneeMemory" "MemorySource" "ProviderCapabilities"
    "ModelLimits" "CodeIntelligence" "Diagnostic" "DiagnosticRelatedInformation"
    "CompletionItem" "HoverInfo" "Location" "Range" "Position" "SymbolInfo"
    "SemanticTokens" "WorkspaceEdit" "TextEdit"
    # protocol_types.go
    "MCPServer" "LSPServer" "ACPServer" "EmbeddingConfig" "VectorDocument"
    "ProtocolCache" "ProtocolMetrics" "MCPTool" "LSPCapability" "VectorSearchResult"
    "ProtocolTypeMCP" "ProtocolTypeLSP" "ProtocolTypeACP" "ProtocolTypeEmbedding"
    "MetricsStatusSuccess" "MetricsStatusError" "MetricsStatusTimeout"
    "ServerTypeLocal" "ServerTypeRemote"
)

CHECKED=0
MISSING=0
for sym in "${EXPECTED_SYMBOLS[@]}"; do
    CHECKED=$((CHECKED + 1))
    if grep -qE "\\b${sym}\\b" "${LEDGER_WORK}"; then
        : # found
    else
        fail "ledger missing symbol ${sym}"
        MISSING=$((MISSING + 1))
    fi
done
if [ "${MISSING}" -eq 0 ]; then
    pass "all ${CHECKED} structural symbols cross-referenced in ledger"
fi

# Section 3: multi-locale fixture sanity
echo ""
echo "Section 3: multi-locale fixture"
if [ ! -f "${FIXTURE}" ]; then
    fail "fixture missing at ${FIXTURE}"
else
    pass "fixture present"
    LOCALE_COUNT=$(grep -oE '"locale":\s*"[^"]+"' "${FIXTURE}" | sort -u | wc -l)
    if [ "${LOCALE_COUNT}" -ge 3 ]; then
        pass "fixture covers ${LOCALE_COUNT} locales (>=3)"
    else
        fail "fixture covers only ${LOCALE_COUNT} locales (<3)"
    fi
fi

# Section 4: runner builds + runs against every section
echo ""
echo "Section 4: multi-locale runner build + run (real models package surface)"
if [ ! -f "${RUNNER}" ]; then
    fail "runner missing at ${RUNNER}"
else
    pass "runner source present"
    cd "${MODULE_DIR}"
    if go build -o /tmp/models_round268_runner ./challenges/runner/ 2>/tmp/models_build.log; then
        pass "runner builds"
        if /tmp/models_round268_runner -fixtures "${FIXTURE}" > /tmp/models_run.log 2>&1; then
            pass "runner exit 0 across every section + locale"
            if grep -q "PASS: \[Section1\]\[constants\]" /tmp/models_run.log; then
                pass "Section 1 TaskStatus/TaskPriority constants audited"
            else
                fail "Section 1 constants audit missing"
            fi
            if grep -q "PASS: \[Section2\]\[NewBackgroundTask+transitions\]\[sr\]" /tmp/models_run.log; then
                pass "Section 2 NewBackgroundTask Cyrillic (sr) lifecycle"
            else
                fail "Section 2 sr NewBackgroundTask missing"
            fi
            if grep -q "PASS: \[Section2\]\[NewBackgroundTask+transitions\]\[ja\]" /tmp/models_run.log; then
                pass "Section 2 NewBackgroundTask Japanese (ja) lifecycle"
            else
                fail "Section 2 ja NewBackgroundTask missing"
            fi
            if grep -q "PASS: \[Section3\]\[LLM+User+Session+Cognee round-trip\]\[ar\]" /tmp/models_run.log; then
                pass "Section 3 LLM+User round-trip Arabic (ar)"
            else
                fail "Section 3 ar round-trip missing"
            fi
            if grep -q "PASS: \[Section3\]\[LLM+User+Session+Cognee round-trip\]\[zh-CN\]" /tmp/models_run.log; then
                pass "Section 3 LLM+User round-trip Han (zh-CN)"
            else
                fail "Section 3 zh-CN round-trip missing"
            fi
            if grep -q "PASS: \[Section4\]\[MCP+LSP+ACP\]\[sr\]" /tmp/models_run.log; then
                pass "Section 4 MCP+LSP+ACP Cyrillic (sr)"
            else
                fail "Section 4 sr MCP+LSP+ACP missing"
            fi
            if grep -q "PASS: \[Section5\]\[ProtocolMetrics\]\[ja\]" /tmp/models_run.log; then
                pass "Section 5 ProtocolMetrics Japanese (ja)"
            else
                fail "Section 5 ja ProtocolMetrics missing"
            fi
            if grep -q "PASS: \[Section6\]\[CodeIntelligence+WorkspaceEdit\]\[ar\]" /tmp/models_run.log; then
                pass "Section 6 CodeIntelligence Arabic (ar)"
            else
                fail "Section 6 ar CodeIntelligence missing"
            fi
            if grep -q "PASS: \[Section7\]\[lifecycle\]\[zh-CN\]" /tmp/models_run.log; then
                pass "Section 7 lifecycle payloads Han (zh-CN)"
            else
                fail "Section 7 zh-CN lifecycle missing"
            fi
            if grep -q "PASS: \[Section8\]\[Capabilities+Provider+Ensemble+VectorDoc\]\[en\]" /tmp/models_run.log; then
                pass "Section 8 Capabilities+Provider+Ensemble english"
            else
                fail "Section 8 en Capabilities missing"
            fi
        else
            fail "runner exit non-zero — see /tmp/models_run.log"
            sed -n '1,80p' /tmp/models_run.log
        fi
    else
        fail "runner build failed — see /tmp/models_build.log"
        sed -n '1,40p' /tmp/models_build.log
    fi
    rm -f /tmp/models_round268_runner
fi

# Section 5: README round-268 anti-bluff section
echo ""
echo "Section 5: README round-268 anti-bluff section"
if grep -q "Anti-bluff guarantees" "${README}"; then
    pass "README declares Anti-bluff guarantees"
else
    fail "README missing Anti-bluff guarantees section"
fi
if grep -q "round-268" "${README}"; then
    pass "README marked round-268"
else
    fail "README missing round-268 marker"
fi

# Cleanup mutated ledger if any
if [ -n "${TMP_LEDGER}" ]; then
    rm -f "${TMP_LEDGER}"
fi

echo ""
echo "=== Summary: ${PASS}/${TOTAL} PASS, ${FAIL} FAIL ==="

if [ "${MUTATE}" -eq 1 ]; then
    if [ "${FAIL}" -gt 0 ]; then
        echo "anti-bluff-mutate: gate correctly detected planted mutation (exit 99)"
        exit 99
    else
        echo "anti-bluff-mutate: gate FAILED to detect planted mutation — bluff!"
        exit 1
    fi
fi

if [ "${FAIL}" -gt 0 ]; then
    exit 1
fi
exit 0
