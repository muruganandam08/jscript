#!/bin/bash

# Check if the user provided a tag as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

# Get the tag provided as an argument
tag=$1

# Check if the changelog file exists; if not, create it
if [ ! -f CHANGELOG.md ]; then
  echo "# Changelog" > CHANGELOG.md
  echo "" >> CHANGELOG.md
fi

# Append new release notes
echo "## Release Notes for $tag" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Get the commits since the last tag and append to the changelog
git log "$tag"..HEAD --pretty=format:'- %s' >> CHANGELOG.md

# Add contributors to the changelog
echo "" >> CHANGELOG.md
echo "## Contributors" >> CHANGELOG.md
git log "$tag"..HEAD --pretty=format:'* %an' | sort | uniq >> CHANGELOG.md

# Print the output file location
echo "Changelog updated in CHANGELOG.md"
