---
name: local-code
description: Use when you want to generate code locally with qwen3-coder:30b using minimal documentation style (short comments and examples only, no verbose docstrings)
---

# Local Code Generation

Generate code using local Ollama model (qwen3-coder:30b).

## Overview

Directly invoke local qwen3-coder:30b model for code generation with minimal documentation style.

## When to Use

- Generate new functions, classes, or scripts
- Create boilerplate code
- Implement algorithms
- Build components

**NOT for full documentation** - use `/local-doc` for that.

## Usage

Call `mcp__ollama__use_local_model` with:
- `task_type`: `"code_generation"`
- `prompt`: User's prompt + "Keep documentation minimal - only short inline comments and a simple usage example. No verbose docstrings."

Return generated code directly without meta-commentary.

## Output Style

```python
def example_function(param):
    # Short inline comment explaining logic
    result = process(param)
    return result

# Example: example_function(5) → processed_5
```

## Error Handling

- **Ollama down**: "Start with: `ollama serve`"
- **Model missing**: "Pull with: `ollama pull qwen3-coder:30b`"
- **Empty prompt**: Show usage example

No API fallback.
