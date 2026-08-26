#!/bin/bash

# Default flags
PUSH_REMOTE=false
AUTHOR_EMAIL=""
AUTHOR_NAME=""

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --push-remote)
      PUSH_REMOTE=true
      shift
      ;;
    --author)
      # Prompt user for email and name
      read -p "Enter author email: " AUTHOR_EMAIL
      read -p "Enter author name: " AUTHOR_NAME
      shift
      ;;
    *)
      shift
      ;;
  esac
done

read -p "Enter path to directory (e.g. 2020/some-project): " SOURCE_DIR
read -p "Enter name for new repository: " REPO_NAME

if $PUSH_REMOTE; then
  read -p "Enter git path to new repository: " REPO_URL
fi

# Save current repo path so we can reference it later
ORIGINAL_DIR=$(pwd)

echo "✔ Splitting tree into branch $REPO_NAME"
git subtree split --prefix="$SOURCE_DIR" -b "$REPO_NAME"

echo "✔ Creating directory and retrieving git history"
mkdir "../$REPO_NAME" && cd "../$REPO_NAME"
git init
git remote add archive "$ORIGINAL_DIR"
git pull archive "$REPO_NAME"

# Rename the pulled branch to 'master'
git branch -m master

# Clean up: remove the temporary remote
git remote remove archive

echo "✔ New repo $REPO_NAME created with full history of $SOURCE_DIR"

if [[ -n "$AUTHOR_EMAIL" && -n "$AUTHOR_NAME" ]]; then
  echo "✔ Normalizing author to $AUTHOR_NAME <$AUTHOR_EMAIL>"

  echo "  + Converting authors:"
  > .mailmap
  for TARGET_EMAIL in $(git log --format="%ae" | sort -u); do
    if [[ "$TARGET_EMAIL" != "$AUTHOR_EMAIL" ]]; then
      echo "    + $TARGET_EMAIL > $AUTHOR_EMAIL"
      echo "$AUTHOR_NAME <$AUTHOR_EMAIL> <$TARGET_EMAIL>" >> .mailmap
    fi
  done

  git filter-repo --mailmap .mailmap --force
  rm .mailmap

  echo "  + Updated authors:"
  for LOGGED_EMAIL in $(git log --format="%ae" | sort -u); do
    echo "    + $LOGGED_EMAIL"
  done
fi

if $PUSH_REMOTE; then
  echo "✔ Pushing to $REPO_URL"
  git remote add origin "$REPO_URL"
  git push -u origin master
fi
