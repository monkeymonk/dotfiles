---
name: local-custom
description: Use when you want to specify a custom Ollama model or override default model selection for any task
---

# Local Custom Model

Use any local Ollama model with custom selection.

## Overview

Flexible model selection for any of your 18 local models.

## When to Use

- Experiment with models
- Use specialized models
- Override defaults
- Test performance

## Usage

**Parse arguments:**
1. If first word matches model name → use as `model_override`
2. Otherwise → use default qwen3-coder:30b

Call `mcp__ollama__use_local_model` with:
- `task_type`: `"custom"`
- `prompt`: User's prompt
- `model_override`: Specified or default model

## Examples

```
llama3.1:70b explain quantum computing
codestral write complex algorithm
starcoder2:15b generate TypeScript
quick prototype (uses default)
```

## Available Models

Check with: `ollama list`

Common:
- llama3.1:70b (best quality, slowest)
- qwen3-coder:30b (balanced)
- deepseek-r1:32b (reasoning)
- qwen2.5-coder:7b (fastest)

## Error Handling

- **Ollama down**: "Start with: `ollama serve`"
- **Model missing**: "Pull with: `ollama pull <model>`" + alternatives

No API fallback.
