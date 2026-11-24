# gh-report

Dense GitHub report of open issues and PRs that deserve attention.

## Usage

Requires Go 1.25+ and an authenticated [GitHub CLI](https://cli.github.com/).
Edit `repos.txt` to select repositories. Each fetch stores up to 50 open issues
and 50 open PRs per repository in the gitignored `data/` directory.
A fetch with any failed request exits nonzero and retains that repository's
previous snapshot.


    make fetch    # one GraphQL call per repo in repos.txt
    make report   # render from data/ to stdout

## Output modes

    go run ./cmd/gh-report           # markdown (default)
    go run ./cmd/gh-report --ansi    # ANSI colors
    go run ./cmd/gh-report --json    # JSON

Originally proposed in [gnolang/gno#5703](https://github.com/gnolang/gno/pull/5703).
This standalone repository retains the original Gno Network General Public
License in [LICENSE.md](LICENSE.md).

## Prior art

Samourai run a [weekly-report skill](https://github.com/samouraiworld/gno-agent-workspace/blob/main/skills/weekly-report.md)
over the same repositories, driven by
[`weekly-report.sh`](https://github.com/samouraiworld/gno-agent-workspace/blob/main/scripts/weekly-report.sh)
and [`parse-context.sh`](https://github.com/samouraiworld/gno-agent-workspace/blob/main/scripts/parse-context.sh)
(pointed out by @davd-gzl on #5703; [sample output](https://github.com/samouraiworld/gno-agent-workspace/blob/main/reports/weekly/2026-05-17/report.md)).

The two solve different halves of the problem and are worth keeping distinct:

- Theirs is prose-first and agent-driven — a shell pipeline gathers context and
  a model writes the narrative. Good for a weekly digest a human reads once.
- This one is deterministic and diff-able: one GraphQL query per repo, then a
  pure renderer with golden tests, no model in the loop. The same input and report time
  give the same report, which makes it usable as a triage list you
  re-run daily and compare against yesterday's.

If the two converge, the natural split is this tool as the data layer (its
`--json` mode is meant for exactly that) feeding a prose pass like theirs,
rather than either one growing the other's half.
