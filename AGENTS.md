# AGENTS.md

Template repo that publishes Literate notebooks as a GitHub Pages book. There is no
library to ship — the deliverable is executed notebooks plus the built site. The main
"code" is the CI driver `.github/ci.jl`.

## Verify changes

No test/lint/typecheck suite. Full local verification:

1. `julia --project=@. -p 4 .github/ci.jl` — runs only notebooks whose content changed
2. `cd docs && jupyter-book build --html` — output in `docs/_build/html`

## Notebook workflow

- Notebook sources are `docs/**/*-lit.jl` in Literate format: `#`-prefixed lines are
  markdown, `#---` separates code cells, `md"""…"""` markdown blocks work
  (`Literate.notebook(...; mdstrings=true)`), and Jupyter soft scope is on.
- `.ipynb` files are generated output and are gitignored (`*.ipynb`). Never hand-edit
  or commit them; `docs/myst.yml` TOC patterns match the *generated* `*.ipynb`.
- `ci.jl` SHA256-caches runs: stamps live in `.cache/<mirrored path>/<name>.sha`, built
  notebooks in `.cache/`. Unchanged notebooks are skipped — force a rerun by deleting
  the `.sha` file, editing the source, or dispatching the "Clear caches" workflow (`.github/workflows/clear-cache.yml`,
  also runs automatically when a PR closes).
- Configurable via env: `DOCDIR` (default `docs`), `NBCACHE` (default `.cache`).
- Literate 2.21 executes notebooks in-process (it vendors IJulia's display code — no
  IJulia dependency). `GKSwstype=100` is set on workers for headless GR.
- `to_literate` in `ci.jl` is an unused helper for manual `.ipynb` → `.jl` conversion;
  `list_notebooks` only picks up `.jl` files.

## Environment quirks

- The Julia version for CI is read from `julia_version = "…"` in the committed
  `Manifest.toml` (ci.yml awk-extracts it for `setup-julia`). The Manifest is
  deliberately committed as the pinned environment and is updated by a weekly bot —
  do not edit it by hand.
- `Startup/` is a local package (PrecompileTools) in the root project's Pkg workspace
  (`[workspace]` + `[sources]` in root `Project.toml`). Put expensive warm-up there and
  `using Startup` from notebooks.

## CI & automation gotchas

- ci.yml caches executed notebooks at the job level: on a cache hit it skips *all*
  Python/Julia setup, then always copies `.cache/docs/*` into `docs/` before building.
  Cache keys hash `Project.toml`, `Manifest.toml`, `Startup/**`, and `docs/**/*.jl`
  (bump `CACHE_NUM` to invalidate the Julia/package cache).
- The site deploys to GitHub Pages only from pushes to `main` (repo Pages setting must
  be "GitHub Actions").
- Dependency updates are automated: Dependabot (pip + github-actions, `automerge` label,
  squash-merged by Kodiak via `.github/.kodiak.toml`) and the weekly
  `update-manifest.yml` PR (uses a GitHub App token so CI triggers on the PR). Expect
  green automated PRs; don't fight them.
- `linkcheck.yml` (lychee, monthly, checks `docs/**/*.md` and `docs/**/*.jl`) files an
  issue on broken links — it never fails CI. Exclusions go in `.lycheeignore`.
- Indentation per `.editorconfig`: 4 spaces in `.jl`, 2 spaces in `.yml`/`.md`/`.toml`/`.json`.
