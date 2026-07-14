---
name: perplexity
description: Ask Perplexity a question by driving Channing's logged-in Chrome session, and report its answer. Use when the user says "ask Perplexity", "what does Perplexity say", "run this past Perplexity", or wants a Perplexity-sourced answer or second opinion. Avoids the paid Perplexity MCP server.
---

# Perplexity via browser

Ask perplexity.ai questions through the browser instead of the paid MCP server.

## Prerequisites

Use the @Chrome tool — they drive Channing's own Chrome, where he is already
logged into Perplexity.

## Asking

1. `tabs_context_mcp`, then `tabs_create_mcp` for a fresh tab.
2. `navigate` to `https://www.perplexity.ai/search/new?q=<url-encoded question>`.
   The `/search/new` path **auto-submits** — no clicking needed. The URL rewrites to
   `/search/<uuid>` once the thread exists.
3. `wait` ~8s, then `get_page_text`.
4. If the answer is still streaming, `wait` and re-read. It is complete when a
   `Follow-ups` block and a trailing `Sources / N` block appear; a final paragraph that
   stops mid-sentence means it is still generating.

## Follow-ups

Stay in the same tab to keep thread context:

1. `read_page` with `filter: interactive` → find the bare `textbox` near the bottom
   (the "Ask a follow-up" box, just above the Submit button).
2. `left_click` its ref, `type` the question, `key: Return`.
3. Wait and `get_page_text` as above.

`get_page_text` returns the **whole thread** every time, so extract only the text after the
last question — don't re-report earlier answers.

## Reporting back

Attribute the answer to Perplexity and keep it distinct from your own knowledge; if you
disagree with it, say so separately rather than silently correcting it.

Citations come through as bare source names (`britannica`, `+2`) with no URLs. If Channing
needs the actual links, click the **Links** tab (`tablist "Answer mode tabs"`) or pull the
`href`s from `read_page`.
