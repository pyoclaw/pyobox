Review the staged changes in this repository. Run `git diff --cached` and analyze with these lenses:

1. **Bugs & Logic Errors** — Off-by-one, null safety, race conditions, incorrect assumptions
2. **Security** — Injection risks, credential exposure, path traversal, unsafe deserialization
3. **Error Handling** — Missing try/catch, swallowed errors, incorrect error propagation
4. **Performance** — N+1 queries, unnecessary allocations, O(n²) where O(n) suffices
5. **Style & Readability** — Naming, complexity, dead code, test coverage gaps

Output a concise review with actionable findings.
