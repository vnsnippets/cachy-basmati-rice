#!/bin/bash

# Get all files owned by all packages and store in a temp file
all_owned=$(mktemp)
echo "Indexing all package files (this is faster)..."
pacman -Ql | awk '{print $2}' | sort > "$all_owned"

# Categorize fonts
echo -e "\n--- OWNED BY PACKAGES ---"
fc-list : file | cut -d: -f1 | sort | uniq | while read -r fontfile; do
    # Check if the file is in our indexed list
    if grep -q "^$fontfile$" "$all_owned"; then
        owner=$(pacman -Qo "$fontfile" | awk '{print $5, $6}')
        echo "$owner -> $fontfile"
    else
        # Save manual ones for later
        echo "$fontfile" >> manual_fonts.tmp
    fi
done

echo -e "\n--- MANUALLY INSTALLED (NO PACKAGE) ---"
if [ -f manual_fonts.tmp ]; then
    cat manual_fonts.tmp
    rm manual_fonts.tmp
else
    echo "No manual fonts found."
fi

rm "$all_owned"
