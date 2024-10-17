import os
import subprocess
import sys

def get_commits(tag):
    """Get the list of commits since the specified tag."""
    result = subprocess.run(
        ['git', 'log', f'{tag}..HEAD', '--pretty=format:%s'],
        stdout=subprocess.PIPE,
        text=True
    )
    return result.stdout.splitlines()

def get_contributors(tag):
    """Get a list of contributors since the specified tag."""
    result = subprocess.run(
        ['git', 'log', f'{tag}..HEAD', '--pretty=format:%an'],
        stdout=subprocess.PIPE,
        text=True
    )
    return list(set(result.stdout.splitlines()))

def generate_release_notes(tag):
    """Generate release notes based on commits and contributors."""
    commits = get_commits(tag)
    contributors = get_contributors(tag)

    with open('RELEASE_NOTES.md', 'w') as f:
        f.write(f"## Release Notes for {tag}\n\n")
        f.write("### Commits:\n")
        for commit in commits:
            f.write(f"- {commit}\n")
        
        f.write("\n## Contributors:\n")
        for contributor in contributors:
            f.write(f"* {contributor}\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python generate_release_notes.py <tag>")
        sys.exit(1)
    
    tag = sys.argv[1]
    generate_release_notes(tag)
    print(f"Release notes generated in RELEASE_NOTES.md")
