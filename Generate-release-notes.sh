#!/bin/bash

# Check if the user provided a tag as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

# Get the tag provided as an argument
tag=$1

# Generate release notes
echo "## Release Notes for $tag" > RELEASE_NOTES.md
echo "" >> RELEASE_NOTES.md

# Get the commits since the last tag
git log "$tag"..HEAD --pretty=format:'- %s' >> RELEASE_NOTES.md

# Add contributors
echo "" >> RELEASE_NOTES.md
echo "## Contributors" >> RELEASE_NOTES.md
git log "$tag"..HEAD --pretty=format:'* %an' | sort | uniq >> RELEASE_NOTES.md

# Print the output file location
echo "Release notes generated in RELEASE_NOTES.md"
