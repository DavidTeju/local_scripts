[Important] When I ask a question, just answer the question. Do NOT make code changes, edits, or modifications unless I explicitly ask you to. Questions are for understanding; action requires a separate, clear instruction.

When generating reports, analyses, or long-form structured output, save it to a file and open it rather than printing to the terminal. Default to a markdown file opened in Obsidian via its URI scheme: `open "obsidian://open?path=$(python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))' "<absolute-path>")"` — `open -a Obsidian <path>` does NOT navigate to the file (Obsidian ignores the path arg and just focuses the app). The file must be inside a known Obsidian vault. Use a self-contained HTML page (opened in the browser) when interactivity adds real value (sortable tables, filtering, charts, collapsible sections, etc.).

[Important] When making significant changes or at the end of a long task/feature run, always check existing documentation for outdated info and update with any relevant information

[Shell] The `rm` command is aliased to `rm -i` (interactive mode). Use `rm -f` to bypass prompts when deletion is intentional.

[Python] Use `uv` for Python package management. Never use `pip install --break-system-packages`. For one-off scripts needing dependencies, use `uvx` or `uv run --with <pkg>` instead.

[Debugging] For confusing bugs, use the AI Agent Debugging Guide at `~/.claude/skills/ai-agent-debugging-guide/`. Core principle: create a standalone debug script with extensive logging using real data. Don't guess - observe first.

NEVER EVER EVER APOLOGIZE. If you made a mistake, focus on understanding why and how we can prevent that in the future. You do not yet have continuous learning. Apologies are useless. Actions are useful

[Multi-Agent] When working with another agent's output (subagent reports, junior agent findings, review results), NEVER blindly trust their claims. Always verify against actual code before acting on or endorsing findings.

[Testing] Red-green testing always. When modifying code, write a failing test first (red), run it to confirm failure, then make the fix and verify it passes (green). No code changes without test-first workflow.

[Shared Config] `@davidteju/dev-config` (at `~/projects/dev-config`) is the shared ESLint, Prettier, TSConfig, Vitest, and lint-staged config package used across all DavidTeju projects. Installed from GitHub. Supports SvelteKit and Next.js. When modifying linting rules, prettier settings, or tsconfig across projects, update this package rather than individual project configs.

[Refactoring] Always leave code better than you found it. When touching a file, fix obvious pre-existing issues in the code you're working with (especially when they cause an actual issue) — don't defer them as "out of scope" just because they existed before your change. (Opportunistic refactoring per Martin Fowler.)

[PR Reviews] When reviewing PRs and leaving inline comments, submit the review as "request changes" (not just "comment") if the goal is to request changes. Use `gh pr review --request-changes`.
