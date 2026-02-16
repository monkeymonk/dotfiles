---
name: local-review
description: Use when you need code review for bugs, security issues, or improvements using deepseek-r1:32b reasoning model locally
---

# Local Code Review

Review code using local deepseek-r1:32b reasoning model.

## Overview

Analyze code for bugs, security, and improvements using local reasoning-optimized model.

## When to Use

- Find bugs and logic errors
- Check security vulnerabilities
- Identify performance issues
- Suggest improvements

## Usage

Call `mcp__ollama__use_local_model` with:
- `task_type`: `"code_review"`
- `prompt`: User's code + review request

Return structured feedback directly.

## Output Format

- Specific issues with line references
- Clear problem explanations
- Concrete fix suggestions
- Reasoning for recommendations

## Error Handling

- **Ollama down**: "Start with: `ollama serve`"
- **Model missing**: "Pull with: `ollama pull deepseek-r1:32b`"

No API fallback.
