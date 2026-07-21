Generate a commit message following conventional commits format from the staged changes.

Run `git diff --cached --stat` and `git diff --cached` to analyze the changes.

Format:
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: feat, fix, refactor, chore, docs, style, test, perf, ci, build, revert
Scopes: keep narrow (component/module name)

Rules:
- First line max 72 chars
- Use imperative mood ("add" not "added")
- Explain WHY not just WHAT
- Reference issues with `#issue` syntax in footer

Output just the commit message (no preamble).
