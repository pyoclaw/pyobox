Generate tests for {{path}}. Use the project's existing test framework.

Cover:
1. **Happy path** — Normal inputs, expected outputs
2. **Edge cases** — Empty, null, boundary values, type edge cases
3. **Error cases** — Invalid input, missing resources, authorization failures
4. **Regression cases** — Known bug scenarios if evident from the code

For each test:
- Descriptive test name following project conventions
- Arrange-Act-Assert structure
- Mock external dependencies
