#!/usr/bin/env bash
set -euo pipefail

PACKAGE=""
TYPE=""
FOLDER=""
DEST=""
SCAN_DIR=""
DELETE_ORIGINAL=false

usage() {
    echo "Usage:"
    echo "  Scan mode:    $0 -s <scan_directory>"
    echo "  Extract mode: $0 -p <package_path> -d <destination_path> [--type <tarball|appimage>] [-f <internal_folder>] [--delete]"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--scan) SCAN_DIR="$2"; shift ;;
        -p|--package) PACKAGE="$2"; shift ;;
        -t|--type) TYPE="$2"; shift ;;
        -f|--folder) FOLDER="$2"; shift ;;
        -d|--destination) DEST="$2"; shift ;;
        --delete) DELETE_ORIGINAL=true ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# If scan is requested, handle both AppImages and tarballs and exit immediately
if [[ -n "$SCAN_DIR" ]]; then
    SCAN_DIR="$(eval echo "$SCAN_DIR")"
    if [[ ! -d "$SCAN_DIR" ]]; then
        echo "Error: Scan directory not found at '$SCAN_DIR'" >&2
        exit 1
    fi
    find "$SCAN_DIR" -maxdepth 2 -type f \( \
        -name '*.AppImage' -o -name '*.appimage' -o \
        -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' -o \
        -name '*.tar.bz2' -o -name '*.tbz2' -o -name '*.tar.xz' \
    \) 2>/dev/null | sort
    exit 0
fi

# Otherwise, proceed with extraction logic
PACKAGE="$(eval echo "$PACKAGE")"
DEST="$(eval echo "$DEST")"

if [[ -z "$PACKAGE" || -z "$DEST" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

if [[ ! -f "$PACKAGE" ]]; then
    echo "Error: Package not found at '$PACKAGE'"
    exit 1
fi

# Determine type if not explicitly given via --type
if [[ -z "$TYPE" ]]; then
    LOWER_PACKAGE="$(echo "$PACKAGE" | tr '[:upper:]' '[:lower:]')"
    if [[ "$LOWER_PACKAGE" == *.appimage ]]; then
        TYPE="appimage"
    elif [[ "$LOWER_PACKAGE" == *.tar || "$LOWER_PACKAGE" == *.tar.gz || "$LOWER_PACKAGE" == *.tgz || "$LOWER_PACKAGE" == *.tar.bz2 || "$LOWER_PACKAGE" == *.tbz2 || "$LOWER_PACKAGE" == *.tar.xz ]]; then
        TYPE="tarball"
    else
        echo "Error: Could not determine package type. Please specify --type <tarball|appimage>" >&2
        exit 1
    fi
fi

# Execute extraction based on the context/type
case "$TYPE" in
    appimage)
        PARENT_DIR="$(dirname "$DEST")"
        mkdir -p "$PARENT_DIR"
        rm -rf "$DEST"

        TEMP_DIR="$(mktemp -d)"
        trap 'rm -rf "$TEMP_DIR"' EXIT

        cd "$TEMP_DIR"
        chmod +x "$PACKAGE"
        "$PACKAGE" --appimage-extract

        if [[ ! -d "$TEMP_DIR/squashfs-root" ]]; then
            echo "Error: Extraction failed, squashfs-root not generated." >&2
            exit 1
        fi

        mv "$TEMP_DIR/squashfs-root" "$DEST"

        if [[ "$DELETE_ORIGINAL" == true ]]; then
            # rm -f "$PACKAGE"
            gio trash "$PACKAGE"
            echo "Deleted $PACKAGE"
        fi

        echo "Extracted AppImage $PACKAGE to $DEST"
        ;;
    tarball)
        if [[ -z "$FOLDER" ]]; then
            echo "Error: Missing required argument -f/--folder for tarball extraction."
            usage
        fi

        PARENT_DIR="$(dirname "$DEST")"
        mkdir -p "$PARENT_DIR"
        rm -rf "$DEST"
        mkdir -p "$DEST"

        tar -tf "$PACKAGE" && tar -xf "$PACKAGE" -C "$DEST" --strip-components=1 "$FOLDER"

        if [[ "$DELETE_ORIGINAL" == true ]]; then
            # rm -f "$PACKAGE"
            gio trash "$PACKAGE"
            echo "Deleted $PACKAGE"
        fi

        echo "Extracted Tarball $PACKAGE/$FOLDER to $DEST"
        ;;
    *)
        echo "Error: Invalid type '$TYPE'. Expected 'tarball' or 'appimage'." >&2
        usage
        ;;
esac