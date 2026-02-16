# lib/ollama.sh — Ollama LLM workflow functions
# Depends: HAS_OLLAMA (bootstrap.sh), OLLAMA_MODEL (aliases/ollama.sh)

[ "$HAS_OLLAMA" = "1" ] || return 0

# --- Shared helpers ---

# Validate file arg, pipe content to ollama with a prompt
_llm_file_prompt() {
  _usage="$1"; _prompt="$2"; _file="$3"
  [ -n "$_file" ] || { echo "Usage: $_usage <file>"; return 1; }
  [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
  cat "$_file" | ollama run "$OLLAMA_MODEL" "$_prompt"
}

# --- Code Understanding ---

_llm_explain() {
  _llm_file_prompt "llm-explain" \
    "Explain this code concisely, focusing on what it does and why:" "$1"
}

_llm_summary() {
  if [ -z "$1" ]; then
    echo "Usage: llm-summary <file_or_directory>"
    return 1
  fi
  if [ -f "$1" ]; then
    cat "$1" | ollama run "$OLLAMA_MODEL" "Summarize this file's purpose, key components, and dependencies. Be concise."
  elif [ -d "$1" ]; then
    tree -L 2 "$1" 2>/dev/null || find "$1" -maxdepth 2 -type f | ollama run "$OLLAMA_MODEL" "Based on this file structure, describe what this directory contains and its purpose. Be concise."
  else
    echo "Error: Not a valid file or directory: $1"
    return 1
  fi
}

# --- Git Integration ---

_llm_review() {
  local diff_cmd="git diff --staged"
  if [ -n "$1" ]; then
    diff_cmd="git diff $1"
  fi
  $diff_cmd | ollama run "$OLLAMA_MODEL" "Review this git diff. Focus on: bugs, security issues, best practices, and improvements. Be concise."
}

_llm_commit() {
  if ! git diff --cached --quiet; then
    local msg=$(git diff --cached | ollama run "$OLLAMA_MODEL" "Generate a concise git commit message (50 chars max) for these changes. Format: '<type>: <description>'. Types: feat, fix, docs, style, refactor, test, chore. Output ONLY the commit message, nothing else.")
    echo "Suggested commit message:"
    echo "$msg"
    echo
    read -p "Use this message? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git commit -m "$msg"
    fi
  else
    echo "No staged changes to commit"
    return 1
  fi
}

# --- Shell Command Help ---

_llm_cmd() {
  if [ -z "$1" ]; then
    echo "Usage: llm-cmd \"<question about shell commands>\""
    return 1
  fi
  ollama run "$OLLAMA_MODEL" "You are a shell command expert. Answer concisely with the command and a brief explanation. Question: $*"
}

_llm_explain_cmd() {
  local cmd="${*:-$(cat)}"
  if [ -z "$cmd" ]; then
    echo "Usage: llm-explain-cmd <command>  OR  echo <command> | llm-explain-cmd"
    return 1
  fi
  echo "$cmd" | ollama run "$OLLAMA_MODEL" "Explain this shell command concisely, breaking down each part:"
}

# --- Code Quality & Improvement ---

_llm_refactor() {
  _llm_file_prompt "llm-refactor" \
    "Suggest refactoring improvements for this code. Focus on: readability, performance, maintainability, and best practices. Be specific and concise." "$1"
}

_llm_optimize() {
  _llm_file_prompt "llm-optimize" \
    "Suggest performance optimizations for this code. Focus on algorithmic improvements, memory usage, and execution speed. Provide specific code suggestions." "$1"
}

_llm_test() {
  _llm_file_prompt "llm-test" \
    "Generate test cases for this code. Include: edge cases, error conditions, and happy paths. Use the appropriate testing framework for the language." "$1"
}

_llm_doc() {
  _llm_file_prompt "llm-doc" \
    "Generate concise documentation for this code. Include: purpose, usage, parameters, return values, and examples. Use markdown format." "$1"
}

# --- Debugging & Problem Solving ---

_llm_debug() {
  if [ -z "$1" ]; then
    echo "Usage: llm-debug \"<error message or description>\""
    return 1
  fi
  ollama run "$OLLAMA_MODEL" "I'm getting this error: $*

Help me debug it. Provide: 1) likely causes, 2) how to investigate, 3) potential solutions. Be concise."
}

# --- Interactive Sessions ---

_llm_code() {
  local model="${1:-deepseek-r1:14b}"
  echo "Starting coding session with $model..."
  echo "Tips: Paste code directly, ask specific questions, type /bye to exit"
  ollama run "$model" "You are a coding assistant. Provide concise, practical code solutions. Include explanations only when necessary. Prefer code examples over lengthy descriptions."
}

# --- Neovim Integration ---

_llm_explain_edit() {
  if [ -z "$1" ]; then
    echo "Usage: llm-explain-edit <file>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi
  local tmpfile=$(mktemp --suffix=.md)
  {
    echo "# Code Explanation: $1"
    echo ""
    cat "$1" | ollama run "$OLLAMA_MODEL" "Explain this code in detail. Include: purpose, logic flow, dependencies, and potential improvements."
    echo ""
    echo "---"
    echo "## Original Code"
    echo '```'
    cat "$1"
    echo '```'
  } > "$tmpfile"
  nvim "$tmpfile" -c "set filetype=markdown"
}

_llm_review_edit() {
  local diff_cmd="git diff --staged"
  local title="Staged Changes"
  if [ -n "$1" ]; then
    diff_cmd="git diff $1"
    title="Changes vs $1"
  fi
  local tmpfile=$(mktemp --suffix=.md)
  {
    echo "# Code Review: $title"
    echo ""
    $diff_cmd | ollama run "$OLLAMA_MODEL" "Review this git diff. Provide: 1) Summary of changes, 2) Potential issues (bugs, security, performance), 3) Suggestions for improvement. Be detailed and specific."
    echo ""
    echo "---"
    echo "## Diff"
    echo '```diff'
    $diff_cmd
    echo '```'
  } > "$tmpfile"
  nvim "$tmpfile" -c "set filetype=markdown"
}

_llm_refactor_edit() {
  if [ -z "$1" ]; then
    echo "Usage: llm-refactor-edit <file>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi
  local tmpfile=$(mktemp --suffix=.md)
  {
    cat "$1" | ollama run "$OLLAMA_MODEL" "Provide detailed refactoring suggestions for this code. Include: 1) Current issues/smells, 2) Proposed refactorings with code examples, 3) Benefits of each change."
  } > "$tmpfile"
  nvim -O "$1" "$tmpfile"
}

# Generates intentional output file (test_file) — not cleaned up
_llm_test_edit() {
  if [ -z "$1" ]; then
    echo "Usage: llm-test-edit <file>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi

  local dir=$(dirname "$1")
  local filename=$(basename "$1")
  local name="${filename%.*}"
  local ext="${filename##*.}"
  local test_file=""

  case "$ext" in
    js|ts|jsx|tsx) test_file="$dir/$name.test.$ext" ;;
    py)            test_file="$dir/test_$name.$ext" ;;
    go)            test_file="$dir/${name}_test.$ext" ;;
    *)             test_file="$dir/$name.test.$ext" ;;
  esac

  echo "Generating tests for $1..."
  cat "$1" | ollama run "$OLLAMA_MODEL" "Generate comprehensive tests for this code. Use the appropriate testing framework for the language. Include: setup, test cases for happy paths, edge cases, error conditions, and cleanup." > "$test_file"

  echo "Tests generated: $test_file"
  nvim -O "$1" "$test_file"
}

# Generates intentional output file (doc_file) — not cleaned up
_llm_doc_edit() {
  if [ -z "$1" ]; then
    echo "Usage: llm-doc-edit <file>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi
  local doc_file="$(dirname "$1")/$(basename "$1" | sed 's/\.[^.]*$//').md"

  echo "Generating documentation for $1..."
  cat "$1" | ollama run "$OLLAMA_MODEL" "Generate comprehensive documentation for this code. Use markdown format. Include: overview, API reference, usage examples, configuration options, and notes about edge cases or gotchas." > "$doc_file"

  echo "Documentation generated: $doc_file"
  nvim -O "$1" "$doc_file"
}

_llm_fix() {
  if [ -z "$1" ]; then
    echo "Usage: llm-fix <file> [error_message]"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi

  local error_context="${2:-last error in this file}"
  local tmpfile=$(mktemp --suffix=.md)

  {
    echo "# Quick Fix Analysis: $1"
    echo ""
    echo "## Error Context"
    echo "$error_context"
    echo ""
    echo "## Analysis & Solution"
    cat "$1" | ollama run "$OLLAMA_MODEL" "This code has an error: $error_context

Provide: 1) Root cause analysis, 2) Exact fix (show code changes), 3) Why this fixes it. Be concise and actionable."
  } > "$tmpfile"

  nvim -O "$1" "$tmpfile"
}

_llm_optimize_edit() {
  if [ -z "$1" ]; then
    echo "Usage: llm-optimize-edit <file>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi

  local ext="${1##*.}"
  local tmpfile=$(mktemp --suffix=".$ext")

  echo "Generating optimized version of $1..."
  cat "$1" | ollama run "$OLLAMA_MODEL" "Optimize this code for performance. Output ONLY the optimized code, no explanations. Preserve all functionality while improving: algorithmic complexity, memory usage, and execution speed." > "$tmpfile"

  echo "Optimized version: $tmpfile"
  nvim -d "$1" "$tmpfile"
}

_llm_convert() {
  if [ -z "$1" ]; then
    echo "Usage: <input> | llm-convert \"<conversion instruction>\""
    echo "Example: cat script.sh | llm-convert \"convert to Python\""
    return 1
  fi

  local instruction="$*"
  local input=$(cat)

  if [ -z "$input" ]; then
    echo "Error: No input provided"
    return 1
  fi

  echo "$input" | ollama run "$OLLAMA_MODEL" "Task: $instruction

Input code:
$input

Output ONLY the converted code, no explanations or markdown formatting."
}

_llm_implement() {
  if [ -z "$1" ]; then
    echo "Usage: llm-implement \"<feature description>\""
    return 1
  fi

  local feature="$*"
  local context=""

  if [ -f "package.json" ]; then
    context="Project uses: $(grep -o '"[^"]*"' package.json | head -5 | tr '\n' ' ')"
  elif [ -f "requirements.txt" ]; then
    context="Python project with: $(head -5 requirements.txt | tr '\n' ' ')"
  elif [ -f "go.mod" ]; then
    context="Go project: $(head -1 go.mod)"
  fi

  local tmpfile=$(mktemp --suffix=.md)
  {
    echo "# Feature Implementation: $feature"
    echo ""
    echo "Context: $context"
    echo ""
    ollama run "$OLLAMA_MODEL" "Feature request: $feature

Project context: $context

Provide:
1. Implementation plan (step-by-step)
2. Required files and their purposes
3. Code examples for each file
4. Configuration changes needed
5. Testing approach

Be thorough but concise."
  } > "$tmpfile"

  nvim "$tmpfile" -c "set filetype=markdown"
}

_llm_security() {
  if [ -z "$1" ]; then
    echo "Usage: llm-security <file>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi

  local tmpfile=$(mktemp --suffix=.md)
  {
    echo "# Security Analysis: $1"
    echo ""
    cat "$1" | ollama run "$OLLAMA_MODEL" "Perform a security audit of this code. Check for:
- SQL injection vulnerabilities
- XSS vulnerabilities
- Command injection
- Path traversal
- Authentication/authorization issues
- Cryptographic weaknesses
- Input validation problems
- Sensitive data exposure

For each issue found, provide: severity, location, explanation, and fix."
    echo ""
    echo "---"
    echo "## Original Code"
    echo '```'
    cat "$1"
    echo '```'
  } > "$tmpfile"

  nvim "$tmpfile" -c "set filetype=markdown"
}

# Generates intentional output file (api-client.*) — not cleaned up
_llm_api_client() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: llm-api-client <spec_file> <target_language>"
    echo "Example: llm-api-client api.yaml typescript"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: Spec file not found: $1"
    return 1
  fi

  local spec_file="$1"
  local language="$2"
  local output_file="api-client.${language}"

  echo "Generating $language API client from $spec_file..."
  cat "$spec_file" | ollama run "$OLLAMA_MODEL" "Generate a complete API client in $language for this OpenAPI/Swagger specification. Include:
- Type definitions
- Error handling
- Request/response interceptors
- Authentication support
- All endpoint methods

Output clean, production-ready code." > "$output_file"

  echo "API client generated: $output_file"
  nvim "$output_file"
}

_llm_arch() {
  local target_dir="${1:-.}"

  if [ ! -d "$target_dir" ]; then
    echo "Error: Directory not found: $target_dir"
    return 1
  fi

  local tmpfile=$(mktemp --suffix=.md)

  {
    echo "# Architecture Analysis: $target_dir"
    echo ""
    echo "## Project Structure"
    echo '```'
    tree -L 3 -I 'node_modules|venv|__pycache__|.git|dist|build' "$target_dir" 2>/dev/null || find "$target_dir" -type f -not -path '*/node_modules/*' -not -path '*/.git/*' | head -50
    echo '```'
    echo ""
  } > "$tmpfile"

  (tree -L 3 -I 'node_modules|venv|__pycache__|.git|dist|build' "$target_dir" 2>/dev/null || find "$target_dir" -type f -not -path '*/node_modules/*' -not -path '*/.git/*' | head -50) | ollama run "$OLLAMA_MODEL" "Based on this project structure, provide:
1. Architecture pattern used (MVC, microservices, layered, etc.)
2. Technology stack
3. Key components and their roles
4. Data flow
5. Potential improvements or concerns

Be concise and insightful." >> "$tmpfile"

  nvim "$tmpfile" -c "set filetype=markdown"
}

# --- Help ---

_llm_help() {
  cat <<EOF
Ollama Integration Commands
============================

Code Understanding:
  llm-explain <file>              - Explain code
  llm-explain-edit <file>         - Explain code and open in Neovim
  llm-summary <path>              - Summarize file or directory
  llm-arch [dir]                  - Analyze project architecture

Git Integration:
  llm-review [ref]                - Review git changes
  llm-review-edit [ref]           - Review and open in Neovim
  llm-commit                      - Generate commit message

Shell Assistance:
  llm-cmd "question"              - Ask how to do something
  llm-explain-cmd <command>       - Explain a command

Code Quality:
  llm-refactor <file>             - Get refactoring suggestions
  llm-refactor-edit <file>        - Refactor with side-by-side view
  llm-optimize <file>             - Get optimization suggestions
  llm-optimize-edit <file>        - Optimize with diff view
  llm-security <file>             - Security audit

Testing & Documentation:
  llm-test <file>                 - Generate tests
  llm-test-edit <file>            - Generate tests in split view
  llm-doc <file>                  - Generate documentation
  llm-doc-edit <file>             - Generate docs in split view

Problem Solving:
  llm-debug "error"               - Help debug an error
  llm-fix <file> [error]          - Quick fix analysis

Development:
  llm-implement "feature"         - Plan feature implementation
  llm-convert "instruction"       - Convert code (pipe input)
  llm-api-client <spec> <lang>    - Generate API client

Interactive:
  llm-code [model]                - Start coding session

Configuration:
  OLLAMA_MODEL                    - Default model (current: $OLLAMA_MODEL)
  OLLAMA_HOST                     - API endpoint (current: $OLLAMA_HOST)

EOF
}
