# Ollama helper functions. Sourced by plugins/ollama.sh after ollama is confirmed present.
# Uses OLLAMA_MODEL as default, plus specialized vars:
#   OLLAMA_MODEL_CODE, OLLAMA_MODEL_REASON, OLLAMA_MODEL_FAST,
#   OLLAMA_MODEL_OCR, OLLAMA_MODEL_VISION, OLLAMA_MODEL_EMBED,
#   OLLAMA_MODEL_THINK, OLLAMA_MODEL_FLASH

# Validate file arg, pipe content to ollama with a prompt
_llm_file_prompt() {
    local _usage _prompt _file
    _usage=$1
    _prompt=$2
    _file=$3
    [ -n "$_file" ] || { echo "Usage: $_usage <file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    cat "$_file" | ollama run "$OLLAMA_MODEL" "$_prompt"
}

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

_llm_review() {
    local diff_cmd
    diff_cmd="git diff --staged"
    if [ -n "$1" ]; then
        diff_cmd="git diff $1"
    fi
    $diff_cmd | ollama run "$OLLAMA_MODEL_REASON" "Review this git diff. Focus on: bugs, security issues, best practices, and improvements. Be concise."
}

_llm_commit() {
    local msg _reply
    if ! git diff --cached --quiet; then
        msg=$(git diff --cached | ollama run "$OLLAMA_MODEL_FAST" "Generate a concise git commit message (50 chars max) for these changes. Format: '<type>: <description>'. Types: feat, fix, docs, style, refactor, test, chore. Output ONLY the commit message, nothing else.")
        echo "Suggested commit message:"
        echo "$msg"
        echo
        printf '%s' "Use this message? (y/n) "
        read -r _reply
        if echo "$_reply" | grep -q '^[Yy]'; then
            git commit -m "$msg"
        fi
    else
        echo "No staged changes to commit"
        return 1
    fi
}

_llm_cmd() {
    if [ -z "$1" ]; then
        echo "Usage: llm-cmd \"<question about shell commands>\""
        return 1
    fi
    ollama run "$OLLAMA_MODEL" "You are a shell command expert. Answer concisely with the command and a brief explanation. Question: $*"
}

_llm_explain_cmd() {
    local cmd
    cmd="${*:-$(cat)}"
    if [ -z "$cmd" ]; then
        echo "Usage: llm-explain-cmd <command>  OR  echo <command> | llm-explain-cmd"
        return 1
    fi
    echo "$cmd" | ollama run "$OLLAMA_MODEL" "Explain this shell command concisely, breaking down each part:"
}

_llm_refactor() {
    local _file="$1"
    [ -n "$_file" ] || { echo "Usage: llm-refactor <file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    cat "$_file" | ollama run "$OLLAMA_MODEL_CODE" \
        "Suggest refactoring improvements for this code. Focus on: readability, performance, maintainability, and best practices. Be specific and concise."
}

_llm_optimize() {
    local _file="$1"
    [ -n "$_file" ] || { echo "Usage: llm-optimize <file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    cat "$_file" | ollama run "$OLLAMA_MODEL_CODE" \
        "Suggest performance optimizations for this code. Focus on algorithmic improvements, memory usage, and execution speed. Provide specific code suggestions."
}

_llm_test() {
    local _file="$1"
    [ -n "$_file" ] || { echo "Usage: llm-test <file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    cat "$_file" | ollama run "$OLLAMA_MODEL_CODE" \
        "Generate test cases for this code. Include: edge cases, error conditions, and happy paths. Use the appropriate testing framework for the language."
}

_llm_doc() {
    _llm_file_prompt "llm-doc" \
        "Generate concise documentation for this code. Include: purpose, usage, parameters, return values, and examples. Use markdown format." "$1"
}

_llm_debug() {
    if [ -z "$1" ]; then
        echo "Usage: llm-debug \"<error message or description>\""
        return 1
    fi
    ollama run "$OLLAMA_MODEL_REASON" "I'm getting this error: $*

Help me debug it. Provide: 1) likely causes, 2) how to investigate, 3) potential solutions. Be concise."
}

_llm_code() {
    local model
    model="${1:-$OLLAMA_MODEL_CODE}"
    echo "Starting coding session with $model..."
    echo "Tips: Paste code directly, ask specific questions, type /bye to exit"
    ollama run "$model" "You are a coding assistant. Provide concise, practical code solutions. Include explanations only when necessary. Prefer code examples over lengthy descriptions."
}

_llm_explain_edit() {
    local tmpfile
    if [ -z "$1" ]; then
        echo "Usage: llm-explain-edit <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi
    tmpfile=$(mktemp --suffix=.md)
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
    local diff_cmd title tmpfile
    diff_cmd="git diff --staged"
    title="Staged Changes"
    if [ -n "$1" ]; then
        diff_cmd="git diff $1"
        title="Changes vs $1"
    fi
    tmpfile=$(mktemp --suffix=.md)
    {
        echo "# Code Review: $title"
        echo ""
        $diff_cmd | ollama run "$OLLAMA_MODEL_REASON" "Review this git diff. Provide: 1) Summary of changes, 2) Potential issues (bugs, security, performance), 3) Suggestions for improvement. Be detailed and specific."
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
    local tmpfile
    if [ -z "$1" ]; then
        echo "Usage: llm-refactor-edit <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi
    tmpfile=$(mktemp --suffix=.md)
    cat "$1" | ollama run "$OLLAMA_MODEL_CODE" "Provide detailed refactoring suggestions for this code. Include: 1) Current issues/smells, 2) Proposed refactorings with code examples, 3) Benefits of each change." > "$tmpfile"
    nvim -O "$1" "$tmpfile"
}

_llm_test_edit() {
    local dir filename name ext test_file
    if [ -z "$1" ]; then
        echo "Usage: llm-test-edit <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi

    dir=$(dirname "$1")
    filename=$(basename "$1")
    name="${filename%.*}"
    ext="${filename##*.}"
    test_file=""

    case "$ext" in
        js|ts|jsx|tsx) test_file="$dir/$name.test.$ext" ;;
        py) test_file="$dir/test_$name.$ext" ;;
        go) test_file="$dir/${name}_test.$ext" ;;
        *) test_file="$dir/$name.test.$ext" ;;
    esac

    echo "Generating tests for $1..."
    cat "$1" | ollama run "$OLLAMA_MODEL_CODE" "Generate comprehensive tests for this code. Use the appropriate testing framework for the language. Include: setup, test cases for happy paths, edge cases, error conditions, and cleanup." > "$test_file"

    echo "Tests generated: $test_file"
    nvim -O "$1" "$test_file"
}

_llm_doc_edit() {
    local doc_file
    if [ -z "$1" ]; then
        echo "Usage: llm-doc-edit <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi
    doc_file="$(dirname "$1")/$(basename "$1" | sed 's/\.[^.]*$//').md"

    echo "Generating documentation for $1..."
    cat "$1" | ollama run "$OLLAMA_MODEL" "Generate comprehensive documentation for this code. Use markdown format. Include: overview, API reference, usage examples, configuration options, and notes about edge cases or gotchas." > "$doc_file"

    echo "Documentation generated: $doc_file"
    nvim -O "$1" "$doc_file"
}

_llm_fix() {
    local error_context tmpfile
    if [ -z "$1" ]; then
        echo "Usage: llm-fix <file> [error_message]"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi

    error_context="${2:-last error in this file}"
    tmpfile=$(mktemp --suffix=.md)

    {
        echo "# Quick Fix Analysis: $1"
        echo ""
        echo "## Error Context"
        echo "$error_context"
        echo ""
        echo "## Analysis & Solution"
        cat "$1" | ollama run "$OLLAMA_MODEL_REASON" "This code has an error: $error_context

Provide: 1) Root cause analysis, 2) Exact fix (show code changes), 3) Why this fixes it. Be concise and actionable."
    } > "$tmpfile"

    nvim -O "$1" "$tmpfile"
}

_llm_optimize_edit() {
    local ext tmpfile
    if [ -z "$1" ]; then
        echo "Usage: llm-optimize-edit <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi

    ext="${1##*.}"
    tmpfile=$(mktemp --suffix=".$ext")

    echo "Generating optimized version of $1..."
    cat "$1" | ollama run "$OLLAMA_MODEL_CODE" "Optimize this code for performance. Output ONLY the optimized code, no explanations. Preserve all functionality while improving: algorithmic complexity, memory usage, and execution speed." > "$tmpfile"

    echo "Optimized version: $tmpfile"
    nvim -d "$1" "$tmpfile"
}

_llm_convert() {
    local instruction input
    if [ -z "$1" ]; then
        echo "Usage: <input> | llm-convert \"<conversion instruction>\""
        echo "Example: cat script.sh | llm-convert \"convert to Python\""
        return 1
    fi

    instruction="$*"
    input=$(cat)

    if [ -z "$input" ]; then
        echo "Error: No input provided"
        return 1
    fi

    echo "$input" | ollama run "$OLLAMA_MODEL_CODE" "Task: $instruction

Input code:
$input

Output ONLY the converted code, no explanations or markdown formatting."
}

_llm_implement() {
    local feature context tmpfile
    if [ -z "$1" ]; then
        echo "Usage: llm-implement \"<feature description>\""
        return 1
    fi

    feature="$*"
    context=""

    if [ -f "package.json" ]; then
        context="Project uses: $(grep -o '\"[^\"]*\"' package.json | head -5 | tr '\n' ' ')"
    elif [ -f "requirements.txt" ]; then
        context="Python project with: $(head -5 requirements.txt | tr '\n' ' ')"
    elif [ -f "go.mod" ]; then
        context="Go project: $(head -1 go.mod)"
    fi

    tmpfile=$(mktemp --suffix=.md)
    {
        echo "# Feature Implementation: $feature"
        echo ""
        echo "Context: $context"
        echo ""
        ollama run "$OLLAMA_MODEL_REASON" "Feature request: $feature

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
    local tmpfile
    if [ -z "$1" ]; then
        echo "Usage: llm-security <file>"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi

    tmpfile=$(mktemp --suffix=.md)
    {
        echo "# Security Analysis: $1"
        echo ""
        cat "$1" | ollama run "$OLLAMA_MODEL_REASON" "Perform a security audit of this code. Check for:
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

_llm_api_client() {
    local spec_file language output_file
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: llm-api-client <spec_file> <target_language>"
        echo "Example: llm-api-client api.yaml typescript"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: Spec file not found: $1"
        return 1
    fi

    spec_file="$1"
    language="$2"
    output_file="api-client.${language}"

    echo "Generating $language API client from $spec_file..."
    cat "$spec_file" | ollama run "$OLLAMA_MODEL_CODE" "Generate a complete API client in $language for this OpenAPI/Swagger specification. Include:
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
    local target_dir tmpfile
    target_dir="${1:-.}"

    if [ ! -d "$target_dir" ]; then
        echo "Error: Directory not found: $target_dir"
        return 1
    fi

    tmpfile=$(mktemp --suffix=.md)

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

## ---------------------------------------------------------------------------
## Vision, OCR, Embedding, and specialized model helpers
## ---------------------------------------------------------------------------

_llm_ocr() {
    local _file
    _file="$1"
    [ -n "$_file" ] || { echo "Usage: llm-ocr <image_file>"; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    local _b64
    _b64=$(base64 -w0 "$_file")
    printf '%s' "$_b64" | ollama run "$OLLAMA_MODEL_OCR" "Extract all text from this image. Return only the extracted text, preserving layout where possible."
}

_llm_vision() {
    local _file _prompt
    _file="$1"
    _prompt="${2:-Describe this image in detail. Include objects, text, layout, and any relevant observations.}"
    [ -n "$_file" ] || { echo "Usage: llm-vision <image_file> [prompt]"; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    local _b64
    _b64=$(base64 -w0 "$_file")
    printf '%s' "$_b64" | ollama run "$OLLAMA_MODEL_VISION" "$_prompt"
}

_llm_embed() {
    local _input
    if [ -n "$1" ] && [ -f "$1" ]; then
        _input=$(cat "$1")
    elif [ -n "$1" ]; then
        _input="$*"
    else
        _input=$(cat)
    fi
    [ -n "$_input" ] || { echo "Usage: llm-embed <text|file>  OR  echo text | llm-embed"; return 1; }
    curl -sf "http://${OLLAMA_HOST}/api/embed" \
        -d "$(printf '{"model":"%s","input":"%s"}' "$OLLAMA_MODEL_EMBED" "$(echo "$_input" | sed 's/"/\\"/g; s/$/\\n/' | tr -d '\n')")"
}

_llm_think() {
    if [ -z "$1" ]; then
        echo "Usage: llm-think \"<question or problem>\""
        return 1
    fi
    ollama run "$OLLAMA_MODEL_THINK" "$*"
}

_llm_flash() {
    if [ -z "$1" ]; then
        echo "Usage: llm-flash \"<prompt>\"  OR  <input> | llm-flash \"<prompt>\""
        return 1
    fi
    local _stdin=""
    if [ ! -t 0 ]; then
        _stdin=$(cat)
    fi
    if [ -n "$_stdin" ]; then
        echo "$_stdin" | ollama run "$OLLAMA_MODEL_FLASH" "$*"
    else
        ollama run "$OLLAMA_MODEL_FLASH" "$*"
    fi
}

_llm_flash_file() {
    local _file="$1" _prompt="$2"
    [ -n "$_file" ] || { echo "Usage: llm-flash-file <file> \"<prompt>\""; return 1; }
    [ -f "$_file" ] || { echo "Error: File not found: $_file"; return 1; }
    [ -n "$_prompt" ] || _prompt="Analyze this file and provide key insights. Be concise."
    cat "$_file" | ollama run "$OLLAMA_MODEL_FLASH" "$_prompt"
}

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

Vision & OCR:
  llm-ocr <image>                 - Extract text from image (glm-ocr)
  llm-vision <image> [prompt]     - Analyze/describe image (llama3.2-vision)

Embedding:
  llm-embed <text|file>           - Generate embeddings (nomic-embed-text)

Fast & Reasoning:
  llm-think "question"            - Quick reasoning (lfm2.5-thinking)
  llm-flash "prompt"              - Fast general task (glm-4.7-flash)
  llm-flash-file <file> "prompt"  - Fast file analysis (glm-4.7-flash)

Interactive:
  llm-code [model]                - Start coding session

Configuration:
  OLLAMA_MODEL          - Default model          (current: $OLLAMA_MODEL)
  OLLAMA_MODEL_CODE     - Code generation model   (current: $OLLAMA_MODEL_CODE)
  OLLAMA_MODEL_REASON   - Reasoning model          (current: $OLLAMA_MODEL_REASON)
  OLLAMA_MODEL_FAST     - Fast/light model         (current: $OLLAMA_MODEL_FAST)
  OLLAMA_MODEL_OCR      - OCR model                (current: $OLLAMA_MODEL_OCR)
  OLLAMA_MODEL_VISION   - Vision model             (current: $OLLAMA_MODEL_VISION)
  OLLAMA_MODEL_EMBED    - Embedding model          (current: $OLLAMA_MODEL_EMBED)
  OLLAMA_MODEL_THINK    - Thinking/reasoning model (current: $OLLAMA_MODEL_THINK)
  OLLAMA_MODEL_FLASH    - Flash/fast general model (current: $OLLAMA_MODEL_FLASH)
  OLLAMA_HOST           - API endpoint             (current: $OLLAMA_HOST)

EOF
}

runtime_ollama_aliases() {
    [ "${RUNTIME_OLLAMA_ALIASES_LOADED-}" = "1" ] && return 0
    RUNTIME_OLLAMA_ALIASES_LOADED=1

    runtime_alias llm-explain '_llm_explain' --desc "LLM explain" --tags "llm,code"
    runtime_alias llm-summary '_llm_summary' --desc "LLM summary" --tags "llm,summary"
    runtime_alias llm-arch '_llm_arch' --desc "LLM architecture" --tags "llm,analysis"

    runtime_alias llm-review '_llm_review' --desc "LLM review" --tags "llm,git,review"
    runtime_alias llm-review-edit '_llm_review_edit' --desc "LLM review edit" --tags "llm,git,review,editor"
    runtime_alias llm-commit '_llm_commit' --desc "LLM commit" --tags "llm,git,commit"

    runtime_alias llm-cmd '_llm_cmd' --desc "LLM command" --tags "llm,shell"
    runtime_alias llm-explain-cmd '_llm_explain_cmd' --desc "LLM explain command" --tags "llm,shell,explain"

    runtime_alias llm-refactor '_llm_refactor' --desc "LLM refactor" --tags "llm,refactor"
    runtime_alias llm-refactor-edit '_llm_refactor_edit' --desc "LLM refactor edit" --tags "llm,refactor,editor"
    runtime_alias llm-optimize '_llm_optimize' --desc "LLM optimize" --tags "llm,optimize"
    runtime_alias llm-optimize-edit '_llm_optimize_edit' --desc "LLM optimize edit" --tags "llm,optimize,editor"
    runtime_alias llm-security '_llm_security' --desc "LLM security" --tags "llm,security"

    runtime_alias llm-test '_llm_test' --desc "LLM test" --tags "llm,test"
    runtime_alias llm-test-edit '_llm_test_edit' --desc "LLM test edit" --tags "llm,test,editor"
    runtime_alias llm-doc '_llm_doc' --desc "LLM doc" --tags "llm,docs"
    runtime_alias llm-doc-edit '_llm_doc_edit' --desc "LLM doc edit" --tags "llm,docs,editor"

    runtime_alias llm-debug '_llm_debug' --desc "LLM debug" --tags "llm,debug"
    runtime_alias llm-fix '_llm_fix' --desc "LLM fix" --tags "llm,fix"

    runtime_alias llm-implement '_llm_implement' --desc "LLM implement" --tags "llm,plan"
    runtime_alias llm-convert '_llm_convert' --desc "LLM convert" --tags "llm,convert"
    runtime_alias llm-api-client '_llm_api_client' --desc "LLM API client" --tags "llm,api"

    runtime_alias llm-code '_llm_code' --desc "LLM code" --tags "llm,interactive"
    runtime_alias llm-explain-edit '_llm_explain_edit' --desc "LLM explain edit" --tags "llm,code,editor"

    runtime_alias llm-ocr '_llm_ocr' --desc "LLM OCR" --tags "llm,ocr,vision"
    runtime_alias llm-vision '_llm_vision' --desc "LLM vision" --tags "llm,vision,image"
    runtime_alias llm-embed '_llm_embed' --desc "LLM embed" --tags "llm,embedding"
    runtime_alias llm-think '_llm_think' --desc "LLM think" --tags "llm,reasoning"
    runtime_alias llm-flash '_llm_flash' --desc "LLM flash" --tags "llm,fast"
    runtime_alias llm-flash-file '_llm_flash_file' --desc "LLM flash file" --tags "llm,fast,file"

    runtime_alias llm-help '_llm_help' --desc "LLM help" --tags "llm,help"
}
