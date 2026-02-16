---
name: local-doc
description: Use when generating documentation, docstrings, or README files using fast qwen2.5-coder:7b model locally
---

# Local Documentation

Generate documentation using local qwen2.5-coder:7b model (~80 tok/s, fastest).

## Overview

Create docstrings, READMEs, and code comments using fast local model.

## When to Use

- Write function docstrings
- Create README files
- Add code comments
- Generate API docs

## Usage

Call `mcp__ollama__use_local_model` with:
- `task_type`: `"documentation"`
- `prompt`: User's prompt

Return documentation directly.

## Output Style

- Language-appropriate format (JSDoc, Python docstrings, etc.)
- Parameter descriptions
- Usage examples
- Proper formatting

## Error Handling

- **Ollama down**: "Start with: `ollama serve`"
- **Model missing**: "Pull with: `ollama pull qwen2.5-coder:7b`"

No API fallback.
