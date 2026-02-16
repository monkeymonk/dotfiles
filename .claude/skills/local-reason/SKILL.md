---
name: local-reason
description: Use when you need deep analysis, architecture decisions, or complex problem-solving using deepseek-r1:32b reasoning model locally
---

# Local Complex Reasoning

Perform deep reasoning using local deepseek-r1:32b model.

## Overview

Handle complex analysis and problem-solving with reasoning-optimized local model.

## When to Use

- Explain complex algorithms
- Compare technologies
- Analyze architectural trade-offs
- Solve technical problems
- Deep code analysis

## Usage

Call `mcp__ollama__use_local_model` with:
- `task_type`: `"reasoning"`
- `prompt`: User's question

Return detailed analysis directly.

## Output Style

- Detailed explanations
- Step-by-step thinking
- Alternative comparisons
- Trade-off analysis
- Concrete examples

## Error Handling

- **Ollama down**: "Start with: `ollama serve`"
- **Model missing**: "Pull with: `ollama pull deepseek-r1:32b`"

No API fallback.
