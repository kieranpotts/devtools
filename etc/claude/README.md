# Claude settings

`~/.claude/settings.json`, and project-level `.claude/settings.json`, are shared
between the CLI and VS Code extensions... indeed, all UIs to Claude.

Anything about how Claude Code _behaves_ – permissions, hooks, MCP,
model/provider – belongs in `~/.claude/settings.json`. MCP serves need to be
added through the CLI.

> [!NOTE]
> Claude's settings.json does NOT support inline comments.

## Permissions

The most liberal option is `bypassPermissions`, which is the equivalent of
passing the `--dangerously-skip-permissions` flag when starting a new session.
This mode skips all permission prompts, including writes to `.git`, `.claude`,
`.vscode`, `.idea`, and `.husky`. There are still a few hardcoded guardrails.
For example, removals targeting the filesystem root or home directory, such
as `rm -rf /` and `rm -rf ~`, still prompt as a circuit breaker against model
error. Nevertheless, this setting is suitable only for highly isolated
environments – containers or VMs where AIs let loose can't cause widespread
damage.

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

For working on local development machines unattended, the safer low-friction
pattern is the `dontAsk` mode paired with an explicit `permissions.allow` list.
Anything not on the list is denied outright, instead of prompting, so flow is
uninterrupted — supporting away-from-keyboard agentic working.

```json
{
  "permissions": {
    "defaultMode": "dontAsk"
  }
}
```

A middle ground is `acceptEdits`, which is what I actually run day-to-day. It
auto-approves file edits — `Write`, `Edit`, `NotebookEdit` — without prompting,
but everything else (`Bash`, `WebFetch`, etc.) still goes through the normal
allow/deny/ask permission flow. This removes the most repetitive prompt
(confirming every file change) while keeping a human-in-the-loop for anything
that runs a command or reaches the network. It's the right default for
sitting at the keyboard and reviewing diffs as they happen, as opposed to
`dontAsk`/`bypassPermissions`, which are for unattended runs.

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

## Allow/deny lists

My settings include both allow and deny lists that are designed to skip prompts
for inspection and routine dev tasks, but to keep prompts for anything that
mutates the world outside of the current repository/workspace.

- `rm`, `sudo`, `dd`, `mkfs` are the classic foot-guns and stay on the deny.
  File deletion is the operation most worth confirming explicitly.

- Read-only `git` subcommands (`status`, `diff`, `log`, `show`, `branch`) plus
  `add`, `restore`, and `rm` are allowed, since these are either inert or
  locally reversible. But `commit`, `push`, `reset --hard`, and `clean` are
  all denied. Mutating revision history (even if append-only) and pushing new
  artifacts to upstream repositories or registries — these activities should
  be deliberate, confirmed actions by the user. The same logic applied for
  `npm publish`, `pnpm publish`, and `docker push`.

- Reading of `.env`, `~/.ssh` and other credentials are denied. These rules not
  only apply to Claude's built-in tools, but also to shell commands like `cat`,
  `head`, `tail`, and `sed`. But they do not apply to arbitrary subprocesses
  that read or write files indirectly, like a Python or Node scripts that opens
  files itself. So it's not a perfect sandbox.

- I've included explicit settings for `ls`, `cat`, `pwd`, `head`, `tail`,
  `wc`, `rg`, `fd`, `diff`, and read-only `git` subcommands. Out-of-the-box,
  Claude will run these in any mode anyway (and `Grep`/`Glob` are separate
  built-in tools, not Bash calls), so these configurations are technically
  redundant, but I've included them anyway to document intent.

- Routine dev-tooling is allowed outright: `npm`/`pnpm`/`yarn`/`npx`,
  `python`/`pip`/`uv`/`pytest`/`ruff`/`mypy`, `make`, `docker compose`, `jq`,
  and basic filesystem ops (`mkdir`, `touch`, `cp`, `mv`).

- `WebSearch` is allowed, and `WebFetch` is scoped to a handful of trusted doc
  domains (GitHub, Antora, Asciidoctor) rather than the open internet.

- Per-project `.claude/settings.json` should add project-specific commands
  (eg. `Bash(terraform plan *)` for an infra repo) rather than putting them
  globally.
