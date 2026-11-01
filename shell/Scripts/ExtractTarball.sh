#!/usr/bin/env bash
set -euo pipefail

TARBALL=""
FOLDER=""
DEST=""
DELETE_ORIGINAL=false

usage() {
    echo "Usage: $0 -t <tarball_path> -f <internal_folder> -d <destination_path> [--delete]"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--package) TARBALL="$2"; shift ;;
        -f|--folder) FOLDER="$2"; shift ;;
        -d|--destination) DEST="$2"; shift ;;
        --delete) DELETE_ORIGINAL=true ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Expand any potential ~ or variables safely
TARBALL="$(eval echo "$TARBALL")"
DEST="$(eval echo "$DEST")"

if [[ -z "$TARBALL" || -z "$FOLDER" || -z "$DEST" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

if [[ ! -f "$TARBALL" ]]; then
    echo "Error: Tarball not found at '$TARBALL'"
    exit 1
fi

PARENT_DIR="$(dirname "$DEST")"
mkdir -p "$PARENT_DIR"
rm -rf "$DEST"
mkdir -p "$DEST"

tar -tf "$TARBALL" && tar -xf "$TARBALL" -C "$DEST" --strip-components=1 "$FOLDER"

if [[ "$DELETE_ORIGINAL" == true ]]; then
    rm -f "$TARBALL"
    echo "Deleted $TARBALL"
fi

echo "Extracted $TARBALL/$FOLDER to $DEST"