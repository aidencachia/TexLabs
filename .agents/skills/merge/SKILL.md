---
name: merge
description: >-
  Squash-merge the requested TexLabs change into main through a GitHub pull
  request. Invoke only when the user explicitly requests merging or landing
  the change, not for review, preparation, passing checks, or skill installation.
disable-model-invocation: true
metadata:
  delta-action: land
---

# Merge TexLabs changes

Use this workflow only for `github.com/aidencachia/TexLabs`, with `origin`
as the publication remote and `main` as the destination. A `/merge`
invocation or equivalent explicit request authorizes merging the identified
change; do not ask for that permission again. Ask if the change itself is
ambiguous.

## Prepare the requested change

1. Inspect the working tree and index, branch and commit history, existing
   pull requests, and remote URLs. Confirm `origin` points to TexLabs on
   GitHub; never publish to the `local` backlink. Fetch `origin` and confirm
   that `main` is still the intended destination. Check for current repository
   contribution instructions, PR templates, and branch rules before preparing
   the submission. Apply any applicable obligations, including conditional
   ones; ask only for required contributions or decisions still outstanding.
2. Reuse a suitable topic branch and PR if their changes match the request.
   Otherwise, prepare a clearly named topic branch from current `origin/main`
   in a separate checkout, leaving the original index and working files
   intact. Replay only the intended commits and transfer only the intended
   staged, unstaged, or untracked changes. Confirm the resulting diff contains
   the entire request and nothing else; never sweep in unrelated edits,
   generated artifacts, or secrets. If the requested change cannot be
   separated safely, stop and ask. Use a descriptive commit title and
   non-interactive commit messages; respect configured signing and hooks.
3. When integrating with current `origin/main`, resolve conflicts
   automatically only if the intended result is clear and unrelated work can
   be preserved. Explain which files conflicted, the options considered,
   what was chosen, and why. If intent is ambiguous, resolution is unsafe,
   or verification fails, stop and describe the blocker. Do not force-push,
   discard changes, or rewrite a shared branch to make it mergeable.

## Verify the candidate

- Review the complete candidate PR diff from its merge base with
  `origin/main`, run `git diff --check origin/main...HEAD` on the committed
  candidate, and inspect changed Markdown for valid structure and affected
  links. A docs-only change that does not affect template behavior needs no
  TeX build.
- For changes affecting the final-year project template, run
  `make -C templates/uni-fyp-template main.pdf` in the separate checkout.
  Source: `templates/uni-fyp-template/makefile` (`main.pdf: main.tex` uses
  `latexmk` with LuaLaTeX), `templates/uni-fyp-template/latexmkrc` (glossary
  helper configuration), and `templates/uni-fyp-template/fict.cls`
  (`biblatex` and glossary dependencies). Verify the resulting PDF and
  affected bibliography or glossary output. Check for `latexmk`, LuaLaTeX,
  Biber, `makeglossaries`, and required TeX packages; an unavailable
  dependency is not a passing build.
- For changes affecting `templates/uniarticle.cls` or
  `templates/unireport.cls`, use a representative minimal document for each
  affected class in a disposable checkout and compile it with a
  `fontspec`-compatible engine. The affected class files declare the
  `fontspec` dependency and the Fira Sans and JetBrains Mono font
  requirements. Verify the output exercises the changed behavior. Keep
  fixtures and generated output out of the PR. Do not enable shell escape
  to work around missing dependencies. If applicable local verification
  cannot pass, stop and explain what is needed.

## Publish, squash-merge, and confirm

1. Check GitHub CLI authentication and repository access. Push only the
   candidate topic branch to `origin` without force. Open or reuse a
   non-draft PR against `main` on `aidencachia/TexLabs`, with a descriptive
   title and a body explaining the change and verification. Verify the PR's
   base, head owner and branch, exact head SHA, and diff before proceeding.
2. Read the current rules for `main`, including applicable rulesets and
   classic branch protection. Confirm that squash merging is enabled and
   that applicable requirements for approvals, conversations, up-to-date
   branches, and any other gates are satisfied. Determine the actual list
   of required checks and verify that **all** passed on the revision GitHub
   requires for this PR, including a test merge revision if applicable.
   Use the PR's check rollup and `gh pr checks --required` to corroborate
   that list; an empty rollup alone does not establish that none are
   required. Pending, failing, missing, or unverifiable required checks
   block the merge. Recheck after any head change or base update that affects
   the evidence. If GitHub now requires a queue or another merge method,
   stop rather than bypass the rules or silently change the approved method.
3. Once verified, run
   `gh pr merge "$pr" -R aidencachia/TexLabs --squash --match-head-commit "$head_sha"`,
   using the reviewed PR number and verified head SHA. Do not use admin
   bypass, auto-merge, or direct pushes to `main`. Do not delete the topic
   branch yourself or reset the original checkout.
4. Confirm GitHub reports the PR as `MERGED` with base `main` and a merge
   commit SHA. Fetch `origin` again and use
   `git merge-base --is-ancestor "$merge_sha" origin/main` to verify that
   the squash commit reached the destination. Report the PR URL, commit,
   verification, and any conflict decisions. If blocked before merging,
   report that the changes have not merged and name the blocker. If the
   merge was attempted but the result cannot be verified, report what
   GitHub confirmed and what remains unknown rather than claiming success
   or retrying blindly.
