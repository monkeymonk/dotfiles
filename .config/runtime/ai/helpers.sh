# AI/LLM helper functions — backend-agnostic (ollama or llama.cpp).
#
# Sourced by plugins/ai.sh after ai/env.sh. All text callers route through
# _llm_run <role> "<prompt>" and image callers through _llm_image — roles
# resolve to concrete model IDs via the AI_MODEL_* env vars (same namespace
# for both backends).
#
# Add a new helper by writing a one-liner that invokes _llm_run (or
# _llm_file / _llm_image) with the appropriate role and prompt. Do NOT
# call `ollama` or `curl $LLAMA_HOST` directly from helpers — that leaks
# backend details everywhere. The only exceptions are _llm_run and
# _llm_image themselves (they own the dispatch) and _llm_code (interactive
# session, ollama-only by design).

# Simple re-source guard.
[ "${_AI_HELPERS_LOADED:-0}" = 1 ] && return 0
_AI_HELPERS_LOADED=1

# ─────────────────────────────────────────────────────────────────────────
# Backend dispatch
# ─────────────────────────────────────────────────────────────────────────

# Pick a backend. Respects $AI_BACKEND if explicitly set to llama|ollama;
# otherwise prefers llama-swap (if the endpoint answers) then ollama.
_llm_backend() {
    case "$AI_BACKEND" in
        llama|ollama) printf '%s\n' "$AI_BACKEND"; return ;;
    esac
    if command -v llama-swap >/dev/null 2>&1 \
            && curl -sf -m 1 "http://${LLAMA_HOST:-127.0.0.1:8080}/v1/models" >/dev/null 2>&1; then
        printf 'llama\n'
    elif command -v ollama >/dev/null 2>&1; then
        printf 'ollama\n'
    else
        printf 'none\n'
    fi
}

# Ensure a backend is reachable; auto-start llama-swap if missing.
# Returns 0 when a backend is ready, non-zero otherwise.
_llm_ensure_backend() {
    [ "$(_llm_backend)" != "none" ] && return 0
    [ "$AI_BACKEND" = "ollama" ] && return 1
    [ "$AI_AUTOSTART" = "0" ] && return 1
    command -v llama-swap >/dev/null 2>&1 || return 1
    if [ ! -f "$LLAMA_SWAP_CONFIG" ]; then
        printf 'llm: LLAMA_SWAP_CONFIG not found: %s\n' "$LLAMA_SWAP_CONFIG" >&2
        return 1
    fi

    local _log="${XDG_STATE_HOME:-$HOME/.local/state}/llama-swap.log"
    mkdir -p "$(dirname "$_log")"
    printf 'llm: starting llama-swap on %s (logs: %s)\n' "$LLAMA_HOST" "$_log" >&2
    nohup llama-swap -config "$LLAMA_SWAP_CONFIG" -listen "$LLAMA_HOST" -watch-config \
        >"$_log" 2>&1 &
    disown 2>/dev/null || true

    # Poll /v1/models until ready or timeout (~10 s; the proxy starts fast).
    local _i=0
    while [ "$_i" -lt 20 ]; do
        curl -sf -m 1 "http://${LLAMA_HOST}/v1/models" >/dev/null 2>&1 && return 0
        sleep 0.5
        _i=$((_i + 1))
    done
    printf 'llm: llama-swap failed to come up within 10s — check %s\n' "$_log" >&2
    return 1
}

# Run curl + jq, printing a readable error if the server returns non-JSON.
# Args: <url> <payload> [jq-filter]
_llm_call_json() {
    local _url="$1" _payload="$2" _filter="${3:-.}"
    local _response _status
    _response=$(curl -sS "$_url" -H 'Content-Type: application/json' -d "$_payload" 2>&1)
    _status=$?
    if [ "$_status" -ne 0 ]; then
        printf 'llm: curl failed (%d):\n%s\n' "$_status" "$_response" >&2
        return "$_status"
    fi
    if ! printf '%s' "$_response" | jq -e . >/dev/null 2>&1; then
        printf 'llm: server returned non-JSON:\n%s\n' "$_response" >&2
        return 1
    fi
    printf '%s' "$_response" | jq -r "$_filter"
}

# role → concrete model id. Backend-agnostic: each role maps to a single
# AI_MODEL_* env var, applied identically to llama-swap and ollama.
_llm_model() {
    local _role="${1:-default}"
    case "$_role" in
        default) printf '%s\n' "${AI_MODEL_DEFAULT:-default}" ;;
        code)    printf '%s\n' "${AI_MODEL_CODE:-code}" ;;
        reason)  printf '%s\n' "${AI_MODEL_REASON:-reason}" ;;
        fast)    printf '%s\n' "${AI_MODEL_FAST:-fast}" ;;
        embed)   printf '%s\n' "${AI_MODEL_EMBED:-embed}" ;;
        vision)  printf '%s\n' "${AI_MODEL_VISION:-vision}" ;;
        ocr)     printf '%s\n' "${AI_MODEL_OCR:-ocr}" ;;
        *)       printf '%s\n' "$_role" ;;  # pass-through (treat as literal model id)
    esac
}

# _llm_run <role> "<prompt>"
# Reads optional stdin as context, appended after two newlines.
# Prints the assistant's response to stdout.
_llm_run() {
    local _role="${1:-default}"; shift
    local _prompt="$*"
    local _stdin="" _backend _model _content _payload

    if [ ! -t 0 ]; then _stdin=$(cat); fi

    _llm_ensure_backend || return 1

    _backend=$(_llm_backend)
    _model=$(_llm_model "$_role")

    case "$_backend" in
        llama)
            if [ -n "$_stdin" ]; then
                _content="${_prompt}"$'\n\n'"${_stdin}"
            else
                _content="$_prompt"
            fi
            _payload=$(jq -n --arg m "$_model" --arg c "$_content" \
                '{model:$m, messages:[{role:"user",content:$c}], stream:false}')
            _llm_call_json "http://${LLAMA_HOST}/v1/chat/completions" \
                "$_payload" '.choices[0].message.content // empty'
            ;;
        ollama)
            if [ -n "$_stdin" ]; then
                printf '%s' "$_stdin" | ollama run "$_model" "$_prompt"
            else
                ollama run "$_model" "$_prompt"
            fi
            ;;
        none)
            printf 'llm: no AI backend available — start llama-swap (llama-swap-up) or install ollama\n' >&2
            return 1
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────
# File-arg helpers
# ─────────────────────────────────────────────────────────────────────────

# _llm_file <role> <file> "<prompt>"  — validate file, pipe into _llm_run.
_llm_file() {
    local _role="$1" _file="$2" _prompt="$3"
    [ -n "$_file" ] || { echo "Usage: <cmd> <file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: file not found: $_file"; return 1; }
    cat "$_file" | _llm_run "$_role" "$_prompt"
}

# _llm_nvim_md <title>  — read markdown body from stdin, write it under a
# top-level heading, open result in Neovim. Callers compose the body in the
# parent shell so shell functions (_llm_run, etc.) stay reachable.
_llm_nvim_md() {
    local _title="$1"
    local _tmp; _tmp=$(mktemp --suffix=.md)
    { printf '# %s\n\n' "$_title"; cat; } > "$_tmp"
    nvim "$_tmp" -c "set filetype=markdown"
}

# _llm_edit_split <role> "<prompt>" <file> <outfile> [nvim-flag]
# Run the prompt over <file>, write the response to <outfile>, open both in
# nvim. Default split is -O (vertical); pass -d for diff view or -O/-o as
# needed.
_llm_edit_split() {
    local _role="$1" _prompt="$2" _file="$3" _out="$4" _flag="${5:--O}"
    [ -f "$_file" ] || { echo "Error: file not found: $_file"; return 1; }
    cat "$_file" | _llm_run "$_role" "$_prompt" > "$_out"
    nvim "$_flag" "$_file" "$_out"
}

# ─────────────────────────────────────────────────────────────────────────
# Code understanding
# ─────────────────────────────────────────────────────────────────────────

_llm_explain() {
    _llm_file default "$1" \
        "Explain this code concisely — what it does and why:"
}

_llm_summary() {
    [ -n "$1" ] || { echo "Usage: llm-summary <file|dir>"; return 1; }
    if [ -f "$1" ]; then
        _llm_file default "$1" \
            "Summarize this file's purpose, key components, and dependencies. Be concise."
    elif [ -d "$1" ]; then
        { tree -L 2 "$1" 2>/dev/null || find "$1" -maxdepth 2 -type f; } \
            | _llm_run default \
                "Based on this structure, describe what this directory contains and its purpose. Be concise."
    else
        echo "Error: not a file or directory: $1"; return 1
    fi
}

_llm_arch() {
    local _dir="${1:-.}"
    [ -d "$_dir" ] || { echo "Error: directory not found: $_dir"; return 1; }
    { tree -L 3 -I 'node_modules|venv|__pycache__|.git|dist|build' "$_dir" 2>/dev/null \
        || find "$_dir" -type f -not -path '*/node_modules/*' -not -path '*/.git/*' | head -50; } \
        | _llm_run default "Based on this project structure, provide:
1. Architecture pattern (MVC, layered, microservices, etc.)
2. Technology stack
3. Key components and their roles
4. Data flow
5. Potential improvements or concerns
Be concise and insightful."
}

# ─────────────────────────────────────────────────────────────────────────
# Git integration
# ─────────────────────────────────────────────────────────────────────────

_llm_review() {
    local _diff="git diff --staged"
    [ -n "$1" ] && _diff="git diff $1"
    $_diff | _llm_run reason \
        "Review this git diff. Focus on: bugs, security issues, best practices, improvements. Be concise."
}

_llm_commit() {
    if git diff --cached --quiet; then
        echo "No staged changes to commit"; return 1
    fi
    local _msg _reply
    _msg=$(git diff --cached | _llm_run fast \
        "Generate a concise git commit message (50 chars max). Format: '<type>: <description>'. Types: feat, fix, docs, style, refactor, test, chore. Output ONLY the commit message, nothing else.")
    echo "Suggested commit message:"
    echo "$_msg"
    echo
    printf 'Use this message? (y/n) '
    read -r _reply
    case "$_reply" in [Yy]*) git commit -m "$_msg" ;; esac
}

# ─────────────────────────────────────────────────────────────────────────
# Shell assistance
# ─────────────────────────────────────────────────────────────────────────

_llm_cmd() {
    [ -n "$1" ] || { echo "Usage: llm-cmd \"<question>\""; return 1; }
    _llm_run default \
        "You are a shell command expert. Answer concisely with the command and a brief explanation. Question: $*"
}

_llm_explain_cmd() {
    local _cmd
    _cmd="${*:-$(cat)}"
    [ -n "$_cmd" ] || { echo "Usage: llm-explain-cmd <command>  OR  echo <cmd> | llm-explain-cmd"; return 1; }
    printf '%s\n' "$_cmd" | _llm_run default \
        "Explain this shell command concisely, breaking down each part:"
}

# ─────────────────────────────────────────────────────────────────────────
# Code quality — refactor / optimize / security / tests / docs
# ─────────────────────────────────────────────────────────────────────────

_llm_refactor() {
    _llm_file code "$1" \
        "Suggest refactoring improvements — readability, performance, maintainability, best practices. Be specific and concise."
}

_llm_optimize() {
    _llm_file code "$1" \
        "Suggest performance optimizations — algorithmic, memory, execution speed. Provide specific code suggestions."
}

_llm_test() {
    _llm_file code "$1" \
        "Generate test cases covering happy paths, edge cases, error conditions. Use the appropriate testing framework for the language."
}

_llm_doc() {
    _llm_file default "$1" \
        "Generate concise documentation — purpose, usage, parameters, return values, examples. Use markdown."
}

_llm_security() {
    local _file="$1"
    [ -n "$_file" ] || { echo "Usage: llm-security <file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: file not found: $_file"; return 1; }
    {
        cat "$_file" | _llm_run reason 'Perform a security audit. Check for:
- SQL/command/path injection
- XSS
- Auth/authz issues
- Cryptographic weaknesses
- Input validation
- Sensitive data exposure
For each issue: severity, location, explanation, fix.'
        printf '\n---\n## Original Code\n```\n'
        cat "$_file"
        printf '\n```\n'
    } | _llm_nvim_md "Security Analysis: $_file"
}

_llm_debug() {
    [ -n "$1" ] || { echo "Usage: llm-debug \"<error>\""; return 1; }
    _llm_run reason "I'm getting this error: $*

Help me debug. Provide: 1) likely causes, 2) how to investigate, 3) potential solutions. Be concise."
}

_llm_fix() {
    local _file="$1" _ctx="${2:-last error in this file}"
    [ -n "$_file" ] || { echo "Usage: llm-fix <file> [error]"; return 1; }
    [ -f "$_file" ] || { echo "Error: file not found: $_file"; return 1; }
    {
        printf '## Error Context\n%s\n\n## Analysis & Solution\n' "$_ctx"
        cat "$_file" | _llm_run reason "This code has an error: $_ctx

Provide: 1) Root cause, 2) Exact fix (show code changes), 3) Why this fixes it. Be concise and actionable."
    } | _llm_nvim_md "Quick Fix: $_file"
}

# ─────────────────────────────────────────────────────────────────────────
# Development flow — convert / implement / api-client
# ─────────────────────────────────────────────────────────────────────────

_llm_convert() {
    [ -n "$1" ] || { echo "Usage: <input> | llm-convert \"<instruction>\""; return 1; }
    local _instr="$*" _input
    _input=$(cat)
    [ -n "$_input" ] || { echo "Error: no input"; return 1; }
    printf '%s' "$_input" | _llm_run code "Task: $_instr

Output ONLY the converted code, no explanations or markdown."
}

_llm_implement() {
    [ -n "$1" ] || { echo "Usage: llm-implement \"<feature>\""; return 1; }
    local _feature="$*" _context=""
    if   [ -f package.json     ]; then _context="Project uses: $(grep -o '"[^"]*"' package.json | head -5 | tr '\n' ' ')"
    elif [ -f requirements.txt ]; then _context="Python project with: $(head -5 requirements.txt | tr '\n' ' ')"
    elif [ -f go.mod           ]; then _context="Go project: $(head -1 go.mod)"
    fi
    {
        printf 'Context: %s\n\n' "$_context"
        _llm_run reason "Feature request: $_feature

Project context: $_context

Provide: 1) Step-by-step plan, 2) Required files and purpose, 3) Code examples, 4) Config changes, 5) Testing approach. Thorough but concise."
    } | _llm_nvim_md "Feature: $_feature"
}

_llm_api_client() {
    [ -n "$1" ] && [ -n "$2" ] || { echo "Usage: llm-api-client <spec> <language>"; return 1; }
    [ -f "$1" ] || { echo "Error: spec not found: $1"; return 1; }
    local _out="api-client.$2"
    echo "Generating $2 API client from $1..."
    _llm_file code "$1" "Generate a complete $2 API client for this OpenAPI spec. Include: type definitions, error handling, request/response interceptors, authentication, all endpoint methods. Clean, production-ready code." > "$_out"
    echo "Written: $_out"
    nvim "$_out"
}

# ─────────────────────────────────────────────────────────────────────────
# Interactive
# ─────────────────────────────────────────────────────────────────────────

_llm_code() {
    local _model="${1:-$AI_MODEL_CODE}"
    if command -v ollama >/dev/null 2>&1 && [ "$(_llm_backend)" = "ollama" ]; then
        echo "Starting ollama coding session with $_model (type /bye to exit)..."
        ollama run "$_model" "You are a coding assistant. Provide concise, practical code solutions. Prefer code over prose."
    else
        echo "Interactive mode only supported on the ollama backend."
        echo "For llama.cpp, use llm-cmd / llm-explain / llm-refactor one-shot commands,"
        echo "or point opencode at http://${LLAMA_HOST}/v1 for a proper REPL."
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────
# Edit-in-nvim variants (same content, open result in Neovim)
# ─────────────────────────────────────────────────────────────────────────

_llm_explain_edit() {
    local _f="$1"
    [ -f "$_f" ] || { echo "Usage: llm-explain-edit <file>"; return 1; }
    {
        cat "$_f" | _llm_run default 'Explain this code in detail — purpose, logic, dependencies, potential improvements.'
        printf '\n---\n## Original Code\n```\n'
        cat "$_f"
        printf '\n```\n'
    } | _llm_nvim_md "Code Explanation: $_f"
}

_llm_review_edit() {
    local _ref="${1-}" _title="Staged Changes" _diff_out
    [ -n "$_ref" ] && _title="Changes vs $_ref"
    if [ -n "$_ref" ]; then
        _diff_out=$(git diff "$_ref")
    else
        _diff_out=$(git diff --staged)
    fi
    {
        printf '%s\n' "$_diff_out" | _llm_run reason 'Review this git diff. Provide: 1) Summary, 2) Issues (bugs, security, performance), 3) Suggestions. Detailed and specific.'
        printf '\n---\n## Diff\n```diff\n%s\n```\n' "$_diff_out"
    } | _llm_nvim_md "Code Review: $_title"
}

_llm_refactor_edit() {
    [ -f "$1" ] || { echo "Usage: llm-refactor-edit <file>"; return 1; }
    local _tmp; _tmp=$(mktemp --suffix=.md)
    _llm_edit_split code \
        "Refactoring suggestions. 1) Current issues/smells, 2) Proposed refactorings with code, 3) Benefits." \
        "$1" "$_tmp"
}

_llm_test_edit() {
    [ -f "$1" ] || { echo "Usage: llm-test-edit <file>"; return 1; }
    local _dir _name _ext _test
    _dir=$(dirname "$1"); _name=$(basename "$1" | sed 's/\.[^.]*$//'); _ext="${1##*.}"
    case "$_ext" in
        js|ts|jsx|tsx) _test="$_dir/$_name.test.$_ext" ;;
        py)            _test="$_dir/test_$_name.$_ext" ;;
        go)            _test="$_dir/${_name}_test.$_ext" ;;
        *)             _test="$_dir/$_name.test.$_ext" ;;
    esac
    echo "Generating tests for $1..."
    _llm_edit_split code \
        "Generate comprehensive tests: setup, happy paths, edge cases, error conditions, cleanup. Use the language's standard test framework." \
        "$1" "$_test"
    echo "Written: $_test"
}

_llm_doc_edit() {
    [ -f "$1" ] || { echo "Usage: llm-doc-edit <file>"; return 1; }
    local _doc="$(dirname "$1")/$(basename "$1" | sed 's/\.[^.]*$//').md"
    echo "Generating docs for $1..."
    _llm_edit_split default \
        "Generate comprehensive markdown docs: overview, API reference, usage examples, configuration, edge cases." \
        "$1" "$_doc"
    echo "Written: $_doc"
}

_llm_optimize_edit() {
    [ -f "$1" ] || { echo "Usage: llm-optimize-edit <file>"; return 1; }
    local _tmp; _tmp=$(mktemp --suffix=".${1##*.}")
    echo "Generating optimized version of $1..."
    _llm_edit_split code \
        "Optimize this code for performance. Output ONLY the optimized code. Preserve functionality; improve complexity, memory, speed." \
        "$1" "$_tmp" -d
}

# ─────────────────────────────────────────────────────────────────────────
# Embeddings
# ─────────────────────────────────────────────────────────────────────────

_llm_embed() {
    local _input
    if   [ -n "$1" ] && [ -f "$1" ]; then _input=$(cat "$1")
    elif [ -n "$1" ];                then _input="$*"
    else                                  _input=$(cat); fi
    [ -n "$_input" ] || { echo "Usage: llm-embed <text|file>  OR  echo text | llm-embed"; return 1; }

    _llm_ensure_backend || return 1

    local _backend _model _payload
    _backend=$(_llm_backend)
    _model=$(_llm_model embed)
    _payload=$(jq -n --arg m "$_model" --arg i "$_input" '{model:$m, input:$i}')
    case "$_backend" in
        llama)  _llm_call_json "http://${LLAMA_HOST}/v1/embeddings" "$_payload" '.' ;;
        ollama) _llm_call_json "http://${OLLAMA_HOST}/api/embed"    "$_payload" '.' ;;
        *) echo "llm: no AI backend available" >&2; return 1 ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────
# Vision / OCR — works on whichever backend is active, provided the chosen
# model (AI_MODEL_VISION / AI_MODEL_OCR) supports image input. On llama.cpp
# this means the llama-swap alias points at a multimodal GGUF + mmproj;
# on ollama it means a vision-capable tag (llama3.2-vision, glm-ocr, …).
# ─────────────────────────────────────────────────────────────────────────

# Guess an image mime type from the file extension.
_llm_image_mime() {
    case "$1" in
        *.png|*.PNG)               printf 'image/png\n' ;;
        *.jpg|*.jpeg|*.JPG|*.JPEG) printf 'image/jpeg\n' ;;
        *.gif|*.GIF)               printf 'image/gif\n' ;;
        *.webp|*.WEBP)             printf 'image/webp\n' ;;
        *.bmp|*.BMP)               printf 'image/bmp\n' ;;
        *)                         printf 'application/octet-stream\n' ;;
    esac
}

# _llm_image <role> <image> "<prompt>"
# Send an image + prompt through the active backend. Prints response.
_llm_image() {
    local _role="$1" _image="$2" _prompt="$3"
    [ -f "$_image" ] || { echo "Error: image not found: $_image"; return 1; }

    _llm_ensure_backend || return 1

    local _backend _model
    _backend=$(_llm_backend)
    _model=$(_llm_model "$_role")

    case "$_backend" in
        ollama)
            # ollama accepts raw base64 as extra arg to `ollama run`.
            base64 -w0 "$_image" | ollama run "$_model" "$_prompt"
            ;;
        llama)
            # OpenAI-compat vision: content is an array of text + image_url parts.
            local _mime _b64 _url _payload
            _mime=$(_llm_image_mime "$_image")
            _b64=$(base64 -w0 "$_image")
            _url="data:${_mime};base64,${_b64}"
            _payload=$(jq -n --arg m "$_model" --arg t "$_prompt" --arg u "$_url" \
                '{model:$m, messages:[{role:"user",content:[{type:"text",text:$t},{type:"image_url",image_url:{url:$u}}]}], stream:false}')
            _llm_call_json "http://${LLAMA_HOST}/v1/chat/completions" \
                "$_payload" '.choices[0].message.content // empty'
            ;;
        none)
            echo "llm: no AI backend available" >&2
            return 1
            ;;
    esac
}

_llm_ocr() {
    [ -f "$1" ] || { echo "Usage: llm-ocr <image>"; return 1; }
    _llm_image ocr "$1" \
        "Extract all text from this image. Return only the extracted text, preserving layout where possible."
}

_llm_vision() {
    [ -f "$1" ] || { echo "Usage: llm-vision <image> [prompt]"; return 1; }
    local _prompt="${2:-Describe this image in detail. Include objects, text, layout, and relevant observations.}"
    _llm_image vision "$1" "$_prompt"
}

# ─────────────────────────────────────────────────────────────────────────
# Flash / think — direct role shortcuts
# ─────────────────────────────────────────────────────────────────────────

_llm_think() {
    [ -n "$1" ] || { echo "Usage: llm-think \"<question>\""; return 1; }
    _llm_run reason "$*"
}

_llm_flash() {
    [ -n "$1" ] || { echo "Usage: llm-flash \"<prompt>\"  OR  <input> | llm-flash \"<prompt>\""; return 1; }
    if [ ! -t 0 ]; then
        _llm_run fast "$*"
    else
        printf '' | _llm_run fast "$*"
    fi
}

_llm_flash_file() {
    local _f="$1" _p="${2:-Analyze this file and provide key insights. Be concise.}"
    _llm_file fast "$_f" "$_p"
}

# ─────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────

_llm_help() {
    local _b; _b=$(_llm_backend)
    cat <<EOF
LLM helpers — backend: $_b
===================================

Code understanding
  llm-explain <file>           explain code concisely
  llm-explain-edit <file>      explain + open in Neovim
  llm-summary <file|dir>       summarize file or directory
  llm-arch [dir]               architecture analysis

Git
  llm-review [ref]             review git changes
  llm-review-edit [ref]        review + open in Neovim
  llm-commit                   suggest + apply commit message

Shell
  llm-cmd "<question>"         how do I do X
  llm-explain-cmd <command>    explain a command

Code quality
  llm-refactor <file>          refactoring suggestions
  llm-refactor-edit <file>     refactor + side-by-side
  llm-optimize <file>          perf suggestions
  llm-optimize-edit <file>     optimize + diff view
  llm-security <file>          security audit
  llm-test <file>              generate tests
  llm-test-edit <file>         tests + split view
  llm-doc <file>               generate docs
  llm-doc-edit <file>          docs + split view

Problem solving
  llm-debug "<error>"          debugging help
  llm-fix <file> [error]       root cause + fix

Development
  llm-implement "<feature>"    implementation plan
  llm-convert "<instruction>"  convert code (pipe input)
  llm-api-client <spec> <lang> generate API client from OpenAPI
  llm-code [model]             interactive session (ollama only)

Vision & embeddings
  llm-ocr <image>              OCR (backend must expose AI_MODEL_OCR)
  llm-vision <image> [prompt]  image analysis (backend must expose AI_MODEL_VISION)
  llm-embed <text|file>        text embedding

Shortcuts
  llm-think "<q>"              reasoning model (role: reason)
  llm-flash "<p>"              fast model (role: fast)
  llm-flash-file <f> "<p>"     fast model on a file

Roles → models
  default  : $(_llm_model default)
  code     : $(_llm_model code)
  reason   : $(_llm_model reason)
  fast     : $(_llm_model fast)
  embed    : $(_llm_model embed)
  vision   : $(_llm_model vision)
  ocr      : $(_llm_model ocr)

Environment
  AI_BACKEND      : ${AI_BACKEND} (auto|llama|ollama)
  LLAMA_HOST      : ${LLAMA_HOST:-unset}
  OLLAMA_HOST     : ${OLLAMA_HOST:-unset}
EOF
}
