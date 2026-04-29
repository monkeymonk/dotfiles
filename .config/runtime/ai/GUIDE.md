# AI Stack Guide

End-to-end walkthrough of the local AI stack in this runtime: backends,
model layout, llama-swap, opencode, and the `llm-*` helpers.

---

## 1. The Pieces

| Layer        | What it does                                              | Source                                  |
| ------------ | --------------------------------------------------------- | --------------------------------------- |
| **Backends** | Run the actual inference (`llama-server`, `ollama`)       | external binaries                       |
| **Proxy**    | `llama-swap` — OpenAI-compatible router, lazy model load  | external binary                         |
| **Plugins**  | Detect tools, set env, auto-start backends                | `plugins/llama.sh`, `plugins/ollama.sh`, `plugins/huggingface.sh`, `plugins/ai.sh` |
| **Helpers**  | `llm-*` shell commands (backend-agnostic)                 | `ai/env.sh`, `ai/helpers.sh`, `ai/aliases.sh` |
| **Clients**  | opencode (REPL), zsh-tips (idle hints), custom callers    | `~/.config/opencode/`, `ai/integrations/zsh-tips.zsh` |

Two backends are supported and auto-detected at call time:

- **llama.cpp** via `llama-server` (one model per process) — usually behind
  `llama-swap` so multiple models share a single port.
- **ollama** — its own daemon and CLI, separate model store.

`_llm_backend` (in `ai/helpers.sh`) prefers `llama-swap` if its endpoint
answers, otherwise falls back to `ollama`. Override with `AI_BACKEND=llama`
or `AI_BACKEND=ollama`.

---

## 2. Model Storage

Bulk model files live under `/data/models/` when present. Sub-layout:

```
/data/models/
├── llama.cpp/                  # raw .gguf files for llama-server
├── ollama/                     # ollama blobs (set OLLAMA_MODELS to point here)
├── huggingface/                # HF Hub cache (HF_HUB_CACHE, set by plugins/huggingface.sh)
├── qwen2.5-coder-7b/           # per-model dirs referenced by llama-swap config
├── qwen3-coder-30b/
├── gpt-oss-20b/
└── nomic-embed/
```

Env vars set by the plugins when `/data/models` exists:

| Var               | Set by                  | Value                       |
| ----------------- | ----------------------- | --------------------------- |
| `LLAMA_MODELS_DIR`| `plugins/llama.sh`      | `/data/models`              |
| `HF_HUB_CACHE`    | `plugins/huggingface.sh`| `/data/models/huggingface`  |
| `HF_HOME`         | `plugins/huggingface.sh`| `$XDG_CACHE_HOME/huggingface` (auth tokens stay on home FS) |

Without `/data/models`, the plugins fall back to XDG-style defaults under
`~/.local/share` and `~/.cache`.

---

## 3. Installing Models

### 3a. GGUF files for llama.cpp (via Hugging Face)

Use the `hf` CLI. Downloads land in `$HF_HUB_CACHE` (deduplicated by hash).
Symlink or copy the .gguf you want into the per-model dir referenced by
your llama-swap config.

```sh
# Pull a single quant of a repo (only the file you want, not all 30 GB)
hf download bartowski/Qwen2.5-Coder-7B-Instruct-GGUF \
    --include "*Q4_K_M.gguf"

# Place it where llama-swap config expects it
mkdir -p "$LLAMA_MODELS_DIR/qwen2.5-coder-7b"
ln -s "$HF_HUB_CACHE/models--bartowski--Qwen2.5-Coder-7B-Instruct-GGUF/snapshots/*/qwen2.5-coder-7b-instruct-q4_k_m.gguf" \
      "$LLAMA_MODELS_DIR/qwen2.5-coder-7b/"
```

Login (only needed for gated repos):

```sh
hf auth login
```

### 3b. Ollama models

Ollama manages its own store. Optionally point `OLLAMA_MODELS=/data/models/ollama`
in your shell rc before bootstrap to keep blobs on `/data`.

```sh
ollama pull qwen2.5-coder:7b
ollama pull nomic-embed-text:latest
ollama list
```

### 3c. List what's cached

```sh
hf cache scan                    # HF Hub disk usage
llama-models                     # alias: find $LLAMA_MODELS_DIR -name '*.gguf'
ollama list
```

---

## 4. llama.cpp Standalone

Without llama-swap, `llama-server` runs one model per process. Useful for
benchmarks or one-off serving.

```sh
# Serve one model on $LLAMA_HOST (default 127.0.0.1:8080)
llama-server \
    -m "$LLAMA_MODELS_DIR/qwen2.5-coder-7b/qwen2.5-coder-7b-instruct-q4_k_m.gguf" \
    -c 16384 \
    -ngl 99 -fa on --jinja \
    --host 127.0.0.1 --port 8080

# OpenAI-compatible call
curl -s http://127.0.0.1:8080/v1/chat/completions \
    -H 'Content-Type: application/json' \
    -d '{"model":"local","messages":[{"role":"user","content":"hi"}]}' \
  | jq -r '.choices[0].message.content'

# Or one-shot CLI generation (no server)
llama-cli -m <model.gguf> -p "explain monads" -n 200
```

GPU backend is auto-detected by `plugins/llama.sh` and exported as
`LLAMA_GPU_BACKEND` (`metal` / `cuda` / `rocm` / `vulkan` / `cpu`). Override
by exporting it before bootstrap.

Common flags worth knowing:

| Flag                | Purpose                                                    |
| ------------------- | ---------------------------------------------------------- |
| `-ngl 99`           | Offload all layers to GPU                                  |
| `-c <n>`            | Context window                                             |
| `-fa on`            | Flash attention (always pass a value — `on` / `off` / `auto`)  |
| `--jinja`           | Use the chat template embedded in the GGUF                 |
| `--embeddings`      | Embedding mode (use with `--pooling mean`)                 |
| `--host` / `--port` | Bind address                                               |

---

## 5. llama-swap (Recommended)

`llama-swap` is a thin OpenAI-compatible proxy that lazily spawns the
right `llama-server` for each requested model and unloads idle ones.
Config lives at `~/.config/llama-swap/config.yaml`.

### Start it

```sh
llama-swap-up                    # alias from plugins/llama.sh
                                 #   = llama-swap -config $LLAMA_SWAP_CONFIG \
                                 #                -listen $LLAMA_HOST -watch-config
```

It will also auto-start on first use of any `llm-*` helper or when
opencode launches (see §7). Logs: `~/.local/state/llama-swap.log`.

### How the config works

Each entry under `models:` is a model definition with a `cmd` (the actual
`llama-server` command) and optional `aliases`. The config uses macros
(`server_base`, `chat_args`, `embed_args`) so individual entries stay short.

Roles → aliases → models:

```
ai/helpers.sh role     llama-swap alias    actual model
─────────────────────  ──────────────────  ──────────────────
default, fast       →  default, fast    →  qwen2.5-coder-7b
code                →  code             →  qwen3-coder-30b
reason              →  reason           →  gpt-oss-20b
embed               →  embed            →  nomic-embed
```

### Add a new model

Append to `~/.config/llama-swap/config.yaml`:

```yaml
  "my-new-model":
    name: "My New Model (Q4_K_M)"
    description: "What it's for"
    aliases: ["fancy"]            # optional — lets `_llm_run fancy` reach it
    cmd: |
      ${server_base}
      -m ${models_dir}/my-new-model/file.gguf
      -c 16384
      ${chat_args}
```

`-watch-config` reloads on save — no restart needed. To wire it into a
helper role, override the role variable in `secrets/` or your shell rc:

```sh
export AI_MODEL_FAST=fancy
```

---

## 6. The `llm-*` Helpers

All helpers route through `_llm_run <role> "<prompt>"` (or `_llm_image` for
vision/OCR). They are backend-agnostic — same commands work whether
llama-swap or ollama is the active backend.

```sh
llm-help                         # full reference + active backend + role map
```

Short tour:

```sh
# Code understanding
llm-explain src/foo.ts
llm-summary src/                 # summarize file or directory
llm-arch                         # architecture analysis of cwd

# Git
llm-review                       # review staged diff
llm-review HEAD~3                # review vs ref
llm-commit                       # propose commit message from staged diff

# Shell
llm-cmd "find files modified in the last hour"
echo 'rsync -avz --delete src/ dst/' | llm-explain-cmd

# Code quality
llm-refactor file.py
llm-optimize file.py
llm-security file.py             # security audit — opens result in nvim
llm-test file.py                 # generate tests
llm-doc file.py                  # generate markdown docs

# Problem solving
llm-debug "TypeError: cannot read property 'x' of undefined"
llm-fix file.py "off-by-one in main loop"

# Development
llm-implement "add JWT auth middleware"
echo 'function add(a,b){return a+b}' | llm-convert "rewrite in Rust"
llm-api-client api.yaml typescript

# Vision / embeddings (need vision/ocr/embed model in the active backend)
llm-vision photo.jpg
llm-ocr scan.png
echo "hello world" | llm-embed
```

The `*-edit` variants (e.g. `llm-refactor-edit`, `llm-test-edit`) write
the result to a file and open it in Neovim alongside the original (split
or diff view).

`llm-code` is the only ollama-only helper (interactive REPL). For
llama.cpp, use opencode instead.

### Override the model for a single call

Roles map to `AI_MODEL_*` env vars. Override per-call by passing a literal
model id as the role:

```sh
# Bypass role mapping — use a llama-swap alias or ollama tag directly
echo "..." | _llm_run qwen3-coder-30b "explain"
```

### Switch backends explicitly

```sh
AI_BACKEND=ollama llm-explain file.py        # one-shot
export AI_BACKEND=llama                      # session-wide
unset AI_BACKEND                             # back to auto

# Or interactively:
llm-use                  # show current
llm-use ollama           # switch
llm-use auto             # back to auto-detect
```

### Test & inspect tools

A few helpers exist purely for trying things out without committing to a
full prompt:

```sh
llm-status                                   # full diag: endpoints, role map, models, storage
llm-models active                            # models on the active backend
llm-models all                               # both backends
llm-bench fast                               # one-prompt round-trip timer
llm-bench qwen2.5-coder-3b                   # bench an explicit model
llm-with qwen2.5-coder-3b "ping"             # one-off call, bypass role mapping
echo "explain mutex" | llm-with reason ""    # stdin context still works
llm-pull qwen2.5-coder:7b                    # ollama pull (no slash → ollama)
llm-pull Qwen/Qwen2.5-Coder-3B-Instruct-GGUF '*Q4_K_M*.gguf'   # HF pull (slash → hf download)
```

`llm-pull` infers the backend from the ref shape and lands HF downloads
under `$LLAMA_MODELS_DIR/<lowercased-name>/` — ready to be referenced from
a llama-swap config entry.

---

## 7. opencode + llama.cpp

`~/.config/opencode/opencode.json` declares an OpenAI-compatible provider
pointing at `http://127.0.0.1:8080/v1` (the llama-swap endpoint). The
`./llama-swap.ts` plugin probes the endpoint on opencode start and
auto-spawns `llama-swap` if it's not already running.

Just launch:

```sh
opencode                         # default model: llama.cpp/code (qwen3-coder-30b)
```

Switch model in the opencode UI, or edit `opencode.json` to add more.
The model names there (`code`, `reason`, `default`, `fast`) match the
llama-swap aliases — keep them in sync if you rename roles in the
llama-swap config.

If `agentbox` is installed, `opencode` is aliased to run inside a Docker
container (see `plugins/agentbox.sh`). Use `localopencode` to bypass and
run on the host directly.

---

## 8. Adding a Custom Helper

1. Write the function in `ai/helpers.sh` (name: `_llm_<name>`):

   ```sh
   _llm_haiku() {
       _llm_file fast "$1" \
           "Write a haiku about this code. Only output the haiku."
   }
   ```

   Use `_llm_run <role> "<prompt>"` for free-form prompts, `_llm_file <role> <file> "<prompt>"`
   for file inputs, `_llm_image <role> <image> "<prompt>"` for vision.
   Never call `ollama` or `curl $LLAMA_HOST` directly — that breaks
   backend dispatch.

2. Register the alias in `ai/aliases.sh` inside `runtime_ai_aliases()`:

   ```sh
   alias llm-haiku='_llm_haiku' --desc "LLM haiku" --tags "llm,fun"
   ```

3. Add a line to `_llm_help` in `helpers.sh` if you want it discoverable.

4. Reload: `RUNTIME_BOOTSTRAP_RELOAD=1 . bootstrap.sh` (soft) or
   `exec zsh -l` (clean).

### Picking a role

| Role      | Use for                                        |
| --------- | ---------------------------------------------- |
| `default` | general-purpose explain / summarize            |
| `code`    | refactor, generate, convert, tests             |
| `reason`  | review, security audit, debug, deep analysis   |
| `fast`    | commit messages, short replies, idle tips      |
| `embed`   | embeddings (different endpoint)                |
| `vision`  | image analysis                                 |
| `ocr`     | text extraction from images                    |

---

## 9. Environment Reference

Set in plugins or `ai/env.sh`. Override by exporting before bootstrap.

| Var                 | Default                              | Where set                   |
| ------------------- | ------------------------------------ | --------------------------- |
| `AI_BACKEND`        | `auto`                               | `ai/env.sh`                 |
| `AI_AUTOSTART`      | `1`                                  | `ai/env.sh`                 |
| `AI_MODEL_DEFAULT`  | `default`                            | `ai/env.sh`                 |
| `AI_MODEL_CODE`     | `code`                               | `ai/env.sh`                 |
| `AI_MODEL_REASON`   | `reason`                             | `ai/env.sh`                 |
| `AI_MODEL_FAST`     | `fast`                               | `ai/env.sh`                 |
| `AI_MODEL_EMBED`    | `embed`                              | `ai/env.sh`                 |
| `AI_MODEL_VISION`   | `vision`                             | `ai/env.sh`                 |
| `AI_MODEL_OCR`      | `ocr`                                | `ai/env.sh`                 |
| `LLAMA_HOST`        | `127.0.0.1:8080`                     | `plugins/llama.sh`          |
| `LLAMA_MODELS_DIR`  | `/data/models` (if present)          | `plugins/llama.sh`          |
| `LLAMA_GPU_BACKEND` | autodetected                         | `plugins/llama.sh`          |
| `LLAMA_SWAP_CONFIG` | `~/.config/llama-swap/config.yaml`   | `plugins/llama.sh`          |
| `OLLAMA_HOST`       | `127.0.0.1:11434`                    | `plugins/ollama.sh`, `ai/env.sh` |
| `OLLAMA_MODELS`     | `/data/models/ollama` (if present)   | `plugins/ollama.sh`         |
| `HF_HOME`           | `$XDG_CACHE_HOME/huggingface`        | `plugins/huggingface.sh`    |
| `HF_HUB_CACHE`      | `/data/models/huggingface` (if present) | `plugins/huggingface.sh` |

---

## 10. Troubleshooting

**`llm: no AI backend available`**
Neither `llama-swap` nor `ollama` is reachable. Run `llama-swap-up` or
start `ollama serve`. Check `AI_AUTOSTART=1` and that `llama-swap` is on
PATH.

**`llama-swap failed to come up within 10s`**
Check the log: `tail -n 50 ~/.local/state/llama-swap.log`. Usual causes:
malformed YAML, missing GGUF path, port already bound, GPU OOM on first
model load.

**Helper hangs forever on a big model**
First load is slow (5-30s for 30B). Subsequent calls hit the cached
process. `globalTTL: 900` in the config unloads idle models — bump it if
you want models to stay hot longer.

**`server returned non-JSON`**
The model failed to load or crashed. Check the llama-swap log for the
upstream `llama-server` stderr.

**Wrong model answering**
Verify role mapping: `llm-help` shows current `role → model id`. Then
`curl -s http://$LLAMA_HOST/v1/models | jq` to see which models/aliases
llama-swap actually exposes.

**`hf` command not found but `huggingface-cli` is**
The plugin aliases `hf` to `huggingface-cli` automatically. Reload the
shell after installing.

**Config edits not taking effect**
`llama-swap-up` runs with `-watch-config` — saves reload automatically.
For runtime plugin changes, `RUNTIME_BOOTSTRAP_RELOAD=1 . bootstrap.sh`
or `exec zsh -l`.

---

## 11. Quick Start (Fresh Machine)

```sh
# 1. Install backends (pick one or both)
yay -S llama.cpp-vulkan ollama-rocm    # or your distro equivalent
go install github.com/mostlygeek/llama-swap/cmd/llama-swap@latest
pip install --user "huggingface_hub[cli]"

# 2. Reload shell so plugins detect them
exec zsh -l

# 3. Pull a model
hf download bartowski/Qwen2.5-Coder-7B-Instruct-GGUF --include "*Q4_K_M.gguf"
# (then symlink/copy into $LLAMA_MODELS_DIR/qwen2.5-coder-7b/)

# 4. Start the proxy
llama-swap-up

# 5. Try it
llm-help
echo "what does 'set -e' do" | llm-cmd
opencode
```
