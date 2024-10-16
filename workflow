name: Release Drafter

on:
  push:
    branches:
      - main  # Trigger on push to main branch
  pull_request:
    types: [closed]

jobs:
  update_release_draft:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Release Drafter
        uses: release-drafter/release-drafter@v5
        with:
          config-name: .github/release-drafter.yml
