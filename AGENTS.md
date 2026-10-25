# AGENTS.md

Template repo that publishes Literate notebooks as a GitHub Pages book. There is no
library to ship — the deliverable is executed notebooks plus the built site. The main
"code" is the CI driver `.github/ci.jl`.

## Verify changes

No test/lint/typecheck suite. Full local verification:

1. `julia --project=@. -p $(nproc) .github/ci.jl` — runs only notebooks whose content changed (CI uses `-p $LITERATE_PROC`, default 4 workers, and sets `BASE_URL` when building the site)
2. `cd docs && jupyter-book build --html` — output in `docs/_build/html`

## Notebook workflow

- Notebook sources are `docs/**/*.jl` in Literate format: `#`-prefixed lines are markdown, `#---` separates code cells, `md"""…"""` markdown blocks work (`Literate.notebook(...; mdstrings=true)`), and Jupyter soft scope is on. Comments in code blocks should start with double hash tags `##` to comply with the Literate format — single-`#` lines are parsed as markdown.
- `.ipynb` files are generated output and are gitignored (`*.ipynb`). Never hand-edit or commit them; `docs/myst.yml` TOC patterns match the *generated* `*.ipynb`.
- `ci.jl` SHA256-caches runs: stamps live in `.cache/<mirrored path>/<name>.sha`, built notebooks in `.cache/`. Unchanged notebooks are skipped — force a rerun by deleting the `.sha` file, editing the source, or dispatching the "Clear caches" workflow (`.github/workflows/clear-cache.yml`, also runs automatically when a PR closes).
- Configurable via env: `DOCDIR` (default `docs`), `NBCACHE` (default `.cache`).
- Literate 2.21 executes notebooks in-process (it vendors IJulia's display code — no IJulia dependency). `GKSwstype=100` is set on workers for headless GR.
- The function `to_literate` in `ci.jl` is an unused helper for manual `.ipynb` → `.jl` conversion; `list_notebooks` only picks up `.jl` files.

## Environment quirks

- The Julia version for CI is read from `julia_version = "…"` in the committed
  `Manifest.toml` (ci.yml awk-extracts it for `setup-julia`). The Manifest is
  deliberately committed as the pinned environment and is updated by a weekly bot. Do not edit it by hand.
- `Startup/` is a local package (PrecompileTools) in the root project's Pkg workspace (`[workspace]` + `[sources]` in root `Project.toml`). Put expensive warm-up there and `using Startup` from notebooks.
- `ci.yml` sets `JULIA_CONDAPKG_ENV=@mpl` so CondaPkg (used by `PythonPlot` in
  `docs/pythonplot-lit.jl`) shares one Python environment; set it locally too or CondaPkg will download its own Python deps per run.

## CI & automation gotchas

- ci.yml caches executed notebooks at the job level: on a cache hit it skips the Julia setup/instantiate/precompile steps and notebook execution (Node.js setup and the site build always run), then always copies `.cache/docs/*` into `docs/` before building. Cache keys hash `Project.toml`, `Manifest.toml`, `Startup/**`, and `docs/**/*.jl` (`CACHE_NUM` is folded into the environment hash, so bumping it invalidates both the notebook and the Julia/package cache; notebook-cache restore-keys allow a partial restore when only notebook contents changed).
- The site deploys to GitHub Pages only from pushes to `main` (repo Pages setting must be "GitHub Actions").
- Dependency updates are automated: Dependabot (github-actions only — the pip and julia ecosystems in `.github/dependabot.yml` are commented out; `automerge` label, squash-merged by Kodiak via `.github/.kodiak.toml`) and the weekly `update-manifest.yml` PR (uses a GitHub App token so CI triggers on the PR). Expect green automated PRs; don't fight them.
- `linkcheck.yml` (lychee, runs monthly, on pushes to `main` touching `docs/**` or `.lycheeignore`, and via dispatch; checks `docs/**/*.md` and `docs/**/*.jl`) files an issue on broken links — it never fails CI. Exclusions go in `.lycheeignore`.
- Indentation per `.editorconfig`: 4 spaces in `.jl`, 2 spaces in `.yml`/`.md`/`.toml`/`.json`.
