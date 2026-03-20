{ mkSkill, pkgs }:

mkSkill {
  name = "code-review";
  description = "Review code changes for correctness, style, and security issues. Use when asked to review a PR, diff, or set of changes.";
  license = "MIT";
  metadata = {
    author = "agentnix-examples";
    version = "1.0";
  };

  skillContent = ''
    # Code Review

    ## Workflow

    1. Read the diff or changed files
    2. Check for correctness — does the logic do what it claims?
    3. Check for style — does it follow project conventions?
    4. Check for security — any injection, auth bypass, or data leak risks?
    5. Summarize findings as actionable comments

    ## Guidelines

    - Be specific: reference file paths and line numbers
    - Suggest fixes, not just problems
    - Distinguish blocking issues from nits
    - Run linters and tests when available before commenting

    See [references/checklist.md](references/checklist.md) for the full review checklist.
  '';

  references = [
    {
      name = "checklist.md";
      content = ''
        # Code Review Checklist

        ## Correctness
        - [ ] Logic matches the stated intent
        - [ ] Edge cases handled (nulls, empty collections, boundaries)
        - [ ] Error paths return meaningful messages

        ## Style
        - [ ] Naming is clear and consistent
        - [ ] No dead code or commented-out blocks
        - [ ] Functions are focused (single responsibility)

        ## Security
        - [ ] No secrets in source
        - [ ] User input is validated/sanitized
        - [ ] Auth checks present where needed

        ## Tests
        - [ ] New code has tests
        - [ ] Existing tests still pass
        - [ ] Edge cases covered
      '';
    }
  ];
}
