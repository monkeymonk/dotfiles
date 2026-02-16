---
name: local-ask
description: Use when you need quick answers to simple questions using fast qwen2.5-coder:7b model locally
---

# Local Quick Queries

Get fast answers using local qwen2.5-coder:7b model (~80 tok/s).

## Overview

Quick responses to simple questions using fastest local model.

## When to Use

- Quick programming questions
- Simple lookups
- Brief explanations
- Syntax questions
- Error meanings

**NOT for:** Complex reasoning (`/local-reason`) or code generation (`/local-code`)

## Usage

Call `mcp__ollama__use_local_model` with:
- `task_type`: `"quick_task"`
- `prompt`: User's question

Return brief answer directly.

## Output Style

- Brief, direct answers
- No unnecessary detail
- Fastest response (~1-3s)

## Error Handling

- **Ollama down**: "Start with: `ollama serve`"
- **Model missing**: "Pull with: `ollama pull qwen2.5-coder:7b`"

No API fallback.
