# ai/ — Local AI Tooling

Shell-integrated LLM tools powered by [Ollama](https://ollama.com). Loaded automatically when `ollama` is on PATH.

## Structure

```
ai/
├── env.sh                    # Model vars, host config (declarative)
├── helpers.sh                # All _llm_* function implementations
├── aliases.sh                # llm-* alias registrations
├── data/
│   └── tips.txt              # Static tips pool for shell idle display
└── integrations/
    └── zsh-tips.zsh          # ZLE idle-tip display + dynamic generation
```

Loaded via `plugins/ollama.sh` (thin shim) during the `setup` hook phase.

## Commands

### Code Understanding

| Command                   | Description                   |
| ------------------------- | ----------------------------- |
| `llm-explain <file>`      | Explain code concisely        |
| `llm-explain-edit <file>` | Explain code → open in Neovim |
| `llm-summary <path>`      | Summarize file or directory   |
| `llm-arch [dir]`          | Analyze project architecture  |

### Git Integration

| Command                 | Description                                 |
| ----------------------- | ------------------------------------------- |
| `llm-review [ref]`      | Review git changes                          |
| `llm-review-edit [ref]` | Review → open in Neovim                     |
| `llm-commit`            | Generate commit message from staged changes |

### Shell Assistance

| Command                     | Description                             |
| --------------------------- | --------------------------------------- |
| `llm-cmd "question"`        | Ask how to do something in the shell    |
| `llm-explain-cmd <command>` | Explain a shell command (accepts stdin) |

### Code Quality

| Command                    | Description                                 |
| -------------------------- | ------------------------------------------- |
| `llm-refactor <file>`      | Get refactoring suggestions                 |
| `llm-refactor-edit <file>` | Refactor with side-by-side Neovim view      |
| `llm-optimize <file>`      | Get optimization suggestions                |
| `llm-optimize-edit <file>` | Optimize with diff view                     |
| `llm-security <file>`      | Security audit (SQLi, XSS, injection, etc.) |

### Testing & Documentation

| Command                | Description                     |
| ---------------------- | ------------------------------- |
| `llm-test <file>`      | Generate test cases             |
| `llm-test-edit <file>` | Generate tests in split view    |
| `llm-doc <file>`       | Generate markdown documentation |
| `llm-doc-edit <file>`  | Generate docs in split view     |

### Problem Solving

| Command                  | Description                                     |
| ------------------------ | ----------------------------------------------- |
| `llm-debug "error"`      | Diagnose an error: causes, investigation, fixes |
| `llm-fix <file> [error]` | Root-cause analysis + fix in Neovim split       |

### Development

| Command                        | Description                                    |
| ------------------------------ | ---------------------------------------------- |
| `llm-implement "feature"`      | Plan feature implementation with code examples |
| `llm-convert "instruction"`    | Convert code via stdin pipe                    |
| `llm-api-client <spec> <lang>` | Generate API client from OpenAPI spec          |
| `llm-code [model]`             | Start interactive coding session               |

### Vision & OCR

| Command                       | Description                  |
| ----------------------------- | ---------------------------- |
| `llm-ocr <image>`             | Extract text from image      |
| `llm-vision <image> [prompt]` | Describe or analyze an image |

### Embedding & Reasoning

| Command                          | Description                                |
| -------------------------------- | ------------------------------------------ |
| `llm-embed <text\|file>`         | Generate embeddings (accepts stdin)        |
| `llm-think "question"`           | Deep reasoning query                       |
| `llm-flash "prompt"`             | Fast general-purpose query (accepts stdin) |
| `llm-flash-file <file> "prompt"` | Fast file analysis                         |

### Meta

| Command    | Description                                         |
| ---------- | --------------------------------------------------- |
| `llm-help` | Print full reference with current model assignments |

## Models

Configured in `env.sh`. Override any via environment before shell init.

| Variable              | Default                   | Purpose                             |
| --------------------- | ------------------------- | ----------------------------------- |
| `OLLAMA_MODEL`        | `qwen2.5-coder:7b`        | General default                     |
| `OLLAMA_MODEL_CODE`   | `qwen3-coder:30b`         | Code generation, refactoring, tests |
| `OLLAMA_MODEL_REASON` | `qwen3.5:35b`             | Reviews, debugging, security audits |
| `OLLAMA_MODEL_FAST`   | `qwen3.5:9b-q4_K_M`       | Commit messages, light tasks        |
| `OLLAMA_MODEL_OCR`    | `glm-ocr:latest`          | Text extraction from images         |
| `OLLAMA_MODEL_VISION` | `llama3.2-vision:11b`     | Image analysis                      |
| `OLLAMA_MODEL_EMBED`  | `nomic-embed-text:latest` | Embeddings                          |
| `OLLAMA_MODEL_THINK`  | `lfm2.5-thinking:latest`  | Deep reasoning                      |
| `OLLAMA_MODEL_FLASH`  | `glm-4.7-flash:latest`    | Fast general tasks                  |

## Server Config

| Variable                   | Default           |
| -------------------------- | ----------------- |
| `OLLAMA_HOST`              | `127.0.0.1:11434` |
| `OLLAMA_NUM_PARALLEL`      | `1`               |
| `OLLAMA_MAX_LOADED_MODELS` | `1`               |
| `OLLAMA_LOG_LEVEL`         | `warn`            |
| `OLLAMA_GPU_OVERHEAD`      | `64`              |

## Dynamic Tips (zsh)

When idle for 8 seconds, the shell displays a rotating tip below the prompt.

- **Static tips** from `ai/data/tips.txt`
- **Dynamic tips** generated per-project via a pluggable generator (cached with `cache-run`, TTL 1h)
- 70/30 weight favoring dynamic tips when available

### Generator Contract

Any command set via `ZSH_TIPS_GENERATOR` must follow:

| Aspect           | Requirement                                            |
| ---------------- | ------------------------------------------------------ |
| **Input**        | Directory path as `$1`                                 |
| **Output**       | Tips to stdout, one per line                           |
| **Exit**         | `0` = success, non-zero = skip                         |
| **Dependencies** | Generator checks its own (no checks in `zsh-tips.zsh`) |

Default generator: `tips-generate` (backend-agnostic — dispatches to ollama or llama.cpp through `ai/helpers.sh :: _llm_run`, whichever is reachable).

Dynamic tips only generate for project directories (detected by `is-project-dir`). A directory is considered a project if it contains a git repo, package manifests, build files, or AI agent context files (CLAUDE.md, AGENTS.md, etc.).

### Configuration

| Variable                 | Default                | Description                   |
| ------------------------ | ---------------------- | ----------------------------- |
| `ZSH_TIPS_DYNAMIC`       | `1`                    | Enable/disable dynamic tips   |
| `ZSH_TIPS_DYNAMIC_TTL`   | `3600`                 | Cache TTL in seconds          |
| `ZSH_TIPS_GENERATOR`     | `tips-generate`        | Generator command             |
| `ZSH_TIPS_DYNAMIC_MODEL` | `$AI_MODEL_FAST`       | Model override (bypasses role mapping) |
| `ZSH_TIPS_DEBUG`         | `0`                    | Enable debug logging          |

### Custom Generator Example

```sh
#!/usr/bin/env sh
# scripts/tips-generate-custom — static project-aware tips
set -e
dir="$1"
[ -f "$dir/Makefile" ] && echo "Run 'make help' to see available targets"
[ -f "$dir/package.json" ] && echo "Run 'npm test' to execute the test suite"
[ -d "$dir/.git" ] && echo "Use 'git log --oneline -10' for recent history"
```

Force refresh tips for current directory:

```sh
tips-refresh          # current directory
tips-refresh ~/myapp  # specific directory
```

Debug: `ZSH_TIPS_DEBUG=1 exec zsh -l` then `tail -f ~/.cache/runtime/tips-debug.log`

Disable dynamic: `ZSH_TIPS_DYNAMIC=0`

## Adding New Helpers

1. Add function to `helpers.sh` (name: `_llm_<name>`)
2. Register alias in `aliases.sh` inside `runtime_ai_aliases()`
3. Add entry to `_llm_help` output in `helpers.sh`
4. Add a line to `data/tips.txt` if useful as a shell tip
