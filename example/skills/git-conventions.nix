{ mkSkill }:

mkSkill {
  name = "git-conventions";
  description = "Enforce git commit message conventions and branching strategy. Use when creating commits, branches, or preparing releases.";

  skillContent = ''
    # Git Conventions

    ## Commit Messages

    Follow the Conventional Commits format:

    ```
    <type>(<scope>): <subject>

    [optional body]

    [optional footer]
    ```

    ### Types
    - `feat` — new feature
    - `fix` — bug fix
    - `docs` — documentation only
    - `style` — formatting, no logic change
    - `refactor` — code restructuring, no behavior change
    - `test` — adding or updating tests
    - `chore` — maintenance, deps, CI

    ### Rules
    - Subject line: imperative mood, max 72 chars, no period
    - Body: wrap at 80 chars, explain *why* not *what*
    - Footer: reference issues with `Closes #123`

    ## Branch Naming

    ```
    <type>/<short-description>
    ```

    Examples: `feat/user-auth`, `fix/null-pointer`, `chore/update-deps`

    ## Examples

    See [examples/good-commits.md](examples/good-commits.md) for annotated examples.
  '';

  examples = [
    {
      name = "good-commits.md";
      content = ''
        # Good Commit Examples

        ```
        feat(auth): add JWT token refresh

        Tokens now auto-refresh 5 minutes before expiry.
        This prevents users from being logged out mid-session.

        Closes #142
        ```

        ```
        fix(api): handle empty response body

        The /users endpoint returned 500 when the database was empty.
        Now returns an empty array with 200 status.
        ```

        ```
        chore: update nixpkgs to 24.11
        ```
      '';
    }
  ];
}
