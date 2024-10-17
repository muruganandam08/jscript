#!/bin/bash

# Step 1: Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $latest_tag"

# Step 2: Generate the next tag
prefix=${latest_tag//[0-9.]/}
version=${latest_tag//[!0-9.]/}
IFS='.' read -r major minor patch <<<"$version"
patch=$((patch + 1))
new_tag="${prefix}${major}.${minor}.${patch}"
echo "New tag: $new_tag"

# Step 3: Generate the changelog
conventional-changelog -p angular -i CHANGELOG.md -s

# Step 4: Commit and push the changelog
git add CHANGELOG.md
git commit -m "chore: update changelog for $new_tag"
git push origin main

# Step 5: Create a new tag and push
git tag "$new_tag"
git push origin "$new_tag"

echo "Release process completed successfully."
