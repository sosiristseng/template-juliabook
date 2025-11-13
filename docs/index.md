# Welcome to your Jupyter Book

See also:

- https://github.com/sosiristseng/template-juliabook-matrix : Using the dynamic parallel matrix runs notebooks concurrently and then `jupyter-book` builds the website.

## Enable GitHub pages

From your repository settings => Pages => GitHub Pages => Build and deployment => Source, select `GitHub actions`.

## Automatic dependency updates

This repository uses [Dependabot](https://docs.github.com/en/code-security/getting-started/dependabot-quickstart-guide) and [Kodiak Bot](https://kodiakhq.com/docs/quickstart) to automatically merge Python and GitHub actions updates.

### Julia dependencies

This repository will regularly update Julia in the `Manifest.toml`, make a PR with the updated packages, and automatically merge the updates if the notebooks are executed without any problem.

See [the instructions](https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#triggering-further-workflow-runs) for how to trigger CI workflows in a PR. This repo uses a custom [GitHub APP](https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#authenticating-with-github-app-generated-tokens) to generate a token on the fly.

## Checking web links

This repository  uses GitHub actions to regularly check if the web links in the notebooks are valid.
