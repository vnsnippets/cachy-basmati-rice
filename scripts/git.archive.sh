#!/bin/bash

# Default flags
VERBOSE=false
KEEP_REMOTE=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --verbose)
      VERBOSE=true
      ;;
    --keep-fetch|--keep-remote)
      KEEP_REMOTE=true
      ;;
  esac
done

# Helper function to run commands with optional echo
RUN() {
  if $VERBOSE; then
    echo "  + $*"
  fi
  "$@"
}

read -p "Enter the remote URL of original repository: " SOURCE_REMOTE_URL
read -p "Enter the branch to target from the original repository [default: master]: " SOURCE_BRANCH
read -p "Enter save location in current repository (e.g. 2018/example-folder): " SAVE_PATH

# Default branch if empty
SOURCE_BRANCH=${SOURCE_BRANCH:-master}

# Derive a safe remote name from the save path (replace unsupported chars with '-')
REMOTE_NAME=$(echo "$SAVE_PATH" | sed 's/[^a-zA-Z0-9]/-/g')

echo "✔ Adding remote $REMOTE_NAME from $SOURCE_REMOTE_URL..."
RUN git remote add "$REMOTE_NAME" "$SOURCE_REMOTE_URL"

echo "✔ Adding subtree under $SAVE_PATH from branch $SOURCE_BRANCH..."
RUN git subtree add --prefix="$SAVE_PATH" "$REMOTE_NAME" "$SOURCE_BRANCH"

if ! $KEEP_REMOTE; then
  echo "✔ Removing the remote $REMOTE_NAME..."
  RUN git remote remove "$REMOTE_NAME"
else
  echo "✔ Keeping the remote $REMOTE_NAME (per flag)."
fi

echo "✔ Done! You can now push."